import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mid_project_template/models.dart';
import 'package:mid_project_template/screens/a_list_screen.dart';
import 'package:mid_project_template/widgets.dart';

const samples = [
  Item(
    id: 1,
    title: 'First trip',
    subtitle: '2000.01.01 · Tokyo',
    image: '',
    destination: 'Tokyo',
    demoStatus: 'past',
  ),
  Item(
    id: 2,
    title: 'Second trip',
    subtitle: '2000.02.01 · Osaka',
    image: '',
    destination: 'Osaka',
    demoStatus: 'past',
  ),
];
Future<void> mount(
  WidgetTester tester, {
  double width = 500,
  double height = 1800,
  bool accessible = false,
}) async {
  tester.view.physicalSize = Size(width, height);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      key: UniqueKey(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(accessibleNavigation: accessible),
        child: child!,
      ),
      home: ListScreen(load: () async => samples, loadNotes: (_) async => []),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> tap(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      finder,
      250,
      scrollable: find.byType(Scrollable).first,
    );
  }
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> fill(WidgetTester tester, String key, String value) async {
  await tester.enterText(find.byKey(ValueKey(key)), value);
  await tester.pumpAndSettle();
}

Future<void> delete(WidgetTester tester, int id) async {
  await tap(tester, find.byKey(ValueKey('delete-$id')));
  await tap(tester, find.text('삭제'));
}

Future<void> elapse(WidgetTester t, int seconds) async {
  await t.pump(Duration(seconds: seconds));
  await t.pumpAndSettle();
}

void main() {
  testWidgets('delete demo toast expires after four seconds', (t) async {
    await mount(t);
    await delete(t, 1);
    expect(find.text('실행 취소'), findsOneWidget);
    await elapse(t, 3);
    expect(find.text('실행 취소'), findsOneWidget);
    await elapse(t, 1);
    expect(find.byType(SnackBar), findsNothing);
    expect(find.text('First trip'), findsOneWidget);
  });
  testWidgets('undo demonstrates feedback without changing records', (t) async {
    await mount(t);
    await delete(t, 1);
    await tap(t, find.text('실행 취소'));
    expect(find.text(prototypeNotice), findsOneWidget);
    expect(find.text('First trip'), findsOneWidget);
  });
  testWidgets('repeat demo deletions clear old queued messages', (t) async {
    await mount(t);
    await delete(t, 1);
    ScaffoldMessenger.of(
      t.element(find.byType(ListScreen)),
    ).showSnackBar(const SnackBar(content: Text('Old queued notice')));
    await delete(t, 2);
    expect(find.textContaining('Second trip 삭제 시연'), findsOneWidget);
    expect(find.text('Old queued notice'), findsNothing);
    await elapse(t, 5);
    expect(find.byType(SnackBar), findsNothing);
  });
  testWidgets('accessibility demo offers a longer bounded undo window', (
    t,
  ) async {
    await mount(t, accessible: true);
    await delete(t, 1);
    await elapse(t, 5);
    expect(find.text('실행 취소'), findsOneWidget);
    await tap(t, find.text('실행 취소'));
    expect(find.text(prototypeNotice), findsOneWidget);
    await delete(t, 2);
    await elapse(t, 10);
    expect(find.byType(SnackBar), findsNothing);
  });
}
