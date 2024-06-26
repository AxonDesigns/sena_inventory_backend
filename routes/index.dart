import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:sena_inventory_backend/lib.dart';

Future<Response> onRequest(RequestContext context) async {
  return switch (context.request.method) {
    HttpMethod.get => await _onGet(context),
    _ => Response(statusCode: HttpStatus.methodNotAllowed),
  };
}

Future<Response> _onGet(RequestContext context) async {
  final user = context.tryRead<User>();
  if (user == null) return redirect('/login');

  return renderTemplate(
    'dashboard',
    values: {'name': user.name},
  );
}
