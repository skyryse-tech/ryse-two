class CompanyFund {
  int? id;
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
      'id': id,
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
      amount: map['amount'].toDouble(),
      description: map['description'],
      type: map['type'],
      date: DateTime.parse(map['date']),
      createdAt: DateTime.parse(map['createdAt']),
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
