import 'package:dart_frog/dart_frog.dart';
import 'package:mysql1/mysql1.dart';

Future<Response> onRequest(RequestContext context) async {
  final connection = await context.read<Future<MySqlConnection>>();
  final result = await connection.query('SELECT * FROM user');
  print(result);

  /* for (final row in result) {
    print(row);
    row.fields.forEach(
      (key, value) => print('${key}: ${value}'),
    );
  } */
  await connection.close();
  return Response(body: 'Welcome to Dart Frog!');
}
