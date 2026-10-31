// D-1 AlertDialog + DropdownButton · 여행 계획 · P03 · P10
// D-2 Form + TextFormField · 계획 입력 · P05
// D-3 ListTile + IconButton · 시간순 계획 관리 · P01 · P03
import 'dart:async';
import 'package:flutter/material.dart';
import '../models.dart';
import '../trip_insights.dart';
import '../trip_plans.dart';

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
  final _date = TextEditingController();
  final _time = TextEditingController();
  final _place = TextEditingController();
  final _activity = TextEditingController();
  int? _tripId;
  TravelPlan? _editing;
  String? _error;
  late final Timer _clock;
  @override
  void initState() {
    super.initState();
    final items = widget.items().where((item) => !item.deleted).toList();
    final future = items.where((item) => canEditTravelPlans(item, widget.now()));
    if (items.isNotEmpty) _select(future.isEmpty ? items.first : future.first);
    // Refresh the permission display when the departure day begins.
    _clock = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }
  @override
  void dispose() {
    _clock.cancel();
    for (final field in [_date, _time, _place, _activity]) { field.dispose(); }
    super.dispose();
  }
  void _select(Item item) {
    _tripId = item.id;
    _editing = null;
    _error = null;
    final start = TripDates.fromItem(item)?.start;
    _date.text = start?.toIso8601String().substring(0, 10) ?? '';
    _time.text = '09:00';
    _place.clear();
    _activity.clear();
  }
  Item? get _item {
    for (final item in widget.items()) {
      if (item.id == _tripId && !item.deleted) return item;
    }
    return null;
  }
  bool get _editable => _item != null && canEditTravelPlans(_item!, widget.now());
  List<TravelPlan> get _plans => widget.plans[_tripId] ?? const [];
  void _apply(List<TravelPlan> plans) {
    // STATE: 미래 여행 계획 → 해당 여행의 세션 메모리만 변경.
    if (!_editable || !widget.onChanged(_tripId!, sortedTravelPlans(plans))) {
      setState(() => _error = '여행이 시작되어 계획을 변경할 수 없어요.');
      return;
    }
    setState(() => _select(_item!));
  }
  void _save() {
    if (!_editable) { setState(() {}); return; }
    final plan = TravelPlan(date: _date.text.trim(), time: _time.text.trim(), place: _place.text.trim(), activity: _activity.text.trim());
    final error = validateTravelPlan(plan, _item!);
    if (error != null) { setState(() => _error = error); return; }
    final plans = [..._plans];
    if (_editing == null) {
      plans.add(plan);
    } else {
      final index = plans.indexOf(_editing!);
      if (index < 0) return;
      plans[index] = plan;
    }
    _apply(plans);
  }
  Widget _field(String key, String label, TextEditingController controller, int length) => TextFormField(
    key: ValueKey(key), controller: controller, maxLength: length,
    decoration: InputDecoration(labelText: label),
  );
  @override
  Widget build(BuildContext context) {
    final items = widget.items().where((item) => !item.deleted).toList();
    final item = _item;
    final editable = _editable;
    return AlertDialog( // D-1 P10
      title: const Text('여행 계획'),
      content: SizedBox(width: 400, child: SingleChildScrollView(child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('계획은 이번 세션에서만 유지돼요. 미래 여행만 변경할 수 있어요.'),
          if (items.isEmpty) const Text('먼저 여행을 추가해 주세요.'),
          if (items.isNotEmpty) DropdownButton<int>(
            key: const ValueKey('plan-trip'), isExpanded: true,
            value: item?.id,
            hint: const Text('여행 선택'),
            items: [for (final trip in items) DropdownMenuItem(value: trip.id, child: Text(trip.title, overflow: TextOverflow.ellipsis))],
            onChanged: (id) => setState(() => _select(items.firstWhere((trip) => trip.id == id))),
          ),
          if (item != null && !editable) const Text('여행이 시작되었거나 날짜가 유효하지 않아 기존 계획만 볼 수 있어요.', key: ValueKey('plans-readonly')),
          if (editable) Form( // D-2 P05
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              _field('plan-date', '날짜 (YYYY-MM-DD)', _date, 10),
              _field('plan-time', '시간 (HH:mm)', _time, 5),
              _field('plan-place', '장소', _place, 100),
              _field('plan-activity', '활동 내용', _activity, 500),
              if (_error != null) Text(_error!),
              FilledButton(key: const ValueKey('save-plan'), onPressed: _save, child: Text(_editing == null ? '계획 추가' : '변경 적용')),
              if (_editing != null) TextButton(onPressed: () => setState(() => _select(item!)), child: const Text('편집 취소')),
            ]),
          ),
          if (item != null && _plans.isEmpty) const Text('아직 여행 계획이 없어요.'),
          for (final plan in sortedTravelPlans(_plans)) ListTile( // D-3 P03
            contentPadding: EdgeInsets.zero,
            title: Text('${plan.date} ${plan.time}\n${plan.place}'),
            subtitle: Text(plan.activity),
            trailing: editable ? Row(mainAxisSize: MainAxisSize.min, children: [
              IconButton(tooltip: '계획 편집', icon: const Icon(Icons.edit_outlined), onPressed: () {
                if (!_editable) { setState(() {}); return; }
                setState(() {
                  _editing = plan; _error = null;
                  _date.text = plan.date; _time.text = plan.time;
                  _place.text = plan.place; _activity.text = plan.activity;
                });
              }),
              IconButton(tooltip: '계획 삭제', icon: const Icon(Icons.delete_outline), onPressed: () => _apply([..._plans]..remove(plan))),
            ]) : null,
          ),
        ],
      ))),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('닫기'))],
    );
  }
}
