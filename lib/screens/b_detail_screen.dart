// 화면 B: 여행 상세 — 여행 정보 | 여행 기록 탭
import 'a_list_screen.dart';
import 'package:flutter/material.dart';
import '../api.dart';
import '../models.dart';
import '../widgets.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({
    super.key,
    required this.item,
    this.loadNotes = fetchNotes,
    this.loadItems = fetchItems,
  });

  final Item item;
  final NotesLoader loadNotes;
  final ItemsLoader loadItems;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late String _title;

  @override
  void initState() {
    super.initState();
    _title = widget.item.title;
  }

  Future<void> _editTitle() async {
    final controller = TextEditingController(text: _title);

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('여행 이름 수정'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 30,
          decoration: const InputDecoration(
            labelText: '여행 이름',
            hintText: '새로운 여행 이름을 입력하세요.',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext, controller.text.trim());
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );

    controller.dispose();

    if (!mounted || result == null || result.isEmpty) return;

    setState(() {
      _title = result;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('여행 이름이 수정되었습니다.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<String>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.of(context).pop(_title);
        }
     },
    child: DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            IconButton(
              onPressed: _editTitle,
              icon: const Icon(Icons.edit_outlined),
              tooltip: '여행 이름 수정',
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: '여행 정보'),
              Tab(text: '여행 기록'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _InfoTab(
              item: widget.item,
              title: _title,
              loadItems: widget.loadItems,
              loadNotes: widget.loadNotes,
            ),
            _NotesTab(
              itemId: widget.item.id,
              load: widget.loadNotes,
            ),
          ],
        ),
      ),
      ),
    );
  }
}

class _InfoTab extends StatelessWidget {
  const _InfoTab({
    required this.item,
    required this.title,
    required this.loadItems,
    required this.loadNotes,
  });

  final Item item;
  final String title;
  final ItemsLoader loadItems;
  final NotesLoader loadNotes;
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return ListView(padding: const EdgeInsets.fromLTRB(18, 12, 18, 24), children: [
      ClipRRect(borderRadius: BorderRadius.circular(22), child: AspectRatio(aspectRatio: 4/3, child: NetImage(item.image))),
      const SizedBox(height: 12),
      FutureBuilder<List<Item>>(future: loadItems(), builder: (context, snap) { if (snap.connectionState != ConnectionState.done || !snap.hasData || snap.data!.isEmpty) return const SizedBox.shrink(); final trips = snap.data!; return SizedBox(height: 112, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: trips.length, separatorBuilder: (_, _) => const SizedBox(width: 10), itemBuilder: (context, index) { final trip = trips[index]; return SizedBox(width: 140, child: InkWell(borderRadius: BorderRadius.circular(12), onTap: () { if (trip.id != item.id) Navigator.of(context).pushReplacement(MaterialPageRoute<void>(builder: (_) => DetailScreen(item: trip, loadNotes: loadNotes, loadItems: loadItems))); }, child: ClipRRect(borderRadius: BorderRadius.circular(12), child: Stack(fit: StackFit.expand, children: [NetImage(trip.image), Positioned(left: 0, right: 0, bottom: 0, child: Container(padding: const EdgeInsets.all(6), color: Colors.black54, child: Text(trip.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 11))))])))); })); }),
      const SizedBox(height: 8),
      const SizedBox(height: 20),
      const Row(children: [Icon(Icons.auto_awesome, color: Color(0xFF2D7770), size: 18), SizedBox(width: 6), Text('A JOURNEY TO REMEMBER', style: TextStyle(letterSpacing: 1.3, fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF2D7770)))]),
      const SizedBox(height: 8), Text(title, style: text.headlineMedium?.copyWith(fontSize: 27)),
      const SizedBox(height: 8), Row(children: [const Icon(Icons.location_on_outlined, color: Color(0xFF64817A), size: 18), const SizedBox(width: 5), Expanded(child: Text(item.subtitle, style: const TextStyle(color: Color(0xFF687775))))]),
      const SizedBox(height: 14), Wrap(spacing: 7, runSpacing: 7, children: [for (final tag in item.tags) Chip(avatar: const Icon(Icons.sell_outlined, size: 14), label: Text(tag), visualDensity: VisualDensity.compact, backgroundColor: const Color(0xFFEAF1ED), side: BorderSide.none)]),
      const SizedBox(height: 18), Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)), child: const Row(children: [Icon(Icons.photo_library_outlined, color: Color(0xFF2D7770), size: 25), SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('순간을 다시 꺼내 보기', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF183B3A))), SizedBox(height: 4), Text('사진과 짧은 기록으로 여행의 흐름을 돌아보세요.', style: TextStyle(fontSize: 12, color: Color(0xFF687775))) ]))])),
      const SizedBox(height: 16),
      OutlinedButton.icon(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('UI 시연용 버튼입니다. 실제 저장은 하지 않습니다.'))), icon: const Icon(Icons.bookmark_border), label: const Text('이 여행 보관하기 (예시)')),
      const SizedBox(height: 8),
      FilledButton.icon(onPressed: () => showDialog<void>(context: context, builder: (dialogContext) => AlertDialog(title: const Text('MY TRAVEL MEMORY'), content: SizedBox(width: 400, child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [SizedBox(height: 180, width: double.infinity, child: NetImage(item.image)), const SizedBox(height: 12), Text(item.title, style: Theme.of(context).textTheme.titleLarge), const SizedBox(height: 6), Text(item.subtitle), const SizedBox(height: 12), const Text('소중한 순간은 오래도록 기억에 남습니다.') ])), actions: [TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('닫기'))])), icon: const Icon(Icons.auto_awesome), label: const Text('여행 추억 카드 만들기')),
    ]);
  }
}


class _NotesTab extends StatefulWidget {
  const _NotesTab({required this.itemId, required this.load});

  final int itemId;
  final NotesLoader load;

  @override
  State<_NotesTab> createState() => _NotesTabState();
}

class _NotesTabState extends State<_NotesTab> {
  late Future<List<Note>> _future = widget.load(widget.itemId);

  void _retry() {
    setState(() {
      _future = widget.load(widget.itemId);
    });
  }

  Future<void> _addNote() async {
    final controller = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('새로운 여행 기록'),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: '오늘의 여행 순간을 기록해 보세요.',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext, controller.text.trim());
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );

    controller.dispose();

    if (!mounted || result == null || result.isEmpty) return;

    final now = DateTime.now();
    final date =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    setState(() {
      _future = _future.then((notes) => [
        ...notes,
        Note(
          id: notes.isEmpty
              ? 1
              : notes.map((note) => note.id).reduce((a, b) => a > b ? a : b) + 1,
          itemId: widget.itemId,
          text: result,
          date: date,
        ),
      ]);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('여행 기록이 추가되었습니다.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Note>>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const LoadingView(label: '여행 기록을 불러오는 중…');
        }

        if (snap.hasError) {
          return ErrorView(
            title: '여행 기록을 불러오지 못했어요.',
            message: '${snap.error}',
            onRetry: _retry,
          );
        }

        final notes = snap.data ?? const <Note>[];

        return ListView(
          padding: const EdgeInsets.all(18),
          children: [
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _addNote,
                icon: const Icon(Icons.add),
                label: const Text('여행 기록 추가'),
              ),
            ),
            const SizedBox(height: 18),

            if (notes.isEmpty)
              const EmptyView(
                message: '아직 기록이 없어요. 여행의 순간을 남겨 보세요.',
              )
            else
              for (var i = 0; i < notes.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: Color(0xFF2D7770),
                              shape: BoxShape.circle,
                            ),
                          ),
                          if (i != notes.length - 1)
                            Container(
                              width: 2,
                              height: 86,
                              color: const Color(0xFFD5E4DE),
                            ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                notes[i].date,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF2D7770),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 7),
                              Text(
                                notes[i].text,
                                style: const TextStyle(
                                  fontSize: 14,
                                  height: 1.45,
                                  color: Color(0xFF183B3A),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
          ],
        );
      },
    );
  }
}

