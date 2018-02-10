import 'router_handler.dart';

class RouterHandlerBean {
  final RouterHandler handler;
  final List<String> methods;

  RouterHandlerBean(RouterHandler handler, List<String> methods)
      : this.handler = handler,
        this.methods = methods;
}