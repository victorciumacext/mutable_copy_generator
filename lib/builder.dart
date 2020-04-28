library mutable_copy_generator;

import 'package:build/build.dart';
import 'package:mutable_copy_generator/src/mutable_copy_generator.dart';
import 'package:source_gen/source_gen.dart' show SharedPartBuilder;

// Builder mutableCopyBuilder(BuilderOptions options) => CopyWithGenerator();
Builder mutableCopyBuilder(BuilderOptions _) => SharedPartBuilder(
      [MutableCopyGenerator()],
      'mutableCopy',
    );
