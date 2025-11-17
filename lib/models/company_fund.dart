class CompanyFund {
  dynamic id; // Can be int (SQLite) or String (MongoDB)
  double amount;
  String description;
  String type; // 'add' or 'remove'
  DateTime date;
  DateTime createdAt;

  CompanyFund({
    this.id,
    required this.amount,
    required this.description,
    required this.type,
    required this.date,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'description': description,
      'type': type,
      'date': date.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CompanyFund.fromMap(Map<String, dynamic> map) {
    return CompanyFund(
      id: map['id'],
      amount: (map['amount'] is double ? map['amount'] : (map['amount'] as num).toDouble()),
      description: map['description'],
      type: map['type'],
      date: map['date'] is String ? DateTime.parse(map['date']) : map['date'] as DateTime,
      createdAt: map['createdAt'] is String ? DateTime.parse(map['createdAt']) : map['createdAt'] as DateTime,
    );
  }

  CompanyFund copyWith({
    int? id,
    double? amount,
    String? description,
    String? type,
    DateTime? date,
    DateTime? createdAt,
  }) {
    return CompanyFund(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      type: type ?? this.type,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
