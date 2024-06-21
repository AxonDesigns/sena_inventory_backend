import 'dart:convert';
import 'package:sena_inventory_backend/entity.dart';
import 'package:sena_inventory_backend/lib.dart';

/// User entity
class User extends Entity {
  /// Create a new user entity
  const User({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.citizenId,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.password,
    required this.roleId,
  });

  /// Create a new user entity from a map
  factory User.fromJson(Map<String, dynamic> map) {
    return User(
      id: BigInt.tryParse(parseString(map['id'])) ?? BigInt.zero,
      citizenId: map['citizen_id'].toString(),
      name: map['name'].toString(),
      email: map['email'].toString(),
      phoneNumber: map['phone_number'].toString(),
      password: map['password'].toString(),
      roleId: BigInt.tryParse(parseString(map['role_id'])) ?? BigInt.zero,
      createdAt: DateTime.tryParse(parseString(map['created_at'])) ?? DateTime.now(),
      updatedAt: DateTime.tryParse(parseString(map['updated_at'])) ?? DateTime.now(),
    );
  }

  final String citizenId;
  final String name;
  final String email;
  final String phoneNumber;
  final String password;
  final BigInt roleId;

  /// Convert to a map
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id.toString(),
      'citizen_id': citizenId,
      'name': name,
      'phone_number': phoneNumber,
      'password': password,
      'role_id': roleId.toString(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'User(id: $id, citizenId: $citizenId, '
        'name: $name, email: $email, phoneNumber: $phoneNumber, '
        'password: $password, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// User Request
class UserDTO {
  /// Create a new user request
  const UserDTO({
    this.citizenId,
    this.name,
    this.email,
    this.phoneNumber,
    this.password,
    this.roleId,
  });

  /// Convert to a map from a json string
  factory UserDTO.fromMap(Map<String, dynamic> map) {
    return UserDTO(
      citizenId: map['citizen_id']?.toString(),
      name: map['name']?.toString(),
      email: map['email']?.toString(),
      phoneNumber: map['phone_number']?.toString(),
      password: map['password']?.toString(),
      roleId: BigInt.tryParse(parseString(map['role_id'])),
    );
  }

  /// Convert to a user request from a json string
  factory UserDTO.fromJson(String json) {
    return UserDTO.fromMap(
      jsonDecode(json) as Map<String, dynamic>,
    );
  }

  final String? citizenId;
  final String? name;
  final String? email;
  final String? phoneNumber;
  final String? password;
  final BigInt? roleId;

  /// Convert to a map
  Map<String, dynamic> toMap() {
    return {
      'citizen_id': citizenId,
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
      'password': password,
    };
  }

  /// Convert to a json string
  String toJson() => jsonEncode(toMap());

  /// Convert to a user
  User toUser() {
    return User(
      id: BigInt.zero,
      citizenId: citizenId ?? '',
      name: name ?? '',
      email: email ?? '',
      phoneNumber: phoneNumber ?? '',
      password: password ?? '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      roleId: roleId ?? BigInt.zero,
    );
  }

  @override
  String toString() {
    return 'UserRequest(citizenId: $citizenId, name: $name, '
        'email: $email, phoneNumber: $phoneNumber, password: $password)';
  }
}
