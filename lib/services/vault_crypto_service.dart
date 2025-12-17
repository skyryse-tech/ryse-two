import 'dart:convert';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/vault_entry.dart';

class VaultCryptoService {
  VaultCryptoService._();
  static final VaultCryptoService instance = VaultCryptoService._();

  encrypt.Key? _key;

  bool get isConfigured => _getKeyString()?.isNotEmpty == true;

  String? _getKeyString() => dotenv.env['VAULT_ENCRYPTION_KEY'];

  void _ensureKey() {
    if (_key != null) return;
    final keyString = _getKeyString();
    if (keyString == null || keyString.isEmpty) {
      throw Exception('VAULT_ENCRYPTION_KEY missing in .env');
    }

    final normalized = keyString.length >= 32
        ? keyString.substring(0, 32)
        : keyString.padRight(32, '0');
    _key = encrypt.Key.fromUtf8(normalized);
  }

  EncryptedVaultRecord encryptEntry(VaultEntry entry) {
    _ensureKey();
    final iv = encrypt.IV.fromSecureRandom(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(_key!, mode: encrypt.AESMode.cbc));
    final payload = jsonEncode(entry.toJson());
    final cipher = encrypter.encrypt(payload, iv: iv);

    return EncryptedVaultRecord(
      cipherText: cipher.base64,
      iv: iv.base64,
      createdAt: entry.createdAt,
      updatedAt: entry.updatedAt,
    );
  }

  VaultEntry decryptEntry(EncryptedVaultRecord record) {
    _ensureKey();
    final encrypter = encrypt.Encrypter(encrypt.AES(_key!, mode: encrypt.AESMode.cbc));
    final iv = encrypt.IV.fromBase64(record.iv);
    final decrypted = encrypter.decrypt64(record.cipherText, iv: iv);
    final decoded = jsonDecode(decrypted) as Map<String, dynamic>;
    return VaultEntry.fromJson(decoded, id: record.id);
  }
}
