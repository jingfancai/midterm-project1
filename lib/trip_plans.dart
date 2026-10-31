import 'models.dart';
import 'trip_insights.dart';

class TravelPlan {
  const TravelPlan({required this.date, required this.time, required this.place, required this.activity});
  final String date;
  final String time;
  final String place;
  final String activity;
  String get sortKey => '$date $time';
}

bool canEditTravelPlans(Item item, DateTime now) =>
    !item.deleted && tripStatus(item, now) == TripStatus.upcoming;

String? validateTravelPlan(TravelPlan plan, Item item) {
  final parsed = TripDates.parse(plan.date.replaceAll('-', '.'));
  final dates = TripDates.fromItem(item);
  if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(plan.date) || parsed == null || dates == null) {
    return '올바른 날짜를 입력해 주세요 (YYYY-MM-DD).';
  }
  if (parsed.start.isBefore(dates.start) || parsed.start.isAfter(dates.end)) {
    return '여행 기간 안의 날짜를 입력해 주세요.';
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
