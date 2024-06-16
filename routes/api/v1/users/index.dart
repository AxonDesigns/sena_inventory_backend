import 'dart:convert';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:sena_inventory_backend/repositories/role_repository.dart';
import 'package:sena_inventory_backend/user_repository.dart';
import 'package:sena_inventory_backend/utils.dart';

Future<Response> onRequest(RequestContext context) async {
  return switch (context.request.method) {
    HttpMethod.get => await _onGet(context),
    HttpMethod.post => await _onPost(context),
    _ => Response(statusCode: HttpStatus.badRequest),
  };
}

Future<Response> _onGet(RequestContext context) async {
  final query = _parseQuery(context.request.uri.queryParameters);
  final userRepository = context.read<UserRepository>();
  final users = await userRepository.getUsers();

  final result = await Future.wait(
    users.map((user) async {
      final userMap = user.toMap();
      if (query.expand.contains('role_id')) {
        final roleRepository = context.read<RoleRepository>();
        final role = await roleRepository.getRole(user.roleId);
        if (role != null) {
          userMap['role'] = role.toMap();
          userMap.remove('role_id');
        }
      }

      return userMap;
    }),
  );

  return Response(body: jsonEncode(result));
}

Future<Response> _onPost(RequestContext context) async {
  final user = UserDTO.fromJson(await context.request.body());
  final userRepository = context.read<UserRepository>();
  await userRepository.createUser(user);

  final createdId = await userRepository.getLastInsertId();
  print(createdId);
  if (createdId == null) {
    return Response(statusCode: HttpStatus.internalServerError, body: 'Error creating user');
  }
  final createdUser = await userRepository.getUser(createdId);
  print(createdUser);
  if (createdUser == null) {
    return Response(statusCode: HttpStatus.internalServerError, body: 'User not found');
  }
  return Response(statusCode: HttpStatus.created, body: createdUser.toJson());
}

({int limit, int offset, List<String> expand}) _parseQuery(Map<String, dynamic> query) {
  final limit = int.tryParse(parseString(query['limit'])) ?? 10;
  final offset = int.tryParse(parseString(query['offset'])) ?? 0;
  final expandList = parseString(query['expand']).split(',').toList();

  return (limit: limit, offset: offset, expand: expandList);
}
