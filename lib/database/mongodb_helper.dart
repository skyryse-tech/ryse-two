import 'package:mongo_dart/mongo_dart.dart';
import '../models/cofounder.dart';
import '../models/expense.dart';
import '../models/settlement.dart';
import '../models/company_fund.dart';

class MongoDBHelper {
  static const String _uri =
      'mongodb+srv://skyryse_db_user:9Fx6BTA561Tf0o5J@cluster0.dxnv2ep.mongodb.net/?appName=Cluster0';
  static const String _cofoundersCollection = 'cofounders';
  static const String _expensesCollection = 'expenses';
  static const String _settlementsCollection = 'settlements';
  static const String _companyFundsCollection = 'company_funds';

  MongoDBHelper._privateConstructor();
  static final MongoDBHelper instance = MongoDBHelper._privateConstructor();

  static Db? _database;
  static DbCollection? _cofoundersCollection_;
  static DbCollection? _expensesCollection_;
  static DbCollection? _settlementsCollection_;
  static DbCollection? _companyFundsCollection_;

  Future<Db> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Db> _initDatabase() async {
    final db = Db(_uri);
    await db.open();
    _cofoundersCollection_ = db.collection(_cofoundersCollection);
    _expensesCollection_ = db.collection(_expensesCollection);
    _settlementsCollection_ = db.collection(_settlementsCollection);
    _companyFundsCollection_ = db.collection(_companyFundsCollection);
    return db;
  }

  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  // CoFounder Operations
  Future<String> insertCoFounder(CoFounder coFounder) async {
    try {
      final collection = _cofoundersCollection_;
      if (collection == null) return '';
      final map = coFounder.toMap();
      map.remove('id'); // Remove id to let MongoDB generate it
      final result = await collection.insertOne(map);
      return (result.id as ObjectId).toHexString();
    } catch (e) {
      return '';
    }
  }

  Future<List<CoFounder>> getCoFounders() async {
    try {
      final collection = _cofoundersCollection_;
      if (collection == null) return [];
      final result = await collection.find().toList();
      return result
          .map((map) => CoFounder.fromMap({...map, 'id': (map['_id'] as ObjectId).toHexString()}))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<CoFounder?> getCoFounder(String id) async {
    try {
      final collection = _cofoundersCollection_;
      if (collection == null) return null;
      final result = await collection.findOne(where.id(ObjectId.fromHexString(id)));
      if (result == null) return null;
      return CoFounder.fromMap({...result, 'id': (result['_id'] as ObjectId).toHexString()});
    } catch (e) {
      return null;
    }
  }

  Future<int> updateCoFounder(CoFounder coFounder) async {
    try {
      final collection = _cofoundersCollection_;
      if (collection == null) return 0;
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
      final collection = _cofoundersCollection_;
      if (collection == null) return 0;
      final result = await collection.deleteOne(where.id(ObjectId.fromHexString(id)));
      return result.ok == 1 ? 1 : 0;
    } catch (e) {
      return 0;
    }
  }

  // Expense Operations
  Future<String> insertExpense(Expense expense) async {
    try {
      final collection = _expensesCollection_;
      if (collection == null) return '';
      final map = expense.toMap();
      map.remove('id');
      final result = await collection.insertOne(map);
      return (result.id as ObjectId).toHexString();
    } catch (e) {
      return '';
    }
  }

  Future<List<Expense>> getExpenses() async {
    try {
      final collection = _expensesCollection_;
      if (collection == null) return [];
      final result = await collection.find().toList();
      // Sort by date descending
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

  Future<List<Expense>> getExpensesByPayer(String payerId) async {
    try {
      final collection = _expensesCollection_;
      if (collection == null) return [];
      final result = await collection.find(where.eq('paidById', payerId)).toList();
      // Sort by date descending
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
      final collection = _expensesCollection_;
      if (collection == null) return null;
      final result = await collection.findOne(where.id(ObjectId.fromHexString(id)));
      if (result == null) return null;
      return Expense.fromMap({...result, 'id': (result['_id'] as ObjectId).toHexString()});
    } catch (e) {
      return null;
    }
  }

  Future<int> updateExpense(Expense expense) async {
    try {
      final collection = _expensesCollection_;
      if (collection == null) return 0;
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
      final collection = _expensesCollection_;
      if (collection == null) return 0;
      final result = await collection.deleteOne(where.id(ObjectId.fromHexString(id)));
      return result.ok == 1 ? 1 : 0;
    } catch (e) {
      return 0;
    }
  }

  // Settlement Operations
  Future<String> insertSettlement(Settlement settlement) async {
    try {
      final collection = _settlementsCollection_;
      if (collection == null) return '';
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
      final collection = _settlementsCollection_;
      if (collection == null) return [];
      final result = await collection.find().toList();
      // Sort by date descending
      result.sort((a, b) {
        final dateA = (a['date'] as DateTime?) ?? DateTime(1900);
        final dateB = (b['date'] as DateTime?) ?? DateTime(1900);
        return dateB.compareTo(dateA);
      });
      return result
          .map((map) => Settlement.fromMap({...map, 'id': (map['_id'] as ObjectId).toHexString()}))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<int> updateSettlement(Settlement settlement) async {
    try {
      final collection = _settlementsCollection_;
      if (collection == null) return 0;
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
      final collection = _settlementsCollection_;
      if (collection == null) return 0;
      final result = await collection.deleteOne(where.id(ObjectId.fromHexString(id)));
      return result.ok == 1 ? 1 : 0;
    } catch (e) {
      return 0;
    }
  }

  // Company Fund Operations
  Future<String> insertCompanyFund(CompanyFund fund) async {
    try {
      final collection = _companyFundsCollection_;
      if (collection == null) return '';
      final map = fund.toMap();
      map.remove('id');
      final result = await collection.insertOne(map);
      return (result.id as ObjectId).toHexString();
    } catch (e) {
      return '';
    }
  }

  Future<List<CompanyFund>> getCompanyFunds() async {
    try {
      final collection = _companyFundsCollection_;
      if (collection == null) return [];
      final result = await collection.find().toList();
      // Sort by date descending
      result.sort((a, b) {
        final dateA = (a['date'] as DateTime?) ?? DateTime(1900);
        final dateB = (b['date'] as DateTime?) ?? DateTime(1900);
        return dateB.compareTo(dateA);
      });
      return result
          .map((map) => CompanyFund.fromMap({...map, 'id': (map['_id'] as ObjectId).toHexString()}))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<int> deleteCompanyFund(String id) async {
    try {
      final collection = _companyFundsCollection_;
      if (collection == null) return 0;
      final result = await collection.deleteOne(where.id(ObjectId.fromHexString(id)));
      return result.ok == 1 ? 1 : 0;
    } catch (e) {
      return 0;
    }
  }

  Future<double> getCompanyFundBalance() async {
    try {
      final collection = _companyFundsCollection_;
      if (collection == null) return 0;
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
}
