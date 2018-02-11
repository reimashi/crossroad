import 'package:test/test.dart';
import 'package:crossroad/crossroad.dart';

void main() {
  group('Path resolutions', () {
    test('Path /', () {
      String path = "/";
      bool setFlag = false;

      Router r = new Router.root();
      r.get(path, (Request req, Map params) { setFlag = true; });
      r.handler(new Request("GET", Uri.parse("http://test" + path)));
      expect(setFlag, isTrue);
    });

    test('Path /test', () {
      String path = "/test";
      bool setFlag = false;

      Router r = new Router.root();
      r.get(path, (Request req, Map params) { setFlag = true; });
      r.handler(new Request("GET", Uri.parse("http://testhost" + path)));
      expect(setFlag, isTrue);
    });

    test('Path /test/ with subrouter', () {
      String path = "/test";
      bool setFlag = false;

      Router r = new Router.root();
      r.route(path).get("/", (Request req, Map params) { setFlag = true; });
      r.handler(new Request("GET", Uri.parse("http://testhost" + path + "/")));
      expect(setFlag, isTrue);
    });

    test('Path /test/test2 with subrouter', () {
      bool setFlag = false;

      Router r = new Router.root();
      r.route("/test")
          .get("/test2", (Request req, Map params) { setFlag = true; });
      r.handler(new Request("GET", Uri.parse("http://testhost/test/test2")));
      expect(setFlag, isTrue);
    });
  });
}