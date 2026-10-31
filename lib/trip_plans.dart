import 'models.dart';
import 'trip_insights.dart';

class TravelPlan {
  const TravelPlan({required this.date, required this.time, required this.place, required this.activity, this.completed = false}) : _original = null;
  const TravelPlan._({required this.date, required this.time, required this.place, required this.activity, required this.completed, required TravelPlan original}) : _original = original;
  final TravelPlan? _original;
  final bool completed;
  Object get identity => _original ?? this;
  TravelPlan copyWith({bool? completed}) => TravelPlan._(date: date, time: time, place: place, activity: activity, completed: completed ?? this.completed, original: _original ?? this);
  final String date;
  final String time;
  final String place;
  final String activity;
  String get sortKey => '$date $time';
}

bool showTravelPlans(Item item, DateTime now) => !item.deleted &&
    [TripStatus.upcoming, TripStatus.ongoing].contains(tripStatus(item, now));

bool canEditTravelPlans(Item item, DateTime now) => showTravelPlans(item, now);

TripDates? editableTravelPlanDates(Item item, DateTime now) {
  if (!canEditTravelPlans(item, now)) return null;
  final dates = TripDates.fromItem(item)!;
  // now is the system local clock; compare calendar components, not UTC instants.
  final today = DateTime.utc(now.year, now.month, now.day);
  return TripDates(dates.start.isAfter(today) ? dates.start : today, dates.end);
}

bool canEditTravelPlan(TravelPlan plan, Item item, DateTime now) {
  final range = editableTravelPlanDates(item, now);
  final date = TripDates.parse(plan.date.replaceAll('-', '.'))?.start;
  return range != null && date != null && !date.isBefore(range.start) && !date.isAfter(range.end);
}

bool canChangeTravelPlans(Item item, List<TravelPlan> before, List<TravelPlan> after, DateTime now) {
  if (!canEditTravelPlans(item, now)) return false;
  if (after.map((plan) => plan.identity).toSet().length != after.length) return false;
  bool sameDetails(TravelPlan a, TravelPlan b) => identical(a.identity, b.identity) &&
      a.date == b.date && a.time == b.time && a.place == b.place && a.activity == b.activity;
  for (final plan in before) {
    if (!canEditTravelPlan(plan, item, now) && !after.any((other) => sameDetails(plan, other))) return false;
  }
  return after.every((plan) => before.any((old) => sameDetails(old, plan)) || validateTravelPlan(plan, item, now: now) == null);
}

String? validateTravelPlan(TravelPlan plan, Item item, {DateTime? now}) {
  final parsed = TripDates.parse(plan.date.replaceAll('-', '.'));
  final dates = TripDates.fromItem(item);
  if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(plan.date) || parsed == null || dates == null) {
    return '올바른 날짜를 입력해 주세요 (YYYY-MM-DD).';
  }
  if (parsed.start.isBefore(dates.start) || parsed.start.isAfter(dates.end)) {
    return '여행 기간 안의 날짜를 입력해 주세요.';
  }
  if (now != null && !canEditTravelPlan(plan, item, now)) {
    return '오늘부터 여행 종료일까지의 계획만 변경할 수 있어요.';
  }
  if (!RegExp(r'^(?:[01]\d|2[0-3]):[0-5]\d$').hasMatch(plan.time)) {
    return '올바른 시간을 입력해 주세요 (HH:mm).';
  }
  if (plan.place.trim().isEmpty || plan.activity.trim().isEmpty) {
    return '장소와 활동을 입력해 주세요.';
  }
  return null;
}

List<TravelPlan> sortedTravelPlans(Iterable<TravelPlan> plans) {
  // Preserve input order for plans at the same time.
  final indexed = plans.toList().asMap().entries.toList();
  indexed.sort((a, b) {
    final order = a.value.sortKey.compareTo(b.value.sortKey);
    return order == 0 ? a.key.compareTo(b.key) : order;
  });
  return indexed.map((entry) => entry.value).toList();
}
