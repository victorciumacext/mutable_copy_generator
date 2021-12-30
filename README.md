# mutable_copy_generator

MutableCopy simplify copy of immutable object. Unlike CopyWith allow to set null value

# Code generation
Code generator for [mutable_copy](https://pub.dev/packages/mutable_copy/)

```dart
import 'package:mutable_copy/mutable_copy.dart';


part 'employe.g.dart';

@MutableCopy
class Employee {
  final String fullName;
  final String department;
  final String team;

  Employee({
    this.fullName,
    this.department,
    this.team,
  });
}
```

# Generate code
```
flutter pub run build_runner build
```

# Usage 

```dart
final e1 = Employee(
  fullName: 'Max Hatson',
  department: 'Mobile',
  team: 'Flutter',
);
final eMutable = e1.copy((o) => o..fullName = 'Bob Watson');
```
