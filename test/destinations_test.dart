import 'package:flutter_test/flutter_test.dart';
import 'package:mid_project_template/destinations.dart';
import 'package:mid_project_template/models.dart';
import 'package:mid_project_template/trip_insights.dart';

void main() {
  const trip = Item(
    id: 1,
    title: 'Trip',
    subtitle: '',
    image: 'wrong-photo',
    destination: 'Tokyo',
    countryCode: 'US',
    startDate: '2000-01-01',
    endDate: '2000-01-03',
  );

  test(
    'English, Korean and Chinese aliases resolve to the same city and country',
    () {
      final tokyo = resolveDestination('Tokyo')!;
      for (final name in [
        '  tOkYo  ',
        '도쿄',
        '东京',
        '东京都',
        '東京都',
        '일본 도쿄',
        '日本东京',
        'Tokyo, Japan',
      ]) {
        expect(resolveDestination(name), same(tokyo), reason: name);
      }
      for (final names in [
        ['Paris', '파리', '巴黎'],
        ['Osaka', '오사카', '大阪'],
        ['Seoul', '서울', '首尔'],
        ['London', '런던', '伦敦'],
        ['New York', '뉴욕', '纽约'],
        ['Beijing', '베이징', '北京'],
        ['Shanghai', '상하이', '上海'],
        ['Singapore', '싱가포르', '新加坡'],
      ]) {
        for (final alias in names.skip(1)) {
          expect(
            resolveDestination(alias),
            same(resolveDestination(names.first)),
          );
        }
      }
      expect(resolveDestination('  New   York  ')!.countryCode, 'US');
    },
  );

  test(
    'unknown, partial, conflicting and ambiguous places never guess a country',
    () {
      for (final name in [
        '',
        'Unknown city',
        'Tokyo Hotel',
        'NotTokyo',
        'Tokyo / Paris',
        'York',
        'Paris, Texas',
        'Tokyo, Korea',
        '서울 아닌 곳',
        '东京附近未知地点',
      ]) {
        expect(resolveDestination(name), isNull, reason: name);
        final unknown = trip.copyWith(destination: name);
        expect(unknown.inferredCountryCode, isEmpty);
        expect(unknown.photoUrl, defaultTripPhoto);
        expect(unknown.toJson()['countryCode'], '');
      }
    },
  );

  test(
    'photo IDs are city-specific, stable across reload and independent of stale images',
    () {
      final tokyo = trip.photoUrl;
      final paris = trip.copyWith(destination: 'Paris').photoUrl;
      expect(tokyo, contains('photo-1540959733332-eab4deabeeaf'));
      expect(paris, contains('photo-1502602898657-3e91760cbb34'));
      expect(tokyo, isNot(paris));
      expect(trip.copyWith(destination: '도쿄').photoUrl, tokyo);
      final saved = trip.toJson();
      expect(saved['image'], tokyo);
      expect(saved['countryCode'], 'JP');
      final refreshed = Item.fromJson(saved)!;
      expect(refreshed.photoUrl, tokyo);
      expect(refreshed.copyWith(favorite: true).photoUrl, tokyo);
      expect(refreshed.copyWith(title: 'New title').photoUrl, tokyo);
      expect(trip.copyWith(destination: 'Busan').inferredCountryCode, 'KR');
      expect(
        trip.copyWith(destination: 'Busan').photoUrl,
        isNot(defaultTripPhoto),
      );
    },
  );

  test(
    'legacy subtitle destinations resolve but titles and tags never imply a country',
    () {
      const legacy = Item(
        id: 1,
        title: 'Trip',
        subtitle: '2000.01.01 · 일본 도쿄',
        image: 'wrong',
      );
      expect(legacy.inferredCountryCode, 'JP');
      expect(legacy.photoUrl, trip.photoUrl);
      const unknown = Item(
        id: 2,
        title: 'Tokyo',
        subtitle: 'Unknown',
        image: '',
        tags: ['Paris'],
      );
      expect(unknown.inferredCountryCode, isEmpty);
      expect(unknown.photoUrl, defaultTripPhoto);
      expect(
        legacy.copyWith(destination: 'Unknown city').inferredCountryCode,
        isEmpty,
      );
    },
  );

  test(
    'country statistics use recognition, deduplicate cities and exclude future/deleted trips',
    () {
      final items = [
        trip,
        trip.copyWith(destination: '오사카'),
        trip.copyWith(destination: '东京'),
        trip.copyWith(
          destination: 'Paris',
          startDate: '2100-01-01',
          endDate: '2100-01-03',
        ),
        trip.copyWith(destination: 'London', deleted: true),
        trip.copyWith(destination: 'Unknown city', countryCode: 'FR'),
      ];
      expect(
        TripSummary(items, {}, DateTime(2026, 10, 29)).visitedCountries,
        1,
      );
      expect(
        TripSummary(
          [...items, trip.copyWith(destination: '파리')],
          {},
          DateTime(2026, 10, 29),
        ).visitedCountries,
        2,
      );
      expect(
        TripSummary(
          [
            trip.copyWith(
              destination: 'Paris',
              startDate: '2026-10-29',
              endDate: '2026-10-30',
            ),
          ],
          {},
          DateTime(2026, 10, 29),
        ).visitedCountries,
        1,
      );
    },
  );
}
