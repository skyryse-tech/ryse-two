class CoFounder {
  dynamic id; // Can be int (SQLite) or String (MongoDB)
  String name;
  String email;
  String phone;
  String avatarColor;
  DateTime createdAt;
  bool isActive;
  String role;
  String bankName;
  String bankAccountNumber;
  String bankIFSC;
  double targetContribution;

  CoFounder({
    this.id,
    required this.name,
    required this.email,
    this.phone = '',
    this.avatarColor = 'FF1E88E5',
    required this.createdAt,
    this.isActive = true,
    this.role = 'Co-founder',
    this.bankName = '',
    this.bankAccountNumber = '',
    this.bankIFSC = '',
    this.targetContribution = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'avatarColor': avatarColor,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
      'role': role,
      'bankName': bankName,
      'bankAccountNumber': bankAccountNumber,
      'bankIFSC': bankIFSC,
      'targetContribution': targetContribution,
    };
  }

  factory CoFounder.fromMap(Map<String, dynamic> map) {
    return CoFounder(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      phone: map['phone'] ?? '',
      avatarColor: map['avatarColor'] ?? 'FF1E88E5',
      createdAt: map['createdAt'] is String ? DateTime.parse(map['createdAt']) : map['createdAt'] as DateTime,
      isActive: map['isActive'] == true || map['isActive'] == 1,
      role: map['role'] ?? 'Co-founder',
      bankName: map['bankName'] ?? '',
      bankAccountNumber: map['bankAccountNumber'] ?? '',
      bankIFSC: map['bankIFSC'] ?? '',
      targetContribution: (map['targetContribution'] is double ? map['targetContribution'] : (map['targetContribution'] as num?)?.toDouble() ?? 0),
    );
  }

  CoFounder copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? avatarColor,
    DateTime? createdAt,
    bool? isActive,
    String? role,
    String? bankName,
    String? bankAccountNumber,
    String? bankIFSC,
    double? targetContribution,
  }) {
    return CoFounder(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarColor: avatarColor ?? this.avatarColor,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      role: role ?? this.role,
      bankName: bankName ?? this.bankName,
      bankAccountNumber: bankAccountNumber ?? this.bankAccountNumber,
      bankIFSC: bankIFSC ?? this.bankIFSC,
      targetContribution: targetContribution ?? this.targetContribution,
    );
  }
}
