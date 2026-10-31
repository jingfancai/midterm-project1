import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('production API cannot issue arbitrary HTTP writes', () {
    final source = File('lib/api.dart').readAsStringSync();
    expect(source.replaceAll(RegExp(r'\s+'), ''), contains('_client.get('));
    expect(source, isNot(contains('http.Request(')));
    expect(source, isNot(contains('_client.send(')));
    expect(RegExp(r'\b(POST|PUT|PATCH|DELETE)\b').hasMatch(source), isFalse);
  });
  test(
    'production screens do not implement persistent mutations or extra profile route',
    () {
      expect(File('lib/screens/d_profile_screen.dart').existsSync(), isFalse);
      final source = Directory('lib')
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'))
          .map((file) => file.readAsStringSync())
          .join('\n');
      expect(
        RegExp(
          r'\b(createItem|updateItem|ItemSaver|ProfileScreen)\b',
        ).hasMatch(source),
        isFalse,
      );
      expect(
        RegExp(
          r'package:(provider|flutter_riverpod|flutter_bloc|shared_preferences|sqflite|hive|firebase_auth)/',
        ).hasMatch(source),
        isFalse,
      );
      expect(source, contains('// STATE:'));
      expect(
        RegExp(r'\.(post|put|patch|delete|send)\s*\(').hasMatch(source),
        isFalse,
      );
      expect(
        RegExp(
          r'\b(writeAsString|writeAsBytes|openWrite)\s*\(',
        ).hasMatch(source),
        isFalse,
      );
    },
  );
  test(
    'design guide has no placeholder elements or stale write authorization',
    () {
      final guide = File('docs/디자인가이드.md').readAsStringSync();
      expect(guide, isNot(contains('TODO')));
      expect(guide, isNot(contains('영구 저장 금지 규칙은 이 요청')));
      for (final marker in ['A-12', 'B-8', 'C-5', 'P01', 'P10', 'GET 전용']) {
        expect(guide, contains(marker));
      }
    },
  );
  test(
    'screen headers agree with guide element names, widgets and principles',
    () {
      final guide = File('docs/디자인가이드.md').readAsStringSync();
      for (final name in [
        'lib/screens/a_list_screen.dart',
        'lib/screens/b_detail_screen.dart',
        'lib/screens/c_result_sheet.dart',
        'lib/screens/d_travel_plans_dialog.dart',
        'lib/screens/e_recommendations_dialog.dart',
        'lib/travel_plans_section.dart',
      ]) {
        final source = File(name).readAsStringSync();
        final headers = RegExp(
          r'^// ([ABCDE]-\d+) (.+?) · (.+?) · (P\d+(?: · P\d+)*)$',
          multiLine: true,
        ).allMatches(source);
        expect(headers, isNotEmpty);
        for (final header in headers) {
          final row = guide
              .split('\n')
              .singleWhere((line) => line.startsWith('| ${header[1]} |'));
          final cells = row.split('|').map((value) => value.trim()).toList();
          expect(cells[2], header[2]);
          expect(cells[3], header[3]);
          expect(cells[5], header[4]);
        }
      }
      expect(guide, contains('**위험 있음**'));
    },
  );
}
