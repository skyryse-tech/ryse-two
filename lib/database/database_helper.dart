import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/cofounder.dart';
import '../models/expense.dart';
import '../models/settlement.dart';
import '../models/company_fund.dart';

class DatabaseHelper {
  static const _databaseName = 'ryse_two.db';
  static const _databaseVersion = 1;

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create Co-founders table
    await db.execute(
      '''CREATE TABLE cofounder (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        phone TEXT,
        avatarColor TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        isActive INTEGER NOT NULL DEFAULT 1,
        role TEXT NOT NULL DEFAULT 'Co-founder',
        bankName TEXT,
        bankAccountNumber TEXT,
        bankIFSC TEXT,
        targetContribution REAL NOT NULL DEFAULT 0
      )''',
    );

    // Create Expenses table
    await db.execute(
      '''CREATE TABLE expense (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        description TEXT NOT NULL,
        amount REAL NOT NULL,
        paidById INTEGER NOT NULL,
        contributorIds TEXT NOT NULL,
        category TEXT NOT NULL,
        date TEXT NOT NULL,
        notes TEXT,
        receipt TEXT,
        createdAt TEXT NOT NULL,
        isCompanyFund INTEGER NOT NULL DEFAULT 0,
        companyName TEXT,
        FOREIGN KEY (paidById) REFERENCES cofounder(id)
      )''',
    );

    // Create Settlements table
    await db.execute(
      '''CREATE TABLE settlement (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fromId INTEGER NOT NULL,
        toId INTEGER NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        notes TEXT,
        settled INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (fromId) REFERENCES cofounder(id),
        FOREIGN KEY (toId) REFERENCES cofounder(id)
      )''',
    );

    // Create Company Fund table
    await db.execute(
      '''CREATE TABLE company_fund (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL NOT NULL,
        description TEXT NOT NULL,
        type TEXT NOT NULL,
        date TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )''',
    );
  }

  // CoFounder Operations
  Future<int> insertCoFounder(CoFounder coFounder) async {
    Database db = await database;
    return await db.insert('cofounder', coFounder.toMap());
  }

  Future<List<CoFounder>> getCoFounders() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('cofounder');
    return List.generate(maps.length, (i) => CoFounder.fromMap(maps[i]));
  }

  Future<CoFounder?> getCoFounder(int id) async {
    Database db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('cofounder', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return CoFounder.fromMap(maps[0]);
  }

  Future<int> updateCoFounder(CoFounder coFounder) async {
    Database db = await database;
    return await db.update('cofounder', coFounder.toMap(),
        where: 'id = ?', whereArgs: [coFounder.id]);
  }

  Future<int> deleteCoFounder(int id) async {
    Database db = await database;
    return await db.delete('cofounder', where: 'id = ?', whereArgs: [id]);
  }

  // Expense Operations
  Future<int> insertExpense(Expense expense) async {
    Database db = await database;
    return await db.insert('expense', expense.toMap());
  }

  Future<List<Expense>> getExpenses() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('expense', orderBy: 'date DESC');
    return List.generate(maps.length, (i) => Expense.fromMap(maps[i]));
  }

  Future<List<Expense>> getExpensesByPayer(int payerId) async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('expense',
        where: 'paidById = ?', whereArgs: [payerId], orderBy: 'date DESC');
    return List.generate(maps.length, (i) => Expense.fromMap(maps[i]));
  }

  Future<Expense?> getExpense(int id) async {
    Database db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('expense', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Expense.fromMap(maps[0]);
  }

  Future<int> updateExpense(Expense expense) async {
    Database db = await database;
    return await db.update('expense', expense.toMap(),
        where: 'id = ?', whereArgs: [expense.id]);
  }

  Future<int> deleteExpense(int id) async {
    Database db = await database;
    return await db.delete('expense', where: 'id = ?', whereArgs: [id]);
  }

  // Settlement Operations
  Future<int> insertSettlement(Settlement settlement) async {
    Database db = await database;
    return await db.insert('settlement', settlement.toMap());
  }

  Future<List<Settlement>> getSettlements() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('settlement', orderBy: 'date DESC');
    return List.generate(maps.length, (i) => Settlement.fromMap(maps[i]));
  }

  Future<int> updateSettlement(Settlement settlement) async {
    Database db = await database;
    return await db.update('settlement', settlement.toMap(),
        where: 'id = ?', whereArgs: [settlement.id]);
  }

  Future<int> deleteSettlement(int id) async {
    Database db = await database;
    return await db.delete('settlement', where: 'id = ?', whereArgs: [id]);
  }

  // Clear all data (for testing)
  Future<void> clearDatabase() async {
    Database db = await database;
    await db.delete('expense');
    await db.delete('settlement');
    await db.delete('company_fund');
    await db.delete('cofounder');
  }

  // Company Fund Operations
  Future<int> insertCompanyFund(CompanyFund fund) async {
    Database db = await database;
    return await db.insert('company_fund', fund.toMap());
  }

  Future<List<CompanyFund>> getCompanyFunds() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('company_fund', orderBy: 'date DESC');
    return List.generate(maps.length, (i) => CompanyFund.fromMap(maps[i]));
  }

  Future<int> deleteCompanyFund(int id) async {
    Database db = await database;
    return await db.delete('company_fund', where: 'id = ?', whereArgs: [id]);
  }

  Future<double> getCompanyFundBalance() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('company_fund');
    double balance = 0;
    for (var map in maps) {
      if (map['type'] == 'add') {
        balance += (map['amount'] as num).toDouble();
      } else {
        balance -= (map['amount'] as num).toDouble();
      }
    }
    return balance;
  }
}
