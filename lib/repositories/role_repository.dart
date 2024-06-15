import 'dart:convert';

import 'package:sena_inventory_backend/entity.dart';
import 'package:sena_inventory_backend/repository.dart';
import 'package:sena_inventory_backend/utils.dart';

/// Role repository
class RoleRepository extends Repository<Role> {
  /// Create a new role repository
  const RoleRepository(super.pool);

  /// Create a new role
  Future<void> createRole(RoleDTO roleRequest) async {
    await pool.execute(
      'INSERT INTO roles (name) VALUES (:name)',
      {'name': roleRequest.name},
    );
  }

  /// Get all roles
  Future<List<Role>> getRoles() async {
    final result = await pool.execute(
      'SELECT id, name, created_at, updated_at FROM roles',
    );
    return result.rows.map((row) {
      return Role.fromMap(row.assoc());
    }).toList();
  }

  /// Get a role by id
  Future<Role?> getRole(BigInt id) async {
    final result = await pool.execute(
      'SELECT id, name, created_at, updated_at '
      'FROM roles WHERE id = :id',
      {'id': id},
    );
    if (result.rows.isEmpty) return null;

    return Role.fromMap(result.rows.first.assoc());
  }

  /// Delete a role by id
  Future<void> deleteRole(BigInt id) async {
    await pool.execute(
      'DELETE FROM roles WHERE id = :id',
      {'id': id},
    );
  }

  /// Update a role by id
  Future<bool> updateRole(RoleDTO roleRequest, BigInt id) async {
    final savedRole = await getRole(id);
    if (savedRole == null) {
      return false;
    }
    await pool.execute(
      'UPDATE roles SET name = :name WHERE id = :id',
      {'id': savedRole.id, 'name': roleRequest.name},
    );

    return true;
  }
}

/// Role entity
class Role extends Entity {
  /// Create a new role entity
  const Role({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.name,
  });

  /// Create a new role entity from a map
  factory Role.fromMap(Map<String, dynamic> map) {
    final id = BigInt.tryParse(parseString(map['id']));
    final createdAt = DateTime.tryParse(parseString(map['created_at']));
    final updatedAt = DateTime.tryParse(parseString(map['updated_at']));

    return Role(
      id: id ?? BigInt.zero,
      name: map['name'] as String,
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// Create a new role entity from a json string
  factory Role.fromJson(String json) {
    return Role.fromMap(
      jsonDecode(json) as Map<String, dynamic>,
    );
  }

  final String name;

  /// Convert to a map
  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id.toString(),
      'name': name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Convert to a json string
  @override
  String toJson() => jsonEncode(toMap());

  /// Convert to a role request
  RoleDTO toRoleDTO() {
    return RoleDTO(
      name: name,
    );
  }

  @override
  String toString() {
    return 'Role(id: $id, name: $name, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// Role Request
class RoleDTO {
  /// Create a new role request
  const RoleDTO({
    this.name,
  });

  /// Convert to a map from a json string
  factory RoleDTO.fromMap(Map<String, dynamic> map) {
    return RoleDTO(
      name: map['name']?.toString(),
    );
  }

  /// Convert to a role request from a json string
  factory RoleDTO.fromJson(String json) {
    return RoleDTO.fromMap(
      jsonDecode(json) as Map<String, dynamic>,
    );
  }

  final String? name;

  /// Convert to a map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
    };
  }

  /// Convert to a json string
  String toJson() => jsonEncode(toMap());

  /// Convert to a role
  Role toRole() {
    return Role(
      id: BigInt.zero,
      name: name ?? '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'RoleRequest(name: $name)';
  }
}