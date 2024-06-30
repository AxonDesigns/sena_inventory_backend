import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:sena_inventory_backend/lib.dart';

Future<Response> onRequest(RequestContext context) async {
  final user = context.tryRead<User>();

  if (user != null) return redirect('/');
  return switch (context.request.method) {
    HttpMethod.get => await renderTemplate(
        'login',
      ),
    _ => Response(statusCode: HttpStatus.methodNotAllowed),
  };
}
