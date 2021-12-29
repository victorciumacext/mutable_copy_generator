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
    final sortedFields = _sortedConstructorFields(classElement);
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
      (r, v) => "$r${v.type} ${v.name};",
    );

    final constructorFields = sortedFields.fold(
      "",
      (r, v) => "$r this.${v.name},",
    );

    final paramsInput = sortedFields.fold(
      "",
      (r, v) => "$r ${v.name}: ${v.name},",
    );

    return '''
        class ${classElement.name}Mutable with Mutable<${classElement.name}> {
          ${fields}

          ${classElement.name}Mutable({
            ${constructorFields}
          });

          @override
          ${classElement.name} copy() {
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

    return '''
        extension ${classElement.name}MutableCopyExt on ${classElement.name} {
          ${classElement.name}Mutable mutableCopy() {
            return ${classElement.name}Mutable(
              ${paramsInput}
            );
          }

          ${classElement.name} copy(UpdateWith<${classElement.name}Mutable> updateWith) {
            return updateWith(mutableCopy()).copy();
          }
        }
    ''';
  }

  List<_FieldInfo> _sortedConstructorFields(ClassElement element) {
    assert(element is ClassElement);

    final constructor = element.unnamedConstructor;
    if (constructor is! ConstructorElement) {
      throw "Default ${element.name} constructor is missing";
    }

    final parameters = constructor.parameters;
    if (parameters is! List<ParameterElement> || parameters.isEmpty) {
      throw "Unnamed constructor for ${element.name} has no parameters";
    }

    parameters.forEach((parameter) {
      if (!parameter.isNamed) {
        throw "Unnamed constructor for ${element.name} contains unnamed parameter. Only named parameters are supported.";
      }
    });

    final fields = parameters.map((v) => _FieldInfo(v)).toList();
    fields.sort((lhs, rhs) => lhs.name.compareTo(rhs.name));

    return fields;
  }
}

class _FieldInfo {
  final String name;
  final String type;

  _FieldInfo(ParameterElement element)
      : this.name = element.name,
        this.type = element.type.getDisplayString(withNullability: true);
}
