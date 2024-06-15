import 'package:dart_frog/dart_frog.dart';
import 'package:dotenv/dotenv.dart';
import 'package:mysql_client/mysql_client.dart';
import 'package:sena_inventory_backend/repositories/role_repository.dart';
import 'package:sena_inventory_backend/user_repository.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart' as shelf;

Handler middleware(Handler handler) {
  final env = DotEnv(includePlatformEnvironment: true)..load();

  final pool = MySQLConnectionPool(
    host: env['DB_HOST'] ?? 'localhost',
    port: int.parse(env['DB_PORT'] ?? '3306'),
    userName: env['DB_USER'] ?? 'root',
    password: env['DB_PASSWORD'] ?? '',
    maxConnections: 10,
    databaseName: env['DB_NAME'],
  );

  return handler
      .use(requestLogger())
      .use(
        fromShelfMiddleware(
          shelf.corsHeaders(headers: {shelf.ACCESS_CONTROL_ALLOW_ORIGIN: '*'}),
        ),
      )
      .use(
        provider<UserRepository>((context) => UserRepository(pool)),
      )
      .use(
        provider<RoleRepository>((context) => RoleRepository(pool)),
      );
}
