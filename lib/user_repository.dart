import 'dart:convert';
import 'package:sena_inventory_backend/entity.dart';
import 'package:sena_inventory_backend/repositories/role_repository.dart';
import 'package:sena_inventory_backend/repository.dart';
import 'package:sena_inventory_backend/utils.dart';

/// User repository
class UserRepository extends Repository<User> {
  /// Create a new user repository
  UserRepository(super.pool) : roleRepository = RoleRepository(pool);

  final RoleRepository roleRepository;

  /// Create a new user
  Future<void> createUser(UserDTO userRequest) async {
    await pool.execute(
      'INSERT INTO users (citizen_id, name, email, phone_number, password) '
      'VALUES (:citizen_id, :name, :phone_number, :password)',
      {
        'citizen_id': userRequest.citizenId,
        'name': userRequest.name,
        'email': userRequest.email,
        'phone_number': userRequest.phoneNumber,
        'password': userRequest.password,
        'role_id': userRequest.roleId.toString(),
      },
    );
  }

  /// Get all users
  Future<List<User>> getUsers() async {
    final result = await pool.execute('SELECT id, citizen_id, name, '
        'email, phone_number, password, role_id, created_at, updated_at FROM users');
    return result.rows.map((row) {
      return User.fromMap(row.assoc());
    }).toList();
  }

  /// Get a user by id
  Future<User?> getUser(BigInt id) async {
    final result = await pool.execute(
        'SELECT id, citizen_id, name, '
        'email, phone_number, password, created_at, '
        'updated_at FROM users WHERE id = :id',
        {
          'id': id,
        });
    if (result.rows.isEmpty) return null;

    return User.fromMap(result.rows.first.assoc());
  }

  /// Delete a user by id
  Future<void> deleteUser(BigInt id) async {
    await pool.execute('DELETE FROM users WHERE id = :id', {
      'id': id,
    });
  }

  /// Update a user by id
  Future<bool> updateUser(UserDTO userRequest, BigInt id) async {
    final savedUser = await getUser(id);
    if (savedUser == null) {
      return false;
    }
    await pool.execute(
      'UPDATE users SET citizen_id = :citizen_id, name = :name, email = :email, '
      'phone_number = :phone_number, password = :password WHERE id = :id',
      {
        'id': savedUser.id,
        'citizen_id': userRequest.citizenId ?? savedUser.citizenId,
        'name': userRequest.name ?? savedUser.name,
        'email': userRequest.email ?? savedUser.email,
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
    required this.email,
    required this.phoneNumber,
    required this.password,
    required this.roleId,
  });

  /// Create a new user entity from a map
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: BigInt.tryParse(parseString(map['id'])) ?? BigInt.zero,
      citizenId: map['citizen_id'].toString(),
      name: map['name'] as String,
      email: map['email'] as String,
      phoneNumber: map['phone_number'].toString(),
      password: map['phone_number'].toString(),
      roleId: BigInt.tryParse(parseString(map['role_id'])) ?? BigInt.zero,
      createdAt: DateTime.tryParse(parseString(map['created_at'])) ?? DateTime.now(),
      updatedAt: DateTime.tryParse(parseString(map['updated_at'])) ?? DateTime.now(),
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
  final String email;
  final String phoneNumber;
  final String password;
  final BigInt roleId;

  /// Convert to a map
  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id.toString(),
      'citizen_id': citizenId,
      'name': name,
      'phone_number': phoneNumber,
      'password': password,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Convert to a json string
  @override
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
