import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:dotenv/dotenv.dart';
import 'package:sena_inventory_backend/lib.dart';
import 'package:sena_inventory_backend/repository.dart';

/// User repository
class UserRepository extends Repository<User> {
  /// Create a new user repository
  UserRepository(super.pool) : _roleRepository = RoleRepository(pool);

  final RoleRepository _roleRepository;

  final _allFields = [
    'id',
    'citizen_id',
    'name',
    'email',
    'phone_number',
    'password',
    'role_id',
    'created_at',
    'updated_at',
  ].join(', ');

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
      'SELECT '
      '$_allFields '
      'FROM users LIMIT :limit OFFSET :offset;',
      {'limit': limit, 'offset': offset},
    );
    return Future.wait(
      result.rows.map((row) async {
        final json = row.assoc().map((key, value) => MapEntry(key, value as dynamic));

        final replacedJson = await _replaceRoleIdWithRole(json);
        if (replacedJson == null) throw Exception('Error replacing role_id');

        return User.fromJson(replacedJson);
      }).toList(),
    );
  }

  /// Get a user by id
  Future<User?> getUser(BigInt id) async {
    final result = await pool.execute(
      'SELECT '
      '$_allFields '
      'FROM users WHERE id = :id;',
      {'id': id},
    );
    if (result.rows.isEmpty) return null;
    final json = result.rows.first.assoc().map((key, value) {
      return MapEntry(key, value as dynamic);
    });

    final replacedJson = await _replaceRoleIdWithRole(json);
    if (replacedJson == null) return null;

    return User.fromJson(replacedJson);
  }

  /// Get a user by email and password
  Future<User?> getUserByEmail(String email) async {
    final result = await pool.execute(
      'SELECT '
      '$_allFields '
      'FROM users WHERE email = :email '
      'LIMIT 1;',
      {'email': email},
    );

    if (result.rows.isEmpty) return null;
    final json = result.rows.first.assoc().map((key, value) => MapEntry(key, value as dynamic));

    final replacedJson = await _replaceRoleIdWithRole(json);
    if (replacedJson == null) return null;

    return User.fromJson(replacedJson);
  }

  Future<User?> getUserByAccessToken(String accessToken) async {
    final env = DotEnv(includePlatformEnvironment: true)..load();
    final JWT jwt;
    try {
      jwt = JWT.verify(accessToken, SecretKey(env['SECRET_JWT_KEY'] ?? ''));
    } catch (e) {
      return null;
    }

    final user = await getUserByEmail(jwt.payload['email'].toString());
    return user;
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
        'role_id': userRequest.roleId ?? savedUser.role.id,
      },
    );

    return true;
  }

  Future<Json?> _replaceRoleIdWithRole(Json json) async {
    final roleId = BigInt.tryParse(json['role_id'].toString());
    if (roleId == null) return null;
    final role = await _roleRepository.getRole(roleId);
    if (role == null) return null;
    json.remove('role_id');
    json['role'] = role.toJson();
    return json;
  }
}
