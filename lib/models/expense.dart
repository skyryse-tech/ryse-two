class Expense {
  int? id;
  String description;
  double amount;
  int paidById;
  List<int> contributorIds;
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
      'id': id,
      'description': description,
      'amount': amount,
      'paidById': paidById,
      'contributorIds': contributorIds.join(','),
      'category': category,
      'date': date.toIso8601String(),
      'notes': notes,
      'receipt': receipt,
      'createdAt': createdAt.toIso8601String(),
      'isCompanyFund': isCompanyFund ? 1 : 0,
      'companyName': companyName,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      description: map['description'],
      amount: map['amount'].toDouble(),
      paidById: map['paidById'],
      contributorIds: (map['contributorIds'] as String?)
              ?.split(',')
              .map((id) => int.parse(id))
              .toList() ??
          [],
      category: map['category'],
      date: DateTime.parse(map['date']),
      notes: map['notes'],
      receipt: map['receipt'],
      createdAt: DateTime.parse(map['createdAt']),
      isCompanyFund: map['isCompanyFund'] == 1,
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
