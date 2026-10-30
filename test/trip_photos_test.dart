import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mid_project_template/models.dart';
import 'package:mid_project_template/photo_picker.dart';
import 'package:mid_project_template/screens/b_detail_screen.dart';
import 'package:mid_project_template/travel_memory_card.dart';
import 'package:mid_project_template/trip_photos.dart';
import 'package:mid_project_template/trip_insights.dart';
import 'package:mid_project_template/widgets.dart';

const sample = Item(
  id: 1,
  title: 'Trip',
  subtitle: '2000.01.01 · Tokyo',
  image: '',
  destination: 'Tokyo',
);
final red = File('test/fixtures/local_photo_red.png').readAsBytesSync();
final blue = File('test/fixtures/local_photo_blue.png').readAsBytesSync();

Future<void> settlePhotos(WidgetTester t) async {
  await t.pump();
  for (var attempt = 0; attempt < 30; attempt++) {
    await t.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 30)),
    );
    await t.pump();
    if (find.byType(LinearProgressIndicator).evaluate().isEmpty) break;
  }
  await t.pumpAndSettle();
}

Future<Item Function()> gallery(
  WidgetTester t, {
  Item item = sample,
  required TripPhotoPicker picker,
  Size size = const Size(400, 800),
}) async {
  t.view.physicalSize = size;
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  var current = item;
  await t.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: StatefulBuilder(
          builder: (_, setState) => SingleChildScrollView(
            child: TripPhotoGallery(
              item: current,
              pickPhotos: picker,
              onChanged: (photos) async {
                setState(() => current = current.copyWith(photos: photos));
              },
            ),
          ),
        ),
      ),
    ),
  );
  await t.pumpAndSettle();
  return () => current;
}

void main() {
  test(
    'user photos stay out of JSON and GET, edits preserve bytes and copy caps at five',
    () {
      final item = sample.copyWith(photos: [red]);
      expect(
        item
            .copyWith(title: 'Edited', review: 'Review', tags: ['tag'])
            .photos
            .single,
        same(red),
      );
      expect(item.toJson().containsKey('photos'), isFalse);
      expect(
        Item.fromJson({
          ...item.toJson(),
          'photos': [blue],
        })!.photos,
        isEmpty,
      );
      expect(sample.copyWith(photos: List.filled(6, red)).photos, hasLength(5));
      expect(item.copyWith(photos: []).photos, isEmpty);
      expect(() => item.photos.add(blue), throwsUnsupportedError);
    },
  );

  test(
    'photo decoder limits dimensions and rejects corrupt/oversized bytes',
    () async {
      final bytes = await prepareTripPhoto(
        File('test/fixtures/local_photo_large.png').readAsBytesSync(),
      );
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      expect(frame.image.width, 1920);
      expect(frame.image.height, 960);
      frame.image.dispose();
      codec.dispose();
      await expectLater(
        prepareTripPhoto(Uint8List.fromList([1, 2, 3])),
        throwsA(isA<PhotoSelectionException>()),
      );
      await expectLater(
        prepareTripPhoto(Uint8List(maxPhotoFileBytes + 1)),
        throwsA(isA<PhotoSelectionException>()),
      );
    },
  );

  testWidgets('empty gallery reuses the matching photo and page counter', (
    t,
  ) async {
    await gallery(t, picker: ({required limit}) async => []);
    expect(find.byType(NetImage), findsOneWidget);
    expect(t.widget<NetImage>(find.byType(NetImage)).url, sample.photoUrl);
    expect(find.text('1 / 1'), findsOneWidget);
    expect(find.text('0 / 5장'), findsOneWidget);
    expect(
      t
          .widget<IconButton>(
            find.widgetWithIcon(IconButton, Icons.delete_outline),
          )
          .onPressed,
      isNull,
    );
    expect(
      t
          .widget<IconButton>(find.widgetWithIcon(IconButton, Icons.swap_horiz))
          .onPressed,
      isNull,
    );
  });

  testWidgets(
    'add five photos, swipe pages, enforce limit without changing other trip fields',
    (t) async {
      final get = await gallery(
        t,
        picker: ({required limit}) async {
          expect(limit, 5);
          return [red, blue, red, blue, red];
        },
      );
      await t.tap(find.byKey(const ValueKey('add-trip-photo')));
      await settlePhotos(t);
      expect(get().photos, hasLength(5));
      expect(get().title, sample.title);
      expect(find.text('1 / 5'), findsOneWidget);
      expect(
        t
            .widget<TextButton>(find.byKey(const ValueKey('add-trip-photo')))
            .onPressed,
        isNull,
      );
      await t.drag(
        find.byKey(const ValueKey('trip-photo-pages')),
        const Offset(-300, 0),
      );
      await t.pumpAndSettle();
      expect(find.text('2 / 5'), findsOneWidget);
    },
  );

  testWidgets(
    'replacement changes current photo only, delete clamps page and final delete restores default',
    (t) async {
      var limitSeen = 0;
      final get = await gallery(
        t,
        item: sample.copyWith(photos: [red, blue]),
        picker: ({required limit}) async {
          limitSeen = limit;
          return [red];
        },
      );
      await t.drag(
        find.byKey(const ValueKey('trip-photo-pages')),
        const Offset(-300, 0),
      );
      await t.pumpAndSettle();
      await t.tap(find.byTooltip('현재 사진 바꾸기'));
      await settlePhotos(t);
      expect(limitSeen, 1);
      expect(get().photos.first, same(red));
      final codec = await t.runAsync(
        () => ui.instantiateImageCodec(get().photos.last),
      );
      final frame = (await t.runAsync(codec!.getNextFrame))!;
      expect(frame.image.width, 40);
      frame.image.dispose();
      codec.dispose();
      expect(find.text('2 / 2'), findsOneWidget);
      await t.tap(find.byTooltip('현재 사진 삭제'));
      await settlePhotos(t);
      expect(get().photos, hasLength(1));
      expect(find.text('1 / 1'), findsOneWidget);
      await t.tap(find.byTooltip('현재 사진 삭제'));
      await settlePhotos(t);
      expect(get().photos, isEmpty);
      expect(find.byType(NetImage), findsOneWidget);
      expect(t.takeException(), isNull);
    },
  );

  testWidgets(
    'cancel, excessive selection and corrupt batch preserve existing photos',
    (t) async {
      var attempt = 0;
      final get = await gallery(
        t,
        item: sample.copyWith(photos: [red]),
        picker: ({required limit}) async {
          expect(limit, 4);
          attempt++;
          return switch (attempt) {
            1 => [],
            2 => List.filled(5, blue),
            _ => [
              blue,
              Uint8List.fromList([1, 2, 3]),
            ],
          };
        },
      );
      for (var i = 0; i < 3; i++) {
        await t.tap(find.byKey(const ValueKey('add-trip-photo')));
        await settlePhotos(t);
        expect(get().photos, hasLength(1));
        expect(get().photos.single, same(red));
      }
      expect(find.textContaining('손상된 사진'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsNothing);
    },
  );

  testWidgets(
    'B photo selection invokes session callback and survives unrelated edits',
    (t) async {
      Item? saved;
      t.view.physicalSize = const Size(500, 1400);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      await t.pumpWidget(
        MaterialApp(
          home: DetailScreen(
            item: sample,
            loadNotes: (_) async => [],
            pickPhotos: ({required limit}) async => [red],
            save: (item) async {
              saved = item;
              return item;
            },
          ),
        ),
      );
      await t.pumpAndSettle();
      final add = find.byKey(const ValueKey('add-trip-photo'));
      await t.scrollUntilVisible(
        add,
        250,
        scrollable: find
            .descendant(
              of: find.byType(ListView).first,
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await t.ensureVisible(add);
      await t.pumpAndSettle();
      await t.tap(add);
      await settlePhotos(t);
      expect(saved!.photos, hasLength(1));
      expect(
        saved!.copyWith(favorite: true).photos.single,
        same(saved!.photos.single),
      );
      expect(find.text('1 / 5장'), findsOneWidget);
    },
  );

  testWidgets('C memory cover and encoded PNG use the first user photo', (
    t,
  ) async {
    final key = GlobalKey();
    final item = sample.copyWith(photos: [red, blue]);
    await t.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: RepaintBoundary(
              key: key,
              child: SizedBox(width: 320, child: TravelMemoryCard(item: item)),
            ),
          ),
        ),
      ),
    );
    await t.pumpAndSettle();
    expect(find.byType(NetImage), findsNothing);
    expect(
      (t.widget<Image>(find.byType(Image)).image as MemoryImage).bytes,
      same(red),
    );
    final png = (await t.runAsync(() => captureMemoryPng(key)))!;
    final pixel = await t.runAsync(() async {
      final codec = await ui.instantiateImageCodec(png);
      final frame = await codec.getNextFrame();
      final raw = (await frame.image.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      ))!;
      final offset = (100 * frame.image.width + 100) * 4;
      final values = raw.buffer.asUint8List().sublist(offset, offset + 3);
      frame.image.dispose();
      codec.dispose();
      return values;
    });
    expect(pixel, [224, 40, 40]);
  });

  testWidgets('photo controls fit 320dp and an appended photo is reachable', (
    t,
  ) async {
    final get = await gallery(
      t,
      item: sample.copyWith(photos: [red, blue]),
      size: const Size(320, 600),
      picker: ({required limit}) async => [red],
    );
    await t.tap(find.byKey(const ValueKey('add-trip-photo')));
    await settlePhotos(t);
    expect(get().photos, hasLength(3));
    expect(
      t.widget<Text>(find.byKey(const ValueKey('photo-page-indicator'))).data,
      '3 / 3',
    );
    expect(t.takeException(), isNull);
  });
  test(
    'photo permissions include ongoing and past days, exclude future invalid and deleted',
    () {
      final today = DateTime(2026, 10, 30);
      expect(canManageTripPhotos(sample, today), isTrue);
      expect(
        canManageTripPhotos(
          sample.copyWith(startDate: '2026-10-30', endDate: '2026-10-30'),
          today,
        ),
        isTrue,
      );
      expect(
        canManageTripPhotos(
          sample.copyWith(startDate: '2026-10-31', endDate: '2026-11-03'),
          today,
        ),
        isFalse,
      );
      expect(
        canManageTripPhotos(
          sample.copyWith(startDate: 'invalid', endDate: 'invalid'),
          today,
        ),
        isFalse,
      );
      expect(
        canManageTripPhotos(sample.copyWith(deleted: true), today),
        isFalse,
      );
    },
  );

  testWidgets(
    'B has one full-width hero gallery with the original guidance above it',
    (t) async {
      t.view.physicalSize = const Size(400, 1000);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      await t.pumpWidget(
        MaterialApp(
          home: DetailScreen(item: sample, loadNotes: (_) async => []),
        ),
      );
      await t.pumpAndSettle();
      final pages = find.byKey(const ValueKey('trip-photo-pages'));
      expect(pages, findsOneWidget);
      expect(find.byType(TripPhotoGallery), findsOneWidget);
      expect(find.byType(NetImage), findsOneWidget);
      for (final label in ['순간을 다시 꺼내 보기', '사진과 짧은 기록으로 여행의 흐름을 돌아보세요.']) {
        expect(find.text(label), findsOneWidget);
        expect(
          t.getBottomLeft(find.text(label)).dy,
          lessThan(t.getTopLeft(pages).dy),
        );
      }
      expect(t.getTopLeft(pages).dx, closeTo(18, 1));
      expect(t.getSize(pages).width, closeTo(364, 1));
      expect(t.getSize(pages).aspectRatio, closeTo(4 / 3, .01));
      expect(t.takeException(), isNull);
    },
  );

  testWidgets('ongoing travel can add a local photo', (t) async {
    final date = DateTime.now().toIso8601String().substring(0, 10);
    final get = await gallery(
      t,
      item: sample.copyWith(startDate: date, endDate: date),
      picker: ({required limit}) async => [red],
    );
    await t.tap(find.byKey(const ValueKey('add-trip-photo')));
    await settlePhotos(t);
    expect(get().photos, hasLength(1));
    expect(find.text('1 / 5장'), findsOneWidget);
  });

  testWidgets(
    'future dates hide stored photos and actions, starting dates restore first photo',
    (t) async {
      t.view.physicalSize = const Size(400, 800);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      var item = sample.copyWith(photos: [red, blue]);
      late StateSetter change;
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (_, setState) {
                change = setState;
                return SingleChildScrollView(
                  child: TripPhotoGallery(
                    item: item,
                    onChanged: (_) async {},
                    pickPhotos: ({required limit}) async => [blue],
                  ),
                );
              },
            ),
          ),
        ),
      );
      await t.pumpAndSettle();
      await t.drag(
        find.byKey(const ValueKey('trip-photo-pages')),
        const Offset(-300, 0),
      );
      await t.pumpAndSettle();
      expect(find.text('2 / 2'), findsOneWidget);
      change(
        () => item = item.copyWith(
          startDate: '2100-01-01',
          endDate: '2100-01-03',
        ),
      );
      await t.pumpAndSettle();
      expect(find.byType(NetImage), findsOneWidget);
      expect(find.byKey(const ValueKey('add-trip-photo')), findsNothing);
      expect(find.byTooltip('현재 사진 삭제'), findsNothing);
      expect(find.byTooltip('현재 사진 바꾸기'), findsNothing);
      expect(find.byKey(const ValueKey('photo-page-indicator')), findsNothing);
      expect(item.photos, hasLength(2));
      change(
        () => item = item.copyWith(
          startDate: '2000-01-01',
          endDate: '2000-01-03',
        ),
      );
      await t.pumpAndSettle();
      expect(find.text('1 / 2'), findsOneWidget);
      expect(find.byType(NetImage), findsNothing);
      expect(t.takeException(), isNull);
    },
  );

  testWidgets(
    'photos selected after a date changes to future are not applied',
    (t) async {
      var item = sample;
      var writes = 0;
      final pending = Completer<List<Uint8List>>();
      late StateSetter change;
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (_, setState) {
                change = setState;
                return SingleChildScrollView(
                  child: TripPhotoGallery(
                    item: item,
                    onChanged: (_) async {
                      writes++;
                    },
                    pickPhotos: ({required limit}) => pending.future,
                  ),
                );
              },
            ),
          ),
        ),
      );
      await t.pumpAndSettle();
      await t.ensureVisible(find.byKey(const ValueKey('add-trip-photo')));
      await t.pumpAndSettle();
      await t.tap(find.byKey(const ValueKey('add-trip-photo')));
      await t.pump();
      change(
        () => item = item.copyWith(
          startDate: '2100-01-01',
          endDate: '2100-01-03',
        ),
      );
      await t.pump();
      pending.complete([red]);
      await t.pumpAndSettle();
      expect(writes, 0);
      expect(find.byType(NetImage), findsOneWidget);
      expect(find.byKey(const ValueKey('add-trip-photo')), findsNothing);
    },
  );
}
