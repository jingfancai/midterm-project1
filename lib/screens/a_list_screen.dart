import 'package:flutter/material.dart';
import '../api.dart';
import '../models.dart';
import '../widgets.dart';
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

  // 本次 App 运行期间新增的旅行
  final List<Item> _addedItems = [];

  void _retry() {
    setState(() {
      _future = widget.load();
    });
  }

  void _open(Item item) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DetailScreen(
          item: item,
          loadNotes: widget.loadNotes,
        ),
      ),
    );
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
                      const SnackBar(
                        content: Text('여행 이름과 목적지를 입력해 주세요.'),
                      ),
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
                    tags: [
                      destinationController.text.trim(),
                    ],
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

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('여행이 추가되었습니다.')),
    );
  }
}

  // 从 subtitle 中提取旅行开始日期
  // 例如：2026.09.12 – 09.15 · 제주특별자치도
  // 여행 시작일과 종료일 가져오기
({DateTime start, DateTime end})? _getTripDates(Item item) {
  final match = RegExp(
    r'(\d{4})\.(\d{1,2})\.(\d{1,2})'
    r'(?:\s*[–-]\s*(?:(\d{4})\.)?(\d{1,2})\.(\d{1,2}))?',
  ).firstMatch(item.subtitle);

  if (match == null) return null;

  final startYear = int.parse(match.group(1)!);
  final startMonth = int.parse(match.group(2)!);
  final startDay = int.parse(match.group(3)!);

  final endYear = int.tryParse(match.group(4) ?? '') ?? startYear;
  final endMonth = int.tryParse(match.group(5) ?? '') ?? startMonth;
  final endDay = int.tryParse(match.group(6) ?? '') ?? startDay;

  return (
    start: DateTime(startYear, startMonth, startDay),
    end: DateTime(endYear, endMonth, endDay),
  );
}

// 미래 여행
bool _isUpcoming(Item item) {
  final dates = _getTripDates(item);
  if (dates == null) return false;

  final today = DateUtils.dateOnly(DateTime.now());
  return dates.start.isAfter(today);
}

// 正在进行的旅行
bool _isOngoing(Item item) {
  final dates = _getTripDates(item);
  if (dates == null) return false;

  final today = DateUtils.dateOnly(DateTime.now());

  return !dates.start.isAfter(today) &&
      !dates.end.isBefore(today);
}

// 过去旅行
bool _isPast(Item item) {
  final dates = _getTripDates(item);
  if (dates == null) return true;

  final today = DateUtils.dateOnly(DateTime.now());
  return dates.end.isBefore(today);
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
              gridDelegate:
                  const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 360,
                mainAxisExtent: 300,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: items.length,
              itemBuilder: (context, i) {
                return TripCard(
                  item: items[i],
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
                        Text(
                          'polarsteps',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                fontSize: 23,
                                letterSpacing: -0.7,
                              ),
                        ),
                        const Spacer(),
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
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(fontSize: 28),
                    ),
                    Text(
                      '추억은 남도록.',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(
                            fontSize: 28,
                            color: const Color(0xFF2D7770),
                          ),
                    ),
                    const SizedBox(height: 9),
                    const Text(
                      '나의 순간들을 한곳에 모아 보세요.',
                      style: TextStyle(
                        color: Color(0xFF687775),
                        fontSize: 14,
                      ),
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
                              final items = [...loadedItems, ..._addedItems];

                              if (!mounted || items.isEmpty) return;

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
                              if (!mounted) return;

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
                      child: LoadingView(
                        label: '여행 기록을 불러오는 중…',
                      ),
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

                  final items = [
                    ...(snap.data ?? const <Item>[]),
                    ..._addedItems,
                  ];

                  if (items.isEmpty) {
                    return const SizedBox(
                      height: 300,
                      child: EmptyView(
                        message: '아직 여행 기록이 없어요. 첫 번째 여행을 기록해 보세요.',
                      ),
                    );
                  }

                  final upcomingTrips =
                      items.where(_isUpcoming).toList();

                  final ongoingTrips =
                      items.where(_isOngoing).toList();

                  final pastTrips =
                      items.where(_isPast).toList();

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final wide =
                          constraints.maxWidth >= wideBreakpoint;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
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
  });

  final Item item;
  final VoidCallback onTap;
  final bool vertical;

  @override
  Widget build(BuildContext context) {
    final image = ClipRRect(
      borderRadius: BorderRadius.circular(17),
      child: Stack(
        fit: StackFit.expand,
        children: [
          NetImage(item.image),
          Positioned(
            left: 12,
            top: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
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
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 17,
                ),
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
                    SizedBox(
                      width: 128,
                      height: 128,
                      child: image,
                    ),
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

