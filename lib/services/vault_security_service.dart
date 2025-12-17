import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'notification_helper.dart';

class VaultSecurityService {
  VaultSecurityService._();
  static final VaultSecurityService instance = VaultSecurityService._();

  static const int _maxAttempts = 3;
  static const Duration _lockDuration = Duration(minutes: 2);

  int _failedAttempts = 0;
  DateTime? _lockedUntil;
  bool _alertSent = false;

  bool get isLocked => _lockedUntil != null && DateTime.now().isBefore(_lockedUntil!);
  int get remainingAttempts => (_maxAttempts - _failedAttempts).clamp(0, _maxAttempts);
  Duration? get lockRemaining => isLocked ? _lockedUntil!.difference(DateTime.now()) : null;

  void resetFailures() {
    _failedAttempts = 0;
    _lockedUntil = null;
    _alertSent = false;
  }

  Future<bool> verifyPin(String pin) async {
    if (isLocked) {
      return false;
    }

    final configuredHash = dotenv.env['VAULT_PIN_HASH'];
    final salt = dotenv.env['VAULT_PIN_SALT'] ?? '';

    if (configuredHash == null || configuredHash.isEmpty) {
      throw Exception('VAULT_PIN_HASH missing in .env');
    }

    final candidate = sha256.convert(utf8.encode('$salt$pin')).toString();
    final isValid = candidate == configuredHash;

    if (isValid) {
      resetFailures();
      return true;
    }

    _failedAttempts += 1;

    if (_failedAttempts >= _maxAttempts) {
      _lockedUntil = DateTime.now().add(_lockDuration);
      if (!_alertSent) {
        await NotificationHelper().sendToAllDevices(
          title: '🚨 Vault PIN Failed',
          body: '3 failed attempts detected. Vault locked temporarily.',
          data: {
            'type': 'vault_security',
            'event': 'pin_failed',
            'attempts': _failedAttempts.toString(),
          },
        );
        _alertSent = true;
      }
    }

    return false;
  }
}
