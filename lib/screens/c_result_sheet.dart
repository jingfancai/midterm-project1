import 'package:flutter/material.dart';
import '../models.dart';
import '../widgets.dart';
import '../trip_insights.dart';

class ResultSheet extends StatelessWidget {
  const ResultSheet({super.key, required this.items, required this.onSelect});

  final List<Item> items;
  final ValueChanged<Item> onSelect;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    // 从现有旅行数据中统计标签种类
    final summary = TripSummary(
      items,
      items.where((item) => item.favorite).map((item) => item.id).toSet(),
      DateTime.now(),
    );

    // 使用第一条旅行作为精选回忆
    final featuredItem = items.isNotEmpty ? items.first : null;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.auto_awesome, color: Color(0xFF2D7770)),
                SizedBox(width: 8),
                Text(
                  'TRAVEL RECAP',
                  style: TextStyle(
                    letterSpacing: 1.4,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2D7770),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Text(
              '나의 여행 돌아보기',
              style: text.headlineMedium?.copyWith(fontSize: 25),
            ),
            const SizedBox(height: 6),

            const Text(
              '지금까지 기록한 여행의 순간들을 다시 만나 보세요.',
              style: TextStyle(color: Color(0xFF687775), fontSize: 13),
            ),
            const SizedBox(height: 18),

            // 여행 통계
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.luggage_outlined,
                    number: '${summary.total}',
                    label: '총 여행',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatCard(
                    icon: Icons.public,
                    number: '${summary.visitedCountries}',
                    label: '방문 국가',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            if (featuredItem != null) ...[
              const Text(
                'FEATURED MEMORY',
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF2D7770),
                ),
              ),
              const SizedBox(height: 10),

              // 精选旅行卡片
              Material(
                color: const Color(0xFFF0F3EF),
                borderRadius: BorderRadius.circular(16),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => onSelect(featuredItem),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 155,
                        width: double.infinity,
                        child: NetImage(featuredItem.photoUrl),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    featuredItem.title,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF183B3A),
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    featuredItem.subtitle,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF687775),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              color: Color(0xFF2D7770),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 20),

            const Text(
              'ALL MY TRIPS',
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w800,
                color: Color(0xFF2D7770),
              ),
            ),
            const SizedBox(height: 10),

            // 全部旅行列表
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = items[index];

                  return Material(
                    color: const Color(0xFFF0F3EF),
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => onSelect(item),
                      child: Padding(
                        padding: const EdgeInsets.all(9),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: SizedBox(
                                width: 64,
                                height: 64,
                                child: NetImage(item.photoUrl),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF183B3A),
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    item.subtitle,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF687775),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right,
                              color: Color(0xFF2D7770),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 8),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('닫기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.number,
    required this.label,
  });

  final IconData icon;
  final String number;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F3EF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF2D7770)),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  number,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF183B3A),
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF687775),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
