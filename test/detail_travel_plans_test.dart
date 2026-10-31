import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mid_project_template/models.dart';
import 'package:mid_project_template/screens/b_detail_screen.dart';
import 'package:mid_project_template/trip_plans.dart';
import 'package:mid_project_template/travel_plans_section.dart';

const trip = Item(id: 1, title: 'Journey', subtitle: '', image: '', destination: 'Tokyo', startDate: '2100-01-01', endDate: '2100-01-03');
const existing = TravelPlan(date: '2100-01-01', time: '09:00', place: 'Museum', activity: 'Morning visit');
Future<void> showPlans(WidgetTester t) async {
  await t.scrollUntilVisible(find.byKey(const ValueKey('travel-plans-section')), 350,
    scrollable: find.descendant(of: find.byType(ListView).first, matching: find.byType(Scrollable)).first);
  await t.pumpAndSettle();
}
Future<void> tapVisible(WidgetTester t, Finder finder) async {
  await t.ensureVisible(finder); await t.pumpAndSettle(); await t.tap(finder); await t.pumpAndSettle();
}
void main() {
  test('AM/PM display handles midnight, noon and stored chronological values', () {
    expect(formatPlanTime('00:00'), 'AM 12:00');
    expect(formatPlanTime('12:00'), 'PM 12:00');
    expect(formatPlanTime('23:45'), 'PM 11:45');
    expect(sortedTravelPlans([const TravelPlan(date: '2100-01-01', time: '12:00', place: '', activity: ''), existing]).first, same(existing));
  });
  testWidgets('B future plans use bounded date picker and AM/PM time picker; CRUD shares memory', (t) async {
    t.view.physicalSize = const Size(700, 1100); t.view.devicePixelRatio = 1; addTearDown(t.view.reset);
    final plans = <int, List<TravelPlan>>{1: [existing]};
    await t.pumpWidget(MaterialApp(home: DetailScreen(item: trip, plans: plans, loadNotes: (_) async => [], now: () => DateTime(2099))));
    await t.pumpAndSettle(); await showPlans(t);
    await tapVisible(t, find.byKey(const ValueKey('add-plan')));
    await tapVisible(t, find.byKey(const ValueKey('plan-date')));
    final picker = t.widget<DatePickerDialog>(find.byType(DatePickerDialog));
    expect(picker.firstDate, DateTime(2100, 1, 1)); expect(picker.lastDate, DateTime(2100, 1, 3));
    await t.tap(find.text('2').last); await t.tap(find.text('OK')); await t.pumpAndSettle();
    await tapVisible(t, find.byKey(const ValueKey('plan-time')));
    expect(find.byType(TimePickerDialog), findsOneWidget);
    expect(find.text('AM'), findsOneWidget); expect(find.text('PM'), findsOneWidget);
    await t.tap(find.text('PM')); await t.tap(find.text('OK')); await t.pumpAndSettle();
    expect(find.text('PM 09:00'), findsOneWidget);
    await t.enterText(find.byKey(const ValueKey('plan-place')), 'Cafe');
    await t.enterText(find.byKey(const ValueKey('plan-activity')), 'Evening break');
    await tapVisible(t, find.byKey(const ValueKey('save-plan')));
    expect(plans[1], hasLength(2)); expect(plans[1]!.last.time, '21:00'); expect(plans[1]!.last.date, '2100-01-02');
    await tapVisible(t, find.byTooltip('계획 편집').first);
    await t.enterText(find.byKey(const ValueKey('plan-place')), 'Gallery');
    await tapVisible(t, find.byKey(const ValueKey('save-plan')));
    expect(plans[1]!.first.place, 'Gallery');
    await tapVisible(t, find.byTooltip('계획 삭제').first);
    await t.tap(find.text('취소')); await t.pumpAndSettle(); expect(plans[1], hasLength(2));
    await tapVisible(t, find.byTooltip('계획 삭제').first);
    await t.tap(find.text('삭제')); await t.pumpAndSettle(); expect(plans[1], hasLength(1));
    await t.pumpWidget(const SizedBox());
  });
  testWidgets('future notes cannot be created; departure day and ended notes still work', (t) async {
    for (final now in [DateTime(2099, 12, 31), DateTime(2100, 1, 1), DateTime(2100, 1, 4)]) {
      await t.pumpWidget(MaterialApp(home: DetailScreen(item: trip, loadNotes: (_) async => [], now: () => now)));
      await t.pumpAndSettle(); await t.tap(find.text('여행 기록')); await t.pumpAndSettle();
      if (now.year == 2099) {
        expect(find.text('여행 기록 추가'), findsNothing); expect(find.byKey(const ValueKey('notes-restricted')), findsOneWidget);
      } else {
        await t.tap(find.text('여행 기록 추가')); await t.pumpAndSettle();
        await t.enterText(find.byType(TextField), 'Today’s memory'); await t.tap(find.text('저장')); await t.pumpAndSettle();
        expect(find.text('Today’s memory'), findsOneWidget);
      }
      await t.pumpWidget(const SizedBox());
    }
  });
  testWidgets('notes permission is rechecked while a note dialog is open', (t) async {
    var now = DateTime(2100, 1, 1);
    await t.pumpWidget(MaterialApp(home: DetailScreen(item: trip, loadNotes: (_) async => [], now: () => now)));
    await t.pumpAndSettle(); await t.tap(find.text('여행 기록')); await t.pumpAndSettle();
    await t.tap(find.text('여행 기록 추가')); await t.pumpAndSettle();
    await t.enterText(find.byType(TextField), 'Must not be applied');
    now = DateTime(2099, 12, 31); // Simulate the trip becoming future while composing.
    await t.tap(find.text('저장')); await t.pumpAndSettle();
    expect(find.text('Must not be applied'), findsNothing);
    await t.pumpWidget(const SizedBox());
  });
  testWidgets('midnight locks an open editor without changing existing plans', (t) async {
    var now = DateTime(2100, 1, 1, 23, 59);
    final plans = <int, List<TravelPlan>>{1: [existing]};
    await t.pumpWidget(MaterialApp(home: Scaffold(body: SingleChildScrollView(child: TravelPlansSection(
      item: () => trip, plans: () => plans[1]!, now: () => now,
      onChanged: (value) { plans[1] = value; return true; },
    )))));
    await t.pumpAndSettle(); await tapVisible(t, find.byTooltip('계획 편집'));
    await t.enterText(find.byKey(const ValueKey('plan-place')), 'Unsaved change');
    now = DateTime(2100, 1, 2); await t.pump(const Duration(minutes: 1)); await t.pumpAndSettle();
    expect(t.widget<FilledButton>(find.byKey(const ValueKey('save-plan'))).onPressed, isNull);
    await t.tap(find.text('취소')); await t.pumpAndSettle();
    expect(plans[1]!.single, same(existing)); expect(find.byTooltip('계획 편집'), findsNothing);
    expect(find.byKey(const ValueKey('add-plan')), findsOneWidget); expect(find.text('Museum'), findsOneWidget);
    await t.pumpWidget(const SizedBox());
  });
  test('ongoing range uses local calendar today and preserves locked past entries', () {
    final journey = trip.copyWith(startDate: '2026-10-28', endDate: '2026-11-01');
    final now = DateTime(2026, 10, 31, 0, 1);
    final range = editableTravelPlanDates(journey, now)!;
    expect(range.start, DateTime.utc(2026, 10, 31));
    expect(range.end, DateTime.utc(2026, 11, 1));
    final past = TravelPlan(date: '2026-10-30', time: '23:59', place: 'Past', activity: 'Keep');
    final today = TravelPlan(date: '2026-10-31', time: '00:00', place: 'Today', activity: 'Change');
    final last = TravelPlan(date: '2026-11-01', time: '23:59', place: 'Last', activity: 'Change');
    expect(canEditTravelPlan(past, journey, now), isFalse);
    expect(canEditTravelPlan(today, journey, now), isTrue);
    expect(canEditTravelPlan(last, journey, now), isTrue);
    expect(validateTravelPlan(past, journey, now: now), isNotNull);
    expect(canChangeTravelPlans(journey, [past], [past, today], now), isTrue);
    expect(canChangeTravelPlans(journey, [past], [], now), isFalse);
    expect(canChangeTravelPlans(journey, [past], [today], now), isFalse);
    expect(canChangeTravelPlans(journey, [past, today], [past], now), isTrue);
    expect(editableTravelPlanDates(journey, DateTime(2026, 11, 1))!.start, DateTime.utc(2026, 11, 1));
    expect(editableTravelPlanDates(journey, DateTime(2026, 11, 2)), isNull);
  });
  testWidgets('ongoing picker starts today and old cards are readonly', (t) async {
    final journey = trip.copyWith(startDate: '2026-10-28', endDate: '2026-11-01');
    final old = TravelPlan(date: '2026-10-30', time: '09:00', place: 'Past', activity: 'Read only');
    final today = TravelPlan(date: '2026-10-31', time: '10:00', place: 'Today', activity: 'Editable');
    final plans = <int, List<TravelPlan>>{1: [old, today]};
    await t.pumpWidget(MaterialApp(home: DetailScreen(item: journey, plans: plans, loadNotes: (_) async => [], now: () => DateTime(2026, 10, 31))));
    await t.pumpAndSettle(); await showPlans(t);
    expect(find.text('Past'), findsOneWidget);
    expect(find.byTooltip('계획 편집'), findsOneWidget);
    expect(find.byTooltip('계획 삭제'), findsOneWidget);
    await tapVisible(t, find.byKey(const ValueKey('add-plan')));
    expect(find.text('2026-10-31'), findsOneWidget);
    await tapVisible(t, find.byKey(const ValueKey('plan-date')));
    final picker = t.widget<DatePickerDialog>(find.byType(DatePickerDialog));
    expect(picker.firstDate, DateTime(2026, 10, 31)); expect(picker.lastDate, DateTime(2026, 11, 1));
    await t.tap(find.text('CANCEL')); await t.pumpAndSettle();
    await t.enterText(find.byKey(const ValueKey('plan-place')), 'New place');
    await t.enterText(find.byKey(const ValueKey('plan-activity')), 'New activity');
    await tapVisible(t, find.byKey(const ValueKey('save-plan')));
    expect(plans[1], hasLength(3)); expect(plans[1]!.first, same(old));
    await tapVisible(t, find.byTooltip('계획 편집').last);
    await t.enterText(find.byKey(const ValueKey('plan-place')), 'Changed today');
    await tapVisible(t, find.byKey(const ValueKey('save-plan')));
    expect(plans[1]!.last.place, 'Changed today');
    await tapVisible(t, find.byTooltip('계획 삭제').last);
    await t.tap(find.text('삭제')); await t.pumpAndSettle();
    expect(plans[1], hasLength(2)); expect(plans[1]!.first, same(old));
    await t.pumpWidget(const SizedBox());
  });
  testWidgets('ended detail hides plans without deleting stored entries', (t) async {
    final plans = <int, List<TravelPlan>>{1: [existing]};
    await t.pumpWidget(MaterialApp(home: DetailScreen(item: trip, plans: plans, loadNotes: (_) async => [], now: () => DateTime(2100, 1, 4))));
    await t.pumpAndSettle();
    await t.drag(find.byType(ListView).first, const Offset(0, -2000)); await t.pumpAndSettle();
    expect(find.byKey(const ValueKey('travel-plans-section')), findsNothing);
    expect(find.text('여행 계획'), findsNothing);
    expect(plans[1]!.single, same(existing));
    await t.tap(find.text('여행 기록')); await t.pumpAndSettle();
    expect(find.text('여행 기록 추가'), findsOneWidget);
    await t.pumpWidget(const SizedBox());
  });
  testWidgets('plan cards and picker editor fit phone and desktop widths', (t) async {
    for (final size in [const Size(320, 640), const Size(1440, 1000)]) {
      t.view.physicalSize = size; t.view.devicePixelRatio = 1;
      await t.pumpWidget(MaterialApp(home: Scaffold(body: SingleChildScrollView(child: TravelPlansSection(
        item: () => trip, plans: () => [existing], onChanged: (_) => true, now: () => DateTime(2099),
      )))));
      await t.pumpAndSettle(); expect(t.takeException(), isNull);
      await tapVisible(t, find.byKey(const ValueKey('add-plan'))); expect(t.takeException(), isNull);
      await t.tap(find.text('취소')); await t.pumpAndSettle();
      await t.pumpWidget(const SizedBox());
    }
    t.view.reset();
  });
}
