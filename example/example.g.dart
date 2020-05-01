// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'example.dart';

// **************************************************************************
// MutableCopyGenerator
// **************************************************************************

extension SimpleObjectMutableCopyExt on SimpleObject {
  SimpleObjectMutable mutableCopy() {
    return SimpleObjectMutable(
      id: id,
      value: value,
    );
  }

  SimpleObject copy(UpdateWith<SimpleObjectMutable> updateWith) {
    return updateWith(mutableCopy()).copy();
  }
}

class SimpleObjectMutable with Mutable<SimpleObject> {
  String id;
  int value;

  SimpleObjectMutable({
    this.id,
    this.value,
  });

  @override
  SimpleObject copy() {
    return SimpleObject(
      id: id,
      value: value,
    );
  }
}
