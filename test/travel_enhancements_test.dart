import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mid_project_template/models.dart';
import 'package:mid_project_template/trip_plans.dart';
import 'package:mid_project_template/travel_plans_section.dart';
import 'package:mid_project_template/travel_notes.dart';
import 'package:mid_project_template/travel_memory_card.dart';
import 'package:mid_project_template/visited_places_map.dart';
import 'package:mid_project_template/screens/a_list_screen.dart';
import 'package:mid_project_template/screens/b_detail_screen.dart';

const trip = Item(id: 1, title: 'Tokyo first', subtitle: '', image: '', destination: 'Tokyo', startDate: '2000-01-01', endDate: '2000-01-03');
final red = File('test/fixtures/local_photo_red.png').readAsBytesSync();
final blue = File('test/fixtures/local_photo_blue.png').readAsBytesSync();
Future<void> tap(WidgetTester t, Finder f) async {
  await t.ensureVisible(f); await t.pumpAndSettle(); await t.tap(f); await t.pumpAndSettle();
}
void main() {
  testWidgets('record deletion cancels or removes only the selected record, then shows empty state', (t) async {
    final notes = [Note(id: 1, itemId: 1, text: 'One', date: '2000-01-01', photo: red), const Note(id: 2, itemId: 1, text: 'Two', date: '2000-01-02')];
    await t.pumpWidget(MaterialApp(home: Scaffold(body: TravelNotesTimeline(item: () => trip, load: (_) async => notes))));
    await t.pumpAndSettle();
    await tap(t, find.byKey(const ValueKey('delete-note-1')));
    await tap(t, find.text('취소')); expect(find.text('One'), findsOneWidget);
    await tap(t, find.byKey(const ValueKey('delete-note-1')));
    await tap(t, find.text('삭제')); expect(find.text('One'), findsNothing); expect(find.text('Two'), findsOneWidget);
    await tap(t, find.byKey(const ValueKey('delete-note-2'))); await tap(t, find.text('삭제'));
    expect(find.byType(TravelNoteCard), findsNothing); expect(find.textContaining('아직 기록이 없어요'), findsOneWidget);
  });
  testWidgets('record delete permission is checked again after confirmation', (t) async {
    var item = trip;
    await t.pumpWidget(MaterialApp(home: Scaffold(body: TravelNotesTimeline(item: () => item, load: (_) async => [const Note(id: 1, itemId: 1, text: 'Keep', date: '2000-01-01')]))));
    await t.pumpAndSettle(); await tap(t, find.byKey(const ValueKey('delete-note-1')));
    item = trip.copyWith(startDate: '2100-01-01', endDate: '2100-01-03');
    await tap(t, find.text('삭제')); expect(find.text('Keep'), findsOneWidget);
    expect(find.byKey(const ValueKey('delete-note-1')), findsNothing);
  });
  test('past plan completion preserves identity and content while deletion stays blocked', () {
    final journey = trip.copyWith(startDate: '2026-10-28', endDate: '2026-11-01');
    const past = TravelPlan(date: '2026-10-30', time: '10:00', place: 'Museum', activity: 'Visit');
    final done = past.copyWith(completed: true);
    expect(identical(done.identity, past.identity), isTrue);
    expect(canChangeTravelPlans(journey, [past], [done], DateTime(2026, 10, 31)), isTrue);
    expect(canChangeTravelPlans(journey, [done], [done.copyWith(completed: false)], DateTime(2026, 10, 31)), isTrue);
    expect(canChangeTravelPlans(journey, [done], [], DateTime(2026, 10, 31)), isFalse);
    expect(canChangeTravelPlans(journey, [past], [done], DateTime(2026, 11, 2)), isFalse);
  });
  testWidgets('completion toggle updates progress and allows past dates on ongoing trips', (t) async {
    var now = DateTime(2026, 10, 31);
    final item = trip.copyWith(startDate: '2026-10-28', endDate: '2026-11-01');
    var plans = [const TravelPlan(date: '2026-10-30', time: '10:00', place: 'Museum', activity: 'Visit'), const TravelPlan(date: '2026-10-31', time: '11:00', place: 'Cafe', activity: 'Rest')];
    await t.pumpWidget(MaterialApp(home: Scaffold(body: SingleChildScrollView(child: TravelPlansSection(item: () => item, plans: () => plans, now: () => now,
      onChanged: (updated) { if (!canChangeTravelPlans(item, plans, updated, now)) return false; plans = updated; return true; })))));
    await t.pumpAndSettle(); expect(find.text('0/2'), findsOneWidget);
    await tap(t, find.byType(CheckboxListTile).first); expect(find.text('1/2'), findsOneWidget); expect(plans.first.completed, isTrue);
    expect(find.byTooltip('계획 편집'), findsOneWidget);
    now = DateTime(2026, 11, 2); await t.pump(const Duration(minutes: 1)); await t.pumpAndSettle();
    expect(t.widget<CheckboxListTile>(find.byType(CheckboxListTile).first).onChanged, isNull);
    await t.pumpWidget(const SizedBox());
  });
  testWidgets('single and multiple city trips show read-only overviews without navigating', (t) async {
    for (final many in [true, false]) {
      await t.pumpWidget(MaterialApp(home: Builder(builder: (_) => Scaffold(body: VisitedPlacesMap(
        items: [trip, if (many) trip.copyWith(id: 2, title: 'Tokyo second')],
      )))));
      await t.pumpAndSettle(); await tap(t, find.byKey(const ValueKey('map-marker-JP/tokyo')));
      if (many) {
        expect(find.byKey(const ValueKey('map-trip-1')), findsOneWidget);
        expect(t.widget<ListTile>(find.byKey(const ValueKey('map-trip-2'))).onTap, isNull);
      }
      expect(find.byType(DetailScreen), findsNothing);
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('• Tokyo first'), findsOneWidget);
      expect(find.text('여행 ${many ? 2 : 1}개'), findsOneWidget);
      await t.pumpWidget(const SizedBox());
    }
  });
  testWidgets('A actions align and city overview closes back to the recap map', (t) async {
    t.view.physicalSize = const Size(400, 1000); t.view.devicePixelRatio = 1; addTearDown(t.view.reset);
    await t.pumpWidget(MaterialApp(home: ListScreen(load: () async => [trip, trip.copyWith(id: 2, title: 'Tokyo second')], loadNotes: (_) async => [])));
    await t.pumpAndSettle();
    final recap = find.byKey(const ValueKey('open-recap')); final recs = find.byKey(const ValueKey('open-recommendations'));
    expect(t.getSize(recap), t.getSize(recs)); expect(t.getCenter(recap).dy, t.getCenter(recs).dy);
    await tap(t, recs); expect(find.text('도시·국가·테마 검색'), findsOneWidget); await tap(t, find.text('닫기'));
    await tap(t, recap); await tap(t, find.byKey(const ValueKey('map-marker-JP/tokyo')));
    expect(t.widget<ListTile>(find.byKey(const ValueKey('map-trip-2'))).onTap, isNull);
    expect(find.byType(DetailScreen), findsNothing);
    await tap(t, find.descendant(of: find.byType(AlertDialog), matching: find.text('닫기')));
    expect(find.byType(VisitedPlacesMap), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
    await t.pumpWidget(const SizedBox());
  });
  testWidgets('all three selected templates preview and export distinct complete PNGs', (t) async {
    t.view.physicalSize = const Size(600, 1200); t.view.devicePixelRatio = 1; addTearDown(t.view.reset);
    final outputs = <String>[];
    for (final template in MemoryTemplate.values) {
      Uint8List? output;
      await t.pumpWidget(MaterialApp(home: Scaffold(body: TravelMemoryDialog(item: trip.copyWith(photos: [red, blue], review: 'Complete story'), savePng: (bytes, name) async { output = bytes; }))));
      await t.pumpAndSettle(); await tap(t, find.byKey(ValueKey('memory-select-${template.name}')));
      expect(t.widget<TravelMemoryCard>(find.byType(TravelMemoryCard)).template, template);
      await t.tap(find.byKey(const ValueKey('export-memory-png'))); await t.pump();
      for (var i = 0; i < 40 && output == null; i++) {
        await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 25))); await t.pump();
      }
      expect(output, isNotNull);
      await t.pumpAndSettle();
      final codec = await t.runAsync(() => ui.instantiateImageCodec(output!));
      final frame = (await t.runAsync(codec!.getNextFrame))!;
      expect(frame.image.width, greaterThan(0)); expect(frame.image.height, greaterThan(0));
      frame.image.dispose(); codec.dispose(); outputs.add(base64Encode(output!));
      await t.pumpWidget(const SizedBox());
    }
    expect(outputs.toSet(), hasLength(3));
  });
}
