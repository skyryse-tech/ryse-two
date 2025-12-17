import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mongo_dart/mongo_dart.dart';
import '../models/cofounder.dart';
import '../models/expense.dart';
import '../models/settlement.dart';
import '../models/company_fund.dart';
import '../models/vault_entry.dart';

class MongoDBHelper {
  // MongoDB connection URI - comes from .env (MONGODB_URI)
  // Make sure:
  // 1. No special characters in password (if any, URL encode them)
  // 2. IP address is whitelisted in MongoDB Atlas
  // 3. Internet permission is enabled in Android manifest
  static String get _uri => dotenv.env['MONGODB_URI'] ?? '';
  static const String _cofoundersCollectionName = 'cofounders';
  static const String _expensesCollectionName = 'expenses';
  static const String _settlementsCollectionName = 'settlements';
  static const String _companyFundsCollectionName = 'company_funds';
  static const String _deviceTokensCollectionName = 'device_tokens';
  // Project Manager Collections (shared schema)
  static const String projectsCollectionName = 'projects';
  static const String projectFeaturesCollectionName = 'project_features';
  static const String researchNotesCollectionName = 'research_notes';
  static const String projectTimelineCollectionName = 'project_timeline';
  static const String vaultEntriesCollectionName = 'vault_entries';

  MongoDBHelper._privateConstructor();
  static final MongoDBHelper instance = MongoDBHelper._privateConstructor();

  static Db? _database;

  Future<Db> get database async {
    if (_database == null || !_database!.isConnected) {
      _database = await _initDatabase();
    }
    return _database!;
  }

  Future<Db> _initDatabase() async {
    try {
      if (_uri.isEmpty) {
        throw Exception('MONGODB_URI is not set in .env');
      }
      print('🔍 Attempting to connect to MongoDB Atlas...');
      print('Connection URI: $_uri');
      print('📝 Using Db.create() for MongoDB Atlas connection...');
      
      // ⭐ IMPORTANT: Use Db.create() for MongoDB Atlas (mongodb+srv://)
      // Documentation: https://pub.dev/packages/mongo_dart#atlas-connection
      final db = await Db.create(_uri);
      
      print('📝 Database instance created, opening connection...');
      
      // Open connection with timeout
      await db.open().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          print('⏱️ Connection timeout after 30 seconds');
          throw Exception('MongoDB connection timeout - Check internet and IP whitelist');
        },
      );
      
      print('✅ MongoDB Connected Successfully!');
      print('🎉 Connection verified at ${DateTime.now()}');
      
      return db;
    } catch (e) {
      print('❌ MongoDB Connection Error: $e');
      print('📋 Error Type: ${e.runtimeType}');
      print('🔗 Connection String: $_uri');
      print('');
      print('💡 TROUBLESHOOTING CHECKLIST:');
      print('   1. ✓ Using Db.create() for mongodb+srv:// URLs');
      print('   2. ☐ Check emulator/device internet: adb shell ping 8.8.8.8');
      print('   3. ☐ Whitelist IP in MongoDB Atlas: https://cloud.mongodb.com/');
      print('   4. ☐ Verify username/password in connection string');
      print('   5. ☐ Enable internet permission in AndroidManifest.xml');
      print('   6. ☐ Check firewall/antivirus not blocking connection');
      print('');
      print('Stack trace: ${StackTrace.current}');
      throw Exception('Failed to initialize MongoDB: $e');
    }
  }

  Future<DbCollection> _getCollection(String collectionName) async {
    final db = await database;
    return db.collection(collectionName);
  }

  Future<void> closeDatabase() async {
    if (_database != null && _database!.isConnected) {
      await _database!.close();
      _database = null;
    }
  }

  // CoFounder Operations
  Future<String> insertCoFounder(CoFounder coFounder) async {
    try {
      final collection = await _getCollection(_cofoundersCollectionName);
      final map = coFounder.toMap();
      map.remove('id');
      final result = await collection.insertOne(map);
      return (result.id as ObjectId).toHexString();
    } catch (e) {
      return '';
    }
  }

  Future<List<CoFounder>> getCoFounders() async {
    try {
      final collection = await _getCollection(_cofoundersCollectionName);
      final result = await collection.find().toList();
      final cofounders = result
          .map((map) => CoFounder.fromMap({...map, 'id': (map['_id'] as ObjectId).toHexString()}))
          .toList();
      print('📋 Loaded ${cofounders.length} cofounders from database');
      return cofounders;
    } catch (e) {
      print('❌ Error loading cofounders: $e');
      return [];
    }
  }

  Future<CoFounder?> getCoFounder(String id) async {
    try {
      final collection = await _getCollection(_cofoundersCollectionName);
      final result = await collection.findOne(where.id(ObjectId.fromHexString(id)));
      if (result == null) return null;
      return CoFounder.fromMap({...result, 'id': (result['_id'] as ObjectId).toHexString()});
    } catch (e) {
      return null;
    }
  }

  Future<int> updateCoFounder(CoFounder coFounder) async {
    try {
      final collection = await _getCollection(_cofoundersCollectionName);
      final map = coFounder.toMap();
      map.remove('id');
      final result = await collection.updateOne(
        where.id(ObjectId.fromHexString(coFounder.id.toString())),
        {'\$set': map},
      );
      return result.nModified;
    } catch (e) {
      return 0;
    }
  }

  Future<int> deleteCoFounder(String id) async {
    try {
      final collection = await _getCollection(_cofoundersCollectionName);
      final result = await collection.deleteOne(where.id(ObjectId.fromHexString(id)));
      return result.ok == 1 ? 1 : 0;
    } catch (e) {
      return 0;
    }
  }

  // Expense Operations
  Future<String> insertExpense(Expense expense) async {
    try {
      final collection = await _getCollection(_expensesCollectionName);
      final map = expense.toMap();
      map.remove('id');
      print('💾 Inserting expense: ${map['description']} - ₹${map['amount']}');
      final result = await collection.insertOne(map);
      final hexId = (result.id as ObjectId).toHexString();
      print('✅ Expense inserted with ID: $hexId');
      return hexId;
    } catch (e) {
      print('❌ Error inserting expense: $e');
      return '';
    }
  }

  Future<List<Expense>> getExpenses() async {
    try {
      final collection = await _getCollection(_expensesCollectionName);
      final result = await collection.find().toList();
      
      // Parse expenses individually to catch parsing errors
      final expenses = <Expense>[];
      for (var map in result) {
        try {
          final expense = Expense.fromMap({...map, 'id': (map['_id'] as ObjectId).toHexString()});
          expenses.add(expense);
        } catch (e) {
          print('❌ Error parsing individual expense: $e');
          print('   Expense data: $map');
        }
      }
      
      // Sort by date (newest first)
      expenses.sort((a, b) => b.date.compareTo(a.date));
      
      print('📋 Loaded ${expenses.length} expenses from database');
      if (expenses.isNotEmpty) {
        print('   First: ${expenses.first.description} - ₹${expenses.first.amount}');
        print('   Last: ${expenses.last.description} - ₹${expenses.last.amount}');
      }
      return expenses;
    } catch (e) {
      print('❌ Error loading expenses: $e');
      return [];
    }
  }

  Future<List<Expense>> getExpensesByPayer(String payerId) async {
    try {
      final collection = await _getCollection(_expensesCollectionName);
      final result = await collection.find(where.eq('paidById', payerId)).toList();
      result.sort((a, b) {
        final dateA = (a['date'] as DateTime?) ?? DateTime(1900);
        final dateB = (b['date'] as DateTime?) ?? DateTime(1900);
        return dateB.compareTo(dateA);
      });
      return result
          .map((map) => Expense.fromMap({...map, 'id': (map['_id'] as ObjectId).toHexString()}))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<Expense?> getExpense(String id) async {
    try {
      final collection = await _getCollection(_expensesCollectionName);
      final result = await collection.findOne(where.id(ObjectId.fromHexString(id)));
      if (result == null) return null;
      return Expense.fromMap({...result, 'id': (result['_id'] as ObjectId).toHexString()});
    } catch (e) {
      return null;
    }
  }

  Future<int> updateExpense(Expense expense) async {
    try {
      final collection = await _getCollection(_expensesCollectionName);
      final map = expense.toMap();
      map.remove('id');
      final result = await collection.updateOne(
        where.id(ObjectId.fromHexString(expense.id.toString())),
        {'\$set': map},
      );
      return result.nModified;
    } catch (e) {
      return 0;
    }
  }

  Future<int> deleteExpense(String id) async {
    try {
      final collection = await _getCollection(_expensesCollectionName);
      final result = await collection.deleteOne(where.id(ObjectId.fromHexString(id)));
      return result.ok == 1 ? 1 : 0;
    } catch (e) {
      return 0;
    }
  }

  // Settlement Operations
  Future<String> insertSettlement(Settlement settlement) async {
    try {
      final collection = await _getCollection(_settlementsCollectionName);
      final map = settlement.toMap();
      map.remove('id');
      final result = await collection.insertOne(map);
      return (result.id as ObjectId).toHexString();
    } catch (e) {
      return '';
    }
  }

  Future<List<Settlement>> getSettlements() async {
    try {
      final collection = await _getCollection(_settlementsCollectionName);
      final result = await collection.find().toList();
      result.sort((a, b) {
        final dateA = (a['date'] as DateTime?) ?? DateTime(1900);
        final dateB = (b['date'] as DateTime?) ?? DateTime(1900);
        return dateB.compareTo(dateA);
      });
      final settlements = result
          .map((map) => Settlement.fromMap({...map, 'id': (map['_id'] as ObjectId).toHexString()}))
          .toList();
      print('📋 Loaded ${settlements.length} settlements from database');
      return settlements;
    } catch (e) {
      print('❌ Error loading settlements: $e');
      return [];
    }
  }

  Future<int> updateSettlement(Settlement settlement) async {
    try {
      final collection = await _getCollection(_settlementsCollectionName);
      final map = settlement.toMap();
      map.remove('id');
      final result = await collection.updateOne(
        where.id(ObjectId.fromHexString(settlement.id.toString())),
        {'\$set': map},
      );
      return result.nModified;
    } catch (e) {
      return 0;
    }
  }

  Future<int> deleteSettlement(String id) async {
    try {
      final collection = await _getCollection(_settlementsCollectionName);
      final result = await collection.deleteOne(where.id(ObjectId.fromHexString(id)));
      return result.ok == 1 ? 1 : 0;
    } catch (e) {
      return 0;
    }
  }

  // Company Fund Operations
  Future<String> insertCompanyFund(CompanyFund fund) async {
    try {
      final collection = await _getCollection(_companyFundsCollectionName);
      final map = fund.toMap();
      map.remove('id');
      print('📄 Inserting company fund: ${map['description']} - ₹${map['amount']}');
      final result = await collection.insertOne(map);
      final hexId = (result.id as ObjectId).toHexString();
      print('✅ Inserted with ID: $hexId');
      return hexId;
    } catch (e) {
      print('❌ Error inserting company fund: $e');
      return '';
    }
  }

  Future<List<CompanyFund>> getCompanyFunds() async {
    try {
      final collection = await _getCollection(_companyFundsCollectionName);
      final result = await collection.find().toList();
      print('📊 Found ${result.length} company fund records in DB');
      
      // Sort by date (convert string dates properly)
      result.sort((a, b) {
        final dateAValue = a['date'];
        final dateBValue = b['date'];
        
        final dateA = dateAValue is DateTime 
            ? dateAValue 
            : (dateAValue is String ? DateTime.parse(dateAValue) : DateTime(1900));
        final dateB = dateBValue is DateTime 
            ? dateBValue 
            : (dateBValue is String ? DateTime.parse(dateBValue) : DateTime(1900));
            
        return dateB.compareTo(dateA); // Newest first
      });
      
      final funds = result
          .map((map) => CompanyFund.fromMap({...map, 'id': (map['_id'] as ObjectId).toHexString()}))
          .toList();
      print('✅ Converted to ${funds.length} CompanyFund objects');
      return funds;
    } catch (e) {
      print('❌ Error fetching company funds: $e');
      return [];
    }
  }

  Future<int> deleteCompanyFund(String id) async {
    try {
      final collection = await _getCollection(_companyFundsCollectionName);
      final result = await collection.deleteOne(where.id(ObjectId.fromHexString(id)));
      return result.ok == 1 ? 1 : 0;
    } catch (e) {
      return 0;
    }
  }

  Future<double> getCompanyFundBalance() async {
    try {
      final collection = await _getCollection(_companyFundsCollectionName);
      final result = await collection.find().toList();
      double balance = 0;
      for (var map in result) {
        if (map['type'] == 'add') {
          balance += ((map['amount'] ?? 0) as num).toDouble();
        } else {
          balance -= ((map['amount'] ?? 0) as num).toDouble();
        }
      }
      return balance;
    } catch (e) {
      return 0;
    }
  }

  // Device Token Operations for FCM
  /// Save or update device token for push notifications
  Future<void> saveDeviceToken(String token) async {
    try {
      final collection = await _getCollection(_deviceTokensCollectionName);
      
      // Check if token already exists
      final existing = await collection.findOne(where.eq('token', token));
      
      if (existing != null) {
        // Update last seen timestamp
        await collection.updateOne(
          where.eq('token', token),
          modify.set('lastSeen', DateTime.now()),
        );
        print('🔄 Updated existing token timestamp');
      } else {
        // Insert new token
        await collection.insertOne({
          'token': token,
          'createdAt': DateTime.now(),
          'lastSeen': DateTime.now(),
        });
        print('✅ Saved new device token');
      }
    } catch (e) {
      print('❌ Error saving device token: $e');
    }
  }

  /// Get all active device tokens for broadcasting notifications
  Future<List<String>> getAllDeviceTokens() async {
    try {
      final collection = await _getCollection(_deviceTokensCollectionName);
      final result = await collection.find().toList();
      
      final tokens = result
          .map((doc) => doc['token'] as String?)
          .where((token) => token != null && token.isNotEmpty)
          .cast<String>()
          .toList();
      
      print('📱 Retrieved ${tokens.length} device tokens from database');
      return tokens;
    } catch (e) {
      print('❌ Error getting device tokens: $e');
      return [];
    }
  }

  /// Remove invalid or expired device token
  Future<void> removeDeviceToken(String token) async {
    try {
      final collection = await _getCollection(_deviceTokensCollectionName);
      await collection.deleteOne(where.eq('token', token));
      print('🗑️ Removed device token from database');
    } catch (e) {
      print('❌ Error removing device token: $e');
    }
  }

  /// Clean up old device tokens (optional - run periodically)
  /// Removes tokens not seen in the last 30 days
  Future<int> cleanupOldTokens() async {
    try {
      final collection = await _getCollection(_deviceTokensCollectionName);
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      
      final result = await collection.deleteMany(
        where.lt('lastSeen', thirtyDaysAgo),
      );
      
      final count = result.nRemoved;
      print('🧹 Cleaned up $count old device tokens');
      return count;
    } catch (e) {
      print('❌ Error cleaning up tokens: $e');
      return 0;
    }
  }

  // Vault Operations (encrypted)
  Future<String> insertVaultEntry(EncryptedVaultRecord record) async {
    try {
      final collection = await _getCollection(vaultEntriesCollectionName);
      final payload = record.toMap();
      payload.remove('id');
      final result = await collection.insertOne(payload);
      return (result.id as ObjectId).toHexString();
    } catch (e) {
      print('❌ Error inserting vault entry: $e');
      return '';
    }
  }

  Future<List<EncryptedVaultRecord>> getVaultEntries() async {
    try {
      final collection = await _getCollection(vaultEntriesCollectionName);
      final result = await collection.find().toList();
      result.sort((a, b) {
        final dateA = a['updatedAt'] is DateTime
            ? a['updatedAt'] as DateTime
            : DateTime.tryParse(a['updatedAt']?.toString() ?? '') ?? DateTime(1900);
        final dateB = b['updatedAt'] is DateTime
            ? b['updatedAt'] as DateTime
            : DateTime.tryParse(b['updatedAt']?.toString() ?? '') ?? DateTime(1900);
        return dateB.compareTo(dateA);
      });
      return result.map((map) => EncryptedVaultRecord.fromMap(map)).toList();
    } catch (e) {
      print('❌ Error loading vault entries: $e');
      return [];
    }
  }

  Future<int> updateVaultEntry(EncryptedVaultRecord record) async {
    try {
      final collection = await _getCollection(vaultEntriesCollectionName);
      final payload = record.toMap();
      payload.remove('id');
      final result = await collection.updateOne(
        where.id(ObjectId.fromHexString(record.id!)),
        {'\$set': payload},
      );
      return result.nModified;
    } catch (e) {
      print('❌ Error updating vault entry: $e');
      return 0;
    }
  }

  Future<int> deleteVaultEntry(String id) async {
    try {
      final collection = await _getCollection(vaultEntriesCollectionName);
      final result = await collection.deleteOne(where.id(ObjectId.fromHexString(id)));
      return result.ok == 1 ? 1 : 0;
    } catch (e) {
      print('❌ Error deleting vault entry: $e');
      return 0;
    }
  }
}
