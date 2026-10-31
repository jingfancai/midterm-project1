// E-1 AlertDialog · 여행지 추천 · P03 · P10
// E-2 Wrap + ChoiceChip · 여행 테마 선택 · P04 · P06
// E-3 ListTile + TextButton · 추천 여행 추가 · P05 · P07
import 'package:flutter/material.dart';

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
  static const _destinations = {
    '문화': ['교토', '파리'],
    '자연': ['제주도', '밴쿠버'],
    '도시': ['서울', '싱가포르'],
  };
  String _theme = '문화';
  @override
  Widget build(BuildContext context) => AlertDialog( // E-1 P10
    title: const Text('여행지 추천'),
    content: SizedBox(
      width: 400,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('테마별로 미리 준비한 여행지예요. 취향 분석이나 실시간 추천은 사용하지 않아요.'),
            const SizedBox(height: 12),
            Wrap( // E-2 P06
              spacing: 8,
              children: [for (final theme in _destinations.keys)
                ChoiceChip(
                  label: Text(theme),
                  selected: theme == _theme,
                  onSelected: (_) {
                    // STATE: 테마 선택 → 고정 목적지 목록.
                    setState(() => _theme = theme);
                  },
                ),
              ],
            ),
            for (final destination in _destinations[_theme]!)
              ListTile( // E-3 P07
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.place_outlined, color: Color(0xFF2D7770)),
                title: Text(destination),
                subtitle: Text('$_theme 여행'),
                trailing: TextButton(
                  key: ValueKey('suggest-$destination'),
                  onPressed: () => Navigator.pop(context, TripSuggestion(destination, _theme)),
                  child: const Text('여행 계획'),
                ),
              ),
          ],
        ),
      ),
    ),
    actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('닫기'))],
  );
}
