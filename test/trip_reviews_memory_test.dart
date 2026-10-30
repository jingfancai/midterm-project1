import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mid_project_template/models.dart';
import 'package:mid_project_template/screens/a_list_screen.dart';
import 'package:mid_project_template/screens/b_detail_screen.dart';
import 'package:mid_project_template/screens/c_result_sheet.dart';
import 'package:mid_project_template/travel_memory_card.dart';
import 'package:mid_project_template/trip_editor.dart';
import 'package:mid_project_template/trip_insights.dart';
import 'package:mid_project_template/visited_places_map.dart';

Item trip(
  int id, {
  String start = '2000-01-01',
  String end = '2000-01-03',
  String review = '',
  List<String> tags = const [],
}) => Item(
  id: id,
  title: 'Trip $id',
  subtitle: '',
  image: '',
  destination: 'Tokyo',
  startDate: start,
  endDate: end,
  review: review,
  tags: tags,
);
String iso(DateTime date) => date.toIso8601String().substring(0, 10);
void size(WidgetTester t, [Size value = const Size(400, 800)]) {
  t.view.physicalSize = value;
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
}

Future<void> fill(WidgetTester t, String key, String value) async {
  final field = find.byKey(ValueKey(key));
  await t.ensureVisible(field);
  await t.pumpAndSettle();
  await t.enterText(field, value);
  await t.pumpAndSettle();
}

Future<void> editor(
  WidgetTester t, {
  Item? item,
  required TripChange save,
}) async {
  size(t);
  await t.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => showDialog<void>(
              context: context,
              builder: (_) => TripEditor(item: item, save: save),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );
  await t.tap(find.text('open'));
  await t.pumpAndSettle();
}

void main() {
  test(
    'GET model supports review, copies can replace and clear tags/review',
    () {
      final item = Item.fromJson({
        'id': 1,
        'title': 'Trip',
        'subtitle': '',
        'image': '',
        'review': 'Full review',
        'tags': ['old'],
      })!;
      expect(item.review, 'Full review');
      final edited = item.copyWith(tags: ['new'], review: 'Edited');
      expect(edited.tags, ['new']);
      expect(edited.review, 'Edited');
      expect(item.copyWith(tags: [], review: '').tags, isEmpty);
      expect(item.review, 'Full review');
      expect(
        Item.fromJson({
          'id': 2,
          'title': '',
          'subtitle': '',
          'image': '',
        })!.review,
        '',
      );
    },
  );

  test(
    'permissions use calendar dates, inclusive ongoing dates and invalid/deleted safeguards',
    () {
      final today = DateTime(2026, 10, 30);
      final future = trip(1, start: '2026-10-31', end: '2026-11-02');
      final current = trip(2, start: '2026-10-30', end: '2026-10-30');
      final past = trip(3, start: '2026-10-01', end: '2026-10-29');
      expect(canReviewTrip(future, today), isFalse);
      expect(canCreateMemory(future, today), isFalse);
      expect(canReviewTrip(current, today), isTrue);
      expect(canCreateMemory(current, today), isFalse);
      expect(canCreateMemory(past, today), isTrue);
      expect(canReviewTrip(past.copyWith(deleted: true), today), isFalse);
      expect(canCreateMemory(past.copyWith(deleted: true), today), isFalse);
      expect(canReviewTrip(trip(4, start: 'invalid'), today), isFalse);
      expect(canCreateMemory(trip(4, start: 'invalid'), today), isFalse);
    },
  );

  testWidgets(
    'new past trip accepts optional review and deduplicated tags in memory',
    (t) async {
      Item? result;
      await editor(
        t,
        save: (item) async {
          result = item;
          return item;
        },
      );
      expect(
        t
            .widget<TextFormField>(find.byKey(const ValueKey('trip-review')))
            .enabled,
        isFalse,
      );
      await fill(t, 'trip-title', 'New trip');
      await fill(t, 'trip-destination', 'Tokyo');
      await fill(t, 'trip-start', '2000-01-01');
      await fill(t, 'trip-end', '2000-01-03');
      await fill(t, 'trip-tags', ' 휴가, 맛집，휴가, ');
      await fill(t, 'trip-review', '모든 감상을 남겨요.');
      await t.tap(find.text('여행 추가'));
      await t.pumpAndSettle();
      expect(result!.tags, ['휴가', '맛집']);
      expect(result!.review, '모든 감상을 남겨요.');
    },
  );

  testWidgets(
    'future trips can edit and remove tags while review stays disabled',
    (t) async {
      Item? result;
      await editor(
        t,
        item: trip(1, start: '2100-01-01', end: '2100-01-03', tags: ['old']),
        save: (item) async {
          result = item;
          return item;
        },
      );
      expect(
        t
            .widget<TextFormField>(find.byKey(const ValueKey('trip-review')))
            .enabled,
        isFalse,
      );
      await fill(t, 'trip-tags', '');
      await t.tap(find.text('저장'));
      await t.pumpAndSettle();
      expect(result!.tags, isEmpty);
      expect(result!.review, isEmpty);
    },
  );

  testWidgets(
    'ongoing trip can edit review and tags; future date changes warn and clear review',
    (t) async {
      Item? result;
      final today = iso(DateTime.now());
      await editor(
        t,
        item: trip(1, start: today, end: today, review: 'old', tags: ['old']),
        save: (item) async {
          result = item;
          return item;
        },
      );
      expect(
        t
            .widget<TextFormField>(find.byKey(const ValueKey('trip-review')))
            .enabled,
        isTrue,
      );
      await fill(t, 'trip-tags', 'new');
      await fill(t, 'trip-review', 'edited');
      await fill(t, 'trip-end', '2100-01-03');
      await fill(t, 'trip-start', '2100-01-01');
      expect(
        t
            .widget<TextFormField>(find.byKey(const ValueKey('trip-review')))
            .enabled,
        isFalse,
      );
      expect(find.text('예정된 날짜로 저장하면 기존 후기는 저장되지 않아요.'), findsOneWidget);
      await t.tap(find.text('저장'));
      await t.pumpAndSettle();
      expect(result!.tags, ['new']);
      expect(result!.review, '');
    },
  );

  testWidgets('B displays full review and all tags while A has no review', (
    t,
  ) async {
    size(t);
    final review = List.filled(20, '여행의 소중한 순간입니다.').join('\n');
    final item = trip(1, review: review, tags: ['one', 'two', 'three', 'four']);
    await t.pumpWidget(
      MaterialApp(
        home: DetailScreen(item: item, loadNotes: (_) async => []),
      ),
    );
    await t.pumpAndSettle();
    await t.scrollUntilVisible(
      find.byKey(const ValueKey('detail-review')),
      250,
      scrollable: find
          .descendant(
            of: find.byType(ListView).first,
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await t.pumpAndSettle();
    final text = t.widget<Text>(find.byKey(const ValueKey('detail-review')));
    expect(text.data, review);
    expect(text.maxLines, isNull);
    for (final tag in item.tags) {
      expect(find.text(tag), findsOneWidget);
    }
    await t.pumpWidget(
      MaterialApp(
        home: ListScreen(load: () async => [item], loadNotes: (_) async => []),
      ),
    );
    await t.pumpAndSettle();
    expect(find.text(review), findsNothing);
  });

  testWidgets(
    'C enables only completed memory cards and includes full fields',
    (t) async {
      size(t, const Size(500, 1400));
      final today = iso(DateTime.now());
      final items = [
        trip(1, review: 'Full review', tags: ['food', 'rest']),
        trip(2, start: today, end: today),
        trip(3, start: '2100-01-01', end: '2100-01-03'),
      ];
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResultSheet(items: items, onSelect: (_) {}),
          ),
        ),
      );
      await t.pumpAndSettle();
      for (final id in [2, 3]) {
        expect(
          t
              .widget<TextButton>(find.byKey(ValueKey('create-memory-$id')))
              .onPressed,
          isNull,
        );
      }
      final create = find.byKey(const ValueKey('create-memory-1'));
      await t.ensureVisible(create);
      await t.pumpAndSettle();
      await t.tap(create);
      await t.pumpAndSettle();
      final card = find.byType(TravelMemoryCard);
      for (final value in [
        'Trip 1',
        items.first.subtitle,
        'food',
        'rest',
        'Full review',
      ]) {
        expect(
          find.descendant(of: card, matching: find.text(value)),
          findsOneWidget,
        );
      }
      expect(t.takeException(), isNull);
    },
  );

  testWidgets('edited review/tags sync B to C and reset after GET refresh', (
    t,
  ) async {
    size(t, const Size(500, 1400));
    final original = trip(1);
    await t.pumpWidget(
      MaterialApp(
        home: ListScreen(
          load: () async => [original],
          loadNotes: (_) async => [],
        ),
      ),
    );
    await t.pumpAndSettle();
    await t.ensureVisible(find.text('Trip 1'));
    await t.tap(find.text('Trip 1'));
    await t.pumpAndSettle();
    await t.tap(find.byTooltip('여행 정보 수정'));
    await t.pumpAndSettle();
    await fill(t, 'trip-tags', '새 태그');
    await fill(t, 'trip-review', '수정한 전체 후기');
    await t.tap(find.text('저장'));
    await t.pumpAndSettle();
    expect(
      t.widget<Text>(find.byKey(const ValueKey('detail-review'))).data,
      '수정한 전체 후기',
    );
    await t.tap(find.byType(BackButton));
    await t.pumpAndSettle();
    expect(find.text('수정한 전체 후기'), findsNothing);
    expect(find.text('새 태그'), findsOneWidget);
    await t.ensureVisible(find.text('기록 모아보기'));
    await t.pumpAndSettle();
    await t.tap(find.text('기록 모아보기'));
    await t.pumpAndSettle();
    final create = find.byKey(const ValueKey('create-memory-1'));
    await t.ensureVisible(create);
    await t.pumpAndSettle();
    await t.tap(create);
    await t.pumpAndSettle();
    final card = find.byType(TravelMemoryCard);
    expect(
      find.descendant(of: card, matching: find.text('수정한 전체 후기')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: card, matching: find.text('새 태그')),
      findsOneWidget,
    );
    await t.tap(
      find.descendant(
        of: find.byType(TravelMemoryDialog),
        matching: find.text('닫기'),
      ),
    );
    await t.pumpAndSettle();
    final close = find.text('닫기');
    await t.ensureVisible(close);
    await t.pumpAndSettle();
    await t.tap(close);
    await t.pumpAndSettle();
    await t.ensureVisible(find.byKey(const ValueKey('refresh-trips')));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const ValueKey('refresh-trips')));
    await t.pumpAndSettle();
    expect(find.text('새 태그'), findsNothing);
    await t.ensureVisible(find.text('Trip 1'));
    await t.pumpAndSettle();
    await t.tap(find.text('Trip 1'));
    await t.pumpAndSettle();
    expect(
      t.widget<Text>(find.byKey(const ValueKey('detail-review'))).data,
      '아직 작성한 후기가 없어요.',
    );
  });

  testWidgets('direct memory dialog also blocks unfinished trips', (t) async {
    size(t);
    await t.pumpWidget(
      MaterialApp(
        home: TravelMemoryDialog(
          item: trip(1, start: '2100-01-01', end: '2100-01-03'),
          savePng: (_, _) async {},
        ),
      ),
    );
    await t.pumpAndSettle();
    expect(find.byType(TravelMemoryCard), findsNothing);
    expect(
      t
          .widget<FilledButton>(find.byKey(const ValueKey('export-memory-png')))
          .onPressed,
      isNull,
    );
  });

  testWidgets(
    'PNG captures full long card outside viewport with genuine PNG bytes',
    (t) async {
      size(t);
      final key = GlobalKey();
      final item = trip(
        1,
        review: List.filled(100, '모든 여행 후기를 PNG에 포함해요.').join('\n'),
        tags: ['one', 'two'],
      );
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: RepaintBoundary(
                key: key,
                child: SizedBox(
                  width: 320,
                  child: TravelMemoryCard(item: item),
                ),
              ),
            ),
          ),
        ),
      );
      await t.pumpAndSettle();
      final bytes = (await t.runAsync(() => captureMemoryPng(key)))!;
      expect(bytes.take(8), [137, 80, 78, 71, 13, 10, 26, 10]);
      final imageSize = await t.runAsync(() async {
        final codec = await ui.instantiateImageCodec(bytes);
        final frame = await codec.getNextFrame();
        final result = Size(
          frame.image.width.toDouble(),
          frame.image.height.toDouble(),
        );
        frame.image.dispose();
        codec.dispose();
        return result;
      });
      expect(imageSize!.height, greaterThan(800));
      expect(imageSize.height, lessThanOrEqualTo(8192));
      expect(t.takeException(), isNull);
    },
  );

  testWidgets(
    'export uses generated bytes and allows retry after a download failure',
    (t) async {
      size(t);
      Uint8List? saved;
      var calls = 0;
      await t.pumpWidget(
        MaterialApp(
          home: TravelMemoryDialog(
            item: trip(1),
            savePng: (bytes, name) async {
              calls++;
              expect(name, 'polarsteps-memory-1.png');
              if (calls == 1) throw StateError('download failed');
              saved = bytes;
            },
          ),
        ),
      );
      await t.pumpAndSettle();
      for (var attempt = 0; attempt < 2; attempt++) {
        await t.tap(find.byKey(const ValueKey('export-memory-png')));
        await t.pump();
        // Rasterization/PNG encoding completes outside the fake test clock.
        await t.runAsync(() async {
          await Future<void>.delayed(const Duration(milliseconds: 300));
        });
        await t.pumpAndSettle();
        if (attempt == 0) {
          expect(find.textContaining('이미지를 내보내지 못했어요'), findsOneWidget);
        }
      }
      expect(calls, 2);
      expect(saved!.take(8), [137, 80, 78, 71, 13, 10, 26, 10]);
    },
  );

  testWidgets(
    'map zoom, pan and reset transform the map and markers together',
    (t) async {
      size(t);
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(body: VisitedPlacesMap(items: [trip(1)])),
        ),
      );
      await t.pumpAndSettle();
      final viewer = find.byKey(const ValueKey('visited-map-viewer'));
      final widget = t.widget<InteractiveViewer>(viewer);
      final controller = widget.transformationController!;
      expect(
        find.descendant(
          of: viewer,
          matching: find.byKey(const ValueKey('map-marker-JP/tokyo')),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(of: viewer, matching: find.byType(Image)),
        findsOneWidget,
      );
      await t.tap(find.byTooltip('지도 확대'));
      await t.pumpAndSettle();
      expect(controller.value.getMaxScaleOnAxis(), closeTo(1.5, .01));
      final before = controller.value.getTranslation();
      await t.drag(viewer, const Offset(40, 25));
      await t.pumpAndSettle();
      expect(controller.value.getTranslation(), isNot(before));
      await t.tap(find.byTooltip('지도 축소'));
      await t.pumpAndSettle();
      expect(controller.value.getMaxScaleOnAxis(), closeTo(1, .01));
      await t.tap(find.byTooltip('지도 초기화'));
      await t.pumpAndSettle();
      expect(controller.value.isIdentity(), isTrue);
      expect(t.takeException(), isNull);
    },
  );
}
