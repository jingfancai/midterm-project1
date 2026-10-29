import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mid_project_template/destinations.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await loadDestinations();
  await testMain();
}
