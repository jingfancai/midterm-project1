import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mid_project_template/destinations.dart';
import 'package:mid_project_template/models.dart';
import 'package:mid_project_template/trip_insights.dart';

void main() {
  late String source;
  late Map<String, dynamic> data;
  setUpAll(() async {
    source = await rootBundle.loadString(destinationAsset);
    data = jsonDecode(source) as Map<String, dynamic>;
  });

  test(
    'bundled catalog contains 50 cities in 35 countries with three-language names',
    () {
      final catalog = DestinationCatalog.parse(source);
      final cities = data['cities'] as List;
      expect(cities, hasLength(50));
      expect(cities.map((city) => city['countryCode']).toSet(), hasLength(35));
      expect(
        catalog.entries.where((entry) => entry.cityId != null),
        hasLength(50),
      );
      for (final city in cities) {
        expect(validCountryCodes, contains(city['countryCode']));
        final names = city['names'] as Map;
        expect(names['en'], matches(RegExp(r'[A-Za-z]')));
        expect(names['ko'], matches(RegExp(r'[가-힣]')));
        expect(names['zh'], matches(RegExp(r'[\u4e00-\u9fff]')));
        for (final name in [...names.values, ...?city['aliases'] as List?]) {
          final match = catalog.resolve(name as String)!;
          expect(match.cityKey, '${city['countryCode']}/${city['id']}');
          expect(resolveDestination(name)?.cityKey, match.cityKey);
          expect(match.countryName, city['countryName']);
          expect(match.photoUrl, city['photoUrl'] ?? catalog.defaultPhotoUrl);
        }
      }
    },
  );

  test(
    'all city names across three languages deduplicate to 50 cities and 35 countries',
    () {
      final trips = <Item>[];
      for (final city in data['cities'] as List) {
        for (final name in (city['names'] as Map).values) {
          trips.add(
            Item(
              id: trips.length + 1,
              title: 'Trip',
              subtitle: '',
              image: '',
              destination: name as String,
              startDate: '2000-01-01',
              endDate: '2000-01-02',
            ),
          );
        }
      }
      final summary = TripSummary(trips, {}, DateTime(2026, 10, 29));
      expect(summary.visitedCities, 50);
      expect(summary.visitedCountries, 35);
    },
  );

  test(
    'malformed data, duplicate aliases and duplicate IDs fail validation',
    () {
      for (final mutate in <void Function(Map<String, dynamic>)>[
        (value) => value['schemaVersion'] = 2,
        (value) => value['cities'][0]['names'].remove('ko'),
        (value) => value['cities'][1]['names']['en'] =
            value['cities'][0]['names']['en'],
        (value) => value['cities'].add(value['cities'][0]),
        (value) =>
            value['cities'][0]['photoUrl'] = 'http://example.test/photo.jpg',
        (value) => value['cities'] = 'invalid',
      ]) {
        final copy = jsonDecode(source) as Map<String, dynamic>;
        mutate(copy);
        expect(
          () => DestinationCatalog.parse(jsonEncode(copy)),
          throwsFormatException,
        );
      }
      expect(
        () => DestinationCatalog.parse('invalid JSON'),
        throwsFormatException,
      );
    },
  );

  test(
    'reloading the asset retains stable identity and photos without network lookup',
    () async {
      final before = resolveDestination('Tokyo')!;
      await loadDestinations();
      expect(resolveDestination('도쿄')!.cityKey, before.cityKey);
      expect(resolveDestination('东京')!.photoUrl, before.photoUrl);
      expect(resolveDestination('쿠알라룸푸르')!.countryCode, 'MY');
      expect(resolveDestination('阿姆斯特丹')!.countryCode, 'NL');
      expect(resolveDestination('Unknown city'), isNull);
      expect(resolveDestination('Jeju Island')!.cityId, isNull);
      expect(resolveDestination('Gangwon')!.cityId, isNull);
    },
  );
}
