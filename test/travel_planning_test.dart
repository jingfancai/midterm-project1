import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mid_project_template/models.dart';
import 'package:mid_project_template/screens/a_list_screen.dart';
import 'package:mid_project_template/screens/d_travel_plans_dialog.dart';
import 'package:mid_project_template/trip_plans.dart';
import 'package:mid_project_template/trip_photos.dart';
import 'package:mid_project_template/destinations.dart';

Widget app() => MaterialApp(home: ListScreen(load: () async => []));
const future = Item(id: 1, title: 'Future', subtitle: '', image: '', startDate: '2100-01-01', endDate: '2100-01-03');
TravelPlan plan(String date, String time, {String place = 'Museum', String activity = 'Visit'}) => TravelPlan(date: date, time: time, place: place, activity: activity);

void main() {
  test('plan permissions reject departure day, past, invalid and deleted trips', () {
    expect(canEditTravelPlans(future, DateTime(2099, 12, 31, 23, 59)), isTrue);
    for (final now in [DateTime(2100, 1, 1), DateTime(2100, 1, 4)]) {
      expect(canEditTravelPlans(future, now), isFalse);
    }
    expect(canEditTravelPlans(future.copyWith(deleted: true), DateTime(2099)), isFalse);
    expect(canEditTravelPlans(future.copyWith(startDate: 'bad'), DateTime(2099)), isFalse);
  });
  test('plans validate calendar, trip range, time and required text; sort stably', () {
    final first = plan('2100-01-01', '09:00');
    final sameTime = plan('2100-01-01', '09:00', place: 'Cafe');
    final later = plan('2100-01-02', '08:00');
    expect(validateTravelPlan(first, future), isNull);
    for (final invalid in [plan('2100-02-30', '09:00'), plan('2100-01-04', '09:00'), plan('2100-01-01', '24:00'), plan('2100-01-01', '9:00'), plan('2100-01-01', '09:60'), plan('2100-01-01', '09:00', place: '  '), plan('2100-01-01', '09:00', activity: ' ')]) {
      expect(validateTravelPlan(invalid, future), isNotNull);
    }
    expect(sortedTravelPlans([later, first, sameTime]), [first, sameTime, later]);
    expect(future.toJson().containsKey('plans'), isFalse);
  });
  test('recommendations reuse all cities, multilingual metadata and exact resolver', () {
    final all = searchDestinations();
    expect(all, hasLength(50));
    expect(all.map((entry) => entry.cityKey).toSet(), hasLength(50));
    for (final entry in all) {
      expect(entry.themes, isNotEmpty);
      expect(entry.keywords, isNotEmpty);
      for (final name in entry.aliases.take(3)) {
        expect(searchDestinations(query: name), contains(same(entry)));
      }
      for (final country in entry.countryNames) {
        expect(searchDestinations(query: country), contains(same(entry)));
      }
      expect(resolveDestination(entry.cityName), same(entry));
    }
    for (final query in ['Tokyo', '도쿄', '东京', '  JAPAN   Tokyo ', '日本 东京', '일본 도쿄']) {
      expect(searchDestinations(query: query).map((e) => e.cityId), contains('tokyo'));
    }
    for (final query in ['nature', '自然', '자연']) {
      expect(searchDestinations(query: query), isNotEmpty);
    }
    expect(searchDestinations(query: 'Tokyo', theme: '자연'), isEmpty);
    expect(searchDestinations(query: 'nothing-matches'), isEmpty);
    expect(searchDestinations(query: '  '), hasLength(50));
    expect(resolveDestination('Tokyo Hotel'), isNull);
  });
  testWidgets('trip selection isolates plans; reopen retains session entries', (t) async {
    final other = future.copyWith(id: 2, title: 'Other');
    final plans = <int, List<TravelPlan>>{1: [plan('2100-01-01', '09:00', place: 'Only first')]};
    Widget dialog() => MaterialApp(home: Scaffold(body: TravelPlansDialog(
      items: () => [future, other], plans: plans, now: () => DateTime(2099),
      onChanged: (id, value) { plans[id] = value; return true; },
    )));
    await t.pumpWidget(dialog());
    await t.pumpAndSettle();
    expect(find.textContaining('Only first'), findsOneWidget);
    await t.ensureVisible(find.byKey(const ValueKey('plan-trip')));
    await t.tap(find.byKey(const ValueKey('plan-trip')));
    await t.pumpAndSettle();
    await t.tap(find.text('Other').last);
    await t.pumpAndSettle();
    expect(find.textContaining('Only first'), findsNothing);
    expect(find.text('아직 여행 계획이 없어요.'), findsOneWidget);
    await t.pumpWidget(const SizedBox());
    await t.pumpWidget(dialog());
    await t.pumpAndSettle();
    expect(find.textContaining('Only first'), findsOneWidget);
    expect(plans[2], isNull);
    await t.pumpWidget(const SizedBox());
  });
  testWidgets('recommendation search, photos, theme, prefill and cancellation', (t) async {
    t.view.physicalSize = const Size(500, 1000);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(app());
    await t.pumpAndSettle();
    Future<void> choose() async {
      await t.tap(find.byKey(const ValueKey('open-recommendations')));
      await t.pumpAndSettle();
      expect(find.text('50개 여행지'), findsOneWidget);
      await t.enterText(find.byKey(const ValueKey('destination-search')), 'zzzz-no-city');
      await t.pumpAndSettle();
      expect(find.text('0개 여행지'), findsOneWidget);
      await t.tap(find.byTooltip('검색 지우기'));
      await t.pumpAndSettle();
      expect(find.text('50개 여행지'), findsOneWidget);
      await t.enterText(find.byKey(const ValueKey('destination-search')), 'Korea Seoul');
      await t.pumpAndSettle();
      expect(find.text('1개 여행지'), findsOneWidget);
      await t.tap(find.widgetWithText(ChoiceChip, '도시'));
      await t.pumpAndSettle();
      await t.ensureVisible(find.byKey(const ValueKey('suggest-서울')));
      await t.tap(find.byKey(const ValueKey('suggest-서울')));
      await t.pumpAndSettle();
    }
    await choose();
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
    for (final key in ['open-travel-plans', 'open-recommendations']) {
      await t.ensureVisible(find.byKey(ValueKey(key)));
      await t.tap(find.byKey(ValueKey(key)));
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
      await t.tap(find.text('닫기'));
      await t.pumpAndSettle();
    }
  });
}
