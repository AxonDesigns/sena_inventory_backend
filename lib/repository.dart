import 'package:mysql_client/mysql_client.dart';

/// Repository
class Repository<T> {
  const Repository(this.pool);

  final MySQLConnectionPool pool;

  /// Get last inserted id
  Future<int?> getLastInsertId() async {
    final result = await pool.execute('SELECT LAST_INSERT_ID()');
    print(result.rows.first.assoc()['LAST_INSERT_ID()'].runtimeType);
    return int.tryParse(result.rows.first.assoc()['LAST_INSERT_ID()'] ?? '');
  }
}
