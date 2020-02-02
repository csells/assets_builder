import 'dart:async';
import 'dart:convert';
import 'package:build/build.dart';
import 'package:glob/glob.dart';
import 'package:source_gen/source_gen.dart';
import 'package:path/path.dart' as path;
import 'dart:math' as math;

class AssetsLibraryGenerator extends Generator {
  static final _binaryFileTypes = RegExp(r'\.(jpe?g|png|gif|ico|svg|ttf|eot|woff|woff2)$', caseSensitive: false);

  final dynamic options;
  AssetsLibraryGenerator(this.options);

  @override
  FutureOr<String> generate(LibraryReader library, BuildStep buildStep) async {
    if (!path.isWithin('assets', buildStep.inputId.path)) return null;

    var name = path.basenameWithoutExtension(buildStep.inputId.path).replaceAll('_', '-');

    var filteredAssets = await buildStep
        .findAssets(Glob('assets/$name/**'))
        .where((asset) => !asset.pathSegments[2].startsWith('.'))
        .toList();

    var items = await _getLines(filteredAssets, buildStep)
        .map((item) => item.contains('\n') ? "'''\n$item'''" : "'$item'")
        .join(',');

    return 'const _data = <String>[$items];';
  }

  static Stream<String> _getLines(List<AssetId> ids, AssetReader reader) async* {
    for (var id in ids) {
      yield path.url.joinAll(id.pathSegments.skip(2));
      yield _binaryFileTypes.hasMatch(path.basename(id.path)) ? 'binary' : 'text';
      yield _base64encode(await reader.readAsBytes(id));
    }
  }

  static String _base64encode(List<int> bytes) {
    var encoded = base64.encode(bytes);

    // cut lines into 76-character chunks – makes for prettier source code
    var lines = <String>[];
    var index = 0;

    while (index < encoded.length) {
      var line = encoded.substring(index, math.min(index + 76, encoded.length));
      lines.add(line);
      index += line.length;
    }

    return lines.join('\n');
  }
}
