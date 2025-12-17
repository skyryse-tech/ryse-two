import 'package:flutter/material.dart';
import '../database/mongodb_helper.dart';
import '../models/vault_entry.dart';
import '../services/vault_crypto_service.dart';

class VaultProvider extends ChangeNotifier {
  final VaultCryptoService _crypto = VaultCryptoService.instance;

  List<VaultEntry> _entries = [];
  bool _isLoading = false;
  String? _error;

  List<VaultEntry> get entries => _entries;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isConfigured => _crypto.isConfigured;

  Future<void> loadVault() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (!isConfigured) {
        throw Exception('VAULT_ENCRYPTION_KEY missing');
      }

      final records = await MongoDBHelper.instance.getVaultEntries();
      _entries = records.map(_crypto.decryptEntry).toList();
      _entries.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addEntry(VaultEntry entry) async {
    if (!isConfigured) {
      throw Exception('VAULT_ENCRYPTION_KEY missing');
    }
    final prepared = entry.copyWith(
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final encrypted = _crypto.encryptEntry(prepared);
    final id = await MongoDBHelper.instance.insertVaultEntry(encrypted);
    _entries.insert(0, prepared.copyWith(id: id));
    notifyListeners();
  }

  Future<void> updateEntry(VaultEntry entry) async {
    if (!isConfigured) {
      throw Exception('VAULT_ENCRYPTION_KEY missing');
    }
    if (entry.id == null) return;
    final refreshed = entry.copyWith(updatedAt: DateTime.now());
    final encrypted = _crypto.encryptEntry(refreshed);
    encrypted.id = entry.id;
    await MongoDBHelper.instance.updateVaultEntry(encrypted);

    final index = _entries.indexWhere((e) => e.id == entry.id);
    if (index != -1) {
      _entries[index] = refreshed;
      _entries.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      notifyListeners();
    }
  }

  Future<void> deleteEntry(String id) async {
    await MongoDBHelper.instance.deleteVaultEntry(id);
    _entries.removeWhere((e) => e.id == id);
    notifyListeners();
  }
}
