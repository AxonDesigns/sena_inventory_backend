import 'package:sena_inventory_backend/entity.dart';
import 'package:sena_inventory_backend/lib.dart';

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
  factory Role.fromJson(Json map) {
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

  /// Role's name
  final String name;

  /// Convert to a map
  @override
  Json toJson() {
    return {
      'id': id.toString(),
      'name': name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Convert to a role request
  RoleDTO toRoleDTO() {
    return RoleDTO(
      name: name,
    );
  }

  @override
  String toString() {
    return 'Role(id: $id, name: $name, '
        'createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// Role Request
class RoleDTO {
  /// Create a new role request
  const RoleDTO({
    this.name,
  });

  /// Convert to a map from a json string
  factory RoleDTO.fromMap(Json map) {
    return RoleDTO(
      name: map['name']?.toString(),
    );
  }

  /// Role's name
  final String? name;

  /// Convert to a map
  Json toMap() {
    return {
      'name': name,
    };
  }

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
