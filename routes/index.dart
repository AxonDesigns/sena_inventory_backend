import 'dart:convert';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:mysql_client/mysql_client.dart';

Future<Response> onRequest(RequestContext context) async {
  return switch (context.request.method) {
    HttpMethod.get => await onGet(context),
    HttpMethod.post => await onPost(context),
    _ => Response(statusCode: HttpStatus.badRequest),
  };
}

Future<Response> onGet(RequestContext context) async {
  final connection = context.read<MySQLConnectionPool>();
  final result = await connection.execute('SELECT * FROM user');
  final rows = result.rows.map((row) => row.assoc()).toList();
  for (final row in rows) {
    print(row);
  }
  await connection.close();
  return Response(statusCode: HttpStatus.ok, body: rows.toString());
}

Future<Response> onPost(RequestContext context) async {
  final json = jsonDecode(await context.request.body());
  print(json);
  return Response(statusCode: HttpStatus.created, body: 'POSTING');
}
