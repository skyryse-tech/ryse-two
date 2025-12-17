import 'package:mongo_dart/mongo_dart.dart' as mongo;

class VaultEntry {
  final String? id;
  final String service;
  final String username;
  final String? email;
  final String password;
  final String url;
  final DateTime createdAt;
  final DateTime updatedAt;

  const VaultEntry({
    this.id,
    required this.service,
    required this.username,
    this.email,
    required this.password,
    required this.url,
    required this.createdAt,
    required this.updatedAt,
  });

  VaultEntry copyWith({
    String? id,
    String? service,
    String? username,
    String? email,
    String? password,
    String? url,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VaultEntry(
      id: id ?? this.id,
      service: service ?? this.service,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      url: url ?? this.url,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'service': service,
      'username': username,
      'email': email,
      'password': password,
      'url': url,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory VaultEntry.fromJson(Map<String, dynamic> json, {String? id}) {
    return VaultEntry(
      id: id,
      service: json['service'] ?? '',
      username: json['username'] ?? '',
      email: json['email'],
      password: json['password'] ?? '',
      url: json['url'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class EncryptedVaultRecord {
  String? id;
  String cipherText;
  String iv;
  DateTime createdAt;
  DateTime updatedAt;

  EncryptedVaultRecord({
    this.id,
    required this.cipherText,
    required this.iv,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'cipherText': cipherText,
      'iv': iv,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory EncryptedVaultRecord.fromMap(Map<String, dynamic> map) {
    final rawId = map['_id'];
    final parsedId = rawId is String
        ? rawId
        : (rawId is mongo.ObjectId ? rawId.toHexString() : null);

    return EncryptedVaultRecord(
      id: parsedId,
      cipherText: map['cipherText'] ?? '',
      iv: map['iv'] ?? '',
      createdAt: map['createdAt'] is DateTime
          ? map['createdAt'] as DateTime
          : DateTime.tryParse(map['createdAt']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: map['updatedAt'] is DateTime
          ? map['updatedAt'] as DateTime
          : DateTime.tryParse(map['updatedAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}
