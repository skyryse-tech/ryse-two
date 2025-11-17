import '../../database/mongodb_helper.dart';

class ConnectionChecker {
  static Future<bool> checkMongoDBConnection() async {
    try {
      final db = await MongoDBHelper.instance.database;
      if (db.isConnected) {
        // Try a simple query to verify connection is working
        final collection = db.collection('cofounders');
        await collection.findOne();
        return true;
      }
      return false;
    } catch (e) {
      print('🔴 MongoDB Connection Error: $e');
      return false;
    }
  }

  static Future<ConnectionStatus> getDetailedStatus() async {
    try {
      print('🔗 Starting connection check...');
      final db = await MongoDBHelper.instance.database;
      
      if (db.isConnected) {
        print('✅ Database connected, testing query...');
        final collection = db.collection('cofounders');
        await collection.findOne();
        
        print('✅ Query successful - connection verified!');
        return ConnectionStatus(
          isConnected: true,
          message: 'Successfully connected to MongoDB',
          timestamp: DateTime.now(),
        );
      }
      
      return ConnectionStatus(
        isConnected: false,
        message: 'Database connection lost',
        timestamp: DateTime.now(),
      );
    } catch (e) {
      print('❌ Connection Check Error: $e');
      print('📋 Error type: ${e.runtimeType}');
      
      String errorMessage = _parseError(e);
      
      return ConnectionStatus(
        isConnected: false,
        message: errorMessage,
        timestamp: DateTime.now(),
        fullError: e.toString(),
      );
    }
  }

  static String _parseError(dynamic error) {
    final errorStr = error.toString().toLowerCase();
    
    if (errorStr.contains('connection refused') || errorStr.contains('refused')) {
      return 'Connection refused. Check if MongoDB is running.';
    } else if (errorStr.contains('timeout') || errorStr.contains('timed out')) {
      return 'Connection timeout. Check your internet connection.';
    } else if (errorStr.contains('authentication failed') || errorStr.contains('auth')) {
      return 'Authentication failed. Check your credentials.';
    } else if (errorStr.contains('network') || errorStr.contains('unreachable')) {
      return 'Network unreachable. Check your firewall.';
    } else if (errorStr.contains('tls') || errorStr.contains('ssl')) {
      return 'TLS/SSL certificate error.';
    }
    
    return 'Connection failed: ${error.toString()}';
  }
}

class ConnectionStatus {
  final bool isConnected;
  final String message;
  final DateTime timestamp;
  final String? fullError;

  ConnectionStatus({
    required this.isConnected,
    required this.message,
    required this.timestamp,
    this.fullError,
  });
}
