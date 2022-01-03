import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:mutable_copy_generator/mutable_copy.dart';
import 'package:source_gen/source_gen.dart';

/// A `Generator` for `package:build_runner`
class MutableCopyGenerator extends GeneratorForAnnotation<MutableCopy> {
  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element is! ClassElement) throw "$element is not a ClassElement";
    final classElement = element;
    final sortedFields = _sortedFields(classElement);
    return '''
     ${_mutableExtensionPart(classElement, sortedFields)}

      ${_mutableObjectPart(classElement, sortedFields)}
    ''';
  }

  String _mutableObjectPart(
    ClassElement classElement,
    List<_FieldInfo> sortedFields,
  ) {
    final fields = sortedFields.fold(
      "",
      (r, v) {
        if (v.type.contains('?')) {
          return "$r${v.type} ${v.name};";
        } else {
          return "$r${v.type}? ${v.name};";
        }
      },
    );

    final constructorFields = sortedFields.fold(
      "",
      (r, v) {
        return "$r this.${v.name},";
      },
    );

    final paramsInput = sortedFields.fold(
      "",
      (r, v) {
        if (v.type.contains('?')) {
          return "$r ${v.name}: ${v.name},";
        } else {
          return "$r ${v.name}: ${v.name}!,";
        }
      },
    );

    final notNullableFields = sortedFields.where((element) => !element.type.contains('?'));

    final nullabilityCheck = notNullableFields.fold("", (r, v) {
      return "if (${v.name} == null) throw '${v.name} could not be null'; ";
    });

    return '''
        class ${classElement.name}Mutable with Mutable<${classElement.name}> {
          ${fields}

          ${classElement.name}Mutable({
            ${constructorFields}
          });

          @override
          ${classElement.name} copy() {
          ${nullabilityCheck}
          
            return ${classElement.name}(
              ${paramsInput}
            );
          }
        }
    ''';
  }

  String _mutableExtensionPart(
    ClassElement classElement,
    List<_FieldInfo> sortedFields,
  ) {
    final paramsInput = sortedFields.fold(
      "",
      (r, v) => "$r ${v.name}: ${v.name},",
    );

    final notNullableParams = sortedFields.where((element) => !element.type.contains('?'));

    final nullableParams = sortedFields.where((element) => element.type.contains('?'));

    final notNullableInputs = notNullableParams.fold('', (r, v) => "$r required ${v.name}: ${v.name},");
    final nullableInputs = nullableParams.fold(
      "",
          (r, v) => "$r ${v.name}: ${v.name},",
    );
    //add unnamed constructor if none is defined
    var unnamedConstructor = '';
    if (classElement.unnamedConstructor == null) {
      print('Adding unnamed constructor');
      print('required fields :${notNullableParams.map((e) => e.name)}');

      unnamedConstructor = '''
      ${classElement.name}({
       ${notNullableInputs}
       ${nullableInputs}
      });
      ''';
    }
    return '''
        extension ${classElement.name}MutableCopyExt on ${classElement.name} {
          ${unnamedConstructor}
        
          ${classElement.name}Mutable mutableCopy() {
            return ${classElement.name}Mutable(
              ${paramsInput}
            );
          }

          ${classElement.name} copyWith(UpdateWith<${classElement.name}Mutable> updateWith) {
            return updateWith(mutableCopy()).copy();
          }
        }
    ''';
  }

  List<_FieldInfo> _sortedFields(ClassElement element) {
    final fields = element.fields;
    if (fields.isEmpty) {
      throw "${element.name} has no parameters";
    }
    final mappedFields = fields.map((v) => _FieldInfo(v)).toList();
    fields.sort((lhs, rhs) => lhs.name.compareTo(rhs.name));

    return mappedFields;
  }
}

class _FieldInfo {
  final String name;
  final String type;

  _FieldInfo(FieldElement element)
      : this.name = element.name,
        this.type = element.type.getDisplayString(withNullability: true);
}
