import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:bcrypt/bcrypt.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:dotenv/dotenv.dart';
import 'package:sena_inventory_backend/lib.dart';

Future<Response> onRequest(RequestContext context) async {
  return switch (context.request.method) {
    HttpMethod.post => await _onPost(context),
    _ => Response(statusCode: HttpStatus.methodNotAllowed),
  };
}

Future<Response> _onPost(RequestContext context) async {
  final body = await context.request.json() as Map<String, dynamic>;
  if (body['email'] == null || body['password'] == null) {
    return Response(statusCode: HttpStatus.badRequest);
  }

  final userRepository = context.read<UserRepository>();
  final user = await userRepository.getUserByEmail(body['email'].toString());

  if (user == null) return Response(statusCode: HttpStatus.unauthorized);

  final isValid = BCrypt.checkpw(body['password'].toString(), user.password);
  if (!isValid) return Response(statusCode: HttpStatus.unauthorized);

  final jwt = JWT({'email': body['email']});
  final env = DotEnv(includePlatformEnvironment: true)..load();
  final expDuration = Duration(seconds: int.tryParse(env['JWT_EXPIRES_IN'] ?? '') ?? 3600);

  final token = jwt.sign(SecretKey(env['SECRET_JWT_KEY'] ?? ''), expiresIn: expDuration);
  final date = DateTime.now().add(expDuration).toUtc();
  final formattedDate =
      '${kDays[date.weekday - 1]}, ${_addPadding(date.day)} ${kMonths[date.month - 1]} ${date.year} ${_addPadding(date.hour)}:${_addPadding(date.minute)}:${_addPadding(date.second)} GMT';
  return Response(
    body: jsonEncode(token),
    headers: {
      HttpHeaders.setCookieHeader: 'token=$token; '
          'Expires=$formattedDate;'
          ' HttpOnly=true; SameSite=Strict; secure=true; path=/',
    },
  );
}

String _addPadding(int value) {
  return value.toString().padLeft(2, '0');
}
