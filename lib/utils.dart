import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:path/path.dart' as path;

String parseString(dynamic value) {
  return value == null ? '' : value.toString();
}

({int limit, int offset, List<String> expand}) parseQuery(Map<String, dynamic> query) {
  final limit = int.tryParse(parseString(query['limit'])) ?? 10;
  final offset = int.tryParse(parseString(query['offset'])) ?? 0;
  final expandList = parseString(query['expand']).split(',').toList();

  return (limit: limit, offset: offset, expand: expandList);
}

/// Render a HTML template
Future<Response> render(String templateName) async {
  final file = File(
    path.join(Directory.current.path, 'templates', '$templateName.html'),
  );

  if (!file.existsSync()) return Response(body: 'Template not found');

  return Response(
    body: await file.readAsString(),
    headers: {
      HttpHeaders.contentTypeHeader: ContentType.html.value,
    },
  );
}

/// Redirect to a new url
Future<Response> redirect(String url) async {
  return Response(
    statusCode: HttpStatus.found,
    headers: {
      HttpHeaders.locationHeader: url,
    },
  );
}
