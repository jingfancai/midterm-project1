import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'models.dart';

const _apiBaseOverride = String.fromEnvironment('API_BASE');

/// json-server 주소. API_BASE를 넘기면 그 값, 아니면 실행 대상에 맞는 기본값.
String get apiBase {
  if (_apiBaseOverride.isNotEmpty) return _apiBaseOverride;
  // Android 에뮬레이터 안의 localhost는 에뮬레이터 자신 → PC는 10.0.2.2
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    return 'http://10.0.2.2:3000';
  }
  return 'http://localhost:3000';
}

/// loading(=slow) · error · empty — 그 외 값이면 평소처럼 서버에서 가져온다.
const demoState = String.fromEnvironment('DEMO_STATE');

/// 화면에 그대로 보여 줄 수 있는 오류 문장
class ApiException implements Exception {
  const ApiException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// All HTTP operations live here. Pass a client for protocol-level tests.
class TripApi {
  TripApi({http.Client? client, String? base})
    : _client = client ?? http.Client(),
      _base = base ?? apiBase;

  final http.Client _client;
  final String _base;

  Future<http.Response> _request(
    String method,
    String path, [
    Map<String, Object>? body,
  ]) async {
    try {
      final request = http.Request(method, Uri.parse('$_base/$path'));
      if (body != null) {
        request.headers['Content-Type'] = 'application/json; charset=utf-8';
        request.body = jsonEncode(body);
      }
      final response = await http.Response.fromStream(
        await _client.send(request).timeout(const Duration(seconds: 10)),
      ).timeout(const Duration(seconds: 10));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(
          '저장 또는 조회에 실패했어요 (HTTP ${response.statusCode}). 서버 설정을 확인하고 다시 시도해 주세요.',
        );
      }
      return response;
    } on ApiException {
      rethrow;
    } on Exception {
      throw const ApiException(
        '서버에 연결하지 못했어요. 연결을 확인한 뒤 목록을 새로고침해 저장 여부를 확인해 주세요.',
      );
    }
  }

  Object? _decode(http.Response response) {
    try {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException {
      throw const ApiException('서버 응답 형식이 올바르지 않아요.');
    }
  }

  Future<List<Object?>> _list(String path) async {
    final data = _decode(await _request('GET', path));
    if (data is! List) throw const ApiException('서버가 목록을 반환하지 않았어요.');
    return data;
  }

  Future<List<Item>> load() async {
    final data = await _list('items?deleted_ne=true');
    return data
        .map(Item.fromJson)
        .nonNulls
        .where((item) => !item.deleted)
        .toList();
  }

  Future<List<Note>> notes(int itemId) async => (await _list(
    'notes?itemId=$itemId',
  )).map(Note.fromJson).nonNulls.toList();

  Future<Item> _save(
    String method,
    String path,
    Map<String, Object> body,
  ) async {
    final item = Item.fromJson(_decode(await _request(method, path, body)));
    if (item == null) {
      throw const ApiException('저장 결과를 읽지 못했어요. 목록을 새로고침해 주세요.');
    }
    return item;
  }

  Future<Item> create(Item item) =>
      _save('POST', 'items', item.toJson(includeId: false));
  Future<Item> update(Item item) =>
      _save('PATCH', 'items/${item.id}', item.toJson());
}

final _api = TripApi();
Future<List<Item>> fetchItems() async {
  if (demoState == 'error') throw const ApiException('DEMO_STATE=error');
  if (demoState == 'empty') return [];
  if (demoState == 'loading' || demoState == 'slow') {
    await Future<void>.delayed(const Duration(seconds: 3));
  }
  return _api.load();
}

Future<List<Note>> fetchNotes(int itemId) => _api.notes(itemId);
Future<Item> createItem(Item item) => _api.create(item);
Future<Item> updateItem(Item item) => _api.update(item);
typedef ItemSaver = Future<Item> Function(Item item);

/// 화면이 데이터를 받는 함수 모양 — 테스트에서는 가짜 함수를 넣는다.
typedef ItemsLoader = Future<List<Item>> Function();
typedef NotesLoader = Future<List<Note>> Function(int itemId);
