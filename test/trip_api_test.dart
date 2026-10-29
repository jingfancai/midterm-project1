import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mid_project_template/api.dart';
import 'package:mid_project_template/models.dart';

void main() {
  const item = Item(
    id: 4,
    title: '여행',
    subtitle: '',
    image: '',
    destination: '도쿄',
    countryCode: 'JP',
    startDate: '2026-06-14',
    endDate: '2026-06-18',
  );

  test(
    'POST omits local ID and uses server ID; PATCH serializes persisted fields',
    () async {
      final methods = <String>[];
      final api = TripApi(
        base: 'http://example.test',
        client: MockClient((request) async {
          methods.add(request.method);
          expect(request.headers['content-type'], contains('application/json'));
          final data = jsonDecode(request.body) as Map<String, dynamic>;
          expect(data['countryCode'], 'JP');
          expect(data['startDate'], '2026-06-14');
          expect(data['destination'], '도쿄');
          if (request.method == 'POST') {
            expect(data.containsKey('id'), isFalse);
            return http.Response(
              jsonEncode({...data, 'id': 42}),
              201,
              headers: {'content-type': 'application/json; charset=utf-8'},
            );
          }
          expect(request.url.path, '/items/42');
          expect(data['favorite'], isTrue);
          expect(data['deleted'], isTrue);
          return http.Response(
            jsonEncode(data),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }),
      );
      final created = await api.create(item);
      expect(created.id, 42);
      final saved = await api.update(
        created.copyWith(favorite: true, deleted: true),
      );
      expect(saved.favorite, isTrue);
      expect(saved.deleted, isTrue);
      expect(methods, ['POST', 'PATCH']);
    },
  );

  test(
    'fresh reads preserve favorites and structured data, excluding deleted trips',
    () async {
      final client = MockClient((request) async {
        expect(request.url.queryParameters['deleted_ne'], 'true');
        return http.Response(
          jsonEncode([
            item.copyWith(favorite: true).toJson(),
            item.copyWith(deleted: true).toJson(),
          ]),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });
      for (var refresh = 0; refresh < 2; refresh++) {
        final loaded = await TripApi(
          base: 'http://example.test',
          client: client,
        ).load();
        expect(loaded, hasLength(1));
        expect(loaded.single.favorite, isTrue);
        expect(loaded.single.subtitle, contains('도쿄'));
        expect(loaded.single.endDate, '2026-06-18');
      }
    },
  );

  test(
    'HTTP errors and malformed responses never report a successful save',
    () async {
      for (final response in [
        http.Response('Forbidden', 403),
        http.Response('error', 500),
        http.Response('not JSON', 200),
        http.Response('{}', 200),
      ]) {
        final api = TripApi(client: MockClient((_) async => response));
        await expectLater(api.update(item), throwsA(isA<ApiException>()));
      }
      final api = TripApi(
        client: MockClient((_) async => throw http.ClientException('offline')),
      );
      await expectLater(api.create(item), throwsA(isA<ApiException>()));
    },
  );
}
