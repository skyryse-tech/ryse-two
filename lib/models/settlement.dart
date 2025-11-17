class Settlement {
  dynamic id; // Can be int (SQLite) or String (MongoDB)
  dynamic fromId; // Can be int or String
  dynamic toId; // Can be int or String
  double amount;
  DateTime date;
  String notes;
  bool settled;
  dynamic relatedExpenseId; // The expense ID that triggered this settlement

  Settlement({
    this.id,
    required this.fromId,
    required this.toId,
    required this.amount,
    required this.date,
    this.notes = '',
    this.settled = false,
    this.relatedExpenseId,
  });

  Map<String, dynamic> toMap() {
    return {
      'fromId': fromId,
      'toId': toId,
      'amount': amount,
      'date': date.toIso8601String(),
      'notes': notes,
      'settled': settled,
      'relatedExpenseId': relatedExpenseId,
    };
  }

  factory Settlement.fromMap(Map<String, dynamic> map) {
    return Settlement(
      id: map['id'],
      fromId: map['fromId'],
      toId: map['toId'],
      amount: map['amount'] is double ? map['amount'] : (map['amount'] as num).toDouble(),
      date: map['date'] is String ? DateTime.parse(map['date']) : map['date'] as DateTime,
      notes: map['notes'] ?? '',
      settled: map['settled'] == true || map['settled'] == 1,
      relatedExpenseId: map['relatedExpenseId'],
    );
  }

  Settlement copyWith({
    int? id,
    int? fromId,
    int? toId,
    double? amount,
    DateTime? date,
    String? notes,
    bool? settled,
  }) {
    return Settlement(
      id: id ?? this.id,
      fromId: fromId ?? this.fromId,
      toId: toId ?? this.toId,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      settled: settled ?? this.settled,
    );
  }
}
