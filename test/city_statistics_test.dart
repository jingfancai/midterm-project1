import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mid_project_template/models.dart';
import 'package:mid_project_template/screens/c_result_sheet.dart';
import 'package:mid_project_template/trip_insights.dart';

void main() {
  test('recap values are examples rather than visited-city calculations', () {
    const summary = TripSummary();
    expect(summary.visitedCities, 4);
    expect(summary.visitedCountries, 2);
  });
  test('summary does not accept user data or dates', () {
    const summary = TripSummary();
    expect(summary.total, 4);
    expect(summary.upcoming, 1);
    expect(summary.ongoing, 1);
    expect(summary.past, 2);
  });
  test('display categories are provided in sample metadata', () {
    const item = Item(
      id: 1,
      title: '',
      subtitle: '2100.01.01',
      image: '',
      demoStatus: 'past',
    );
    expect(tripStatus(item), TripStatus.past);
  });
  testWidgets('recap example cards and notice fit narrow viewport', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ResultSheet(items: const [], onSelect: (_) {}),
        ),
      ),
    );
    await tester.pumpAndSettle();
    for (final entry in {'방문 도시 수': '4', '방문 국가': '2'}.entries) {
      final card = find
          .ancestor(of: find.text(entry.key), matching: find.byType(Container))
          .first;
      expect(
        find.descendant(of: card, matching: find.text(entry.value)),
        findsOneWidget,
      );
    }
    expect(find.textContaining('실제 데이터에서 계산하지 않습니다'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
