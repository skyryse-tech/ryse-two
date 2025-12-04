import 'package:flutter/material.dart';
import '../../services/fcm_token_service.dart';
import '../../services/fcm_service.dart';
import '../../database/mongodb_helper.dart';
import '../../services/notification_helper.dart';

/// Debug screen to test notification system
/// Add this to your app to test notifications manually
class NotificationDebugScreen extends StatefulWidget {
  const NotificationDebugScreen({super.key});

  @override
  State<NotificationDebugScreen> createState() => _NotificationDebugScreenState();
}

class _NotificationDebugScreenState extends State<NotificationDebugScreen> {
  String _status = 'Ready to test';
  bool _isLoading = false;
  String? _fcmToken;
  String? _oauthToken;
  int _deviceTokenCount = 0;

  @override
  void initState() {
    super.initState();
    _checkInitialState();
  }

  Future<void> _checkInitialState() async {
    setState(() {
      _isLoading = true;
      _status = 'Checking initial state...';
    });

    try {
      // Get FCM token
      _fcmToken = FCMService().fcmToken;
      
      // Get device token count
      final tokens = await MongoDBHelper.instance.getAllDeviceTokens();
      _deviceTokenCount = tokens.length;

      setState(() {
        _status = 'Initial check complete';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _testOAuthToken() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing OAuth token generation...';
    });

    try {
      final service = FCMTokenService();
      final token = await service.getAccessToken();
      
      if (token != null) {
        _oauthToken = '${token.substring(0, 20)}...';
        setState(() {
          _status = '✅ OAuth token generated successfully!';
          _isLoading = false;
        });
      } else {
        setState(() {
          _status = '❌ Failed to generate OAuth token. Check .env file.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _status = '❌ OAuth token error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _testNotification() async {
    setState(() {
      _isLoading = true;
      _status = 'Sending test notification...';
    });

    try {
      await NotificationHelper().sendToAllDevices(
        title: '🔔 Test Notification',
        body: 'If you see this, notifications are working!',
        data: {'type': 'test'},
      );
      
      setState(() {
        _status = '✅ Notification sent! Check if you received it.';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _status = '❌ Notification error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Debug'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else
                      Text(_status),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // FCM Token Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FCM Token',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(_fcmToken != null 
                      ? '✅ ${_fcmToken!.substring(0, 30)}...' 
                      : '❌ No FCM token found'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),

            // OAuth Token Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'OAuth Token',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(_oauthToken != null 
                      ? '✅ $_oauthToken' 
                      : '⚠️ Not tested yet'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Device Tokens Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Device Tokens in Database',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text('$_deviceTokenCount device(s)'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Test Buttons
            ElevatedButton(
              onPressed: _isLoading ? null : _testOAuthToken,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
              child: const Text('1. Test OAuth Token'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _isLoading ? null : _testNotification,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.green,
              ),
              child: const Text('2. Send Test Notification'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _isLoading ? null : _checkInitialState,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.orange,
              ),
              child: const Text('Refresh Status'),
            ),
            const SizedBox(height: 24),

            // Instructions
            Card(
              color: Colors.blue[50],
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📋 Instructions',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text('1. Check if FCM Token exists'),
                    Text('2. Test OAuth Token (should say ✅)'),
                    Text('3. Send Test Notification'),
                    Text('4. Check if notification appears'),
                    SizedBox(height: 8),
                    Text(
                      'If notification doesn\'t appear, check logs!',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
