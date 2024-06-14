import 'package:dart_frog/dart_frog.dart';
import 'package:dotenv/dotenv.dart';
import 'package:mysql1/mysql1.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart' as shelf;

Handler middleware(Handler handler) {
  final env = DotEnv(includePlatformEnvironment: true)..load();
  final settings = ConnectionSettings(
    host: env['DB_HOST'] ?? 'localhost',
    port: int.parse(env['DB_PORT'] ?? '3306'),
    user: env['DB_USER'] ?? 'root',
    password: env['DB_PASSWORD'] ?? '14172003',
    db: env['DB_NAME'] ?? 'mercado',
  );

  return handler
      .use(requestLogger())
      .use(
        fromShelfMiddleware(
          shelf.corsHeaders(
            headers: {
              shelf.ACCESS_CONTROL_ALLOW_ORIGIN: '*',
            },
          ),
        ),
      )
      .use(
        provider<Future<MySqlConnection>>(
          (context) async => MySqlConnection.connect(settings),
        ),
      );
}
