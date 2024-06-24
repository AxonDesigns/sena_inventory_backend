import 'package:sena_inventory_backend/models/models.dart';
import 'package:sena_inventory_backend/repository.dart';

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
  Future<List<Role>> getRoles(int limit, int offset) async {
    final result = await pool.execute(
      'SELECT id, name, created_at, updated_at FROM roles '
      'LIMIT :limit OFFSET :offset;',
      {'limit': limit, 'offset': offset},
    );
    return result.rows.map((row) {
      return Role.fromJson(row.assoc());
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

    return Role.fromJson(result.rows.first.assoc());
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
