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

// Session interactions work, but every fresh GET restores the original fixture.
void main() {
  testWidgets(
    'favorite changes only in the session and resets on GET refresh',
    (t) async {
      await mount(t);
      await tap(t, find.byKey(const ValueKey('favorite-1')));
      expect(find.byTooltip('즐겨찾기 해제'), findsOneWidget);
      await tap(t, find.byKey(const ValueKey('refresh-trips')));
      expect(find.byTooltip('즐겨찾기 해제'), findsNothing);
      await mount(t);
      expect(find.text('First trip'), findsOneWidget);
    },
  );
  testWidgets(
    'delete removes a card and undo restores it without changing GET data',
    (t) async {
      await mount(t);
      await delete(t, 1);
      expect(find.text('First trip'), findsNothing);
      await tap(t, find.text('실행 취소'));
      expect(find.text('First trip'), findsOneWidget);
      await mount(t);
      expect(find.text('First trip'), findsOneWidget);
    },
  );
  testWidgets(
    'edit synchronizes detail and home then GET refresh restores original',
    (t) async {
      await mount(t);
      await tap(t, find.text('First trip'));
      await tap(t, find.byTooltip('여행 정보 수정'));
      await fill(t, 'trip-title', 'Changed');
      await fill(t, 'trip-destination', 'Paris');
      await fill(t, 'trip-start', '2000-03-01');
      await fill(t, 'trip-end', '2000-03-05');
      await tap(t, find.text('저장'));
      expect(find.text('Changed'), findsWidgets);
      expect(find.textContaining('Paris'), findsOneWidget);
      await tap(t, find.byType(BackButton));
      expect(find.text('Changed'), findsOneWidget);
      expect(find.text('방문 국가 2개'), findsOneWidget);
      await tap(t, find.byKey(const ValueKey('refresh-trips')));
      expect(find.text('First trip'), findsOneWidget);
      expect(find.text('Changed'), findsNothing);
    },
  );
  testWidgets('new trips get unique session IDs and vanish after GET refresh', (
    t,
  ) async {
    await mount(t);
    await tap(t, find.byType(FloatingActionButton));
    await fill(t, 'trip-title', 'New trip');
    await fill(t, 'trip-destination', 'Paris');
    await tap(t, find.text('여행 추가'));
    await tap(t, find.byKey(const ValueKey('trip-search')));
    await fill(t, 'trip-search', 'New trip');
    expect(
      find.descendant(
        of: find.byType(TripCard),
        matching: find.text('New trip'),
      ),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('delete--1')), findsOneWidget);
    await tap(t, find.byType(FloatingActionButton));
    await fill(t, 'trip-title', 'New trip two');
    await fill(t, 'trip-destination', 'Osaka');
    await tap(t, find.text('여행 추가'));
    expect(find.byKey(const ValueKey('delete--1')), findsOneWidget);
    expect(find.byKey(const ValueKey('delete--2')), findsOneWidget);
    expect(find.text('총 여행 4'), findsOneWidget);
    await tap(t, find.byKey(const ValueKey('refresh-trips')));
    await fill(t, 'trip-search', '');
    expect(find.text('New trip'), findsNothing);
    expect(find.text('New trip two'), findsNothing);
    expect(find.text('총 여행 2'), findsOneWidget);
  });
  testWidgets('canceling editor preserves all data', (t) async {
    await mount(t);
    await tap(t, find.byType(FloatingActionButton));
    await fill(t, 'trip-title', 'Canceled');
    await tap(t, find.text('취소'));
    expect(find.text('Canceled'), findsNothing);
    expect(find.text('First trip'), findsOneWidget);
  });
  testWidgets(
    'country resolves multilingual destinations with an honest unknown hint',
    (t) async {
      await mount(t);
      await tap(t, find.byType(FloatingActionButton));
      await fill(t, 'trip-destination', 'Tokyo');
      expect(find.textContaining('자동 인식 국가:'), findsOneWidget);
      expect(find.byKey(const ValueKey('country-code')), findsNothing);
      await fill(t, 'trip-destination', 'Unknown');
      expect(find.textContaining('국가를 인식하지 못했어요'), findsOneWidget);
    },
  );
  testWidgets('record creation updates temporary timeline only', (t) async {
    await mount(t);
    await tap(t, find.text('First trip'));
    await tap(t, find.text('여행 기록'));
    await tap(t, find.text('여행 기록 추가'));
    await t.enterText(find.byType(TextField), 'My note');
    await tap(t, find.text('저장'));
    expect(find.text('My note'), findsOneWidget);
    await tap(t, find.byType(BackButton));
    await tap(t, find.text('First trip'));
    await tap(t, find.text('여행 기록'));
    expect(find.text('My note'), findsNothing);
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
    final card = find.ancestor(
      of: find.text('First trip'),
      matching: find.byType(TripCard),
    );
    final photo = t
        .widget<NetImage>(
          find.descendant(of: card, matching: find.byType(NetImage)),
        )
        .url;
    await tap(t, find.text('First trip'));
    expect(t.widget<NetImage>(find.byType(NetImage).first).url, photo);
  });
}
