import 'dart:io';
import 'package:bcrypt/bcrypt.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:sena_inventory_backend/lib.dart';

Future<Response> onRequest(RequestContext context) async {
  return switch (context.request.method) {
    HttpMethod.post => await _onPost(context),
    _ => Response(statusCode: HttpStatus.methodNotAllowed),
  };
}

Future<Response> _onPost(RequestContext context) async {
  final body = await context.request.body();
  final formData = parseFormData(body);

  final userRepository = context.read<UserRepository>();
  final user = await userRepository.getUserByEmail(formData['email'].toString());
  if (user != null) {
    return Response(
      statusCode: HttpStatus.unauthorized,
      body: 'User already exists',
    );
  }

  formData['password'] = BCrypt.hashpw(formData['password'].toString(), BCrypt.gensalt());
  final success = await userRepository.createUser(UserDTO.fromJson(formData));
  if (!success) {
    return Response(statusCode: HttpStatus.badRequest, body: 'User creation failed');
  }

  return redirect('/login');
}
