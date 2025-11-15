import 'package:flutter/material.dart';
import '../models/cofounder.dart';
import '../models/expense.dart';
import '../models/settlement.dart';
import '../database/database_helper.dart';

class ExpenseProvider extends ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  List<CoFounder> _coFounders = [];
  List<Expense> _expenses = [];
  List<Settlement> _settlements = [];

  List<CoFounder> get coFounders => _coFounders;
  List<Expense> get expenses => _expenses;
  List<Settlement> get settlements => _settlements;

  // Load all data
  Future<void> loadAllData() async {
    await loadCoFounders();
    await loadExpenses();
    await loadSettlements();
  }

  // CoFounder operations
  Future<void> loadCoFounders() async {
    _coFounders = await _databaseHelper.getCoFounders();
    notifyListeners();
  }

  Future<bool> addCoFounder(CoFounder coFounder) async {
    try {
      int id = await _databaseHelper.insertCoFounder(coFounder);
      coFounder.id = id;
      _coFounders.add(coFounder);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateCoFounder(CoFounder coFounder) async {
    try {
      await _databaseHelper.updateCoFounder(coFounder);
      int index =
          _coFounders.indexWhere((cf) => cf.id == coFounder.id);
      if (index != -1) {
        _coFounders[index] = coFounder;
      }
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteCoFounder(int id) async {
    try {
      await _databaseHelper.deleteCoFounder(id);
      _coFounders.removeWhere((cf) => cf.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  CoFounder? getCoFounderById(int id) {
    try {
      return _coFounders.firstWhere((cf) => cf.id == id);
    } catch (e) {
      return null;
    }
  }

  // Expense operations
  Future<void> loadExpenses() async {
    _expenses = await _databaseHelper.getExpenses();
    notifyListeners();
  }

  Future<bool> addExpense(Expense expense) async {
    try {
      int id = await _databaseHelper.insertExpense(expense);
      expense.id = id;
      _expenses.add(expense);
      notifyListeners();
      await calculateSettlements();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateExpense(Expense expense) async {
    try {
      await _databaseHelper.updateExpense(expense);
      int index = _expenses.indexWhere((e) => e.id == expense.id);
      if (index != -1) {
        _expenses[index] = expense;
      }
      notifyListeners();
      await calculateSettlements();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteExpense(int id) async {
    try {
      await _databaseHelper.deleteExpense(id);
      _expenses.removeWhere((e) => e.id == id);
      notifyListeners();
      await calculateSettlements();
      return true;
    } catch (e) {
      return false;
    }
  }

  double getTotalExpenses() {
    return _expenses.fold(0, (sum, exp) => sum + exp.amount);
  }

  double getExpensesByPayer(int payerId) {
    return _expenses
        .where((exp) => exp.paidById == payerId)
        .fold(0, (sum, exp) => sum + exp.amount);
  }

  // Settlement calculations
  Future<void> loadSettlements() async {
    _settlements = await _databaseHelper.getSettlements();
    notifyListeners();
  }

  Future<void> calculateSettlements() async {
    // Calculate balances for each co-founder
    Map<int, double> balances = {};

    // Initialize balances
    for (var coFounder in _coFounders) {
      balances[coFounder.id!] = 0;
    }

    // Calculate based on expenses
    for (var expense in _expenses) {
      double perPerson = expense.getContributionPerPerson();

      // Add to payer's balance
      balances[expense.paidById] =
          (balances[expense.paidById] ?? 0) + expense.amount;

      // Subtract from contributors
      for (var contributorId in expense.contributorIds) {
        balances[contributorId] =
            (balances[contributorId] ?? 0) - perPerson;
      }
    }

    // Generate settlements based on who owes whom
    await _databaseHelper.clearDatabase();
    for (var coFounder in _coFounders) {
      await _databaseHelper.insertCoFounder(coFounder);
    }
    for (var expense in _expenses) {
      await _databaseHelper.insertExpense(expense);
    }

    notifyListeners();
  }

  Map<int, double> getBalances() {
    Map<int, double> balances = {};

    for (var coFounder in _coFounders) {
      balances[coFounder.id!] = 0;
    }

    for (var expense in _expenses) {
      double perPerson = expense.getContributionPerPerson();
      balances[expense.paidById] =
          (balances[expense.paidById] ?? 0) + expense.amount;

      for (var contributorId in expense.contributorIds) {
        balances[contributorId] =
            (balances[contributorId] ?? 0) - perPerson;
      }
    }

    return balances;
  }

  Future<bool> recordSettlement(Settlement settlement) async {
    try {
      int id = await _databaseHelper.insertSettlement(settlement);
      settlement.id = id;
      _settlements.add(settlement);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }
}
