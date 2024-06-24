import 'package:sena_inventory_backend/models/models.dart';
import 'package:sena_inventory_backend/repositories/role_repository.dart';
import 'package:sena_inventory_backend/repository.dart';

/// User repository
class UserRepository extends Repository<User> {
  /// Create a new user repository
  UserRepository(super.pool) : roleRepository = RoleRepository(pool);

  final RoleRepository roleRepository;

  /// Create a new user
  Future<bool> createUser(UserDTO userRequest) async {
    if (userRequest.email == null ||
        userRequest.password == null ||
        userRequest.name == null ||
        userRequest.phoneNumber == null ||
        userRequest.roleId == null ||
        userRequest.citizenId == null) {
      return false;
    }

    await pool.execute(
      'INSERT INTO users (citizen_id, name, email, phone_number, password, role_id) '
      'VALUES (:citizen_id, :name, :email, :phone_number, :password, :role_id)',
      {
        'citizen_id': userRequest.citizenId,
        'name': userRequest.name,
        'email': userRequest.email,
        'phone_number': userRequest.phoneNumber,
        'password': userRequest.password,
        'role_id': userRequest.roleId.toString(),
      },
    );

    return true;
  }

  /// Get all users
  Future<List<User>> getUsers(int limit, int offset) async {
    final result = await pool.execute(
      'SELECT id, citizen_id, name, '
      'email, phone_number, password, role_id, created_at, updated_at FROM users '
      'LIMIT :limit OFFSET :offset;',
      {'limit': limit, 'offset': offset},
    );
    return result.rows.map((row) {
      return User.fromJson(row.assoc());
    }).toList();
  }

  /// Get a user by id
  Future<User?> getUser(BigInt id) async {
    final result = await pool.execute(
      'SELECT id, citizen_id, name, '
      'email, phone_number, password, role_id, created_at, '
      'updated_at FROM users WHERE id = :id;',
      {'id': id},
    );
    if (result.rows.isEmpty) return null;

    return User.fromJson(result.rows.first.assoc());
  }

  /// Get a user by email and password
  Future<User?> getUserByEmail(String email) async {
    final result = await pool.execute(
      'SELECT id, citizen_id, name, '
      'email, phone_number, password, role_id, created_at, '
      'updated_at FROM users WHERE email = :email '
      'LIMIT 1;',
      {'email': email},
    );

    if (result.rows.isEmpty) return null;

    return User.fromJson(result.rows.first.assoc());
  }

  /// Delete a user by id
  Future<void> deleteUser(BigInt id) async {
    await pool.execute(
      'DELETE FROM users WHERE id = :id',
      {'id': id},
    );
  }

  /// Update a user by id
  Future<bool> updateUser(UserDTO userRequest, BigInt id) async {
    final savedUser = await getUser(id);
    if (savedUser == null) {
      return false;
    }
    await pool.execute(
      'UPDATE users SET citizen_id = :citizen_id, name = :name, email = :email, '
      'phone_number = :phone_number, password = :password, role_id = :role_id WHERE id = :id',
      {
        'id': savedUser.id,
        'citizen_id': userRequest.citizenId ?? savedUser.citizenId,
        'name': userRequest.name ?? savedUser.name,
        'email': userRequest.email ?? savedUser.email,
        'phone_number': userRequest.phoneNumber ?? savedUser.phoneNumber,
        'password': userRequest.password ?? savedUser.password,
        'role_id': userRequest.roleId ?? savedUser.roleId,
      },
    );

    return true;
  }
}
