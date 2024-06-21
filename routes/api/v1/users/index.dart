import 'dart:convert';
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
  final query = parseQuery(context.request.uri.queryParameters);
  final userRepository = context.read<UserRepository>();
  final users = await userRepository.getUsers();

  final result = await Future.wait(
    users.map((user) async {
      final userMap = user.toJson();
      if (query.expand.contains('role_id')) {
        final roleRepository = context.read<RoleRepository>();
        final role = await roleRepository.getRole(user.roleId);
        if (role != null) {
          userMap['role'] = role.toJson();
          userMap.remove('role_id');
        }
      }

      return userMap;
    }),
  );

  return Response(body: jsonEncode(result));
}

Future<Response> _onPost(RequestContext context) async {
  final user = UserDTO.fromMap(await context.request.json() as Map<String, dynamic>);
  final userRepository = context.read<UserRepository>();
  await userRepository.createUser(user);

  final createdId = await userRepository.getLastInsertId();
  if (createdId == null) {
    return Response(statusCode: HttpStatus.internalServerError, body: 'Error creating user');
  }
  final createdUser = await userRepository.getUser(createdId);
  if (createdUser == null) {
    return Response(statusCode: HttpStatus.notFound, body: 'User not found');
  }
  return Response(statusCode: HttpStatus.created, body: jsonEncode(createdUser.toJson()));
}

Future<Map<String, dynamic>> handleExpand(
  RequestContext context,
  Map<String, dynamic> map,
  List<String> expandList,
) async {
  return map;
}
