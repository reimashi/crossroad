# crossroad

Simple router without dependencies for shelf 

## Usage

A simple usage example:

```dart
import 'package:crossroad/crossroad.dart';

main() {
    Crossroad.get('/:param1/:param2/:param3', (shelf.Request request, Map p) {
        return new shelf.Response.ok("Parameters: ${p.toString()}");
    });
    
    io.serve(Crossroad.handler, 'localhost', 8080).then((server) {
        print("Shelf listening on http://${server.address.host}:${server.port}");
    });
}
```