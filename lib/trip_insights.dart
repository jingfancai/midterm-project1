import 'models.dart';

enum TripSort { newest, oldest, title }

enum TripStatus { upcoming, ongoing, past, unknown }

/// Supports the existing subtitle format, including abbreviated end dates.
class TripDates {
  const TripDates(this.start, this.end);

  final DateTime start;
  final DateTime end;

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
  final dates = TripDates.parse(item.subtitle);
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
    return (!favoritesOnly || favorites.contains(item.id)) &&
        terms.every(text.contains);
  }).toList();
  selected.sort((a, b) {
    int order;
    if (sort == TripSort.title) {
      order = a.title.toLowerCase().compareTo(b.title.toLowerCase());
    } else {
      final aDate = TripDates.parse(a.subtitle)?.start;
      final bDate = TripDates.parse(b.subtitle)?.start;
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
      days = items.fold(
        0,
        (sum, item) => sum + (TripDates.parse(item.subtitle)?.days ?? 0),
      );

  final int total;
  final int favoriteCount;
  final int upcoming;
  final int ongoing;
  final int past;
  final int unknown;
  final int days;
}
