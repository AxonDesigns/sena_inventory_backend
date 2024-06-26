import 'package:dart_frog/dart_frog.dart';
import 'package:sena_inventory_backend/lib.dart';
import 'package:sena_inventory_backend/utils.dart';

/// Authenticator
typedef Authenticator<T extends Object> = Future<T?> Function(
  RequestContext context,
  String token,
);

/// Provides the authenticated user if available.
Middleware authentication<T extends Object>({
  required Authenticator<T> authenticator,
}) {
  return (handler) => (context) async {
        T? user;
        final token = getAccessToken(context);
        if (token != null) {
          user = await authenticator(context, token);
        }

        return handler(context.provide<T?>(() => user));
      };
}
