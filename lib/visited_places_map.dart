import 'package:flutter/material.dart';
import 'models.dart';
import 'trip_insights.dart';

/// C-6: bundled Plate Carree image and catalog coordinates; no map service.
class VisitedPlacesMap extends StatelessWidget {
  const VisitedPlacesMap({super.key, required this.items});
  final List<Item> items;

  Offset _position(VisitedCity city, Size size) => Offset(
    (city.destination.longitude! + 180) / 360 * size.width,
    (90 - city.destination.latitude!) / 180 * size.height,
  );

  void _showPlaces(BuildContext context, List<VisitedCity> nearby) {
    // STATE: 선택한 Marker → 현재 메모리의 도시·국가·여행 제목 Dialog.
    // C-7 P03 · P10: nearby cities remain selectable even when markers overlap.
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('방문 장소'),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (nearby.length > 1)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Text('가까운 도시를 함께 표시해요.'),
                  ),
                for (final city in nearby)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${city.destination.cityName} · ${city.destination.countryName}',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        for (final trip in city.trips) Text('• ${trip.title}'),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cities = visitedCities(items, DateTime.now());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '방문 장소 지도',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFF183B3A),
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: AspectRatio(
              aspectRatio: 2,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final size = Size(
                    constraints.maxWidth,
                    constraints.maxHeight,
                  );
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.asset(
                            'assets/images/world_map.png',
                            fit: BoxFit.fill,
                            semanticLabel: '로컬 정적 세계 지도',
                          ),
                        ),
                      ),
                      for (final city in cities)
                        Positioned(
                          left: _position(city, size).dx - 18,
                          top: _position(city, size).dy - 18,
                          width: 36,
                          height: 36,
                          child: IconButton(
                            key: ValueKey(
                              'map-marker-${city.destination.cityKey}',
                            ),
                            tooltip:
                                '${city.destination.cityName} · ${city.destination.countryName}',
                            padding: EdgeInsets.zero,
                            onPressed: () => _showPlaces(context, [
                              city,
                              ...cities.where(
                                (other) =>
                                    other != city &&
                                    (_position(other, size) -
                                                _position(city, size))
                                            .distance <
                                        36,
                              ),
                            ]),
                            icon: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: const Color(0xFF2D7770),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          cities.isEmpty
              ? '표시할 방문 도시가 없어요. 시작한 여행의 인식된 도시만 표시해요.'
              : '표시된 도시 ${cities.length}개 · 점을 누르면 도시와 여행을 볼 수 있어요.',
          style: const TextStyle(fontSize: 11, color: Color(0xFF687775)),
        ),
      ],
    );
  }
}
