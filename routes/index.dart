import 'package:dart_frog/dart_frog.dart';
import 'package:sena_inventory_backend/lib.dart';

Future<Response> onRequest(RequestContext context) async {
  final token = getTokenFromCookies(context);
  if (token == null || !verifyToken(token)) return redirect('/login');

  return render('dashboard');
}
