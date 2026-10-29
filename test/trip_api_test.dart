import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mid_project_template/api.dart';

void main() {
  test('travel and notes requests are GET-only with no body', () async {
    final paths = <String>[];
    final api = TripApi(
      base: 'http://example.test',
      client: MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.body, isEmpty);
        paths.add(request.url.toString());
        return http.Response('[]', 200);
      }),
    );
    expect(await api.load(), isEmpty);
    expect(await api.notes(1), isEmpty);
    expect(paths, [
      'http://example.test/items',
      'http://example.test/notes?itemId=1',
    ]);
  });
  test('sample records load unchanged on every GET', () async {
    final api = TripApi(
      client: MockClient(
        (request) async => http.Response(
          jsonEncode([
            {
              'id': 1,
              'title': 'Trip',
              'subtitle': '2026.09.12 · Tokyo',
              'image': '',
            },
          ]),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        ),
      ),
    );
    final first = await api.load();
    final refreshed = await api.load();
    expect(first.single.title, refreshed.single.title);
    expect(first.single.destinationName, 'Tokyo');
  });
  test(
    'GET HTTP, network and malformed-response errors remain visible',
    () async {
      for (final response in [
        http.Response('Forbidden', 403),
        http.Response('error', 500),
        http.Response('bad', 200),
        http.Response('{}', 200),
      ]) {
        final api = TripApi(client: MockClient((_) async => response));
        await expectLater(api.load(), throwsA(isA<ApiException>()));
      }
      await expectLater(
        TripApi(
          client: MockClient(
            (_) async => throw http.ClientException('offline'),
          ),
        ).load(),
        throwsA(isA<ApiException>()),
      );
    },
  );
}
