import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mid_project_template/models.dart';
import 'package:mid_project_template/screens/a_list_screen.dart';
import 'package:mid_project_template/trip_photos.dart';

Widget app() => MaterialApp(home: ListScreen(load: () async => []));

void main() {
  testWidgets('wishes add, toggle, reopen, delete and reset on new session', (t) async {
    await t.pumpWidget(app());
    await t.pumpAndSettle();
    Future<void> open() async {
      await t.tap(find.byKey(const ValueKey('open-wishlist')));
      await t.pumpAndSettle();
    }
    await open();
    expect(t.widget<FilledButton>(find.byKey(const ValueKey('add-wish'))).onPressed, isNull);
    await t.enterText(find.byKey(const ValueKey('wish-input')), '  Kyoto  ');
    await t.tap(find.byKey(const ValueKey('add-wish')));
    await t.pumpAndSettle();
    await t.tap(find.byType(Checkbox));
    await t.pumpAndSettle();
    expect(t.widget<CheckboxListTile>(find.byType(CheckboxListTile)).value, isTrue);
    await t.tap(find.text('닫기'));
    await t.pumpAndSettle();
    await open();
    expect(find.text('Kyoto'), findsOneWidget);
    expect(t.widget<CheckboxListTile>(find.byType(CheckboxListTile)).value, isTrue);
    await t.tap(find.byType(Checkbox));
    await t.pumpAndSettle();
    expect(t.widget<CheckboxListTile>(find.byType(CheckboxListTile)).value, isFalse);
    await t.tap(find.byTooltip('소원 삭제'));
    await t.pumpAndSettle();
    expect(find.text('아직 여행 소원이 없어요.'), findsOneWidget);
    await t.enterText(find.byKey(const ValueKey('wish-input')), 'Paris');
    await t.tap(find.byKey(const ValueKey('add-wish')));
    await t.pumpAndSettle();
    await t.pumpWidget(const SizedBox());
    await t.pumpWidget(app());
    await t.pumpAndSettle();
    await open();
    expect(find.text('Paris'), findsNothing);
    expect(t.takeException(), isNull);
  });

  testWidgets('theme suggestions prefill create form, cancel and confirm', (t) async {
    await t.pumpWidget(app());
    await t.pumpAndSettle();
    Future<void> choose() async {
      await t.tap(find.byKey(const ValueKey('open-recommendations')));
      await t.pumpAndSettle();
      expect(find.text('교토'), findsOneWidget);
      await t.tap(find.text('도시'));
      await t.pumpAndSettle();
      expect(find.text('교토'), findsNothing);
      await t.tap(find.byKey(const ValueKey('suggest-서울')));
      await t.pumpAndSettle();
    }
    await choose();
    expect(t.widget<TextFormField>(find.byKey(const ValueKey('trip-title'))).controller!.text, '서울 여행');
    expect(t.widget<TextFormField>(find.byKey(const ValueKey('trip-destination'))).controller!.text, '서울');
    expect(t.widget<TextFormField>(find.byKey(const ValueKey('trip-tags'))).controller!.text, '도시');
    await t.tap(find.text('취소'));
    await t.pumpAndSettle();
    expect(find.text('서울 여행'), findsNothing);
    await choose();
    await t.tap(find.text('여행 추가'));
    await t.pumpAndSettle();
    expect(find.text('서울 여행'), findsOneWidget);
    expect(t.takeException(), isNull);
  });

  testWidgets('thumbnail click and swipe synchronize; future hides navigation', (t) async {
    t.view.physicalSize = const Size(400, 900);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    final photos = ['red', 'blue'].map((name) => File('test/fixtures/local_photo_$name.png').readAsBytesSync()).toList();
    var item = Item(id: 1, title: 'Trip', subtitle: '', image: '', startDate: '2000-01-01', endDate: '2000-01-03', photos: photos);
    late StateSetter change;
    await t.pumpWidget(MaterialApp(home: Scaffold(body: StatefulBuilder(builder: (_, setState) {
      change = setState;
      return SingleChildScrollView(child: TripPhotoGallery(item: item, onChanged: (_) async {}));
    }))));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const ValueKey('photo-thumbnail-1')));
    await t.pumpAndSettle();
    expect(find.text('2 / 2'), findsOneWidget);
    await t.drag(find.byKey(const ValueKey('trip-photo-pages')), const Offset(650, 0));
    await t.pumpAndSettle();
    expect(find.text('1 / 2'), findsOneWidget);
    change(() => item = item.copyWith(startDate: '2100-01-01', endDate: '2100-01-03'));
    await t.pumpAndSettle();
    expect(find.byKey(const ValueKey('photo-thumbnails')), findsNothing);
    expect(t.takeException(), isNull);
  });

  testWidgets('planning dialogs fit a narrow window', (t) async {
    t.view.physicalSize = const Size(320, 600);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(app());
    await t.pumpAndSettle();
    for (final key in ['open-wishlist', 'open-recommendations']) {
      await t.ensureVisible(find.byKey(ValueKey(key)));
      await t.tap(find.byKey(ValueKey(key)));
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
      await t.tap(find.text('닫기'));
      await t.pumpAndSettle();
    }
  });
}
