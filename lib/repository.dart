import 'package:mysql_client/mysql_client.dart';
import 'package:sena_inventory_backend/entity.dart';

/// Repository
class Repository<T extends Entity> {
  /// Create a new repository
  const Repository(this.pool);

  /// database pool
  final MySQLConnectionPool pool;

  /// Get last inserted id
  Future<int?> getLastInsertId() async {
    final result = await pool.execute('SELECT LAST_INSERT_ID()');
    return int.tryParse(result.rows.first.assoc()['LAST_INSERT_ID()'] ?? '');
  }
}
