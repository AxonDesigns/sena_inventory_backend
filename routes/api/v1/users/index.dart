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
  final users = await userRepository.getUsers(query.limit, query.offset);

  /*final json = await Future.wait(
    users.map((user) async {
      final userJson = user.toJson()..remove('password');
      return parseExpand(context, query.expand, userJson);
    }),
  );*/

  final json = users.map((user) => user.toJson()).toList();

  return Response(body: jsonEncode(json));
}

Future<Response> _onPost(RequestContext context) async {
  print(await context.request.json() as Json);
  final user = UserDTO.fromJson(await context.request.json() as Json);
  final userRepository = context.read<UserRepository>();
  await userRepository.createUser(user);

  final createdId = await userRepository.getLastInsertId();
  if (createdId == null) {
    return Response(
      statusCode: HttpStatus.internalServerError,
      body: 'Error creating user',
    );
  }
  print(createdId);
  final createdUser = await userRepository.getUser(createdId);
  if (createdUser == null) {
    return Response(
      statusCode: HttpStatus.notFound,
      body: 'User not found',
    );
  }
  return Response(
    statusCode: HttpStatus.created,
    body: jsonEncode(createdUser.toJson()),
  );
}
