import 'models.dart';

enum TripSort { newest, oldest, title }

enum TripStatus { upcoming, ongoing, past, unknown }

// STATE: 실제 날짜 → 여행 분류 (구현하지 않음). GET 예시 데이터의 표시값만 사용.
TripStatus tripStatus(Item item) => switch (item.demoStatus) {
  'upcoming' => TripStatus.upcoming,
  'ongoing' => TripStatus.ongoing,
  'past' => TripStatus.past,
  _ => TripStatus.unknown,
};

// STATE: 검색어·필터·정렬 → 결과 (구현하지 않음).
// Any nonempty query/filter shows the same first sample; no text search or sort.
List<Item> selectTrips(
  List<Item> items, {
  required String query,
  required Set<int> favorites,
  required bool favoritesOnly,
  required TripSort sort,
}) => query.trim().isNotEmpty || favoritesOnly ? items.take(1).toList() : items;

// Presentation constants, deliberately independent of user data, dates or edits.
class TripSummary {
  const TripSummary();
  final int total = 4;
  final int favoriteCount = 1;
  final int upcoming = 1;
  final int ongoing = 1;
  final int past = 2;
  final int unknown = 0;
  final int days = 13;
  final int visitedCountries = 2;
  final int visitedCities = 4;
}
