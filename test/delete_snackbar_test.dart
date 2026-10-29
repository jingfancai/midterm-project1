import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mid_project_template/models.dart';
import 'package:mid_project_template/screens/a_list_screen.dart';

const first = Item(
  id: 1,
  title: 'First trip',
  subtitle: '',
  image: '',
  destination: 'Tokyo',
);
const second = Item(
  id: 2,
  title: 'Second trip',
  subtitle: '',
  image: '',
  destination: 'Osaka',
);

Future<Map<int, Item>> mount(
  WidgetTester tester, {
  bool accessible = false,
}) async {
  tester.view.physicalSize = const Size(500, 1400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final rows = {1: first, 2: second};
  await tester.pumpWidget(
    MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(accessibleNavigation: accessible),
        child: child!,
      ),
      home: ListScreen(
        load: () async => rows.values.where((item) => !item.deleted).toList(),
        update: (item) async {
          rows[item.id] = item;
          return item;
        },
        loadNotes: (_) async => [],
      ),
    ),
  );
  await tester.pumpAndSettle();
  return rows;
}

Future<void> delete(WidgetTester tester, int id) async {
  final button = find.byKey(ValueKey('delete-$id'));
  await tester.ensureVisible(button);
  await tester.pumpAndSettle();
  await tester.tap(button);
  await tester.pumpAndSettle();
  await tester.tap(find.text('삭제'));
  await tester.pumpAndSettle();
}

Future<void> elapse(WidgetTester tester, Duration duration) async {
  await tester.pump(duration);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('successful deletion toast disappears after about four seconds', (
    tester,
  ) async {
    final rows = await mount(tester);
    await delete(tester, 1);
    expect(rows[1]!.deleted, isTrue);
    expect(find.text('First trip 여행이 삭제되었습니다.'), findsOneWidget);
    await elapse(tester, const Duration(seconds: 3));
    expect(find.text('실행 취소'), findsOneWidget);
    await elapse(tester, const Duration(seconds: 1));
    expect(find.byType(SnackBar), findsNothing);
    expect(rows[1]!.deleted, isTrue);
  });

  testWidgets('undo before timeout restores the correct deleted trip', (
    tester,
  ) async {
    final rows = await mount(tester);
    await delete(tester, 1);
    await elapse(tester, const Duration(seconds: 2));
    await tester.tap(find.text('실행 취소'));
    await tester.pumpAndSettle();
    expect(rows[1]!.deleted, isFalse);
    expect(find.text('First trip'), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets(
    'repeated deletions replace old and queued toasts; undo targets the latest trip',
    (tester) async {
      final rows = await mount(tester);
      await delete(tester, 1);
      final messenger = ScaffoldMessenger.of(
        tester.element(find.byType(ListScreen)),
      );
      messenger.showSnackBar(
        const SnackBar(content: Text('Queued old message')),
      );
      await delete(tester, 2);
      expect(find.text('First trip 여행이 삭제되었습니다.'), findsNothing);
      expect(find.text('Second trip 여행이 삭제되었습니다.'), findsOneWidget);
      expect(find.text('Queued old message'), findsNothing);
      await tester.tap(find.text('실행 취소'));
      await tester.pumpAndSettle();
      expect(rows[1]!.deleted, isTrue);
      expect(rows[2]!.deleted, isFalse);
      await elapse(tester, const Duration(seconds: 12));
      expect(find.byType(SnackBar), findsNothing);
      expect(find.text('Queued old message'), findsNothing);
    },
  );

  testWidgets(
    'accessibility grants extra undo time without keeping the toast forever',
    (tester) async {
      final rows = await mount(tester, accessible: true);
      await delete(tester, 1);
      await elapse(tester, const Duration(seconds: 5));
      expect(find.text('실행 취소'), findsOneWidget);
      await tester.tap(find.text('실행 취소'));
      await tester.pumpAndSettle();
      expect(rows[1]!.deleted, isFalse);
      await delete(tester, 2);
      await elapse(tester, const Duration(seconds: 9));
      expect(find.text('실행 취소'), findsOneWidget);
      await elapse(tester, const Duration(seconds: 1));
      expect(find.byType(SnackBar), findsNothing);
      expect(rows[2]!.deleted, isTrue);
    },
  );
}
