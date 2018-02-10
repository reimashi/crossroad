import 'package:test/test.dart';
import 'package:crossroad/src/route.dart';

void main() {
  group('Corrent paths', () {
    test('Path /', () {
      expect(new Route("/").runtimeType, Route);
    });
  });

  group('Regexp in path', () {
    test('?', () {
      Route testRoute = new Route("/global/ab?cd/test");

      expect(testRoute.match("/global/acd/test"), isTrue);
      expect(testRoute.match("/global/abcd/test"), isTrue);
      expect(testRoute.match("/global/aXcd/test"), isFalse);
    });

    test('+', () {
      Route testRoute = new Route("/global/ab+cd/test");

      expect(testRoute.match("/global/acd/test"), isFalse);
      expect(testRoute.match("/global/abcd/test"), isTrue);
      expect(testRoute.match("/global/abbbcd/test"), isTrue);
    });

    test('*', () {
      Route testRoute = new Route("/global/ab*cd/test");

      expect(testRoute.match("/global/acd/test"), isTrue);
      expect(testRoute.match("/global/abcd/test"), isTrue);
      expect(testRoute.match("/global/abbbcd/test"), isTrue);
    });

    test('()', () {
      Route testRoute = new Route("/global/ab(cd)?e/test");

      expect(testRoute.match("/global/abe/test"), isTrue);
      expect(testRoute.match("/global/abde/test"), isFalse);
      expect(testRoute.match("/global/abcde/test"), isTrue);
    });
  });

  group('Param parser', () {
    Route testRoute;

    setUp(() {
      testRoute = new Route("/global/:tparam/test");
    });

    test('Param extraction', () {
      String url = "/global/x/test";
      expect(testRoute.parameters(url).length, 1);
      expect(testRoute.parameters(url).containsKey("tparam"), isTrue);
    });

    test('Param bool parser', () {
      String url = "/global/true/test";

      expect(testRoute.match(url), true);
      expect(testRoute.parameters(url)["tparam"].runtimeType, bool);
      expect(testRoute.parameters(url)["tparam"], true);

      url = "/global/false/test";

      expect(testRoute.match(url), true);
      expect(testRoute.parameters(url)["tparam"].runtimeType, bool);
      expect(testRoute.parameters(url)["tparam"], false);
    });

    test('Param int parser', () {
      String url = "/global/123/test";

      expect(testRoute.match(url), true);
      expect(testRoute.parameters(url)["tparam"].runtimeType, int);
      expect(testRoute.parameters(url)["tparam"], 123);
    });

    test('Param double parser', () {
      String url = "/global/-1.45/test";

      expect(testRoute.match(url), true);
      expect(testRoute.parameters(url)["tparam"].runtimeType, double);
      expect(testRoute.parameters(url)["tparam"], -1.45);
    });

    test('Param date parser', () {
      String url = "/global/2002-12-31T23:00:00-01:00/test";

      expect(testRoute.match(url), true);
      expect(testRoute.parameters(url)["tparam"].runtimeType, DateTime);
      expect(testRoute.parameters(url)["tparam"],
          new DateTime.utc(2003, 01, 01));
    });

    test('Param list parser', () {
      String url = "/global/3,2002-12-31T23:00:00+01:00/test";

      expect(testRoute.match(url), true);
      expect(testRoute.parameters(url)["tparam"] is List, isTrue);

      List params = testRoute.parameters(url)["tparam"];
      expect(params[0].runtimeType, int);
      expect(params[1].runtimeType, DateTime);
    });
  });
}
