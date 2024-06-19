import 'package:dart_frog/dart_frog.dart';
import 'package:sena_inventory_backend/lib.dart';

Future<Response> onRequest(RequestContext context) async {
  if (!isAuthenticated(context)) return redirect('/login');

  return render('dashboard');
}
