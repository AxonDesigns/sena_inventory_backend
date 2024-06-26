import 'dart:convert';
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
  final query = parseQuery(context.request.uri.queryParameters);
  final roleRepository = context.read<RoleRepository>();
  final roles = await roleRepository.getRoles(query.limit, query.offset);
  final json = roles.map((role) => role.toJson()).toList();

  return Response(body: jsonEncode(json));
}
