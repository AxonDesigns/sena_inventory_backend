import 'package:dart_frog/dart_frog.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:dotenv/dotenv.dart';
import 'package:sena_inventory_backend/lib.dart';

Future<Response> onRequest(RequestContext context) async {
  final cookies = context.request.headers['cookie']?.split(';') ?? [];
  String? token;
  try {
    token = cookies.firstWhere((element) => element.startsWith('token=')).split('=')[1];
  } catch (e) {
    return redirect('/_/login.html');
  }

  final env = DotEnv(includePlatformEnvironment: true)..load();
  try {
    final payload = JWT.verify(token, SecretKey(env['SECRET_JWT_KEY'] ?? '')).payload as Map<String, dynamic>;
    print(payload);

    return render('dashboard');
  } catch (e) {
    return redirect('/_/login.html');
  }
}
