import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:sena_inventory_backend/lib.dart';

Future<Response> onRequest(RequestContext context) async {
  return switch (context.request.method) {
    HttpMethod.get => await _onGet(context),
    HttpMethod.post => await _onPost(context),
    _ => Response(statusCode: HttpStatus.methodNotAllowed),
  };
}

Future<Response> _onGet(RequestContext context) async {
  return renderTemplate('test_form');
}

Future<Response> _onPost(RequestContext context) async {
  final body = await context.request.body();
  final formData = parseFormData(body);
  print(formData);
  return redirect('/');
}
