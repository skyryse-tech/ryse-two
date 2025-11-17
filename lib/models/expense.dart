class Expense {
  dynamic id; // Can be int (SQLite) or String (MongoDB)
  String description;
  double amount;
  dynamic paidById; // Can be int or String
  List<dynamic> contributorIds; // Can be ints or Strings
  String category;
  DateTime date;
  String? notes;
  String? receipt;
  DateTime createdAt;
  bool isCompanyFund;
  String companyName;

  Expense({
    this.id,
    required this.description,
    required this.amount,
    required this.paidById,
    required this.contributorIds,
    required this.category,
    required this.date,
    this.notes,
    this.receipt,
    required this.createdAt,
    this.isCompanyFund = false,
    this.companyName = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'description': description,
      'amount': amount,
      'paidById': paidById,
      'contributorIds': contributorIds,
      'category': category,
      'date': date.toIso8601String(),
      'notes': notes,
      'receipt': receipt,
      'createdAt': createdAt.toIso8601String(),
      'isCompanyFund': isCompanyFund,
      'companyName': companyName,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      description: map['description'],
      amount: (map['amount'] is double ? map['amount'] : (map['amount'] as num).toDouble()),
      paidById: map['paidById'],
      contributorIds: (map['contributorIds'] as List?)?.cast<dynamic>() ?? [],
      category: map['category'],
      date: map['date'] is String ? DateTime.parse(map['date']) : map['date'] as DateTime,
      notes: map['notes'],
      receipt: map['receipt'],
      createdAt: map['createdAt'] is String ? DateTime.parse(map['createdAt']) : map['createdAt'] as DateTime,
      isCompanyFund: map['isCompanyFund'] == true || map['isCompanyFund'] == 1,
      companyName: map['companyName'] ?? '',
    );
  }

  double getContributionPerPerson() {
    return amount / (contributorIds.isEmpty ? 1 : contributorIds.length);
  }

  Expense copyWith({
    int? id,
    String? description,
    double? amount,
    int? paidById,
    List<int>? contributorIds,
    String? category,
    DateTime? date,
    String? notes,
    String? receipt,
    DateTime? createdAt,
    bool? isCompanyFund,
    String? companyName,
  }) {
    return Expense(
      id: id ?? this.id,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      paidById: paidById ?? this.paidById,
      contributorIds: contributorIds ?? this.contributorIds,
      category: category ?? this.category,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      receipt: receipt ?? this.receipt,
      createdAt: createdAt ?? this.createdAt,
      isCompanyFund: isCompanyFund ?? this.isCompanyFund,
      companyName: companyName ?? this.companyName,
    );
  }
}

const List<String> expenseCategories = [
  'Office Supplies',
  'Equipment',
  'Software & Tools',
  'Marketing',
  'Travel',
  'Utilities',
  'Rent/Space',
  'Food & Beverage',
  'Professional Services',
  'Other',
];
