import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mid_project_template/models.dart';
import 'package:mid_project_template/screens/b_detail_screen.dart';
import 'package:mid_project_template/travel_notes.dart';

const trip = Item(id: 1, title: 'Trip', subtitle: '', image: '', startDate: '2000-01-01', endDate: '2000-01-03');
final red = File('test/fixtures/local_photo_red.png').readAsBytesSync();
final blue = File('test/fixtures/local_photo_blue.png').readAsBytesSync();
Future<void> settlePhoto(WidgetTester t) async {
  await t.pump();
  for (var i = 0; i < 40; i++) {
    await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 25)));
    await t.pump();
    if (find.byType(LinearProgressIndicator).evaluate().isEmpty) break;
  }
  await t.pumpAndSettle();
}
Future<void> tap(WidgetTester t, Finder f) async {
  await t.ensureVisible(f); await t.pumpAndSettle(); await t.tap(f); await t.pumpAndSettle();
}
void main() {
  test('legacy notes ignore JSON photos and copy edits preserve independent metadata', () {
    final legacy = Note.fromJson({'id': 1, 'itemId': 1, 'text': 'Old', 'date': '2000-01-01', 'photo': red, 'time': 'bad'})!;
    expect(legacy.photo, isNull); expect(legacy.time, isEmpty);
    final note = legacy.copyWith(photo: red);
    expect(note.copyWith(text: 'Changed').photo, same(red));
    expect(note.copyWith(clearPhoto: true).photo, isNull);
    expect(note.copyWith(text: 'Changed').date, legacy.date);
    expect(Note.fromJson({'id': 1, 'itemId': 1, 'text': 'Old', 'date': '2000-01-01', 'time': '13:45'})!.time, '13:45');
  });
  testWidgets('create, edit, replace, cancel and remove a single independent record photo', (t) async {
    t.view.physicalSize = const Size(600, 1100); t.view.devicePixelRatio = 1; addTearDown(t.view.reset);
    var picks = 0;
    final item = trip.copyWith(photos: [blue]);
    await t.pumpWidget(MaterialApp(home: DetailScreen(item: item, loadNotes: (_) async => [],
      pickPhotos: ({required limit}) async => throw StateError('Top gallery must not be used'),
      pickNotePhoto: ({required limit}) async { expect(limit, 1); return [picks++ == 0 ? red : blue]; })));
    await t.pumpAndSettle(); await t.tap(find.text('여행 기록')); await t.pumpAndSettle();
    await tap(t, find.text('여행 기록 추가'));
    expect(find.byKey(const ValueKey('note-photo-preview')), findsNothing);
    await t.enterText(find.byKey(const ValueKey('note-text')), 'First note');
    await t.ensureVisible(find.byKey(const ValueKey('pick-note-photo')));
    await t.tap(find.byKey(const ValueKey('pick-note-photo'))); await settlePhoto(t);
    await tap(t, find.byKey(const ValueKey('save-note')));
    var note = t.widget<TravelNoteCard>(find.byType(TravelNoteCard)).note;
    final first = note.photo!; final date = note.date; final time = note.time;
    expect(find.byKey(ValueKey('note-photo-${note.id}')), findsOneWidget);
    expect(item.photos.single, same(blue));
    await tap(t, find.byTooltip('기록 편집'));
    await t.enterText(find.byKey(const ValueKey('note-text')), 'Edited note');
    await t.ensureVisible(find.byKey(const ValueKey('pick-note-photo')));
    await t.tap(find.byKey(const ValueKey('pick-note-photo'))); await settlePhoto(t);
    await tap(t, find.byKey(const ValueKey('save-note')));
    note = t.widget<TravelNoteCard>(find.byType(TravelNoteCard)).note;
    expect(note.text, 'Edited note'); expect(note.photo, isNot(equals(first))); expect(note.date, date); expect(note.time, time);
    final replacement = note.photo;
    await tap(t, find.byTooltip('기록 편집'));
    await tap(t, find.byKey(const ValueKey('remove-note-photo')));
    await tap(t, find.text('취소'));
    expect(t.widget<TravelNoteCard>(find.byType(TravelNoteCard)).note.photo, same(replacement));
    await tap(t, find.byTooltip('기록 편집'));
    await tap(t, find.byKey(const ValueKey('remove-note-photo')));
    await tap(t, find.byKey(const ValueKey('save-note')));
    note = t.widget<TravelNoteCard>(find.byType(TravelNoteCard)).note;
    expect(note.photo, isNull); expect(note.text, 'Edited note');
    expect(t.takeException(), isNull);
    await t.pumpWidget(const SizedBox());
  });
  testWidgets('cancel, multiple and corrupt selections preserve the original photo', (t) async {
    var attempt = 0;
    await t.pumpWidget(MaterialApp(home: Scaffold(body: TravelNoteEditor(
      note: Note(id: 1, itemId: 1, text: 'Keep', date: '2000-01-01', photo: red), allowed: () => true,
      pickPhoto: ({required limit}) async => switch (attempt++) {0 => [], 1 => [red, blue], _ => [Uint8List.fromList([1, 2, 3])]},
    ))));
    for (var i = 0; i < 3; i++) {
      await t.ensureVisible(find.byKey(const ValueKey('pick-note-photo')));
      await t.tap(find.byKey(const ValueKey('pick-note-photo'))); await settlePhoto(t);
      final image = t.widget<Image>(find.byKey(const ValueKey('note-photo-preview')));
      expect((image.image as MemoryImage).bytes, same(red));
    }
    await t.pumpWidget(const SizedBox());
  });
  testWidgets('future permission during selection blocks bytes and save', (t) async {
    var allowed = true;
    final pending = Completer<List<Uint8List>>();
    await t.pumpWidget(MaterialApp(home: Scaffold(body: TravelNoteEditor(
      note: const Note(id: 1, itemId: 1, text: 'Keep', date: '2000-01-01'), allowed: () => allowed,
      pickPhoto: ({required limit}) => pending.future,
    ))));
    await t.ensureVisible(find.byKey(const ValueKey('pick-note-photo')));
    await t.tap(find.byKey(const ValueKey('pick-note-photo'))); await t.pump();
    expect(t.widget<FilledButton>(find.byKey(const ValueKey('save-note'))).onPressed, isNull);
    allowed = false; pending.complete([red]); await settlePhoto(t);
    expect(find.byKey(const ValueKey('note-photo-preview')), findsNothing);
    expect(t.widget<FilledButton>(find.byKey(const ValueKey('save-note'))).onPressed, isNull);
    await t.pumpWidget(const SizedBox());
  });
  testWidgets('two notes own different photos; reloading restores GET originals', (t) async {
    t.view.physicalSize = const Size(600, 1800); t.view.devicePixelRatio = 1; addTearDown(t.view.reset);
    final notes = [Note(id: 1, itemId: 1, text: 'One', date: '2000-01-01', photo: red), Note(id: 2, itemId: 1, text: 'Two', date: '2000-01-02', photo: blue)];
    await t.pumpWidget(MaterialApp(home: Scaffold(body: TravelNotesTimeline(item: () => trip, load: (_) async => notes))));
    await t.pumpAndSettle();
    final cards = t.widgetList<TravelNoteCard>(find.byType(TravelNoteCard)).toList();
    expect(cards[0].note.photo, same(red)); expect(cards[1].note.photo, same(blue));
    await t.pumpWidget(const SizedBox());
    await t.pumpWidget(MaterialApp(home: Scaffold(body: TravelNotesTimeline(item: () => trip, load: (_) async => [const Note(id: 1, itemId: 1, text: 'Original', date: '2000-01-01')]))));
    await t.pumpAndSettle(); expect(find.byKey(const ValueKey('note-photo-1')), findsNothing);
    await t.pumpWidget(const SizedBox());
  });
  testWidgets('editor and timeline fit narrow and desktop windows', (t) async {
    for (final size in [const Size(320, 640), const Size(1440, 1000)]) {
      t.view.physicalSize = size; t.view.devicePixelRatio = 1;
      await t.pumpWidget(MaterialApp(home: Scaffold(body: TravelNotesTimeline(item: () => trip, load: (_) async => [Note(id: 1, itemId: 1, text: 'Long story ' * 40, date: '2000-01-01', time: '13:00', photo: red)]))));
      await t.pumpAndSettle(); expect(t.takeException(), isNull);
      await tap(t, find.byTooltip('기록 편집')); expect(t.takeException(), isNull);
      await tap(t, find.text('취소')); await t.pumpWidget(const SizedBox());
    }
    t.view.reset();
  });
}
