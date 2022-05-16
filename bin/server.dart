import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';

// Configure routes.
final _router = Router()
  ..get('/', _rootHandler)
  ..get('/echo/<message>', _echoHandler);

Response _rootHandler(Request request) {
  return Response.ok('Hello, World!\n');
}

Response _echoHandler(Request request) {
  return Response.ok('Hello\n');
}

void main(List<String> args) async {
  // Use any available host or container IP (usually `0.0.0.0`).
  final ipv4 = InternetAddress.anyIPv4;

  print(ipv4);

  // Configure a pipeline that logs requests.
  final _handler = Pipeline().addMiddleware(logRequests()).addHandler(_router);

  // For running in containers, we respect the PORT environment variable.
  final port = int.parse(Platform.environment['PORT'] ?? '8000');
  final server = await serve(_handler, ipv4, port);
  print('Server listening on port ${server.port}');
}
