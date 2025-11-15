class AppConstants {
  // App Info
  static const String appName = 'Ryse';
  static const String appVersion = '1.0.0';
  
  // Strings
  static const String noExpensesFound = 'No expenses found';
  static const String noCoFoundersFound = 'No co-founders added yet';
  static const String selectCategoryHint = 'Select a category';
  static const String enterAmountHint = 'Enter amount';
  
  // Default Values
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 12.0;
  
  // Animation Duration
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
}

class AppStrings {
  // Dashboard
  static const String dashboard = 'Dashboard';
  static const String totalExpenses = 'Total Expenses';
  static const String expensesRecorded = 'expenses recorded';
  static const String coFoundersBalance = 'Co-founders Balance';
  static const String getsRefund = 'Gets refund';
  static const String owes = 'Owes';
  static const String recentExpenses = 'Recent Expenses';
  static const String paidBy = 'Paid by';
  static const String viewAll = 'View All';
  
  // Expenses
  static const String expenses = 'Expenses';
  static const String addExpense = 'Add Expense';
  static const String description = 'Description';
  static const String whatDidYouSpend = 'What did you spend on?';
  static const String amount = 'Amount';
  static const String category = 'Category';
  static const String whoPaid = 'Who Paid?';
  static const String whoContributed = 'Who Contributed?';
  static const String notes = 'Notes';
  static const String addNotesOptional = 'Add any additional notes...';
  static const String deleteExpense = 'Delete Expense?';
  static const String deleteExpenseConfirm = 'This action cannot be undone.';
  static const String expenseDeletedSuccess = 'Expense deleted';
  
  // Co-founders
  static const String coFounders = 'Co-founders';
  static const String addCoFounder = 'Add Co-founder';
  static const String chooseAvatarColor = 'Choose Avatar Color';
  static const String fullName = 'Full Name';
  static const String email = 'Email';
  static const String phone = 'Phone (optional)';
  static const String deleteCoFounder = 'Delete Co-founder?';
  static const String deleteCoFounderConfirm = 'This will also delete all related expenses.';
  static const String coFounderDeletedSuccess = 'Co-founder deleted';
  static const String coFounderAddedSuccess = 'Co-founder added successfully';
  static const String paid = 'Paid';
  
  // Reports
  static const String reports = 'Reports & Analytics';
  static const String overview = 'Overview';
  static const String byPerson = 'By Person';
  static const String byCategory = 'By Category';
  static const String transactions = 'Transactions';
  static const String avgExpense = 'Avg Expense';
  static const String expenseDistribution = 'Expense Distribution';
  static const String contributionSummary = 'Contribution Summary';
  static const String expensesByCategory = 'Expenses by Category';
  
  // Settlements
  static const String settlements = 'Settlements';
  static const String allSettled = 'All settled!';
  static const String confirmSettlement = 'Confirm Settlement';
  static const String willTransfer = 'will transfer';
  static const String to = 'to';
  static const String markAsSettled = 'Mark as Settled';
  static const String settlementRecorded = 'Settlement recorded';
  
  // Buttons
  static const String cancel = 'Cancel';
  static const String save = 'Save';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String confirm = 'Confirm';
  
  // Validation
  static const String enterDescription = 'Please enter a description';
  static const String enterAmount = 'Please enter an amount';
  static const String selectPayer = 'Please select who paid';
  static const String selectContributors = 'Please select contributors';
  static const String enterName = 'Please enter a name';
  static const String enterEmail = 'Please enter an email';
  static const String errorAddingCoFounder = 'Error adding co-founder';
  static const String expenseAddedSuccess = 'Expense added successfully';
}
