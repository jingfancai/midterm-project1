// B-8 TripEditor · 여행 정보 수정 · P05
// A-11 TripEditor · 여행 추가 · P05
import 'package:flutter/material.dart';
import 'models.dart';
import 'trip_insights.dart';
import 'destinations.dart';

/// The same form and input validation are used for creating and editing trips.
class TripEditor extends StatefulWidget {
  const TripEditor({super.key, this.item, this.initialTitle, this.initialDestination, this.initialTags = const [], required this.save});
  final Item? item;
  final String? initialTitle;
  final String? initialDestination;
  final List<String> initialTags;
  final TripChange save;

  @override
  State<TripEditor> createState() => _TripEditorState();
}

class _TripEditorState extends State<TripEditor> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _destination;
  late final TextEditingController _start;
  late final TextEditingController _end;
  late final TextEditingController _tags;
  late final TextEditingController _review;
  bool _saving = false;
  String? _error;

  String _iso(DateTime value) => value.toIso8601String().substring(0, 10);

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    final dates = item == null ? null : TripDates.fromItem(item);
    final start = dates?.start ?? DateTime.now().add(const Duration(days: 7));
    _title = TextEditingController(text: item?.title ?? widget.initialTitle ?? '');
    _destination = TextEditingController(text: item?.destinationName ?? widget.initialDestination ?? '');
    _start = TextEditingController(text: _iso(start));
    _end = TextEditingController(text: _iso(dates?.end ?? start));
    _tags = TextEditingController(text: (item?.tags ?? widget.initialTags).join(', '));
    _review = TextEditingController(text: item?.review ?? '');
  }

  @override
  void dispose() {
    for (final c in [_title, _destination, _start, _end, _tags, _review]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pick(TextEditingController controller) async {
    final parsed = DateTime.tryParse(controller.text) ?? DateTime.now();
    final initial = parsed.isBefore(DateTime(1900))
        ? DateTime(1900)
        : parsed.isAfter(DateTime(2200))
        ? DateTime(2200)
        : parsed;
    final value = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime(2200),
    );
    if (value != null && mounted) setState(() => controller.text = _iso(value));
  }

  Item get _draft =>
      (widget.item ?? const Item(id: 0, title: '', subtitle: '', image: ''))
          .copyWith(startDate: _start.text.trim(), endDate: _end.text.trim());
  bool get _reviewAllowed =>
      _date(_start.text) == null &&
      _date(_end.text) == null &&
      _end.text.trim().compareTo(_start.text.trim()) >= 0 &&
      canReviewTrip(_draft, DateTime.now());

  // STATE: 입력 → 세션의 여행; 서버 전송·영구 저장 없음.
  Future<void> _save() async {
    if (_saving || !_form.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    final original =
        widget.item ??
        Item(id: 0, title: '', subtitle: '', image: defaultTripPhoto);
    final destination = resolveDestination(_destination.text);
    try {
      final saved = await widget.save(
        original.copyWith(
          title: _title.text.trim(),
          tags: _tags.text
              .split(RegExp('[,，\\n]'))
              .map((tag) => tag.trim())
              .where((tag) => tag.isNotEmpty)
              .toSet()
              .toList(),
          // Changing dates to future/invalid clears the review in the saved session.
          review: _reviewAllowed ? _review.text.trim() : '',
          destination: _destination.text.trim(),
          countryCode: destination?.countryCode ?? '',
          image: destination?.photoUrl ?? defaultTripPhoto,
          startDate: _start.text.trim(),
          endDate: _end.text.trim(),
        ),
      );
      if (mounted) Navigator.pop(context, saved);
    } catch (error) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = '$error';
        });
      }
    }
  }

  Widget _field(
    String key,
    String label,
    TextEditingController controller, {
    String? Function(String?)? validator,
    Widget? suffix,
    ValueChanged<String>? onChanged,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      key: ValueKey(key),
      controller: controller,
      enabled: !_saving,
      maxLength: 100,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        counterText: '',
        suffixIcon: suffix,
      ),
      validator:
          validator ??
          (value) => value == null || value.trim().isEmpty ? '필수 항목입니다.' : null,
    ),
  );

  String? _date(String? value) =>
      value == null ||
          !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value.trim()) ||
          TripDates.parse(value.trim().replaceAll('-', '.')) == null
      ? '올바른 날짜를 입력해 주세요 (YYYY-MM-DD).'
      : null;

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_saving,
    child: AlertDialog(
      title: Text(widget.item == null ? '새로운 여행 추가' : '여행 정보 수정'),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Form(
            key: _form,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _field('trip-title', '여행 이름', _title),
                _field(
                  'trip-destination',
                  '목적지',
                  _destination,
                  // STATE: 목적지 → 자동 인식 국가·안내문 (추가 입력 불필요)
                  onChanged: (_) => setState(() {}),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    _destination.text.trim().isEmpty
                        ? '도시 이름을 입력하면 국가를 자동으로 인식해요.'
                        : resolveDestination(_destination.text) == null
                        ? '국가를 인식하지 못했어요. 도시 이름을 확인해 주세요. 방문 국가 통계에서 제외됩니다.'
                        : '자동 인식 국가: ${resolveDestination(_destination.text)!.countryName}',
                    key: const ValueKey('destination-country'),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF687775),
                    ),
                  ),
                ),
                _field(
                  'trip-start',
                  '출발 날짜 (YYYY-MM-DD)',
                  _start,
                  validator: _date,
                  onChanged: (_) => setState(() {}),
                  suffix: IconButton(
                    onPressed: _saving ? null : () => _pick(_start),
                    icon: const Icon(Icons.calendar_month),
                  ),
                ),
                _field(
                  'trip-end',
                  '종료 날짜 (YYYY-MM-DD)',
                  _end,
                  onChanged: (_) => setState(() {}),
                  validator: (value) {
                    final error = _date(value);
                    if (error != null) return error;
                    if (_date(_start.text) == null &&
                        value!.trim().compareTo(_start.text.trim()) < 0) {
                      return '종료일은 출발일보다 빠를 수 없어요.';
                    }
                    return null;
                  },
                  suffix: IconButton(
                    onPressed: _saving ? null : () => _pick(_end),
                    icon: const Icon(Icons.calendar_month),
                  ),
                ),
                // STATE: Tag/후기 입력 → 현재 여행의 메모리 표시 데이터.
                TextFormField(
                  key: const ValueKey('trip-tags'),
                  controller: _tags,
                  enabled: !_saving,
                  maxLength: 500,
                  decoration: const InputDecoration(
                    labelText: '태그',
                    hintText: '쉼표로 구분해 주세요 (예: 휴가, 맛집)',
                    counterText: '',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  key: const ValueKey('trip-review'),
                  controller: _review,
                  enabled: !_saving && _reviewAllowed,
                  minLines: 3,
                  maxLines: 6,
                  maxLength: 2000,
                  decoration: const InputDecoration(
                    labelText: '여행 후기',
                    hintText: '여행에서 느낀 점을 남겨 보세요.',
                  ),
                ),
                if (!_reviewAllowed)
                  Text(
                    reviewRestriction(_draft, DateTime.now()),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF687775),
                    ),
                  ),
                if (!_reviewAllowed && _review.text.isNotEmpty)
                  const Text(
                    '예정된 날짜로 저장하면 기존 후기는 저장되지 않아요.',
                    style: TextStyle(fontSize: 12),
                  ),
                if (_error != null)
                  Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                if (_saving) const LinearProgressIndicator(),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: Text(widget.item == null ? '여행 추가' : '저장'),
        ),
      ],
    ),
  );
}
