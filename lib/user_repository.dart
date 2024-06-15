import 'dart:convert';
import 'package:sena_inventory_backend/entity.dart';
import 'package:sena_inventory_backend/repository.dart';

/// User repository
class UserRepository extends Repository<User> {
  /// Create a new user repository
  const UserRepository(super.pool);

  /// Create a new user
  Future<void> createUser(User user) async {
    await pool.execute(
      'INSERT INTO user (citizen_id, name, phone_number, password) '
      'VALUES (:citizen_id, :name, :phone_number, :password)',
      {
        'id': user.id,
        'citizen_id': user.citizenId,
        'name': user.name,
        'phone_number': user.phoneNumber,
        'password': user.password,
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
  Future<User> getUser(int id) async {
    final result = await pool.execute('SELECT id, citizen_id, name, phone_number, password, created_at, updated_at FROM user WHERE id = :id', {
      'id': id,
    });
    return User.fromMap(result.rows.first.assoc());
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
    return User(
      id: BigInt.tryParse(map['id'] == null ? '' : map['id'] as String),
      citizenId: map['citizen_id'].toString(),
      name: map['name'] as String,
      phoneNumber: map['phone_number'].toString(),
      password: map['phone_number'].toString(),
      createdAt: DateTime.tryParse(
        map['created_at'] == null ? '' : map['created_at'] as String,
      ),
      updatedAt: DateTime.tryParse(
        map['updated_at'] == null ? '' : map['updated_at'] as String,
      ),
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
      'id': id?.toInt(),
      'citizen_id': citizenId,
      'name': name,
      'phone_number': phoneNumber,
      'password': password,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Convert to a json string
  String toJson() => jsonEncode(toMap());

  @override
  String toString() {
    return 'User(id: $id, citizenId: $citizenId, '
        'name: $name, phoneNumber: $phoneNumber, '
        'password: $password, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
