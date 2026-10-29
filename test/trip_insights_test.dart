import 'package:flutter_test/flutter_test.dart';
import 'package:mid_project_template/models.dart';
import 'package:mid_project_template/trip_insights.dart';

const items = [
  Item(id: 1, title: 'First', subtitle: '', image: '', demoStatus: 'upcoming'),
  Item(id: 2, title: 'Second', subtitle: '', image: '', demoStatus: 'past'),
];
void main() {
  test('statistics are explicitly fixed example values', () {
    const s = TripSummary();
    expect(
      [s.total, s.visitedCities, s.visitedCountries, s.days],
      [4, 4, 2, 13],
    );
  });
  test(
    'classification uses a provided display label, not the current date',
    () {
      expect(tripStatus(items.first), TripStatus.upcoming);
      expect(tripStatus(items.last), TripStatus.past);
    },
  );
  test('unknown display label stays unknown without parsing dates', () {
    expect(
      tripStatus(
        const Item(id: 3, title: '', subtitle: '2000.01.01', image: ''),
      ),
      TripStatus.unknown,
    );
  });
  test('any query or favorite selection shows the same prewritten example', () {
    for (final query in ['Tokyo', 'missing', '中文']) {
      expect(
        selectTrips(
          items,
          query: query,
          favorites: {2},
          favoritesOnly: false,
          sort: TripSort.newest,
        ),
        [items.first],
      );
    }
    expect(
      selectTrips(
        items,
        query: '',
        favorites: {2},
        favoritesOnly: true,
        sort: TripSort.newest,
      ),
      [items.first],
    );
  });
  test('sort options never reorder the source data', () {
    for (final sort in TripSort.values) {
      expect(
        selectTrips(
          items,
          query: '',
          favorites: {},
          favoritesOnly: false,
          sort: sort,
        ),
        items,
      );
    }
  });
}
