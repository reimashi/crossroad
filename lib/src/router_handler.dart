import 'dart:async';
import 'package:shelf/shelf.dart';

typedef FutureOr<Response> RouterHandler(Request request, Map<String, Object> params);