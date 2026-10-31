// E-1 AlertDialog · 여행지 추천 · P03 · P10
// E-2 Wrap + ChoiceChip · 여행 테마 선택 · P04 · P06
// E-3 ListTile + NetImage + TextButton · 추천 여행 추가 · P05 · P07
// E-4 TextField · 여행지 키워드 검색 · P01 · P07
import 'package:flutter/material.dart';
import '../destinations.dart';
import '../widgets.dart';

class TripSuggestion {
  const TripSuggestion(this.destination, this.theme);
  final String destination;
  final String theme;
  String get title => '$destination 여행';
}

class RecommendationsDialog extends StatefulWidget {
  const RecommendationsDialog({super.key});
  @override
  State<RecommendationsDialog> createState() => _RecommendationsDialogState();
}

class _RecommendationsDialogState extends State<RecommendationsDialog> {
  final _search = TextEditingController();
  String _theme = '전체';
  @override
  void dispose() { _search.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final results = searchDestinations(query: _search.text, theme: _theme == '전체' ? null : _theme);
    return AlertDialog( // E-1 P10
      title: const Text('여행지 추천'),
      content: SizedBox(
        width: 480,
        height: MediaQuery.sizeOf(context).height * .6,
        child: CustomScrollView(slivers: [
          SliverToBoxAdapter(child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('기존 도시 목록의 고정 테마예요. 검색·필터만 제공하며 취향 분석은 하지 않아요.'),
          TextField( // E-4 P07
            key: const ValueKey('destination-search'),
            controller: _search,
            decoration: InputDecoration(labelText: '도시·국가·테마 검색', suffixIcon: IconButton(
              tooltip: '검색 지우기', icon: const Icon(Icons.clear),
              onPressed: () => setState(() => _search.clear()),
            )),
            // STATE: 키워드 입력 → 로컬 카탈로그 결과 즉시 갱신.
            onChanged: (_) => setState(() {}),
          ),
          Wrap( // E-2 P06
            spacing: 8,
            children: [for (final theme in ['전체', '문화', '자연', '도시']) ChoiceChip(
              label: Text(theme), selected: theme == _theme,
              onSelected: (_) => setState(() => _theme = theme),
            )],
          ),
          Text('${results.length}개 여행지', key: const ValueKey('destination-count')),
          ])),
          if (results.isEmpty)
            const SliverToBoxAdapter(child: Text('검색 조건에 맞는 여행지가 없어요. 검색어나 테마를 바꿔 주세요.'))
          else SliverList.builder(
              itemCount: results.length,
              itemBuilder: (_, index) {
                final destination = results[index];
                return Column(mainAxisSize: MainAxisSize.min, children: [
                  ClipRRect(borderRadius: BorderRadius.circular(17), child: AspectRatio(aspectRatio: 16 / 9, child: NetImage(destination.photoUrl))),
                  ListTile( // E-3 P07
                    contentPadding: EdgeInsets.zero,
                    title: Text(destination.cityName),
                    subtitle: Text('${destination.countryName} · ${destination.themes.join(' · ')}'),
                    trailing: TextButton(
                      key: ValueKey('suggest-${destination.cityName}'),
                      onPressed: () => Navigator.pop(context, TripSuggestion(destination.cityName, _theme == '전체' ? destination.themes.first : _theme)),
                      child: const Text('여행 계획'),
                    ),
                  ),
                  const SizedBox(height: 12),
                ]);
              },
            ),
        ]),
      ),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('닫기'))],
    );
  }
}
