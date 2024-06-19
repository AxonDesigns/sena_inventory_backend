import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:sena_inventory_backend/lib.dart';

Future<Response> onRequest(RequestContext context) async {
  return switch (context.request.method) {
    HttpMethod.post => Response(
        headers: {
          HttpHeaders.setCookieHeader: invalidateToken,
        },
      ),
    _ => Response(statusCode: HttpStatus.methodNotAllowed),
  };
}
