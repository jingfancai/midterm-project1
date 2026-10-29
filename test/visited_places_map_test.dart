import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mid_project_template/destinations.dart';
import 'package:mid_project_template/models.dart';
import 'package:mid_project_template/screens/c_result_sheet.dart';
import 'package:mid_project_template/trip_insights.dart';
import 'package:mid_project_template/visited_places_map.dart';

Item trip(
  int id,
  String destination, {
  String start = '2000-01-01',
  String end = '2000-01-03',
  bool deleted = false,
}) => Item(
  id: id,
  title: 'Trip $id',
  subtitle: '',
  image: '',
  destination: destination,
  startDate: start,
  endDate: end,
  deleted: deleted,
);

const tokyoMarker = ValueKey('map-marker-JP/tokyo');
const osakaMarker = ValueKey('map-marker-JP/osaka');

Future<void> mount(
  WidgetTester t,
  List<Item> items, {
  Size size = const Size(400, 800),
}) async {
  t.view.physicalSize = size;
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  await t.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: ResultSheet(items: items, onSelect: (_) {}),
      ),
    ),
  );
  await t.pumpAndSettle();
}

void main() {
  test(
    'all 50 cities have valid coordinates shared by every name alias',
    () async {
      final source = await rootBundle.loadString(destinationAsset);
      final data = jsonDecode(source) as Map<String, dynamic>;
      final cities = DestinationCatalog.parse(
        source,
      ).entries.where((d) => d.cityId != null);
      expect(cities, hasLength(50));
      for (final city in cities) {
        expect(city.latitude, inInclusiveRange(-90, 90));
        expect(city.longitude, inInclusiveRange(-180, 180));
        for (final alias in city.aliases) {
          final resolved = resolveDestination(alias)!;
          expect(resolved.latitude, city.latitude);
          expect(resolved.longitude, city.longitude);
        }
      }
      for (final values in [
        [91, 0],
        [0, 181],
        ['invalid', 0],
        [0, null],
      ]) {
        final copy = jsonDecode(jsonEncode(data));
        copy['cities'][0]['latitude'] = values[0];
        copy['cities'][0]['longitude'] = values[1];
        expect(
          () => DestinationCatalog.parse(jsonEncode(copy)),
          throwsFormatException,
        );
      }
    },
  );

  test('map and summary share visit eligibility and aliases deduplicate', () {
    final today = DateTime(2026, 10, 30);
    final items = [
      trip(1, 'Tokyo'),
      trip(2, '도쿄'),
      trip(3, '东京'),
      trip(4, 'Osaka', start: '2026-10-30', end: '2026-11-01'),
      trip(5, 'Paris', start: '2100-01-01', end: '2100-01-03'),
      trip(6, 'London', deleted: true),
      trip(7, 'Berlin', start: 'invalid'),
      trip(8, 'Unknown'),
      trip(9, 'Jeju Island'),
    ];
    final cities = visitedCities(items, today);
    expect(cities, hasLength(2));
    expect(
      cities
          .singleWhere((c) => c.destination.cityId == 'tokyo')
          .trips
          .map((t) => t.id),
      [1, 2, 3],
    );
    expect(TripSummary(items, {}, today).visitedCities, cities.length);
    expect(visitedCities([trip(1, 'Tokyo', deleted: true)], today), isEmpty);
    expect(
      visitedCities([trip(1, 'Paris')], today).single.destination.cityId,
      'paris',
    );
  });

  testWidgets(
    'recap replaces Featured Memory with local map and preserves records',
    (t) async {
      await mount(t, [
        trip(1, 'Tokyo'),
        trip(2, '도쿄'),
        trip(3, 'Osaka'),
        trip(4, 'Paris', start: '2100-01-01', end: '2100-01-03'),
        trip(5, 'London', deleted: true),
      ]);
      expect(find.text('FEATURED MEMORY'), findsNothing);
      expect(find.byType(VisitedPlacesMap), findsOneWidget);
      expect(find.byKey(tokyoMarker), findsOneWidget);
      expect(find.byKey(osakaMarker), findsOneWidget);
      expect(find.byKey(const ValueKey('map-marker-FR/paris')), findsNothing);
      expect(find.byKey(const ValueKey('map-marker-GB/london')), findsNothing);
      expect(find.text('Trip 5'), findsNothing);
      // Future records remain in ALL MY TRIPS even though not marked as visited.
      await t.ensureVisible(find.text('Trip 4'));
      await t.pumpAndSettle();
      expect(find.text('Trip 4'), findsOneWidget);
      final image = t
          .widgetList<Image>(find.byType(Image))
          .singleWhere((image) => image.image is AssetImage);
      expect(
        (image.image as AssetImage).assetName,
        'assets/images/world_map.png',
      );
    },
  );

  testWidgets(
    'overlapping markers show every nearby city and all eligible trip titles',
    (t) async {
      await mount(t, [
        trip(1, 'Tokyo'),
        trip(2, '도쿄'),
        trip(3, 'Osaka'),
        trip(4, 'Tokyo', start: '2100-01-01', end: '2100-01-03'),
        trip(5, 'Tokyo', deleted: true),
      ]);
      await t.ensureVisible(find.byKey(tokyoMarker));
      await t.pumpAndSettle();
      // Dots overlap at world scale; either hit must expose all nearby cities.
      await t.tapAt(t.getCenter(find.byKey(tokyoMarker)));
      await t.pumpAndSettle();
      final dialog = find.byType(AlertDialog);
      expect(
        find.descendant(of: dialog, matching: find.text('도쿄 · 일본')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: dialog, matching: find.text('오사카 · 일본')),
        findsOneWidget,
      );
      for (final id in [1, 2, 3]) {
        expect(
          find.descendant(of: dialog, matching: find.text('• Trip $id')),
          findsOneWidget,
        );
      }
      expect(
        find.descendant(of: dialog, matching: find.text('• Trip 4')),
        findsNothing,
      );
      expect(
        find.descendant(of: dialog, matching: find.text('• Trip 5')),
        findsNothing,
      );
      await t.tap(find.descendant(of: dialog, matching: find.text('닫기')));
      await t.pumpAndSettle();
      expect(dialog, findsNothing);
    },
  );

  testWidgets(
    'empty visit map explains future, unrecognized and region exclusions',
    (t) async {
      await mount(t, [
        trip(1, 'Tokyo', start: '2100-01-01', end: '2100-01-03'),
        trip(2, 'Unknown'),
        trip(3, 'Jeju Island'),
      ]);
      expect(find.byKey(tokyoMarker), findsNothing);
      expect(find.textContaining('표시할 방문 도시가 없어요'), findsOneWidget);
      expect(t.takeException(), isNull);
    },
  );

  for (final size in [const Size(320, 480), const Size(1024, 768)]) {
    testWidgets('map and full records remain reachable at $size', (t) async {
      await mount(
        t,
        List.generate(20, (i) => trip(i + 1, 'Tokyo')),
        size: size,
      );
      final map = find.byType(VisitedPlacesMap);
      await t.ensureVisible(map);
      await t.pumpAndSettle();
      expect(t.getSize(map).width, lessThanOrEqualTo(size.width));
      final record = find.text('Trip 20');
      await t.ensureVisible(record);
      await t.pumpAndSettle();
      await t.tap(record);
      await t.ensureVisible(find.text('닫기'));
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
    });
  }
}
