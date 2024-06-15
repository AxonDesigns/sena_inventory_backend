import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:sena_inventory_backend/user_repository.dart';

Future<Response> onRequest(RequestContext context) async {
  return switch (context.request.method) {
    HttpMethod.get => await onGet(context),
    HttpMethod.post => await onPost(context),
    _ => Response(statusCode: HttpStatus.badRequest),
  };
}

Future<Response> onGet(RequestContext context) async {
  final userRepository = context.read<UserRepository>();
  final users = await userRepository.getUsers();

  final result = users.map((user) => user.toJson()).toList();
  return Response(body: result.toString());
}

Future<Response> onPost(RequestContext context) async {
  final user = User.fromJson(await context.request.body());
  final userRepository = context.read<UserRepository>();
  await userRepository.createUser(user);

  final createdId = await userRepository.getLastInsertId();
  if (createdId == null) {
    return Response(statusCode: HttpStatus.internalServerError);
  }
  final createdUser = await userRepository.getUser(createdId);
  return Response(statusCode: HttpStatus.created, body: createdUser.toJson());
}
