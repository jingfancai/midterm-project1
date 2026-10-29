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

// Former persistence regressions now assert that prototype actions never mutate data.
void main() {
  testWidgets('favorite demo leaves the card unchanged after refresh', (
    t,
  ) async {
    await mount(t);
    await tap(t, find.byKey(const ValueKey('favorite-1')));
    expect(find.text(prototypeNotice), findsOneWidget);
    expect(find.byTooltip('즐겨찾기 해제'), findsNothing);
    await mount(t);
    expect(find.text('First trip'), findsOneWidget);
  });
  testWidgets('delete confirmation and undo are demonstrations only', (
    t,
  ) async {
    await mount(t);
    await delete(t, 1);
    expect(find.text('First trip'), findsOneWidget);
    await tap(t, find.text('실행 취소'));
    expect(find.text(prototypeNotice), findsOneWidget);
    await mount(t);
    expect(find.text('First trip'), findsOneWidget);
  });
  testWidgets('edit form keeps current data after demo save', (t) async {
    await mount(t);
    await tap(t, find.text('First trip'));
    await tap(t, find.byTooltip('여행 정보 수정'));
    await fill(t, 'trip-title', 'Changed');
    await fill(t, 'trip-destination', 'Paris');
    await tap(t, find.text('저장'));
    expect(find.text('Changed'), findsNothing);
    expect(find.text('First trip'), findsWidgets);
    await tap(t, find.byType(BackButton));
    expect(find.text('First trip'), findsOneWidget);
  });
  testWidgets('new trip form demonstrates save without creating a record', (
    t,
  ) async {
    await mount(t);
    await tap(t, find.byType(FloatingActionButton));
    await fill(t, 'trip-title', 'New trip');
    await fill(t, 'trip-destination', 'Paris');
    await tap(t, find.text('여행 추가'));
    expect(find.text('New trip'), findsNothing);
    expect(find.text(prototypeNotice), findsOneWidget);
    await mount(t);
    expect(find.text('New trip'), findsNothing);
  });
  testWidgets('canceling editor preserves all data', (t) async {
    await mount(t);
    await tap(t, find.byType(FloatingActionButton));
    await fill(t, 'trip-title', 'Canceled');
    await tap(t, find.text('취소'));
    expect(find.text('Canceled'), findsNothing);
    expect(find.text('First trip'), findsOneWidget);
  });
  testWidgets('country field is explanatory rather than actual recognition', (
    t,
  ) async {
    await mount(t);
    await tap(t, find.byType(FloatingActionButton));
    await fill(t, 'trip-destination', 'Tokyo');
    expect(find.textContaining('실제 인식·계산은 하지 않습니다'), findsOneWidget);
    expect(find.byKey(const ValueKey('country-code')), findsNothing);
    await fill(t, 'trip-destination', 'Unknown');
    expect(find.textContaining('실제 인식·계산은 하지 않습니다'), findsOneWidget);
  });
  testWidgets('record creation shows feedback without changing timeline', (
    t,
  ) async {
    await mount(t);
    await tap(t, find.text('First trip'));
    await tap(t, find.text('여행 기록'));
    await tap(t, find.text('여행 기록 추가'));
    await t.enterText(find.byType(TextField), 'My note');
    await tap(t, find.text('저장'));
    expect(find.text('My note'), findsNothing);
    expect(find.text(prototypeNotice), findsOneWidget);
  });
  testWidgets('avatar opens a local explanation instead of another page', (
    t,
  ) async {
    await mount(t);
    await tap(t, find.byType(CircleAvatar));
    expect(find.text('프로필 안내'), findsOneWidget);
    expect(find.byType(BackButton), findsNothing);
    await tap(t, find.text('닫기'));
    expect(find.text('First trip'), findsOneWidget);
  });
  testWidgets('photo rendering remains consistent between home and detail', (
    t,
  ) async {
    await mount(t);
    final photo = t.widget<NetImage>(find.byType(NetImage).first).url;
    await tap(t, find.text('First trip'));
    expect(t.widget<NetImage>(find.byType(NetImage).first).url, photo);
  });
}
