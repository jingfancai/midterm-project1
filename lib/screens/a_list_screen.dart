// 화면 A — 나의 여행 목록 · 디자인 가이드 대응표
// A-1 Row + Text · 브랜드명과 프로필 영역 · P04
// A-2 ListView + Card (TripCard) · 여행 카드 목록 · P06
// A-3 GridView (≥600dp) · 넓은 화면 여행 카드 격자 · P07
// A-4 LoadingView · 불러오는 중 표시 · P01
// A-5 ErrorView + FilledButton · 오류 안내·다시 시도 · P09
// A-6 EmptyView · 빈 목록 안내 · P01
// A-7 TextField · 여행 검색 · P07
// A-8 FilterChip + DropdownButton · 즐겨찾기 필터·그룹 내 정렬 · P07
// A-9 IconButton + AlertDialog + SnackBar · 즐겨찾기·삭제·실행 취소 · P03 · P05
// A-10 Wrap + Chip · 전체 여행 통계 · P01
import 'package:flutter/material.dart';
import '../api.dart';
import '../models.dart';
import '../widgets.dart';
import '../trip_insights.dart';
import 'b_detail_screen.dart';
import 'c_result_sheet.dart';
import 'd_profile_screen.dart';

const wideBreakpoint = 600.0;

class ListScreen extends StatefulWidget {
  const ListScreen({
    super.key,
    this.load = fetchItems,
    this.loadNotes = fetchNotes,
  });

  final ItemsLoader load;
  final NotesLoader loadNotes;

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  late Future<List<Item>> _future = widget.load();

  final _searchController = TextEditingController();
  String _query = '';
  bool _favoritesOnly = false;
  TripSort _sort = TripSort.newest;
  final Set<int> _favorites = {};
  final Set<int> _deletedIds = {};
  final Map<int, String> _titles = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Item> _activeItems(List<Item> loaded) => [
    for (final item in [...loaded, ..._addedItems])
      if (!_deletedIds.contains(item.id))
        Item(
          id: item.id,
          title: _titles[item.id] ?? item.title,
          subtitle: item.subtitle,
          image: item.image,
          tags: item.tags,
        ),
  ];

  void _toggleFavorite(Item item) {
    // STATE: 즐겨찾기 ID → A-8 필터 · A-9 아이콘 · A-10 통계 (세션 한정)
    setState(() {
      if (!_favorites.add(item.id)) _favorites.remove(item.id);
    });
  }

  Future<void> _deleteTrip(Item item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        // A-9 P05
        title: const Text('여행 삭제'),
        content: Text(
          '“${item.title}” 여행을 이 목록에서 삭제할까요?\n이번 실행에만 적용되며 원본 데이터는 유지됩니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    // STATE: 삭제 ID → 목록·통계·회고에서 제외, 실행 취소로 복원
    setState(() => _deletedIds.add(item.id));
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        // A-9 P03
        content: Text('${item.title} 여행이 삭제되었습니다.'),
        action: SnackBarAction(
          label: '실행 취소',
          onPressed: () {
            if (mounted) setState(() => _deletedIds.remove(item.id));
          },
        ),
      ),
    );
  }

  void _resetFilters() {
    _searchController.clear();
    setState(() {
      _query = '';
      _favoritesOnly = false;
    });
  }

  // 본 실행에서만 여행을 추가하며 서버에는 쓰지 않는다.
  final List<Item> _addedItems = [];

  void _retry() {
    setState(() {
      _future = widget.load();
    });
  }

  Future<void> _open(Item item) async {
    final newTitle = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        builder: (_) => DetailScreen(item: item, loadNotes: widget.loadNotes),
      ),
    );

    if (newTitle == null || !mounted) return;

    setState(() => _titles[item.id] = newTitle);
  }

  Future<void> _addTrip() async {
    final titleController = TextEditingController();
    final destinationController = TextEditingController();

    DateTime startDate = DateTime.now().add(const Duration(days: 7));
    DateTime endDate = DateTime.now().add(const Duration(days: 10));

    String formatDate(DateTime date) {
      return '${date.year}.'
          '${date.month.toString().padLeft(2, '0')}.'
          '${date.day.toString().padLeft(2, '0')}';
    }

    final newItem = await showDialog<Item>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('새로운 여행 추가'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: '여행 이름',
                        hintText: '예: 교토 가을 여행',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: destinationController,
                      decoration: const InputDecoration(
                        labelText: '목적지',
                        hintText: '예: 일본 교토',
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 출발 날짜
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('출발 날짜'),
                      subtitle: Text(formatDate(startDate)),
                      trailing: const Icon(Icons.calendar_month),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: dialogContext,
                          initialDate: startDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2035),
                        );

                        if (picked != null) {
                          setDialogState(() {
                            startDate = picked;

                            if (endDate.isBefore(startDate)) {
                              endDate = startDate;
                            }
                          });
                        }
                      },
                    ),

                    // 结束日期
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('종료 날짜'),
                      subtitle: Text(formatDate(endDate)),
                      trailing: const Icon(Icons.calendar_month),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: dialogContext,
                          initialDate: endDate,
                          firstDate: startDate,
                          lastDate: DateTime(2035),
                        );

                        if (picked != null) {
                          setDialogState(() {
                            endDate = picked;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('취소'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (titleController.text.trim().isEmpty ||
                        destinationController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('여행 이름과 목적지를 입력해 주세요.')),
                      );
                      return;
                    }

                    final newTrip = Item(
                      id: DateTime.now().microsecondsSinceEpoch,
                      title: titleController.text.trim(),
                      subtitle:
                          '${formatDate(startDate)} – '
                          '${formatDate(endDate)} · '
                          '${destinationController.text.trim()}',
                      image:
                          'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?w=1000&q=85',
                      tags: [destinationController.text.trim()],
                    );

                    Navigator.pop(dialogContext, newTrip);
                  },
                  child: const Text('여행 추가'),
                ),
              ],
            );
          },
        );
      },
    );

    titleController.dispose();
    destinationController.dispose();

    if (newItem != null && mounted) {
      setState(() {
        _addedItems.add(newItem);
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('여행이 추가되었습니다.')));
    }
  }

  Widget _buildControls(List<Item> items, int resultCount) {
    final summary = TripSummary(items, _favorites, DateTime.now());
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 0, 22, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '전체 여행 통계',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF183B3A),
            ),
          ),
          Wrap(
            spacing: 8,
            children: [
              // A-10 P01
              Chip(label: Text('총 여행 ${summary.total}')),
              Chip(label: Text('즐겨찾기 ${summary.favoriteCount}')),
              Chip(label: Text('예정 ${summary.upcoming}')),
              Chip(label: Text('진행 ${summary.ongoing}')),
              Chip(label: Text('완료 ${summary.past}')),
              if (summary.unknown > 0)
                Chip(label: Text('날짜 미정 ${summary.unknown}')),
              Chip(label: Text('여행일 합계 ${summary.days}일')),
            ],
          ),
          const Text(
            '여행별 기간의 합계 · 날짜 미정 제외 · 이번 실행에만 반영',
            style: TextStyle(fontSize: 11, color: Color(0xFF687775)),
          ),
          const SizedBox(height: 14),
          TextField(
            // A-7 P07
            key: const ValueKey('trip-search'),
            controller: _searchController,
            // STATE: 검색어 → 제목·목적지·태그에 맞는 여행 카드
            onChanged: (value) => setState(() => _query = value),
            decoration: InputDecoration(
              labelText: '여행 검색',
              hintText: '여행 이름, 목적지, 태그',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      tooltip: '검색어 지우기',
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                    ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              FilterChip(
                // A-8 P07
                label: const Text('즐겨찾기만'),
                selected: _favoritesOnly,
                onSelected: (value) => setState(() => _favoritesOnly = value),
                avatar: const Icon(Icons.bookmark_border, size: 18),
              ),
              DropdownButton<TripSort>(
                key: const ValueKey('trip-sort'),
                value: _sort,
                // STATE: 정렬 기준 → 각 날짜 그룹 안의 여행 순서
                onChanged: (value) {
                  if (value != null) setState(() => _sort = value);
                },
                items: const [
                  DropdownMenuItem(
                    value: TripSort.newest,
                    child: Text('최신 출발일순'),
                  ),
                  DropdownMenuItem(
                    value: TripSort.oldest,
                    child: Text('오래된 출발일순'),
                  ),
                  DropdownMenuItem(value: TripSort.title, child: Text('이름순')),
                ],
              ),
              Text(
                '$resultCount개 표시',
                style: const TextStyle(color: Color(0xFF687775)),
              ),
            ],
          ),
          const Text(
            '각 여행 그룹 안에서 정렬됩니다.',
            style: TextStyle(fontSize: 11, color: Color(0xFF687775)),
          ),
        ],
      ),
    );
  }

  Widget _buildTripSection({
    required String title,
    required List<Item> items,
    required bool wide,
  }) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12, left: 4),
            child: Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF183B3A),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${items.length}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF78908A),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (wide)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 360,
                mainAxisExtent: 300,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: items.length,
              itemBuilder: (context, i) {
                return TripCard(
                  item: items[i],
                  favorite: _favorites.contains(items[i].id),
                  onFavorite: () => _toggleFavorite(items[i]),
                  onDelete: () => _deleteTrip(items[i]),
                  onTap: () => _open(items[i]),
                  vertical: true,
                );
              },
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 14),
              itemBuilder: (context, i) {
                return TripCard(
                  item: items[i],
                  favorite: _favorites.contains(items[i].id),
                  onFavorite: () => _toggleFavorite(items[i]),
                  onDelete: () => _deleteTrip(items[i]),
                  onTap: () => _open(items[i]),
                );
              },
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.explore_rounded,
                          color: Color(0xFF2D7770),
                          size: 30,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'polarsteps',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontSize: 23, letterSpacing: -0.7),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const ProfileScreen(),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(30),
                          child: const CircleAvatar(
                            radius: 19,
                            backgroundColor: Color(0xFFDDEAE3),
                            child: Icon(
                              Icons.person_outline,
                              color: Color(0xFF183B3A),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Text(
                      '여행은 지나가도,',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineMedium?.copyWith(fontSize: 28),
                    ),
                    Text(
                      '추억은 남도록.',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            fontSize: 28,
                            color: const Color(0xFF2D7770),
                          ),
                    ),
                    const SizedBox(height: 9),
                    const Text(
                      '나의 순간들을 한곳에 모아 보세요.',
                      style: TextStyle(color: Color(0xFF687775), fontSize: 14),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        const Text(
                          '나의 여행',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF183B3A),
                          ),
                        ),
                        const Spacer(),
                        InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () async {
                            try {
                              final loadedItems = await _future;
                              final items = _activeItems(loadedItems);

                              if (!context.mounted || items.isEmpty) return;

                              showModalBottomSheet<void>(
                                context: context,
                                showDragHandle: true,
                                isScrollControlled: true,
                                builder: (sheetContext) => ResultSheet(
                                  items: items,
                                  onSelect: (item) {
                                    Navigator.of(sheetContext).pop();
                                    _open(item);
                                  },
                                ),
                              );
                            } catch (_) {
                              if (!context.mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('여행 기록을 불러오지 못했어요.'),
                                ),
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE4EFEB),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              '기록 모아보기',
                              style: TextStyle(
                                color: Color(0xFF2D7770),
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: FutureBuilder<List<Item>>(
                future: _future,
                builder: (context, snap) {
                  if (snap.connectionState != ConnectionState.done) {
                    return const SizedBox(
                      height: 260,
                      child: LoadingView(label: '여행 기록을 불러오는 중…'),
                    );
                  }

                  if (snap.hasError) {
                    return SizedBox(
                      height: 300,
                      child: ErrorView(
                        title: '여행 기록을 불러오지 못했어요.',
                        message: '${snap.error}',
                        onRetry: _retry,
                      ),
                    );
                  }

                  final items = _activeItems(snap.data ?? const <Item>[]);
                  final visible = selectTrips(
                    items,
                    query: _query,
                    favorites: _favorites,
                    favoritesOnly: _favoritesOnly,
                    sort: _sort,
                  );
                  final today = DateTime.now();

                  if (items.isEmpty && _deletedIds.isEmpty) {
                    return const SizedBox(
                      height: 300,
                      child: EmptyView(
                        message: '아직 여행 기록이 없어요. 첫 번째 여행을 기록해 보세요.',
                      ),
                    );
                  }

                  final upcomingTrips = visible
                      .where(
                        (item) =>
                            tripStatus(item, today) == TripStatus.upcoming,
                      )
                      .toList();

                  final ongoingTrips = visible
                      .where(
                        (item) => tripStatus(item, today) == TripStatus.ongoing,
                      )
                      .toList();

                  final pastTrips = visible
                      .where(
                        (item) => tripStatus(item, today) == TripStatus.past,
                      )
                      .toList();

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final wide = constraints.maxWidth >= wideBreakpoint;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildControls(items, visible.length),
                          if (visible.isEmpty)
                            Padding(
                              padding: const EdgeInsets.all(22),
                              child: Column(
                                children: [
                                  EmptyView(
                                    message: items.isEmpty
                                        ? '표시할 여행이 없어요. 삭제는 아래에서 실행 취소할 수 있어요.'
                                        : '검색 조건에 맞는 여행이 없어요.',
                                  ),
                                  if (items.isNotEmpty)
                                    TextButton(
                                      onPressed: _resetFilters,
                                      child: const Text('검색·필터 초기화'),
                                    ),
                                ],
                              ),
                            ),
                          _buildTripSection(
                            title: '다가오는 여행',
                            items: upcomingTrips,
                            wide: wide,
                          ),
                          _buildTripSection(
                            title: '진행 중인 여행',
                            items: ongoingTrips,
                            wide: wide,
                          ),
                          _buildTripSection(
                            title: '지난 여행',
                            items: pastTrips,
                            wide: wide,
                          ),
                          _buildTripSection(
                            title: '날짜 미정',
                            items: visible
                                .where(
                                  (item) =>
                                      tripStatus(item, today) ==
                                      TripStatus.unknown,
                                )
                                .toList(),
                            wide: wide,
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),

            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(22, 4, 22, 24),
                child: Center(
                  child: Text(
                    'YOUR JOURNEY, YOUR STORY',
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 2,
                      color: Color(0xFF8A9995),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTrip,
        backgroundColor: const Color(0xFF2F8179),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class TripCard extends StatelessWidget {
  const TripCard({
    super.key,
    required this.item,
    required this.onTap,
    this.vertical = false,
    this.favorite = false,
    this.onFavorite,
    this.onDelete,
  });

  final Item item;
  final VoidCallback onTap;
  final bool vertical;
  final bool favorite;
  final VoidCallback? onFavorite;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final image = ClipRRect(
      borderRadius: BorderRadius.circular(17),
      child: Stack(
        fit: StackFit.expand,
        children: [
          NetImage(item.image),
          Positioned(
            right: 4,
            bottom: 4,
            child: Material(
              color: Colors.white.withValues(alpha: .95),
              borderRadius: BorderRadius.circular(24),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onFavorite != null)
                    IconButton(
                      // A-9 P03
                      key: ValueKey('favorite-${item.id}'),
                      tooltip: favorite ? '즐겨찾기 해제' : '즐겨찾기 추가',
                      isSelected: favorite,
                      onPressed: onFavorite,
                      color: const Color(0xFF2D7770),
                      icon: Icon(
                        favorite ? Icons.bookmark : Icons.bookmark_border,
                      ),
                    ),
                  if (onDelete != null)
                    IconButton(
                      key: ValueKey('delete-${item.id}'),
                      tooltip: '여행 삭제',
                      onPressed: onDelete,
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Color(0xFF687775),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 12,
            top: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .92),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'TRIP MEMORY',
                style: TextStyle(
                  fontSize: 9,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF183B3A),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    final info = Padding(
      padding: const EdgeInsets.fromLTRB(2, 12, 2, 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontSize: 17),
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              const Icon(
                Icons.place_outlined,
                size: 15,
                color: Color(0xFF64817A),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  item.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF687775),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 5,
            runSpacing: 5,
            children: [
              for (final tag in item.tags.take(3))
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF1ED),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(
                      color: Color(0xFF42665E),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: vertical
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: image),
                    info,
                  ],
                )
              : Row(
                  children: [
                    SizedBox(width: 128, height: 128, child: image),
                    const SizedBox(width: 14),
                    Expanded(child: info),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 15,
                      color: Color(0xFF78908A),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
