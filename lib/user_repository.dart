import 'dart:convert';
import 'package:sena_inventory_backend/entity.dart';
import 'package:sena_inventory_backend/repository.dart';

/// User repository
class UserRepository extends Repository<User> {
  /// Create a new user repository
  const UserRepository(super.pool);

  /// Create a new user
  Future<void> createUser(UserDTO userRequest) async {
    await pool.execute(
      'INSERT INTO user (citizen_id, name, phone_number, password) '
      'VALUES (:citizen_id, :name, :phone_number, :password)',
      {
        'citizen_id': userRequest.citizenId,
        'name': userRequest.name,
        'phone_number': userRequest.phoneNumber,
        'password': userRequest.password,
      },
    );
  }

  /// Get all users
  Future<List<User>> getUsers() async {
    final result = await pool.execute('SELECT id, citizen_id, name, phone_number, password, created_at, updated_at FROM user');
    return result.rows.map((row) {
      return User.fromMap(row.assoc());
    }).toList();
  }

  /// Get a user by id
  Future<User?> getUser(int id) async {
    final result = await pool.execute('SELECT id, citizen_id, name, phone_number, password, created_at, updated_at FROM user WHERE id = :id', {
      'id': id,
    });
    if (result.rows.isEmpty) return null;

    return User.fromMap(result.rows.first.assoc());
  }

  /// Delete a user by id
  Future<void> deleteUser(int id) async {
    await pool.execute('DELETE FROM user WHERE id = :id', {
      'id': id,
    });
  }

  /// Update a user by id
  Future<bool> updateUser(UserDTO userRequest, int id) async {
    final savedUser = await getUser(id);
    if (savedUser == null) {
      return false;
    }
    await pool.execute(
      'UPDATE user SET citizen_id = :citizen_id, name = :name, '
      'phone_number = :phone_number, password = :password WHERE id = :id',
      {
        'id': savedUser.id,
        'citizen_id': userRequest.citizenId ?? savedUser.citizenId,
        'name': userRequest.name ?? savedUser.name,
        'phone_number': userRequest.phoneNumber ?? savedUser.phoneNumber,
        'password': userRequest.password ?? savedUser.password,
      },
    );

    return true;
  }
}

/// User entity
class User extends Entity {
  /// Create a new user entity
  const User({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.citizenId,
    required this.name,
    required this.phoneNumber,
    required this.password,
  });

  /// Create a new user entity from a map
  factory User.fromMap(Map<String, dynamic> map) {
    final id = BigInt.tryParse(map['id'] == null ? '' : map['id'] as String);
    final createdAt = DateTime.tryParse(
      map['created_at'] == null ? '' : map['created_at'] as String,
    );
    final updatedAt = DateTime.tryParse(
      map['updated_at'] == null ? '' : map['updated_at'] as String,
    );
    return User(
      id: id ?? BigInt.zero,
      citizenId: map['citizen_id'].toString(),
      name: map['name'] as String,
      phoneNumber: map['phone_number'].toString(),
      password: map['phone_number'].toString(),
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// Create a new user entity from a json string
  factory User.fromJson(String json) {
    return User.fromMap(
      jsonDecode(json) as Map<String, dynamic>,
    );
  }

  final String citizenId;
  final String name;
  final String phoneNumber;
  final String password;

  /// Convert to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id.toInt(),
      'citizen_id': citizenId,
      'name': name,
      'phone_number': phoneNumber,
      'password': password,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Convert to a json string
  String toJson() => jsonEncode(toMap());

  //TODO: Might be useless
  /// Convert to a user request
  UserDTO toUserDTO() {
    return UserDTO(
      citizenId: citizenId,
      name: name,
      phoneNumber: phoneNumber,
      password: password,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, citizenId: $citizenId, '
        'name: $name, phoneNumber: $phoneNumber, '
        'password: $password, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// User Request

class UserDTO {
  /// Create a new user request
  const UserDTO({
    this.citizenId,
    this.name,
    this.phoneNumber,
    this.password,
  });

  /// Convert to a map from a json string
  factory UserDTO.fromMap(Map<String, dynamic> map) {
    return UserDTO(
      citizenId: map['citizen_id']?.toString(),
      name: map['name']?.toString(),
      phoneNumber: map['phone_number']?.toString(),
      password: map['password']?.toString(),
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
  final String? phoneNumber;
  final String? password;

  /// Convert to a map
  Map<String, dynamic> toMap() {
    return {
      'citizen_id': citizenId,
      'name': name,
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
      phoneNumber: phoneNumber ?? '',
      password: password ?? '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'UserRequest(citizenId: $citizenId, name: $name, phoneNumber: $phoneNumber, password: $password)';
  }
}
