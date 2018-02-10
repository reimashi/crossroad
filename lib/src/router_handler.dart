import 'dart:async';
import 'package:shelf/shelf.dart';

typedef FutureOr<Response> RouterHandler(
    Request request, Map<String, Object> params);

RouterHandler HandlerWrapper(Handler handler) =>
    (Request req, _) => handler(req);
