import 'dart:async';

import 'package:shelf/shelf.dart' as shelf;

import 'mustache_string.dart';

typedef ValuesProvider = FutureOr<dynamic> Function();
typedef Predicate = FutureOr<bool> Function(
    shelf.Request request, shelf.Response response);

/// Mustache renderer [shelf.Middleware]
///
/// Basically you specify the [valuesProvider] function, that gets evaluated
/// on each request, providing data for mustache.
///
/// You can specify a [predicate] function, that checks if the current request
/// should be processed by the mustache template processor.
///
/// If you are using mustache includes (also known as partials), you might want
/// to configure the [includePath].
shelf.Middleware mustache(
  ValuesProvider valuesProvider, {
  String? includePath,
  Predicate? predicate,
}) {
  return (shelf.Handler innerHandler) {
    return (shelf.Request request) async {
      final response = await innerHandler(request);

      /// Test if we want to mustache this request
      if (predicate == null || await predicate(request, response)) {
        final body = await response.readAsString();

        /// Rerender body with mustache
        final mustachedBody = body.mustache(
          await valuesProvider(),
          includePath: includePath ?? '.',
        );

        /// Return new body
        return response.change(body: mustachedBody);
      } else {
        /// Respond unchanged
        return response;
      }
    };
  };
}
