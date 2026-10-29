import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mid_project_template/models.dart';
import 'package:mid_project_template/screens/a_list_screen.dart';

const trips = [
  Item(
    id: 1,
    title: 'Tokyo Summer',
    subtitle: '2000.06.14 – 06.18 · 일본 도쿄',
    image: '',
    tags: ['바다'],
  ),
  Item(
    id: 2,
    title: 'Jeju Spring',
    subtitle: '2000.09.12 – 09.15 · 제주도',
    image: '',
    tags: ['산책'],
  ),
];

Future<void> open(
  WidgetTester tester, {
  List<Item> items = trips,
  double width = 400,
  double height = 1400,
}) async {
  tester.view.physicalSize = Size(width, height);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      home: ListScreen(
        load: () async => items,
        loadNotes: (_) async => [],
        update: (item) async => item,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'search covers destination and tags; clearing and empty results recover',
    (tester) async {
      await open(tester);
      await tester.enterText(
        find.byKey(const ValueKey('trip-search')),
        '도쿄 바다',
      );
      await tester.pumpAndSettle();
      expect(find.text('Tokyo Summer'), findsOneWidget);
      expect(find.text('Jeju Spring'), findsNothing);
      // Statistics remain global while the displayed list is filtered.
      expect(find.text('총 여행 2'), findsOneWidget);
      await tester.enterText(
        find.byKey(const ValueKey('trip-search')),
        'missing',
      );
      await tester.pumpAndSettle();
      expect(find.text('검색 조건에 맞는 여행이 없어요.'), findsOneWidget);
      await tapVisible(tester, find.text('검색·필터 초기화'));
      expect(find.text('Tokyo Summer'), findsOneWidget);
      expect(find.text('Jeju Spring'), findsOneWidget);
    },
  );

  testWidgets(
    'favorite filter updates cards and statistics without opening detail',
    (tester) async {
      await open(tester);
      await tapVisible(tester, find.byKey(const ValueKey('favorite-1')));
      expect(find.text('즐겨찾기 1'), findsOneWidget);
      expect(find.byType(BackButton), findsNothing);
      await tapVisible(tester, find.text('즐겨찾기만'));
      expect(find.text('Tokyo Summer'), findsOneWidget);
      expect(find.text('Jeju Spring'), findsNothing);
      await tapVisible(tester, find.byKey(const ValueKey('favorite-1')));
      expect(find.text('즐겨찾기 0'), findsOneWidget);
      expect(find.text('검색 조건에 맞는 여행이 없어요.'), findsOneWidget);
    },
  );

  testWidgets(
    'delete cancellation, confirmation, undo and recap share active trips',
    (tester) async {
      await open(tester);
      await tapVisible(tester, find.byKey(const ValueKey('favorite-1')));
      await tapVisible(tester, find.byKey(const ValueKey('delete-1')));
      await tapVisible(tester, find.text('취소'));
      expect(find.text('총 여행 2'), findsOneWidget);
      await tapVisible(tester, find.byKey(const ValueKey('delete-1')));
      await tapVisible(tester, find.text('삭제'));
      expect(find.text('Tokyo Summer'), findsNothing);
      expect(find.text('총 여행 1'), findsOneWidget);
      expect(find.text('즐겨찾기 0'), findsOneWidget);
      expect(find.text('여행일 합계 4일'), findsOneWidget);
      await tapVisible(tester, find.text('실행 취소'));
      expect(find.text('총 여행 2'), findsOneWidget);
      expect(find.text('즐겨찾기 1'), findsOneWidget);
      expect(find.text('여행일 합계 9일'), findsOneWidget);
      await tapVisible(tester, find.byKey(const ValueKey('delete-1')));
      await tapVisible(tester, find.text('삭제'));
      await tapVisible(tester, find.text('기록 모아보기'));
      expect(find.text('Tokyo Summer'), findsNothing);
      expect(find.text('나의 여행 돌아보기'), findsOneWidget);
    },
  );

  testWidgets('last trip deletion can be undone from the empty view', (
    tester,
  ) async {
    await open(tester, items: [trips.first]);
    await tapVisible(tester, find.byKey(const ValueKey('delete-1')));
    await tapVisible(tester, find.text('삭제'));
    expect(find.text('총 여행 0'), findsOneWidget);
    expect(find.text('표시할 여행이 없어요. 삭제는 아래에서 실행 취소할 수 있어요.'), findsOneWidget);
    await tapVisible(tester, find.text('실행 취소'));
    expect(find.text('Tokyo Summer'), findsOneWidget);
  });

  testWidgets('sorting changes card order within a group', (tester) async {
    await open(tester);
    expect(
      tester.getTopLeft(find.text('Jeju Spring')).dy,
      lessThan(tester.getTopLeft(find.text('Tokyo Summer')).dy),
    );
    await tapVisible(tester, find.byKey(const ValueKey('trip-sort')));
    await tapVisible(tester, find.text('오래된 출발일순').last);
    expect(
      tester.getTopLeft(find.text('Tokyo Summer')).dy,
      lessThan(tester.getTopLeft(find.text('Jeju Spring')).dy),
    );
    await tapVisible(tester, find.byKey(const ValueKey('trip-sort')));
    await tapVisible(tester, find.text('이름순').last);
    expect(
      tester.getTopLeft(find.text('Jeju Spring')).dy,
      lessThan(tester.getTopLeft(find.text('Tokyo Summer')).dy),
    );
  });

  for (final width in [320.0, 1024.0]) {
    testWidgets('controls and actions fit a $width dp viewport', (
      tester,
    ) async {
      await open(tester, width: width, height: 800);
      await tapVisible(tester, find.byKey(const ValueKey('favorite-1')));
      // Let Flutter report overflow failures with their render locations.
      expect(
        find.byType(GridView),
        width >= 600 ? findsOneWidget : findsNothing,
      );
    });
  }
}
