import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:sena_inventory_backend/user_repository.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  return switch (context.request.method) {
    HttpMethod.get => await _onGet(context, id),
    HttpMethod.delete => await _onDelete(context, id),
    HttpMethod.put => await _onPut(context, id),
    _ => Response(statusCode: HttpStatus.badRequest),
  };
}

Future<Response> _onGet(RequestContext context, String id) async {
  final userRepository = context.read<UserRepository>();
  final user = await userRepository.getUser(int.parse(id));
  if (user == null) {
    return Response(statusCode: HttpStatus.notFound);
  }
  return Response(body: user.toJson());
}

Future<Response> _onDelete(RequestContext context, String id) async {
  final userRepository = context.read<UserRepository>();
  await userRepository.deleteUser(int.parse(id));
  return Response();
}

Future<Response> _onPut(RequestContext context, String id) async {
  final userRepository = context.read<UserRepository>();
  final userRequest = UserDTO.fromJson(await context.request.body());
  await userRepository.updateUser(userRequest, int.parse(id));
  return Response();
}
