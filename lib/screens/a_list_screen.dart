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
import '../trip_editor.dart';
import 'b_detail_screen.dart';
import 'c_result_sheet.dart';
import 'd_profile_screen.dart';

const wideBreakpoint = 600.0;

class ListScreen extends StatefulWidget {
  const ListScreen({
    super.key,
    this.load = fetchItems,
    this.loadNotes = fetchNotes,
    this.create = createItem,
    this.update = updateItem,
  });

  final ItemsLoader load;
  final NotesLoader loadNotes;
  final ItemSaver create;
  final ItemSaver update;

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  late Future<List<Item>> _future = _load();
  List<Item> _items = [];
  final _searchController = TextEditingController();
  String _query = '';
  bool _favoritesOnly = false;
  TripSort _sort = TripSort.newest;
  bool _hadDeletion = false;
  final Set<int> _busyIds = {};
  Set<int> get _favorites =>
      _items.where((item) => item.favorite).map((item) => item.id).toSet();

  Future<List<Item>> _load() async {
    _items = (await widget.load()).where((item) => !item.deleted).toList();
    return _items;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _accept(Item saved) {
    if (!mounted) return;
    setState(() {
      final index = _items.indexWhere((item) => item.id == saved.id);
      final items = [..._items];
      if (saved.deleted) {
        items.removeWhere((item) => item.id == saved.id);
      } else if (index < 0) {
        items.add(saved);
      } else {
        items[index] = saved;
      }
      _items = items;
      _future = Future.value(_items);
    });
  }

  Future<Item> _persist(Item item) async {
    final saved = await widget.update(item);
    _accept(saved);
    return saved;
  }

  Future<bool> _action(Item item) async {
    if (_busyIds.contains(item.id)) return false;
    setState(() => _busyIds.add(item.id));
    try {
      await _persist(item);
      return true;
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$error')));
      }
      return false;
    } finally {
      if (mounted) setState(() => _busyIds.remove(item.id));
    }
  }

  Future<void> _toggleFavorite(Item item) async {
    // STATE: 서버 저장 성공 → 카드·필터·통계 갱신. 실패 시 기존 값 유지.
    await _action(item.copyWith(favorite: !item.favorite));
  }

  Future<void> _deleteTrip(Item item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        // A-9 P05
        title: const Text('여행 삭제'),
        content: Text(
          '“${item.title}” 여행을 삭제할까요?\n새로고침 후에도 목록에서 제외됩니다. 삭제 직후 실행 취소할 수 있어요.',
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
    if (!await _action(item.copyWith(deleted: true)) || !mounted) return;
    setState(() => _hadDeletion = true);
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        // Action snack bars persist by default in this Flutter version.
        persist: false,
        duration: MediaQuery.accessibleNavigationOf(context)
            ? const Duration(seconds: 10)
            : const Duration(seconds: 4),
        content: Text('${item.title} 여행이 삭제되었습니다.'),
        action: SnackBarAction(
          label: '실행 취소',
          onPressed: () async {
            final restored = await _action(item.copyWith(deleted: false));
            if (!restored && mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('복원하지 못했어요. 다시 시도해 주세요.'),
                  action: SnackBarAction(
                    label: '다시 시도',
                    onPressed: () => _action(item.copyWith(deleted: false)),
                  ),
                ),
              );
            }
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

  void _retry() {
    setState(() {
      _future = _load();
    });
  }

  Future<void> _open(Item item) => Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      builder: (_) => DetailScreen(
        item: item,
        loadNotes: widget.loadNotes,
        loadItems: () async => _items,
        save: _persist,
      ),
    ),
  );

  Future<void> _addTrip() async {
    await showDialog<Item>(
      context: context,
      barrierDismissible: false,
      builder: (_) => TripEditor(
        save: (item) async {
          final saved = await widget.create(item);
          _accept(saved);
          return saved;
        },
      ),
    );
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
              Chip(label: Text('방문 국가 ${summary.visitedCountries}개')),
              Chip(label: Text('방문 도시 수 ${summary.visitedCities}개')),
            ],
          ),
          const Text(
            '여행 기간 합계 · 방문 도시·국가는 시작한 여행만 중복 없이 집계',
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
                  onFavorite: _busyIds.contains(items[i].id)
                      ? null
                      : () => _toggleFavorite(items[i]),
                  onDelete: _busyIds.contains(items[i].id)
                      ? null
                      : () => _deleteTrip(items[i]),
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
                  onFavorite: _busyIds.contains(items[i].id)
                      ? null
                      : () => _toggleFavorite(items[i]),
                  onDelete: _busyIds.contains(items[i].id)
                      ? null
                      : () => _deleteTrip(items[i]),
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
                        IconButton(
                          tooltip: '여행 새로고침',
                          key: const ValueKey('refresh-trips'),
                          onPressed: _busyIds.isEmpty ? _retry : null,
                          icon: const Icon(Icons.refresh),
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
                              final items = loadedItems
                                  .where((item) => !item.deleted)
                                  .toList();

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

                  final items = (snap.data ?? const <Item>[])
                      .where((item) => !item.deleted)
                      .toList();
                  final visible = selectTrips(
                    items,
                    query: _query,
                    favorites: _favorites,
                    favoritesOnly: _favoritesOnly,
                    sort: _sort,
                  );
                  final today = DateTime.now();

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
                                        ? (_hadDeletion
                                              ? '표시할 여행이 없어요. 삭제는 아래에서 실행 취소할 수 있어요.'
                                              : '아직 여행 기록이 없어요. 첫 번째 여행을 기록해 보세요.')
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
          NetImage(item.photoUrl),
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
