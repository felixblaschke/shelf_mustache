import 'dart:io';

import 'package:mustache_template/mustache.dart';

/// Mustache extension on [String] types
extension MustacheString on String {
  /// Processes this string with mustache template engine.
  ///
  /// You specify the [values] to provide data for mustache.
  ///
  /// If you are using mustache includes (also known as partials), you might want
  /// to configure the [includePath].
  String mustache(dynamic values, {String includePath = '.'}) {
    var template = Template(this, partialResolver: (path) {
      var resolvedFile = File(includePath + '/' + path);
      if (resolvedFile.existsSync()) {
        var resolvedString = resolvedFile.readAsStringSync();
        return Template(resolvedString);
      } else {
        throw ArgumentError(
            'Trying to include file "$path" at "${resolvedFile.absolute.path}" but no file found. Hint: You can configure the base include path with the "includePath" parameter.');
      }
    });

    return template.renderString(values);
  }
}
