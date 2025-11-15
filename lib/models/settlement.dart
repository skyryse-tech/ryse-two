class Settlement {
  int? id;
  int fromId;
  int toId;
  double amount;
  DateTime date;
  String notes;
  bool settled;

  Settlement({
    this.id,
    required this.fromId,
    required this.toId,
    required this.amount,
    required this.date,
    this.notes = '',
    this.settled = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fromId': fromId,
      'toId': toId,
      'amount': amount,
      'date': date.toIso8601String(),
      'notes': notes,
      'settled': settled ? 1 : 0,
    };
  }

  factory Settlement.fromMap(Map<String, dynamic> map) {
    return Settlement(
      id: map['id'],
      fromId: map['fromId'],
      toId: map['toId'],
      amount: map['amount'].toDouble(),
      date: DateTime.parse(map['date']),
      notes: map['notes'] ?? '',
      settled: map['settled'] == 1,
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
