import 'package:dart_frog/dart_frog.dart';
import 'package:dotenv/dotenv.dart';
import 'package:mysql_client/mysql_client.dart';
import 'package:sena_inventory_backend/lib.dart';
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

  final userRepository = UserRepository(pool);

  return handler
      .use(requestLogger())
      .use(
        fromShelfMiddleware(
          shelf.corsHeaders(headers: {shelf.ACCESS_CONTROL_ALLOW_ORIGIN: '*'}),
        ),
      )
      .use(provider<DotEnv>((context) => env))
      .use(provider<UserRepository>((context) => userRepository))
      .use(provider<RoleRepository>((context) => RoleRepository(pool)))
      .use(
    authentication(
      authenticator: (context, token) {
        return userRepository.getUserByAccessToken(token);
      },
    ),
  );
}
