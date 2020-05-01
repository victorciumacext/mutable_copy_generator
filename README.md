# mutable_copy_generator

MutableCopy simplify copy of immutable object. Unlike CopyWith allow to set null value

# Code generation
Code generator for [mutable_copy](https://pub.dev/packages/mutable_copy/)

```dart
import 'package:mutable_copy/mutable_copy.dart';


part 'employe.g.dart';

@imutable
@MutableCopy
class Employe {
  final String fullName;
  final String department;
  final String team;

  Employe({
    this.fullName,
    this.department,
    this.team,
  });
}
```

# Add dependencies
```
dependencies:
  ...
  mutable_copy: ^0.2.5

dev_dependencies:
  ...
  mutable_copy_generator: ^0.26
  build_runner: ^1.9.0
```

# Generate code
```
flutter pub run build_runner build
```

# Udage 

```dart
final e1 = Employe(
  fullName: 'Max Hatson',
  department: 'Mobile',
  team: 'Flutter',
);
final eMutable = e1.copy((o) => o..fullName = 'Bob Watson');
```
