import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mid_project_template/destinations.dart';
import 'package:mid_project_template/models.dart';
import 'package:mid_project_template/widgets.dart';

void main() {
  test(
    'all 50 cities have distinct dedicated photos and recorded reusable licenses',
    () async {
      final data =
          jsonDecode(await rootBundle.loadString(destinationAsset)) as Map;
      final cities = data['cities'] as List;
      expect(cities, hasLength(50));
      expect(cities.map((city) => city['photoUrl']).toSet(), hasLength(50));
      for (final city in cities) {
        expect(city['photoUrl'], isNot(data['defaultPhotoUrl']));
        final credit = city['photoSource'] as Map;
        expect(credit['title'], isNotEmpty);
        expect(Uri.parse(credit['pageUrl'] as String).scheme, 'https');
        expect(Uri.parse(credit['licenseUrl'] as String).scheme, 'https');
        expect([
          'CC0',
          'Public domain',
          'Unsplash License',
        ], contains(credit['license']));
        final uri = Uri.parse(city['photoUrl'] as String);
        expect([
          'images.unsplash.com',
          'thumb.wikimedia.org',
          'upload.wikimedia.org',
        ], contains(uri.host));
        expect(uri.queryParameters.keys, isNot(contains('random')));
      }
    },
  );

  test(
    'Shanghai, Beijing and Jeju aliases retain the same dedicated photo after saving and reload',
    () {
      final urls = <String>{};
      for (final aliases in [
        ['Shanghai', '상하이', '上海'],
        ['Beijing', '베이징', '北京'],
        ['Jeju Island', '제주도', '济州岛'],
      ]) {
        final photo = resolveDestination(aliases.first)!.photoUrl;
        expect(photo, isNot(defaultTripPhoto));
        urls.add(photo);
        for (final alias in aliases) {
          final item = Item(
            id: 1,
            title: 'Trip',
            subtitle: '',
            image: 'stale-photo',
            destination: alias,
          );
          expect(item.photoUrl, photo);
          expect(Item.fromJson(item.toJson())!.photoUrl, photo);
          expect(item.copyWith(favorite: true).photoUrl, photo);
        }
      }
      expect(urls, hasLength(3));
      expect(resolveDestination('Unknown city'), isNull);
      expect(resolveDestination('Gangwon')!.photoUrl, defaultTripPhoto);
    },
  );

  testWidgets(
    'unavailable city photo falls back once to the neutral cover and then the existing icon',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NetImage(
              'https://example.invalid/unavailable-city.jpg',
              width: 128,
              height: 80,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final urls = tester
          .widgetList<Image>(find.byType(Image))
          .map((image) => (image.image as NetworkImage).url)
          .toList();
      expect(urls, [
        'https://example.invalid/unavailable-city.jpg',
        defaultTripPhoto,
      ]);
      expect(find.byIcon(Icons.image_outlined), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(Image), findsNWidgets(2));
    },
  );

  testWidgets(
    'an unavailable neutral cover does not recursively request itself',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: NetImage(defaultTripPhoto))),
      );
      await tester.pumpAndSettle();
      expect(find.byType(Image), findsOneWidget);
      expect(find.byIcon(Icons.image_outlined), findsOneWidget);
    },
  );
}
