import 'models.dart';
import 'destinations.dart';

enum TripSort { newest, oldest, title }

enum TripStatus { upcoming, ongoing, past, unknown }

/// Supports the existing subtitle format, including abbreviated end dates.
class TripDates {
  const TripDates(this.start, this.end);

  final DateTime start;
  final DateTime end;

  static TripDates? fromItem(Item item) {
    if (item.startDate.isEmpty && item.endDate.isEmpty) {
      return parse(item.subtitle);
    }
    if (item.startDate.isEmpty || item.endDate.isEmpty) return null;
    return parse(
      '${item.startDate.replaceAll('-', '.')} – ${item.endDate.replaceAll('-', '.')}',
    );
  }

  int get days => end.difference(start).inDays + 1;

  static TripDates? parse(String subtitle) {
    final match = RegExp(
      r'^(\d{4})\.(\d{1,2})\.(\d{1,2})'
      r'(?:\s*[–-]\s*(?:(\d{4})\.)?(\d{1,2})\.(\d{1,2}))?'
      r'(?=\s*(?:·|$))',
    ).firstMatch(subtitle.trim());
    if (match == null) return null;
    final year = int.parse(match[1]!);
    final month = int.parse(match[2]!);
    final day = int.parse(match[3]!);
    final endMonth = int.tryParse(match[5] ?? '') ?? month;
    final endDay = int.tryParse(match[6] ?? '') ?? day;
    final endYear =
        int.tryParse(match[4] ?? '') ?? (endMonth < month ? year + 1 : year);
    // UTC calendar dates avoid daylight-saving changes affecting day counts.
    final start = DateTime.utc(year, month, day);
    final end = DateTime.utc(endYear, endMonth, endDay);
    if (start.year != year ||
        start.month != month ||
        start.day != day ||
        end.year != endYear ||
        end.month != endMonth ||
        end.day != endDay ||
        end.isBefore(start)) {
      return null;
    }
    return TripDates(start, end);
  }
}

TripStatus tripStatus(Item item, DateTime today) {
  final dates = TripDates.fromItem(item);
  if (dates == null) return TripStatus.unknown;
  final date = DateTime.utc(today.year, today.month, today.day);
  if (dates.start.isAfter(date)) return TripStatus.upcoming;
  if (dates.end.isBefore(date)) return TripStatus.past;
  return TripStatus.ongoing;
}

List<Item> selectTrips(
  List<Item> items, {
  required String query,
  required Set<int> favorites,
  required bool favoritesOnly,
  required TripSort sort,
}) {
  final terms = query.trim().toLowerCase().split(RegExp(r'\s+'));
  final selected = items.where((item) {
    final text = '${item.title} ${item.subtitle} ${item.tags.join(' ')}'
        .toLowerCase();
    return !item.deleted &&
        (!favoritesOnly || favorites.contains(item.id)) &&
        terms.every(text.contains);
  }).toList();
  selected.sort((a, b) {
    int order;
    if (sort == TripSort.title) {
      order = a.title.toLowerCase().compareTo(b.title.toLowerCase());
    } else {
      final aDate = TripDates.fromItem(a)?.start;
      final bDate = TripDates.fromItem(b)?.start;
      if (aDate == null && bDate != null) return 1;
      if (bDate == null && aDate != null) return -1;
      order = aDate == null ? 0 : aDate.compareTo(bDate!);
      if (sort == TripSort.newest) order = -order;
    }
    return order != 0 ? order : a.id.compareTo(b.id);
  });
  return selected;
}

class TripSummary {
  TripSummary(List<Item> items, Set<int> favorites, DateTime today)
    : this._(items.where((item) => !item.deleted).toList(), favorites, today);

  TripSummary._(List<Item> items, Set<int> favorites, DateTime today)
    : total = items.length,
      favoriteCount = items.where((item) => favorites.contains(item.id)).length,
      upcoming = items
          .where((item) => tripStatus(item, today) == TripStatus.upcoming)
          .length,
      ongoing = items
          .where((item) => tripStatus(item, today) == TripStatus.ongoing)
          .length,
      past = items
          .where((item) => tripStatus(item, today) == TripStatus.past)
          .length,
      unknown = items
          .where((item) => tripStatus(item, today) == TripStatus.unknown)
          .length,
      visitedCountries = _visitedDestinations(
        items,
        today,
      ).map((destination) => destination.countryCode).toSet().length,
      visitedCities = _visitedDestinations(
        items,
        today,
      ).map((destination) => destination.cityKey).nonNulls.toSet().length,
      days = items.fold(
        0,
        (sum, item) => sum + (TripDates.fromItem(item)?.days ?? 0),
      );

  final int total;
  final int favoriteCount;
  final int upcoming;
  final int ongoing;
  final int past;
  final int unknown;
  final int days;
  final int visitedCountries;
  final int visitedCities;
}

// City and country counts must use identical visit eligibility rules.
Iterable<DestinationInfo> _visitedDestinations(
  List<Item> items,
  DateTime today,
) => items
    .where(
      (item) =>
          !item.deleted &&
          [
            TripStatus.ongoing,
            TripStatus.past,
          ].contains(tripStatus(item, today)),
    )
    .map((item) => item.destinationInfo)
    .nonNulls;
