// D-1 AlertDialog · 미래 여행 위시리스트 · P03 · P10
// D-2 TextField + FilledButton · 여행 소원 추가 · P05
// D-3 CheckboxListTile + IconButton · 여행 소원 관리 · P01 · P03
import 'package:flutter/material.dart';

class TravelWish {
  const TravelWish(this.title, {this.done = false});
  final String title;
  final bool done;
}

class WishlistDialog extends StatefulWidget {
  const WishlistDialog({super.key, required this.wishes, required this.onChanged});
  final List<TravelWish> wishes;
  final ValueChanged<List<TravelWish>> onChanged;
  @override
  State<WishlistDialog> createState() => _WishlistDialogState();
}

class _WishlistDialogState extends State<WishlistDialog> {
  final _input = TextEditingController();
  late List<TravelWish> _wishes = [...widget.wishes];
  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _change(List<TravelWish> wishes) {
    // STATE: 추가·체크·삭제 → 세션 위시리스트만 갱신.
    setState(() => _wishes = wishes);
    widget.onChanged(wishes);
  }

  void _add() {
    final title = _input.text.trim();
    if (title.isEmpty) return;
    _change([..._wishes, TravelWish(title)]);
    _input.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) => AlertDialog( // D-1 P03
    title: const Text('미래 여행 위시리스트'),
    content: SizedBox(
      width: 400,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('이번 세션에서만 유지돼요. 앱을 다시 시작하면 초기화돼요.'),
            TextField( // D-2 P05
              key: const ValueKey('wish-input'),
              controller: _input,
              maxLength: 100,
              decoration: const InputDecoration(labelText: '여행 소원'),
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => _add(),
            ),
            FilledButton(
              key: const ValueKey('add-wish'),
              onPressed: _input.text.trim().isEmpty ? null : _add,
              child: const Text('소원 추가'),
            ),
            if (_wishes.isEmpty) const Text('아직 여행 소원이 없어요.'),
            for (var i = 0; i < _wishes.length; i++)
              CheckboxListTile( // D-3 P03
                key: ValueKey('wish-$i'),
                contentPadding: EdgeInsets.zero,
                title: Text(_wishes[i].title),
                value: _wishes[i].done,
                onChanged: (done) {
                  final updated = [..._wishes];
                  updated[i] = TravelWish(updated[i].title, done: done ?? false);
                  _change(updated);
                },
                secondary: IconButton(
                  tooltip: '소원 삭제',
                  onPressed: () => _change([..._wishes]..removeAt(i)),
                  icon: const Icon(Icons.delete_outline),
                ),
              ),
          ],
        ),
      ),
    ),
    actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('닫기'))],
  );
}
