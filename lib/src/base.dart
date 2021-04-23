import 'dart:io';

import 'package:mustache_template/mustache.dart';
import 'package:shelf/shelf.dart';

String _mustacheString(String content, dynamic values, {String? includePath}) {
  var template = Template(content, partialResolver: (path) {
    if (includePath == null) {
      throw ArgumentError('The parameter \'includePath\' is required when using mustache include syntax.');
    } else {
      var resolvedFile = File(includePath + '/' + path);
      var resolvedString = resolvedFile.readAsStringSync();
      return Template(resolvedString);
    }
  });

  return template.renderString(values);
}

Middleware mustache(dynamic values, {String? includePath}) {
  return (Handler innerHandler) {
    return (Request request) async {
      var response = await innerHandler(request);
      var body = await response.readAsString();
      var mustachedBody = _mustacheString(body, values, includePath: includePath);
      return response.change(body: mustachedBody);
    };
  };
}
