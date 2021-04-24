Mustache template rendering integration for shelf

## Usage

You can either use the `String` extension within request handlers:

```dart
var result = 'hello {{ name }}!'.mustache({'name': 'john'});
```

Or use the `mustache()` middleware to post-process responses automatically. 

For more detail, look at example:

```dart
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_mustache/shelf_mustache.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_static/shelf_static.dart';

void main() async {
  var router = Router();

  // http://localhost:8080/hello/john
  router.get('/hello/<name>', (shelf.Request request, String name) {
    var body = 'hello {{ name }}!'.mustache({'name': name});
    return shelf.Response.ok(body);
  });

  // http://localhost:8080/with/imports
  router.get('/with/imports', (shelf.Request request) {
    var body = '{{> index.html }}'.mustache({
      'title': 'John Doe Website',
    }, includePath: 'example/public');
    return shelf.Response.ok(body, headers: {'Content-Type': 'text/html'});
  });

  // http://localhost:8080/path/index.html
  // Post-process a whole directory with middleware
  router.mount(
      '/path/',
      shelf.Pipeline()
          .addMiddleware(
              // mustache model gets evaluated on each request
              mustache(() => {'title': 'My page'},
                  // (optional:) configure include path
                  includePath: 'example/public',
                  // (optional:) decide processing based on a predicate
                  predicate: (req, res) =>
                      req.headers['content-type'] == 'text/html'))
          .addHandler(createStaticHandler('example/public')));

  await io.serve(router, 'localhost', 8080);
}
```
