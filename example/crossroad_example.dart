import 'package:crossroad/crossroad.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;

void main() {
  // Compatible with shelf middleware
  Crossroad.addMiddleware(shelf.logRequests());

  // Simple string path
  Crossroad.get('/', (shelf.Request request, _) {
    return new shelf.Response.ok('Hello world');
  });

  // Regexp path
  Crossroad.get(new RegExp(r"^/[0-9]{5}$"), (shelf.Request request, _) {
    return new shelf.Response.ok("5-digit number: ${request.url}");
  });

  // Nested routers, for relative paths
  Router paramsRouter = Crossroad.route("/params");

  // Extract parameters from paths
  paramsRouter.get('/:param1/:param2/:param3', (shelf.Request request, Map<String, Object> p) {
    return new shelf.Response.ok("Parameters: ${p.toString()}");
  });

  // Shelf standard handler
  io.serve(Crossroad.handler, 'localhost', 8080).then((server) {
    print("Shelf listening on http://${server.address.host}:${server.port}");
  });
}
