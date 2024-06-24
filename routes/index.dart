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
  if (!isAuthenticated(context)) return redirect('/login');
  final user = await getUserFromToken(context);
  return renderTemplate(
    'dashboard',
    values: {'name': user?.name ?? '<UNKNOWN>'},
  );
}
