import 'package:flutter_test/flutter_test.dart';
import 'package:mid_project_template/models.dart';
import 'package:mid_project_template/trip_insights.dart';

Item trip(
  int id,
  String title,
  String subtitle, [
  List<String> tags = const [],
]) => Item(id: id, title: title, subtitle: subtitle, image: '', tags: tags);

void main() {
  test(
    'date parsing handles abbreviated ranges, leap days and year rollover',
    () {
      expect(TripDates.parse('2026.09.12 – 09.15 · 제주')!.days, 4);
      expect(TripDates.parse('2026.12.30 – 01.02 · 서울')!.days, 4);
      expect(TripDates.parse('2028.02.28 – 2028.03.01 · 서울')!.days, 3);
      expect(TripDates.parse('2026.07.05 · 강원도')!.days, 1);
      for (final invalid in [
        '설명',
        '2026.02.30 · 서울',
        '2026.09.12 – 09.11 · 서울',
        '2026.09.12 – bad',
      ]) {
        expect(TripDates.parse(invalid), isNull, reason: invalid);
      }
    },
  );

  test('status boundaries include both the first and last travel days', () {
    final item = trip(1, 'Trip', '2026.09.12 – 09.15 · 제주');
    expect(tripStatus(item, DateTime(2026, 9, 11)), TripStatus.upcoming);
    expect(tripStatus(item, DateTime(2026, 9, 12, 23)), TripStatus.ongoing);
    expect(tripStatus(item, DateTime(2026, 9, 15)), TripStatus.ongoing);
    expect(tripStatus(item, DateTime(2026, 9, 16)), TripStatus.past);
    expect(
      tripStatus(trip(2, 'Unknown', ''), DateTime(2026)),
      TripStatus.unknown,
    );
  });

  final items = [
    trip(1, 'Tokyo Summer', '2026.06.14 – 06.18 · 일본 도쿄', ['일본', '바다']),
    trip(2, 'Jeju', '2026.09.12 – 09.15 · 제주도', ['바다']),
    trip(3, 'Alpha', '날짜 미정'),
  ];

  List<Item> select({
    String query = '',
    bool favoritesOnly = false,
    TripSort sort = TripSort.newest,
  }) => selectTrips(
    items,
    query: query,
    favorites: {1},
    favoritesOnly: favoritesOnly,
    sort: sort,
  );

  test(
    'search combines title, destination and tag terms, independent of case',
    () {
      expect(select(query: '  TOKYO 일본 바다 ').map((e) => e.id), [1]);
      expect(select(query: '바다').map((e) => e.id), [2, 1]);
      expect(select(query: '제주', favoritesOnly: true), isEmpty);
      expect(select(favoritesOnly: true).map((e) => e.id), [1]);
      expect(select(query: 'missing'), isEmpty);
    },
  );

  test(
    'sorting uses real dates, keeps undated trips last, and leaves source intact',
    () {
      expect(select().map((e) => e.id), [2, 1, 3]);
      expect(select(sort: TripSort.oldest).map((e) => e.id), [1, 2, 3]);
      expect(select(sort: TripSort.title).map((e) => e.id), [3, 2, 1]);
      expect(items.map((e) => e.id), [1, 2, 3]);
    },
  );

  test(
    'statistics count active trips, favorites and inclusive calendar days',
    () {
      final summary = TripSummary(items, {1, 99}, DateTime(2026, 9, 13));
      expect(summary.total, 3);
      expect(summary.favoriteCount, 1);
      expect(summary.days, 9);
      expect(summary.ongoing, 1);
      expect(summary.past, 1);
      expect(summary.upcoming, 0);
      expect(summary.unknown, 1);
      expect(TripSummary([], {1}, DateTime(2026)).days, 0);
    },
  );
}
