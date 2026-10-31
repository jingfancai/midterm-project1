// B-16 CheckboxListTile + LinearProgressIndicator · 계획 완료 진행률 · P01 · P03
// B-12 TravelPlansSection · 여행 일정 카드 · P01 · P03
// B-13 TravelPlanEditor · 계획 선택·입력 · P05
import 'dart:async';
import 'package:flutter/material.dart';
import 'models.dart';
import 'trip_plans.dart';

const _ink = Color(0xFF183B3A);
const _teal = Color(0xFF2D7770);
const _muted = Color(0xFF687775);

String formatPlanTime(String time) {
  final parts = time.split(':');
  final hour = int.parse(parts[0]);
  return '${hour < 12 ? 'AM' : 'PM'} ${(hour % 12 == 0 ? 12 : hour % 12).toString().padLeft(2, '0')}:${parts[1]}';
}

class TravelPlansSection extends StatefulWidget {
  const TravelPlansSection({super.key, required this.item, required this.plans, required this.onChanged, this.now = DateTime.now});
  final Item Function() item;
  final List<TravelPlan> Function() plans;
  final bool Function(List<TravelPlan>) onChanged;
  final DateTime Function() now;
  @override
  State<TravelPlansSection> createState() => _TravelPlansSectionState();
}

class _TravelPlansSectionState extends State<TravelPlansSection> {
  late final Timer _clock;
  bool _busy = false;
  bool get _editable => canEditTravelPlans(widget.item(), widget.now());
  @override
  void initState() {
    super.initState();
    _clock = Timer.periodic(const Duration(minutes: 1), (_) { if (mounted) setState(() {}); });
  }
  @override
  void dispose() { _clock.cancel(); super.dispose(); }
  void _message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }
  Future<void> _edit([TravelPlan? original]) async {
    if (!_editable || _busy || (original != null && !canEditTravelPlan(original, widget.item(), widget.now()))) return;
    setState(() => _busy = true);
    try {
      final plan = await showDialog<TravelPlan>(
        context: context,
        builder: (_) => TravelPlanEditor(item: widget.item, original: original, now: widget.now),
      );
      if (!mounted || plan == null) return;
      if (!_editable || (original != null && !canEditTravelPlan(original, widget.item(), widget.now()))) { _message('지난 날짜의 계획은 보기만 가능해요.'); return; }
      final error = validateTravelPlan(plan, widget.item(), now: widget.now());
      if (error != null) { _message(error); return; }
      final plans = [...widget.plans()];
      if (original == null) {
        plans.add(plan);
      } else {
        final index = plans.indexOf(original);
        if (index < 0) return;
        plans[index] = plan;
      }
      // STATE: 계획 편집 결과 → 현재 여행의 세션 메모리, 정렬된 카드.
      if (!widget.onChanged(sortedTravelPlans(plans))) _message('계획을 변경할 수 없어요. 여행 날짜를 확인해 주세요.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
  Future<void> _delete(TravelPlan plan) async {
    if (!_editable || _busy || !canEditTravelPlan(plan, widget.item(), widget.now())) return;
    setState(() => _busy = true);
    try {
      final confirmed = await showDialog<bool>(context: context, builder: (dialogContext) => AlertDialog(
        title: const Text('계획 삭제'), content: Text('${plan.place} 계획을 삭제할까요?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('취소')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('삭제')),
        ],
      ));
      if (!mounted || confirmed != true) return;
      if (!_editable || !canEditTravelPlan(plan, widget.item(), widget.now())) { _message('지난 날짜의 계획은 보기만 가능해요.'); return; }
      if (!widget.onChanged([...widget.plans()]..remove(plan))) _message('계획을 삭제할 수 없어요.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
  void _toggle(TravelPlan plan, bool completed) {
    if (_busy || !canEditTravelPlans(widget.item(), widget.now())) return;
    final plans = [...widget.plans()];
    final index = plans.indexOf(plan);
    if (index < 0) return;
    // STATE: 완료 체크 → 현재 여행의 완료 수/진행률, 콘텐츠 편집 권한과 분리.
    plans[index] = plan.copyWith(completed: completed);
    if (!widget.onChanged(plans)) _message('완료 상태를 변경할 수 없어요.');
    if (mounted) setState(() {});
  }
  @override
  Widget build(BuildContext context) {
    final plans = sortedTravelPlans(widget.plans());
    final editable = _editable;
    return Container(
      key: const ValueKey('travel-plans-section'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFFF0F5F1), borderRadius: BorderRadius.circular(22)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          const Icon(Icons.route_outlined, color: _teal), const SizedBox(width: 10),
          Expanded(child: Text('여행 계획', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: _ink))),
          Text('${plans.where((plan) => plan.completed).length}/${plans.length}', key: const ValueKey('plan-progress'), style: const TextStyle(color: _teal, fontWeight: FontWeight.w800)),
        ]),
        const SizedBox(height: 10),
        LinearProgressIndicator(value: plans.isEmpty ? 0 : plans.where((plan) => plan.completed).length / plans.length, semanticsLabel: '계획 완료 진행률'),
        const SizedBox(height: 10),
        Text(editable ? '오늘과 앞으로의 여정을 준비해 보세요. 지난 날짜의 계획은 보기만 가능해요.' : '계획을 변경할 수 없는 여행이에요.',
          key: editable ? null : const ValueKey('plans-readonly'), style: const TextStyle(color: _muted, height: 1.5, fontSize: 12)),
        const SizedBox(height: 6),
        const Text('이번 세션에서만 유지돼요.', style: TextStyle(color: _muted, fontSize: 11)),
        if (editable) Padding(padding: const EdgeInsets.only(top: 14), child: Align(alignment: Alignment.centerLeft,
          child: FilledButton.icon(key: const ValueKey('add-plan'), onPressed: _busy ? null : () => _edit(), icon: const Icon(Icons.add), label: const Text('계획 추가')))),
        if (plans.isEmpty) const Padding(padding: EdgeInsets.symmetric(vertical: 26), child: Column(children: [
          Icon(Icons.event_note_outlined, color: _teal, size: 36), SizedBox(height: 10),
          Text('아직 여행 계획이 없어요.', style: TextStyle(color: _muted)),
        ])),
        for (var index = 0; index < plans.length; index++) ...[
          if (index == 0 || plans[index - 1].date != plans[index].date)
            Padding(padding: const EdgeInsets.only(top: 22, bottom: 12), child: Row(children: [
              const Icon(Icons.calendar_today_outlined, size: 16, color: _teal), const SizedBox(width: 8),
              Text(plans[index].date.replaceAll('-', '.'), style: const TextStyle(color: _teal, fontWeight: FontWeight.w800)),
              const SizedBox(width: 12), const Expanded(child: Divider(color: Color(0xFFD5E4DE))),
            ])),
          _planCard(plans[index], canEditTravelPlan(plans[index], widget.item(), widget.now())),
        ],
      ]),
    );
  }
  Widget _planCard(TravelPlan plan, bool editable) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: LayoutBuilder(builder: (_, constraints) {
      final time = Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(color: const Color(0xFFE4EFEB), borderRadius: BorderRadius.circular(10)),
        child: Text(formatPlanTime(plan.time), style: const TextStyle(color: _teal, fontWeight: FontWeight.w800, fontSize: 12)));
      final content = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        CheckboxListTile(contentPadding: EdgeInsets.zero, dense: true,
          title: Text(plan.completed ? '완료' : '완료 표시', style: const TextStyle(color: _teal, fontSize: 12)),
          value: plan.completed,
          onChanged: !_busy && canEditTravelPlans(widget.item(), widget.now()) ? (value) => _toggle(plan, value ?? false) : null),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.place_outlined, size: 19, color: _teal), const SizedBox(width: 6),
          Expanded(child: Text(plan.place, style: const TextStyle(color: _ink, fontSize: 16, fontWeight: FontWeight.w700))),
        ]),
        const SizedBox(height: 9), Text(plan.activity, style: const TextStyle(color: _muted, height: 1.5)),
        if (!editable) const Padding(padding: EdgeInsets.only(top: 10), child: Text('지난 계획 · 보기 전용', style: TextStyle(color: _muted, fontSize: 11))),
        if (editable) Wrap(spacing: 4, children: [
          IconButton(tooltip: '계획 편집', onPressed: _busy ? null : () => _edit(plan), icon: const Icon(Icons.edit_outlined, color: _teal)),
          IconButton(tooltip: '계획 삭제', onPressed: _busy ? null : () => _delete(plan), icon: const Icon(Icons.delete_outline, color: _muted)),
        ]),
      ]);
      return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white,
        borderRadius: BorderRadius.circular(17), border: Border.all(color: const Color(0xFFE1EAE4))),
        child: constraints.maxWidth >= 420
          ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [time, const SizedBox(width: 18), Expanded(child: content)])
          : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [time, const SizedBox(height: 14), content]));
    }),
  );
}

class TravelPlanEditor extends StatefulWidget {
  const TravelPlanEditor({super.key, required this.item, this.original, this.now = DateTime.now});
  final Item Function() item;
  final TravelPlan? original;
  final DateTime Function() now;
  @override
  State<TravelPlanEditor> createState() => _TravelPlanEditorState();
}
class _TravelPlanEditorState extends State<TravelPlanEditor> {
  late final _place = TextEditingController(text: widget.original?.place ?? '');
  late final _activity = TextEditingController(text: widget.original?.activity ?? '');
  late DateTime _date;
  late TimeOfDay _time;
  String? _error;
  late final Timer _clock;
  @override
  void initState() {
    super.initState();
    final old = widget.original;
    final initial = old == null
        ? (editableTravelPlanDates(widget.item(), widget.now())?.start ?? widget.now())
        : DateTime.parse(old.date);
    _date = DateTime(initial.year, initial.month, initial.day);
    final parts = (old?.time ?? '09:00').split(':');
    _time = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    _clock = Timer.periodic(const Duration(minutes: 1), (_) { if (mounted) setState(() {}); });
  }
  @override
  void dispose() { _clock.cancel(); _place.dispose(); _activity.dispose(); super.dispose(); }
  bool get _editable => canEditTravelPlans(widget.item(), widget.now()) &&
      (widget.original == null || canEditTravelPlan(widget.original!, widget.item(), widget.now()));
  String get _iso => '${_date.year.toString().padLeft(4, '0')}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}';
  String get _timeValue => '${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}';
  Future<void> _pickDate() async {
    if (!_editable) return;
    final dates = editableTravelPlanDates(widget.item(), widget.now())!;
    final first = DateTime(dates.start.year, dates.start.month, dates.start.day);
    final last = DateTime(dates.end.year, dates.end.month, dates.end.day);
    final initial = _date.isBefore(first) ? first : _date.isAfter(last) ? last : _date;
    final picked = await showDatePicker(context: context, initialDate: initial, firstDate: first, lastDate: last);
    if (mounted && picked != null && _editable) {
      final current = editableTravelPlanDates(widget.item(), widget.now())!;
      final chosen = DateTime.utc(picked.year, picked.month, picked.day);
      if (chosen.isBefore(current.start) || chosen.isAfter(current.end)) return;
      setState(() => _date = picked);
    }
  }
  Future<void> _pickTime() async {
    if (!_editable) return;
    final picked = await showTimePicker(context: context, initialTime: _time,
      builder: (context, child) => MediaQuery(data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
        child: Localizations.override(context: context, locale: const Locale('en', 'US'), child: child!)));
    if (mounted && picked != null && _editable) setState(() => _time = picked);
  }
  void _save() {
    if (!_editable) { setState(() => _error = '지난 날짜의 계획은 변경할 수 없어요.'); return; }
    final plan = TravelPlan(date: _iso, time: _timeValue, place: _place.text.trim(), activity: _activity.text.trim(), completed: widget.original?.completed ?? false);
    final error = validateTravelPlan(plan, widget.item(), now: widget.now());
    if (error != null) { setState(() => _error = error); return; }
    Navigator.pop(context, plan);
  }
  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.original == null ? '새로운 여행 계획' : '여행 계획 편집'),
    content: SizedBox(width: 460, child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
      const Text('하루의 순간을 차근차근 채워 보세요.', style: TextStyle(color: _muted)), const SizedBox(height: 20),
      LayoutBuilder(builder: (_, constraints) {
        final date = _picker('plan-date', Icons.calendar_today_outlined, '날짜', _iso, _pickDate);
        final time = _picker('plan-time', Icons.schedule_outlined, '시간', formatPlanTime(_timeValue), _pickTime);
        return constraints.maxWidth >= 380
          ? Row(children: [Expanded(child: date), const SizedBox(width: 12), Expanded(child: time)])
          : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [date, const SizedBox(height: 12), time]);
      }),
      const SizedBox(height: 20),
      TextField(key: const ValueKey('plan-place'), controller: _place, maxLength: 100,
        decoration: const InputDecoration(labelText: '장소', hintText: '어디에서 만나볼까요?', prefixIcon: Icon(Icons.place_outlined), filled: true, border: OutlineInputBorder())),
      const SizedBox(height: 12),
      TextField(key: const ValueKey('plan-activity'), controller: _activity, minLines: 3, maxLines: 6, maxLength: 500,
        decoration: const InputDecoration(labelText: '활동 내용', hintText: '기대하는 순간을 적어 보세요.', alignLabelWithHint: true, prefixIcon: Icon(Icons.notes_outlined), filled: true, border: OutlineInputBorder())),
      if (!_editable) const Text('지난 날짜의 계획은 보기만 가능해요.'),
      if (_error != null) Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
    ]))),
    actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
      FilledButton(key: const ValueKey('save-plan'), onPressed: _editable ? _save : null, child: const Text('계획 저장'))],
  );
  Widget _picker(String key, IconData icon, String label, String value, VoidCallback onTap) => OutlinedButton(
    key: ValueKey(key), onPressed: _editable ? onTap : null,
    style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
    child: Row(children: [Icon(icon, size: 20), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 11, color: _muted)), const SizedBox(height: 5),
      Text(value, style: const TextStyle(color: _ink, fontWeight: FontWeight.w700)),
    ]))]),
  );
}
