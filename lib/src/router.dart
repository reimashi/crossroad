import 'dart:async';
import 'package:shelf/shelf.dart' as shelf;
import 'route.dart';
import 'router_handler.dart';
import 'router_handler_bean.dart';

class Router {
  final Router _parent;
  Map<Route, RouterHandlerBean> _handlers = {};
  Map<Route, Router> _childs = {};
  shelf.Pipeline _pipeline = const shelf.Pipeline();

  Router._(Router parent) : this._parent = parent;

  void all(Pattern path, RouterHandler handler,
      [List<String> methods = const ["GET", "POST", "PUT", "DELETE"]]) {
    Route newRoute = new Route(path);

    if (!this._handlers.keys.any((r) => r.compareTo(newRoute) == 0))
      this._handlers[newRoute] = new RouterHandlerBean(handler, methods);
    else
      throw new Exception("Route collision: ${newRoute}.");
  }

  void get(Pattern path, RouterHandler handler) =>
      all(path, handler, const ["GET"]);

  void post(Pattern path, RouterHandler handler) =>
      all(path, handler, const ["POST"]);

  void put(Pattern path, RouterHandler handler) =>
      all(path, handler, const ["PUT"]);

  void delete(Pattern path, RouterHandler handler) =>
      all(path, handler, const ["DELETE"]);

  void getS(Pattern path, shelf.Handler handler) =>
      get(path, HandlerWrapper(handler));

  void postS(Pattern path, shelf.Handler handler) =>
      post(path, HandlerWrapper(handler));

  void putS(Pattern path, shelf.Handler handler) => 
      put(path, HandlerWrapper(handler));

  void deleteS(Pattern path, shelf.Handler handler) =>
      delete(path, HandlerWrapper(handler));

  Router route(Pattern path) {
    Route newRoute = new Route(path);

    if (!this._childs.containsKey(newRoute)) {
      Router newRouter = new Router._(this);
      this._childs[newRoute] = newRouter;
      return newRouter;
    } else
      throw new Exception("Route collision: ${newRoute}.");
  }

  shelf.Pipeline addMiddleware(shelf.Middleware middleware) {
    this._pipeline = this._pipeline.addMiddleware(middleware);
    return this._pipeline;
  }

  FutureOr<shelf.Response> _getHandler(shelf.Request req, [String url = null]) {
    url = url ?? "/" + req.url.toString();

    for (Route route in this._handlers.keys) {
      if (route.match(url) &&
          this._handlers[route].methods.contains(req.method)) {
        return this._handlers[route].handler(req, route.parameters(url));
      }
    }

    for (Route route in this._childs.keys) {
      if (route.isSubPath(url)) {
        print(route.subPath(url));
        return this._childs[route]._getHandler(req, route.subPath(url));
      }
    }

    return new shelf.Response.notFound("Not found");
  }

  shelf.Handler get handler {
    return this._pipeline.addHandler(_getHandler);
  }

  String toString() {
    String childStr = "";
    this._childs.forEach((Route path, Router router) {
      childStr +=
          "\t${path} => ${router.toString().split("\n").join("\n\t")}\t";
    });

    return "${this._parent == null ? "/ => " : ""}{\n\t"
        "${this._handlers.keys.join("\n\t")}\n"
        "${this._childs.length > 0 ? "${childStr}\n" : ""}"
        "}";
  }
}

final Crossroad = new Router._(null);
