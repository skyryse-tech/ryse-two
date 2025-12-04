import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../database/mongodb_helper.dart';
import 'fcm_token_service.dart';

/// Helper class to send push notifications to all devices
/// Uses Firebase Cloud Messaging API V1 (OAuth 2.0)
class NotificationHelper {
  static final NotificationHelper _instance = NotificationHelper._internal();
  factory NotificationHelper() => _instance;
  NotificationHelper._internal();

  final FCMTokenService _tokenService = FCMTokenService();

  /// Send notification to all registered devices using FCM API V1
  /// 
  /// [title] - Notification title
  /// [body] - Notification body
  /// [data] - Optional custom data payload
  Future<void> sendToAllDevices({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      print('📤 Sending notification to all devices...');
      print('📋 Title: $title');
      print('📋 Body: $body');

      // Get all device tokens from database
      final tokens = await MongoDBHelper.instance.getAllDeviceTokens();
      
      if (tokens.isEmpty) {
        print('⚠️ No device tokens found in database');
        return;
      }

      print('📱 Found ${tokens.length} device(s) to notify');

      // Get OAuth access token
      final accessToken = await _tokenService.getAccessToken();
      
      if (accessToken == null) {
        print('❌ Failed to get OAuth access token');
        print('💡 Please configure service account credentials in .env file');
        return;
      }

      // Get project ID
      final projectId = dotenv.env['FCM_PROJECT_ID'];
      if (projectId == null || projectId.contains('your-')) {
        print('❌ FCM_PROJECT_ID not configured in .env file');
        return;
      }

      // Send to each device using FCM API V1
      await _sendUsingV1API(tokens, title, body, data, accessToken, projectId);
      
    } catch (e) {
      print('❌ Error sending notification: $e');
    }
  }

  /// Send notification using Firebase Cloud Messaging API V1
  /// Uses OAuth 2.0 authentication with service account
  Future<void> _sendUsingV1API(
    List<String> tokens,
    String title,
    String body,
    Map<String, dynamic>? data,
    String accessToken,
    String projectId,
  ) async {
    try {
      // FCM V1 API endpoint
      final fcmEndpoint = 'https://fcm.googleapis.com/v1/projects/$projectId/messages:send';
      
      // Send to each token individually
      // FCM V1 API only supports one token per request
      for (final token in tokens) {
        try {
          final response = await http.post(
            Uri.parse(fcmEndpoint),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $accessToken',
            },
            body: jsonEncode({
              'message': {
                'token': token,
                'notification': {
                  'title': title,
                  'body': body,
                },
                'data': {
                  'click_action': 'FLUTTER_NOTIFICATION_CLICK',
                  ...?data?.map((key, value) => MapEntry(key, value.toString())),
                },
                'android': {
                  'priority': 'HIGH',
                  'notification': {
                    'channel_id': 'ryse_two_updates',
                    'sound': 'default',
                    'default_vibrate_timings': true,
                    'notification_priority': 'PRIORITY_HIGH',
                  },
                },
                'apns': {
                  'payload': {
                    'aps': {
                      'alert': {
                        'title': title,
                        'body': body,
                      },
                      'sound': 'default',
                      'badge': 1,
                    },
                  },
                },
              },
            }),
          );

          if (response.statusCode == 200) {
            print('✅ Notification sent successfully to device');
          } else {
            final result = jsonDecode(response.body);
            print('❌ FCM V1 request failed: ${response.statusCode}');
            print('Response: ${response.body}');
            
            // Check for invalid token errors
            final error = result['error'];
            if (error != null) {
              final errorCode = error['status'];
              if (errorCode == 'NOT_FOUND' || errorCode == 'INVALID_ARGUMENT') {
                print('🗑️ Removing invalid token from database');
                await MongoDBHelper.instance.removeDeviceToken(token);
              }
            }
          }
        } catch (e) {
          print('❌ Error sending to token: $e');
        }
      }
      
      print('✅ Notification broadcast completed');
    } catch (e) {
      print('❌ Error in FCM V1 API: $e');
    }
  }

  /// Send notification to specific device token
  Future<void> sendToDevice({
    required String token,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    // Get OAuth access token
    final accessToken = await _tokenService.getAccessToken();
    if (accessToken == null) {
      print('❌ Failed to get OAuth access token');
      return;
    }

    final projectId = dotenv.env['FCM_PROJECT_ID'];
    if (projectId == null) {
      print('❌ FCM_PROJECT_ID not configured');
      return;
    }

    await _sendUsingV1API([token], title, body, data, accessToken, projectId);
  }

  /// Send notification for expense-related events
  Future<void> sendExpenseNotification({
    required String action, // 'added', 'updated', 'deleted'
    required String description,
    required double amount,
    required String paidBy,
  }) async {
    final title = _getExpenseTitle(action);
    final body = '$paidBy $action ₹${amount.toStringAsFixed(2)} for $description';
    
    await sendToAllDevices(
      title: title,
      body: body,
      data: {
        'type': 'expense',
        'action': action,
        'description': description,
        'amount': amount.toString(),
      },
    );
  }

  /// Send notification for cofounder-related events
  Future<void> sendCofounderNotification({
    required String action, // 'added', 'updated', 'deleted'
    required String name,
  }) async {
    final title = _getCofounderTitle(action);
    final body = 'Co-founder $name has been $action';
    
    await sendToAllDevices(
      title: title,
      body: body,
      data: {
        'type': 'cofounder',
        'action': action,
        'name': name,
      },
    );
  }

  /// Send notification for settlement-related events
  Future<void> sendSettlementNotification({
    required String action,
    required String fromName,
    required String toName,
    required double amount,
  }) async {
    final title = 'Settlement $action';
    final body = '$fromName paid ₹${amount.toStringAsFixed(2)} to $toName';
    
    await sendToAllDevices(
      title: title,
      body: body,
      data: {
        'type': 'settlement',
        'action': action,
        'amount': amount.toString(),
      },
    );
  }

  /// Send notification for company fund-related events
  Future<void> sendCompanyFundNotification({
    required String action, // 'added', 'deducted'
    required String description,
    required double amount,
  }) async {
    final title = action == 'added' ? '💰 Fund Added' : '💸 Fund Deducted';
    final body = '₹${amount.toStringAsFixed(2)} $action - $description';
    
    await sendToAllDevices(
      title: title,
      body: body,
      data: {
        'type': 'company_fund',
        'action': action,
        'description': description,
        'amount': amount.toString(),
      },
    );
  }

  String _getExpenseTitle(String action) {
    switch (action) {
      case 'added':
        return '💸 New Expense Added';
      case 'updated':
        return '✏️ Expense Updated';
      case 'deleted':
        return '🗑️ Expense Deleted';
      default:
        return '💸 Expense Update';
    }
  }

  String _getCofounderTitle(String action) {
    switch (action) {
      case 'added':
        return '👤 New Co-founder Added';
      case 'updated':
        return '✏️ Co-founder Updated';
      case 'deleted':
        return '🗑️ Co-founder Removed';
      default:
        return '👤 Co-founder Update';
    }
  }
}
