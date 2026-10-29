import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mid_project_template/destinations.dart';
import 'package:mid_project_template/models.dart';
import 'package:mid_project_template/screens/c_result_sheet.dart';
import 'package:mid_project_template/trip_insights.dart';

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

void main() {
  test('Tokyo aliases share one city identity, distinct from Osaka', () {
    final key = resolveDestination('Tokyo')!.cityKey;
    expect(key, isNotNull);
    for (final alias in ['도쿄', '东京', '东京都', 'Tokyo, Japan']) {
      expect(resolveDestination(alias)!.cityKey, key);
    }
    expect(resolveDestination('Osaka')!.cityKey, isNot(key));
  });

  test(
    'Tokyo and Osaka count as two cities and one country across repeated trips',
    () {
      final summary = TripSummary(
        [
          trip(1, 'Tokyo'),
          trip(2, '도쿄'),
          trip(3, '东京'),
          trip(4, 'Osaka'),
          trip(5, '오사카'),
          trip(6, '大阪'),
          trip(7, 'Paris', start: '2100-01-01', end: '2100-01-03'),
          trip(8, 'London', deleted: true),
          trip(9, 'Unknown city'),
          trip(10, 'Berlin', start: 'invalid'),
        ],
        {},
        DateTime(2026, 10, 29),
      );
      expect(summary.visitedCities, 2);
      expect(summary.visitedCountries, 1);
    },
  );

  test(
    'today is included, future and unknown dates excluded, regions are not cities',
    () {
      final today = DateTime(2026, 10, 29);
      final summary = TripSummary(
        [
          trip(1, 'Tokyo', start: '2026-10-29', end: '2026-10-30'),
          trip(2, 'Osaka', start: '2026-10-30', end: '2026-11-01'),
          trip(3, 'Paris', start: '', end: ''),
          trip(4, '강원도'),
          trip(5, 'Jeju Island'),
        ],
        {},
        today,
      );
      expect(summary.visitedCities, 1);
      expect(summary.visitedCountries, 2);
      expect(TripSummary([], {}, today).visitedCities, 0);
      expect(
        TripSummary([trip(1, 'Tokyo', deleted: true)], {}, today).visitedCities,
        0,
      );
    },
  );

  testWidgets(
    'recap reuses statistic cards for two visited cities and one country at narrow width',
    (tester) async {
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResultSheet(
              items: [
                trip(1, 'Tokyo'),
                trip(2, '大阪'),
                trip(3, '도쿄'),
                trip(4, 'Paris', start: '2100-01-01', end: '2100-01-03'),
              ],
              onSelect: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      for (final entry in {'방문 도시 수': '2', '방문 국가': '1'}.entries) {
        final card = find
            .ancestor(
              of: find.text(entry.key),
              matching: find.byType(Container),
            )
            .first;
        expect(
          find.descendant(of: card, matching: find.text(entry.value)),
          findsOneWidget,
        );
      }
      expect(tester.takeException(), isNull);
    },
  );
}
