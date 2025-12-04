import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:googleapis_auth/auth_io.dart';

/// Service to generate OAuth 2.0 access tokens for FCM API V1
/// Uses service account credentials to generate tokens
class FCMTokenService {
  static final FCMTokenService _instance = FCMTokenService._internal();
  factory FCMTokenService() => _instance;
  FCMTokenService._internal();

  AccessCredentials? _cachedCredentials;
  DateTime? _tokenExpiry;

  /// Get a valid OAuth 2.0 access token for FCM API V1
  /// Uses service account credentials from .env file
  /// Caches token until it expires (typically 1 hour)
  Future<String?> getAccessToken() async {
    try {
      // Return cached token if still valid
      if (_cachedCredentials != null && _tokenExpiry != null) {
        if (DateTime.now().isBefore(_tokenExpiry!)) {
          print('🔑 Using cached OAuth token');
          return _cachedCredentials!.accessToken.data;
        }
      }

      print('🔄 Generating new OAuth 2.0 access token...');

      // Get service account credentials from .env
      final projectId = dotenv.env['FCM_PROJECT_ID'];
      final clientId = dotenv.env['FCM_CLIENT_ID'];
      final privateKey = dotenv.env['FCM_PRIVATE_KEY'];
      final clientEmail = dotenv.env['FCM_CLIENT_EMAIL'];

      print('📋 Checking .env credentials...');
      print('   FCM_PROJECT_ID: ${projectId != null ? "✅ $projectId" : "❌ Missing"}');
      print('   FCM_CLIENT_ID: ${clientId != null ? "✅ $clientId" : "❌ Missing"}');
      print('   FCM_PRIVATE_KEY: ${privateKey != null ? "✅ Found (${privateKey.length} chars)" : "❌ Missing"}');
      print('   FCM_CLIENT_EMAIL: ${clientEmail != null ? "✅ $clientEmail" : "❌ Missing"}');

      if (projectId == null || clientId == null || privateKey == null || clientEmail == null) {
        print('❌ Missing FCM credentials in .env file');
        print('Required: FCM_PROJECT_ID, FCM_CLIENT_ID, FCM_PRIVATE_KEY, FCM_CLIENT_EMAIL');
        return null;
      }
      
      print('✅ All credentials fetched successfully from .env');

      if (projectId.contains('your-') || clientEmail.contains('your-')) {
        print('❌ Please update .env file with actual Firebase credentials');
        return null;
      }

      // Clean up private key format (handle escaped newlines)
      final cleanPrivateKey = privateKey
          .replaceAll('\\n', '\n')
          .replaceAll(r'\n', '\n');

      // Create service account credentials JSON
      final serviceAccountJson = {
        'type': 'service_account',
        'project_id': projectId,
        'private_key_id': clientId,
        'private_key': cleanPrivateKey,
        'client_email': clientEmail,
        'client_id': clientId,
        'auth_uri': 'https://accounts.google.com/o/oauth2/auth',
        'token_uri': 'https://oauth2.googleapis.com/token',
        'auth_provider_x509_cert_url': 'https://www.googleapis.com/oauth2/v1/certs',
      };

      // Create service account credentials
      final accountCredentials = ServiceAccountCredentials.fromJson(serviceAccountJson);

      // Define the required scopes for FCM
      final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

      // Obtain access credentials
      final authClient = await clientViaServiceAccount(accountCredentials, scopes);
      
      _cachedCredentials = authClient.credentials;
      _tokenExpiry = _cachedCredentials!.accessToken.expiry.subtract(const Duration(minutes: 1)); // 1 min buffer
      
      final token = _cachedCredentials!.accessToken.data;
      
      print('✅ OAuth token generated successfully');
      print('⏰ Token expires at: ${_cachedCredentials!.accessToken.expiry}');
      
      // Close the client
      authClient.close();
      
      return token;
    } catch (e) {
      print('❌ Error getting access token: $e');
      print('💡 Verify your service account credentials in .env file');
      return null;
    }
  }

  /// Clear cached token (useful for testing or logout)
  void clearToken() {
    _cachedCredentials = null;
    _tokenExpiry = null;
    print('🗑️ Cleared cached OAuth token');
  }
}
