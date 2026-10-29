// B-8 TripEditor · 여행 정보 수정 · P05 · P10
// A-11 TripEditor · 여행 추가 시연 · P05 · P10
import 'package:flutter/material.dart';
import 'models.dart';
import 'widgets.dart';

/// The same form and server validation are used for creating and editing trips.
class TripEditor extends StatefulWidget {
  const TripEditor({super.key, this.item});
  final Item? item;

  @override
  State<TripEditor> createState() => _TripEditorState();
}

class _TripEditorState extends State<TripEditor> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _destination;
  late final TextEditingController _start;
  late final TextEditingController _end;
  static const _saving = false;
  static const String? _error = null;

  String _iso(DateTime value) => value.toIso8601String().substring(0, 10);

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _title = TextEditingController(text: item?.title ?? '');
    _destination = TextEditingController(text: item?.destinationName ?? '');
    _start = TextEditingController(
      text: item?.startDate.isNotEmpty == true ? item!.startDate : '2026-09-12',
    );
    _end = TextEditingController(
      text: item?.endDate.isNotEmpty == true ? item!.endDate : '2026-09-15',
    );
  }

  @override
  void dispose() {
    for (final c in [_title, _destination, _start, _end]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pick(TextEditingController controller) async {
    final parsed = DateTime.tryParse(controller.text) ?? DateTime(2026, 9, 12);
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

  void _save() {
    // STATE: 입력 정보 → 생성/수정된 여행 (구현하지 않음)
    Navigator.pop(context);
    showPrototypeNotice(context);
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

  String? _date(String? value) => null; // 입력 형식 UI 예시만 제공

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
                  // STATE: 목적지 → 국가 인식 결과 (구현하지 않음; 고정 시연 안내)
                  onChanged: (_) => setState(() {}),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    '국가·사진 자동 인식은 시연 예시입니다. 실제 인식·계산은 하지 않습니다.',
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
                  suffix: IconButton(
                    onPressed: _saving ? null : () => _pick(_start),
                    icon: const Icon(Icons.calendar_month),
                  ),
                ),
                _field(
                  'trip-end',
                  '종료 날짜 (YYYY-MM-DD)',
                  _end,
                  validator: (value) {
                    final error = _date(value);
                    if (error != null) return error;
                    return null;
                  },
                  suffix: IconButton(
                    onPressed: _saving ? null : () => _pick(_end),
                    icon: const Icon(Icons.calendar_month),
                  ),
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
