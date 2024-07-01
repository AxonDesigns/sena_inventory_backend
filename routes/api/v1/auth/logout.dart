import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:sena_inventory_backend/lib.dart';
import 'package:sena_inventory_backend/utils.dart';

Future<Response> onRequest(RequestContext context) async {
  if (!isAuthenticated(context)) return redirect('/login');
  return switch (context.request.method) {
    HttpMethod.post => await redirect(
        '/login',
        headers: {
          HttpHeaders.setCookieHeader: invalidateToken,
        },
      ),
    _ => Response(statusCode: HttpStatus.methodNotAllowed),
  };
}
