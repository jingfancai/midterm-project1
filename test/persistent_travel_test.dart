import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mid_project_template/models.dart';
import 'package:mid_project_template/destinations.dart';
import 'package:mid_project_template/widgets.dart';
import 'package:mid_project_template/screens/a_list_screen.dart';
import 'package:mid_project_template/trip_insights.dart';

const original = Item(
  id: 1,
  title: 'Original trip',
  subtitle: '',
  image: '',
  destination: 'Seoul',
  countryCode: 'KR',
  startDate: '2000-01-01',
  endDate: '2000-01-03',
);

class Store {
  final Map<int, Item> rows = {1: original};
  bool fail = false;
  int saves = 0;
  Completer<void>? pending;
  Future<List<Item>> load() async =>
      rows.values.where((item) => !item.deleted).toList();
  Future<Item> update(Item item) async {
    saves++;
    if (pending != null) await pending!.future;
    if (fail) throw Exception('저장 실패');
    rows[item.id] = item;
    return item;
  }

  Future<Item> create(Item item) async {
    if (fail) throw Exception('저장 실패');
    final saved = Item.fromJson({...item.toJson(), 'id': rows.length + 1})!;
    rows[saved.id] = saved;
    return saved;
  }
}

Future<void> mount(WidgetTester tester, Store store) async {
  tester.view.physicalSize = const Size(500, 1400);
  tester.view.devicePixelRatio = 1;
  await tester.pumpWidget(
    MaterialApp(
      key: UniqueKey(),
      home: ListScreen(
        load: store.load,
        update: store.update,
        create: store.create,
        loadNotes: (_) async => [],
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> fill(WidgetTester tester, String key, String value) async {
  await tester.enterText(find.byKey(ValueKey(key)), value);
  await tester.pumpAndSettle();
}

void main() {
  test(
    'country statistics deduplicate ISO identities and exclude future, unknown and deleted trips',
    () {
      final items = [
        original,
        original.copyWith(destination: 'Busan', countryCode: ' kr '),
        original.copyWith(destination: 'Tokyo', countryCode: 'KR'),
        original.copyWith(
          destination: 'Paris',
          countryCode: 'FR',
          startDate: '2100-01-01',
          endDate: '2100-01-03',
        ),
        original.copyWith(
          destination: 'London',
          countryCode: 'GB',
          deleted: true,
        ),
        original.copyWith(
          destination: 'Berlin',
          countryCode: 'DE',
          startDate: 'invalid',
        ),
        original.copyWith(destination: 'Unknown city', countryCode: 'US'),
      ];
      final summary = TripSummary(items, {}, DateTime(2026, 10, 29));
      expect(summary.visitedCountries, 2);
      expect(summary.total, 6);
      expect(
        TripSummary(
          [original.copyWith(startDate: '2026-10-29', endDate: '2026-10-30')],
          {},
          DateTime(2026, 10, 29),
        ).visitedCountries,
        1,
      );
    },
  );

  testWidgets(
    'favorites, deletion and undo survive a fresh page and keep statistics in sync',
    (tester) async {
      addTearDown(tester.view.reset);
      final store = Store();
      await mount(tester, store);
      await tap(tester, find.byKey(const ValueKey('favorite-1')));
      await mount(tester, store);
      expect(find.byTooltip('즐겨찾기 해제'), findsOneWidget);
      expect(find.text('즐겨찾기 1'), findsOneWidget);
      await tap(tester, find.byKey(const ValueKey('delete-1')));
      await tap(tester, find.text('삭제'));
      expect(find.text('총 여행 0'), findsOneWidget);
      expect(find.text('방문 국가 0개'), findsOneWidget);
      await tap(tester, find.text('실행 취소'));
      await mount(tester, store);
      expect(find.text('Original trip'), findsOneWidget);
      expect(find.text('즐겨찾기 1'), findsOneWidget);
      await tap(tester, find.byKey(const ValueKey('delete-1')));
      await tap(tester, find.text('삭제'));
      await mount(tester, store);
      expect(find.text('Original trip'), findsNothing);
      expect(find.text('총 여행 0'), findsOneWidget);
    },
  );

  testWidgets(
    'editing title, destination, country and dates updates detail, home and fresh reads',
    (tester) async {
      addTearDown(tester.view.reset);
      final store = Store();
      await mount(tester, store);
      await tap(tester, find.text('Original trip'));
      await tap(tester, find.byTooltip('여행 정보 수정'));
      await fill(tester, 'trip-title', 'Updated trip');
      await fill(tester, 'trip-destination', 'Tokyo');
      expect(find.text('자동 인식 국가: 일본'), findsOneWidget);
      await fill(tester, 'trip-start', '2100-01-01');
      await fill(tester, 'trip-end', '2100-01-05');
      await tap(tester, find.text('저장'));
      expect(find.text('Updated trip'), findsWidgets);
      expect(find.text('2100.01.01 – 2100.01.05 · Tokyo'), findsOneWidget);
      await tap(tester, find.byType(BackButton));
      expect(find.text('Updated trip'), findsOneWidget);
      expect(find.text('예정 1'), findsOneWidget);
      expect(find.text('방문 국가 0개'), findsOneWidget);
      expect(find.text('여행일 합계 5일'), findsOneWidget);
      await mount(tester, store);
      expect(find.text('Updated trip'), findsOneWidget);
      expect(find.text('2100.01.01 – 2100.01.05 · Tokyo'), findsOneWidget);
    },
  );

  testWidgets(
    'create persists server ID, details and dates after rebuilding the page',
    (tester) async {
      addTearDown(tester.view.reset);
      final store = Store();
      await mount(tester, store);
      await tap(tester, find.byType(FloatingActionButton));
      await fill(tester, 'trip-title', 'New trip');
      await fill(tester, 'trip-destination', 'Osaka');
      await fill(tester, 'trip-start', '2001-01-01');
      await fill(tester, 'trip-end', '2001-01-02');
      await tap(tester, find.text('여행 추가'));
      expect(find.text('총 여행 2'), findsOneWidget);
      expect(find.text('방문 국가 2개'), findsOneWidget);
      await mount(tester, store);
      expect(find.text('New trip'), findsOneWidget);
      expect(find.byKey(const ValueKey('favorite-2')), findsOneWidget);
      expect(store.rows[2]!.endDate, '2001-01-02');
      expect(store.rows[2]!.countryCode, 'JP');
    },
  );

  testWidgets('failed mutations keep original data and editor open for retry', (
    tester,
  ) async {
    addTearDown(tester.view.reset);
    final store = Store()..fail = true;
    await mount(tester, store);
    await tap(tester, find.byKey(const ValueKey('favorite-1')));
    expect(find.text('즐겨찾기 0'), findsOneWidget);
    await tap(tester, find.byKey(const ValueKey('delete-1')));
    await tap(tester, find.text('삭제'));
    expect(find.text('Original trip'), findsOneWidget);
    expect(find.text('총 여행 1'), findsOneWidget);
    await tap(tester, find.text('Original trip'));
    await tap(tester, find.byTooltip('여행 정보 수정'));
    await fill(tester, 'trip-title', 'Changed');
    await tap(tester, find.text('저장'));
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.textContaining('저장 실패'), findsWidgets);
    expect(store.rows[1]!.title, 'Original trip');
    store.fail = false;
    await tap(tester, find.text('저장'));
    expect(find.byType(AlertDialog), findsNothing);
    expect(store.rows[1]!.title, 'Changed');
  });

  testWidgets(
    'invalid dates cannot be saved and unknown destinations show guidance',
    (tester) async {
      addTearDown(tester.view.reset);
      final store = Store();
      await mount(tester, store);
      await tap(tester, find.byType(FloatingActionButton));
      await fill(tester, 'trip-title', 'New');
      await fill(tester, 'trip-destination', 'City');
      await fill(tester, 'trip-start', '2026-02-30');
      await tap(tester, find.text('여행 추가'));
      expect(find.textContaining('국가를 인식하지 못했어요.'), findsOneWidget);
      expect(find.byKey(const ValueKey('country-code')), findsNothing);
      expect(find.text('올바른 날짜를 입력해 주세요 (YYYY-MM-DD).'), findsWidgets);
      expect(store.rows.length, 1);
      await fill(tester, 'trip-start', '2026-03-02');
      await fill(tester, 'trip-end', '2026-03-01');
      await tap(tester, find.text('여행 추가'));
      expect(find.text('종료일은 출발일보다 빠를 수 없어요.'), findsOneWidget);
      expect(store.rows.length, 1);
    },
  );
  testWidgets(
    'editing an unknown place clears old country and photo without blocking persistence',
    (tester) async {
      addTearDown(tester.view.reset);
      final store = Store();
      await mount(tester, store);
      await tap(tester, find.text('Original trip'));
      await tap(tester, find.byTooltip('여행 정보 수정'));
      expect(find.byKey(const ValueKey('country-code')), findsNothing);
      for (final name in ['Tokyo', '도쿄', '东京都']) {
        await fill(tester, 'trip-destination', name);
        expect(find.text('자동 인식 국가: 일본'), findsOneWidget);
      }
      await fill(tester, 'trip-destination', 'Unknown city');
      expect(find.textContaining('국가를 인식하지 못했어요.'), findsOneWidget);
      await tap(tester, find.text('저장'));
      expect(store.rows[1]!.countryCode, '');
      expect(store.rows[1]!.image, defaultTripPhoto);
      await tap(tester, find.byType(BackButton));
      expect(find.text('방문 국가 0개'), findsOneWidget);
      await mount(tester, store);
      expect(
        tester.widget<NetImage>(find.byType(NetImage).first).url,
        defaultTripPhoto,
      );
      expect(find.text('총 여행 1'), findsOneWidget);
    },
  );

  testWidgets(
    'auto recognition updates country totals after adding, editing and deleting trips',
    (tester) async {
      addTearDown(tester.view.reset);
      final store = Store();
      store.rows[1] = original.copyWith(destination: 'Tokyo');
      await mount(tester, store);
      expect(find.text('방문 국가 1개'), findsOneWidget);
      await tap(tester, find.byType(FloatingActionButton));
      await fill(tester, 'trip-title', 'Osaka trip');
      await fill(tester, 'trip-destination', '오사카');
      await fill(tester, 'trip-start', '2000-01-01');
      await fill(tester, 'trip-end', '2000-01-03');
      await tap(tester, find.text('여행 추가'));
      expect(find.text('총 여행 2'), findsOneWidget);
      expect(find.text('방문 국가 1개'), findsOneWidget);
      await tap(tester, find.text('Original trip'));
      await tap(tester, find.byTooltip('여행 정보 수정'));
      await fill(tester, 'trip-destination', '巴黎');
      expect(find.text('자동 인식 국가: 프랑스'), findsOneWidget);
      await tap(tester, find.text('저장'));
      await tap(tester, find.byType(BackButton));
      expect(find.text('방문 국가 2개'), findsOneWidget);
      await tap(tester, find.byKey(const ValueKey('delete-1')));
      await tap(tester, find.text('삭제'));
      expect(find.text('방문 국가 1개'), findsOneWidget);
      await mount(tester, store);
      expect(find.text('방문 국가 1개'), findsOneWidget);
    },
  );

  testWidgets(
    'destination photos agree across home, detail, recap and fresh reads',
    (tester) async {
      addTearDown(tester.view.reset);
      final store = Store();
      store.rows[1] = original.copyWith(
        destination: 'Tokyo',
        image: 'stale-photo',
      );
      final expected = resolveDestination('Tokyo')!.photoUrl;
      await mount(tester, store);
      expect(
        tester.widget<NetImage>(find.byType(NetImage).first).url,
        expected,
      );
      await tap(tester, find.text('Original trip'));
      expect(
        tester.widget<NetImage>(find.byType(NetImage).first).url,
        expected,
      );
      await tap(tester, find.byTooltip('여행 정보 수정'));
      await fill(tester, 'trip-destination', 'Paris');
      await tap(tester, find.text('저장'));
      final paris = resolveDestination('Paris')!.photoUrl;
      expect(tester.widget<NetImage>(find.byType(NetImage).first).url, paris);
      await tap(tester, find.byType(BackButton));
      await mount(tester, store);
      expect(tester.widget<NetImage>(find.byType(NetImage).first).url, paris);
      await tap(tester, find.text('기록 모아보기'));
      expect(find.text('나의 여행 돌아보기'), findsOneWidget);
      expect(
        tester
            .widgetList<NetImage>(find.byType(NetImage))
            .every((image) => image.url == paris),
        isTrue,
      );
    },
  );
}
