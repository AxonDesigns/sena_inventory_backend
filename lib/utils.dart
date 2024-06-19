import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:dotenv/dotenv.dart';
import 'package:path/path.dart' as path;
import 'package:sena_inventory_backend/lib.dart';

String parseString(dynamic value) {
  return value == null ? '' : value.toString();
}

/// Parse query string
({int limit, int offset, List<String> expand}) parseQuery(Map<String, dynamic> query) {
  final limit = int.tryParse(parseString(query['limit'])) ?? 10;
  final offset = int.tryParse(parseString(query['offset'])) ?? 0;
  final expandList = parseString(query['expand']).split(',').toList();

  return (limit: limit, offset: offset, expand: expandList);
}

/// Render a HTML template
Future<Response> render(
  String templateName, {
  int statusCode = HttpStatus.found,
  Map<String, String> headers = const {},
}) async {
  final file = File(
    path.join(Directory.current.path, 'templates', '$templateName.html'),
  );

  if (!file.existsSync()) return Response(body: 'Template not found');
  final template = await file.readAsString();

  return Response(
    body: template,
    statusCode: HttpStatus.found,
    headers: {
      HttpHeaders.contentTypeHeader: ContentType.html.value,
      ...headers,
    },
  );
}

/// Redirect to a new url
Future<Response> redirect(
  String url, {
  int statusCode = HttpStatus.found,
  Map<String, String> headers = const {},
  String? body,
}) async {
  return Response(
    statusCode: HttpStatus.found,
    body: body,
    headers: {HttpHeaders.locationHeader: url, ...headers},
  );
}

/// Get token from cookie
String? getTokenFromCookies(RequestContext context) {
  final cookies = context.request.headers['cookie']?.split(';') ?? [];
  try {
    return cookies
        .firstWhere(
          (element) => element.startsWith('$kTokenKey='),
        )
        .split('=')[1];
  } catch (e) {
    return null;
  }
}

/// Verify token
JWT? verifyToken(String token) {
  try {
    final env = DotEnv(includePlatformEnvironment: true)..load();
    return JWT.verify(token, SecretKey(env['SECRET_JWT_KEY'] ?? ''));
  } catch (e) {
    return null;
  }
}

/// Is user authenticated?
bool isAuthenticated(RequestContext context) {
  final token = getTokenFromCookies(context);
  if (token == null) return false;

  return verifyToken(token) != null;
}

String get invalidateToken {
  return '$kTokenKey=; Expires=Thu, 01 Jan 1970 00:00:00 GMT; HttpOnly=true; SameSite=Strict; secure=true; path=/';
}
