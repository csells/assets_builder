import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'src/asset_builder_base.dart';

Builder assetsBuilder(options) =>
    LibraryBuilder(AssetsLibraryGenerator(options), generatedExtension: '.asset.dart');
