import 'package:flutter/material.dart';
import '../models/cofounder.dart';
import '../models/expense.dart';
import '../models/settlement.dart';
import '../models/company_fund.dart';
import '../database/mongodb_helper.dart';

class ExpenseProvider extends ChangeNotifier {
  final MongoDBHelper _databaseHelper = MongoDBHelper.instance;

  List<CoFounder> _coFounders = [];
  List<Expense> _expenses = [];
  List<Settlement> _settlements = [];
  List<CompanyFund> _companyFunds = [];
  double _companyFundBalance = 0;

  List<CoFounder> get coFounders => _coFounders;
  List<Expense> get expenses => _expenses;
  List<Settlement> get settlements => _settlements;
  List<CompanyFund> get companyFunds => _companyFunds;
  double get companyFundBalance => _companyFundBalance;

  // Load all data
  Future<void> loadAllData() async {
    try {
      await loadCoFounders();
      await loadExpenses();
      await loadSettlements();
      await loadCompanyFunds();
    } catch (e) {
      // Error loading data from MongoDB
    }
  }

  // CoFounder operations
  Future<void> loadCoFounders() async {
    try {
      _coFounders = await _databaseHelper.getCoFounders();
      notifyListeners();
    } catch (e) {
      // Error loading cofounders
    }
  }

  Future<bool> addCoFounder(CoFounder coFounder) async {
    try {
      String id = await _databaseHelper.insertCoFounder(coFounder);
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

  Future<bool> deleteCoFounder(dynamic id) async {
    try {
      await _databaseHelper.deleteCoFounder(id.toString());
      _coFounders.removeWhere((cf) => cf.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  CoFounder? getCoFounderById(dynamic id) {
    try {
      return _coFounders.firstWhere((cf) => cf.id == id);
    } catch (e) {
      return null;
    }
  }

  // Expense operations
  Future<void> loadExpenses() async {
    try {
      _expenses = await _databaseHelper.getExpenses();
      notifyListeners();
    } catch (e) {
      // Error loading expenses
    }
  }

  Future<bool> addExpense(Expense expense) async {
    try {
      String id = await _databaseHelper.insertExpense(expense);
      expense.id = id;
      _expenses.add(expense);
      notifyListeners();
      await calculateSettlements();
      
      // If company fund was used, deduct from company fund balance
      if (expense.isCompanyFund) {
        await _loadCompanyFundBalance();
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> _loadCompanyFundBalance() async {
    _companyFundBalance = await _databaseHelper.getCompanyFundBalance();
    notifyListeners();
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

  Future<bool> deleteExpense(dynamic id) async {
    try {
      await _databaseHelper.deleteExpense(id.toString());
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

  double getExpensesByPayer(dynamic payerId) {
    return _expenses
        .where((exp) => exp.paidById == payerId && !exp.isCompanyFund)
        .fold(0, (sum, exp) => sum + exp.amount);
  }

  // Settlement calculations
  Future<void> loadSettlements() async {
    try {
      _settlements = await _databaseHelper.getSettlements();
      notifyListeners();
    } catch (e) {
      // Error loading settlements
    }
  }

  Future<void> calculateSettlements() async {
    // This method now just calculates balances in memory
    // No need to clear or rewrite database
    notifyListeners();
  }

  Map<dynamic, double> getBalances() {
    Map<dynamic, double> balances = {};

    // Initialize balances for all co-founders
    for (var coFounder in _coFounders) {
      balances[coFounder.id] = 0;
    }

    // Add expenses to balances (skip company fund expenses)
    for (var expense in _expenses) {
      // Skip company fund expenses in balance calculation
      if (expense.isCompanyFund) {
        continue;
      }

      // Validate that paidById is not empty
      if (expense.paidById == null || expense.paidById.toString().isEmpty) {
        continue;
      }

      double perPerson = expense.getContributionPerPerson();
      balances[expense.paidById] =
          (balances[expense.paidById] ?? 0) + expense.amount;

      for (var contributorId in expense.contributorIds) {
        if (contributorId != null && contributorId.toString().isNotEmpty) {
          balances[contributorId] =
              (balances[contributorId] ?? 0) - perPerson;
        }
      }
    }

    // Adjust balances for settlements
    for (var settlement in _settlements) {
      if (settlement.settled) {
        // Reduce the payer's balance (they paid less now) and reduce the receiver's balance (they owe less)
        balances[settlement.fromId] =
            (balances[settlement.fromId] ?? 0) + settlement.amount;
        balances[settlement.toId] =
            (balances[settlement.toId] ?? 0) - settlement.amount;
      }
    }

    return balances;
  }

  Future<bool> recordSettlement(Settlement settlement) async {
    try {
      String id = await _databaseHelper.insertSettlement(settlement);
      settlement.id = id;
      _settlements.add(settlement);
      // Recalculate to update UI with new balances
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> markSettlementAsSettled(Settlement settlement) async {
    try {
      settlement.settled = true;
      await _databaseHelper.updateSettlement(settlement);
      int index = _settlements.indexWhere((s) => s.id == settlement.id);
      if (index != -1) {
        _settlements[index] = settlement;
      }
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Settlement? getSettlementById(dynamic id) {
    try {
      return _settlements.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }

  // Company Fund Operations
  Future<void> loadCompanyFunds() async {
    try {
      _companyFunds = await _databaseHelper.getCompanyFunds();
      _companyFundBalance = await _databaseHelper.getCompanyFundBalance();
      print('✅ Loaded ${_companyFunds.length} company funds');
      notifyListeners();
    } catch (e) {
      print('❌ Error loading company funds: $e');
    }
  }

  Future<bool> addCompanyFund(CompanyFund fund) async {
    try {
      String id = await _databaseHelper.insertCompanyFund(fund);
      if (id.isNotEmpty) {
        fund.id = id;
        _companyFunds.insert(0, fund);
        _companyFundBalance = await _databaseHelper.getCompanyFundBalance();
        print('💰 Updated company fund balance: ₹$_companyFundBalance');
        notifyListeners();
        return true;
      }
      print('❌ Failed to insert company fund - empty ID returned');
      return false;
    } catch (e) {
      print('❌ Error adding company fund: $e');
      return false;
    }
  }

  Future<bool> removeCompanyFund(dynamic id) async {
    try {
      await _databaseHelper.deleteCompanyFund(id.toString());
      _companyFunds.removeWhere((f) => f.id == id);
      _companyFundBalance = await _databaseHelper.getCompanyFundBalance();
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }
}
