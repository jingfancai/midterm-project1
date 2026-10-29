import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mid_project_template/models.dart';
import 'package:mid_project_template/screens/a_list_screen.dart';

const samples = [
  Item(
    id: 1,
    title: 'First trip',
    subtitle: '2000.01.01 · Tokyo',
    image: '',
    destination: 'Tokyo',
  ),
  Item(
    id: 2,
    title: 'Second trip',
    subtitle: '2000.02.01 · Osaka',
    image: '',
    destination: 'Osaka',
  ),
];
Future<void> mount(
  WidgetTester tester, {
  double width = 500,
  double height = 1400,
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

void main() {
  testWidgets('search matches actual data and shows empty for unknown input', (
    t,
  ) async {
    await mount(t);
    await fill(t, 'trip-search', 'Tokyo');
    expect(find.text('First trip'), findsOneWidget);
    expect(find.text('Second trip'), findsNothing);
    await fill(t, 'trip-search', 'no-match');
    expect(find.text('First trip'), findsNothing);
    expect(find.text('검색 조건에 맞는 여행이 없어요.'), findsOneWidget);
    await tap(t, find.byTooltip('검색어 지우기'));
    expect(find.text('Second trip'), findsOneWidget);
  });
  testWidgets('favorite filter uses current session toggles', (t) async {
    await mount(t);
    await tap(t, find.byKey(const ValueKey('favorite-1')));
    await tap(t, find.text('즐겨찾기만'));
    expect(find.text('First trip'), findsOneWidget);
    expect(find.text('Second trip'), findsNothing);
    await tap(t, find.text('즐겨찾기만'));
    expect(find.text('Second trip'), findsOneWidget);
  });
  testWidgets('deletion cancellation keeps cards', (t) async {
    await mount(t);
    await tap(t, find.byKey(const ValueKey('delete-1')));
    await tap(t, find.text('취소'));
    expect(find.text('First trip'), findsOneWidget);
  });
  testWidgets('delete and undo update current city and country statistics', (
    t,
  ) async {
    await mount(t);
    await delete(t, 1);
    expect(find.text('총 여행 1'), findsOneWidget);
    expect(find.text('방문 도시 수 1개'), findsOneWidget);
    expect(find.text('방문 국가 1개'), findsOneWidget);
    await tap(t, find.text('실행 취소'));
    expect(find.text('방문 도시 수 2개'), findsOneWidget);
    expect(find.text('총 여행 2'), findsOneWidget);
  });
  testWidgets('sort changes the displayed order within a group', (t) async {
    await mount(t);
    await tap(t, find.byKey(const ValueKey('trip-sort')));
    await tap(t, find.text('오래된 출발일순').last);
    expect(
      t.getTopLeft(find.text('First trip')).dy,
      lessThan(t.getTopLeft(find.text('Second trip')).dy),
    );
  });
  for (final width in [320.0, 1024.0]) {
    testWidgets('demo controls fit $width dp', (t) async {
      await mount(t, width: width, height: 800);
      await tap(t, find.byKey(const ValueKey('favorite-1')));
      expect(find.byTooltip('즐겨찾기 해제'), findsOneWidget);
      expect(t.takeException(), isNull);
    });
  }
}
