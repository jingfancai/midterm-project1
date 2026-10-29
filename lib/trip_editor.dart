// B-8 TripEditor · 여행 정보 수정 / A 여행 추가 · P05 · P09
import 'package:flutter/material.dart';
import 'api.dart';
import 'models.dart';
import 'trip_insights.dart';

/// The same form and server validation are used for creating and editing trips.
class TripEditor extends StatefulWidget {
  const TripEditor({super.key, this.item, required this.save});
  final Item? item;
  final ItemSaver save;

  @override
  State<TripEditor> createState() => _TripEditorState();
}

class _TripEditorState extends State<TripEditor> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _destination;
  late final TextEditingController _country;
  late final TextEditingController _start;
  late final TextEditingController _end;
  bool _saving = false;
  String? _error;

  String _iso(DateTime value) => value.toIso8601String().substring(0, 10);

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    final dates = item == null ? null : TripDates.fromItem(item);
    final start = dates?.start ?? DateTime.now().add(const Duration(days: 7));
    _title = TextEditingController(text: item?.title ?? '');
    _destination = TextEditingController(
      text: item?.destination.isNotEmpty == true
          ? item!.destination
          : item?.subtitle.split('·').last.trim() ?? '',
    );
    _country = TextEditingController(text: item?.countryCode ?? '');
    _start = TextEditingController(text: _iso(start));
    _end = TextEditingController(text: _iso(dates?.end ?? start));
  }

  @override
  void dispose() {
    for (final c in [_title, _destination, _country, _start, _end]) {
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

  Future<void> _save() async {
    if (_saving || !_form.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    final original =
        widget.item ??
        const Item(
          id: 0,
          title: '',
          subtitle: '',
          image:
              'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?w=1000&q=85',
        );
    try {
      final saved = await widget.save(
        original.copyWith(
          title: _title.text.trim(),
          destination: _destination.text.trim(),
          countryCode: _country.text.trim().toUpperCase(),
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
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      key: ValueKey(key),
      controller: controller,
      enabled: !_saving,
      maxLength: key == 'country-code' ? 2 : 100,
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
                _field('trip-destination', '목적지', _destination),
                _field(
                  'country-code',
                  '국가 코드 (예: KR, JP, US)',
                  _country,
                  validator: (value) =>
                      validCountryCodes.contains(value?.trim().toUpperCase())
                      ? null
                      : 'ISO 국가 코드를 입력해 주세요.',
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
