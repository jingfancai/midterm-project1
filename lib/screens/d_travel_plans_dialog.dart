// D-1 AlertDialog + DropdownButton · 여행 계획 · P03 · P10
// D-3 TravelPlansSection · 시간순 계획 관리 · P01 · P03
import 'package:flutter/material.dart';
import '../models.dart';
import '../trip_plans.dart';
import '../travel_plans_section.dart';

class TravelPlansDialog extends StatefulWidget {
  const TravelPlansDialog({super.key, required this.items, required this.plans, required this.onChanged, this.now = DateTime.now});
  final List<Item> Function() items;
  final Map<int, List<TravelPlan>> plans;
  final bool Function(int, List<TravelPlan>) onChanged;
  final DateTime Function() now;
  @override
  State<TravelPlansDialog> createState() => _TravelPlansDialogState();
}
class _TravelPlansDialogState extends State<TravelPlansDialog> {
  int? _tripId;
  @override
  void initState() {
    super.initState();
    final items = widget.items().where((item) => !item.deleted).toList();
    final future = items.where((item) => canEditTravelPlans(item, widget.now()));
    if (items.isNotEmpty) _tripId = (future.isEmpty ? items.first : future.first).id;
  }
  @override
  Widget build(BuildContext context) {
    final items = widget.items().where((item) => !item.deleted).toList();
    final selected = items.where((item) => item.id == _tripId);
    final item = selected.isEmpty ? null : selected.first;
    return AlertDialog( // D-1 P10
      title: const Text('여행 계획'),
      content: SizedBox(width: 520, child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        if (items.isEmpty) const Text('먼저 여행을 추가해 주세요.'),
        if (items.isNotEmpty) DropdownButton<int>(key: const ValueKey('plan-trip'), isExpanded: true, value: item?.id,
          items: [for (final trip in items) DropdownMenuItem(value: trip.id, child: Text(trip.title, overflow: TextOverflow.ellipsis))],
          onChanged: (id) => setState(() => _tripId = id)),
        if (item != null) TravelPlansSection( // D-3 P03
          key: ValueKey(item.id), item: () => widget.items().firstWhere((trip) => trip.id == item.id, orElse: () => item.copyWith(deleted: true)),
          plans: () => widget.plans[item.id] ?? const [], now: widget.now,
          onChanged: (plans) {
            final current = widget.items().where((trip) => trip.id == item.id);
            if (current.isEmpty || !canEditTravelPlans(current.first, widget.now())) return false;
            return widget.onChanged(item.id, plans);
          },
        ),
      ]))),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('닫기'))],
    );
  }
}
