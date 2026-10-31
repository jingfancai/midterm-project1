// B-17 IconButton + AlertDialog · 여행 기록 삭제 · P03 · P05
// B-14 TravelNoteCard · 사진 여행 기록 카드 · P02 · P06
// B-15 TravelNoteEditor · 여행 기록 편집 · P03 · P05
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'api.dart';
import 'models.dart';
import 'photo_picker.dart';
import 'trip_insights.dart';
import 'trip_photos.dart';
import 'travel_plans_section.dart' show formatPlanTime;
import 'widgets.dart';

const _ink = Color(0xFF183B3A);
const _teal = Color(0xFF2D7770);
const _muted = Color(0xFF687775);

Widget _notePhoto(Uint8List bytes, {Key? key}) => ClipRRect(
  borderRadius: BorderRadius.circular(15),
  child: AspectRatio(aspectRatio: 4 / 3, child: Image.memory(bytes, key: key, semanticLabel: '여행 기록 사진', fit: BoxFit.cover,
    errorBuilder: (_, _, _) => const Center(child: Icon(Icons.broken_image_outlined, color: _muted)))),
);

class TravelNotesTimeline extends StatefulWidget {
  const TravelNotesTimeline({super.key, required this.item, required this.load, this.now = DateTime.now, this.pickPhoto});
  final Item Function() item;
  final NotesLoader load;
  final DateTime Function() now;
  final TripPhotoPicker? pickPhoto;
  @override
  State<TravelNotesTimeline> createState() => _TravelNotesTimelineState();
}
class _TravelNotesTimelineState extends State<TravelNotesTimeline> {
  late Future<List<Note>> _future = widget.load(widget.item().id);
  bool _busy = false;
  bool get _allowed => canReviewTrip(widget.item(), widget.now());
  Future<void> _edit(List<Note> notes, [Note? original]) async {
    if (!_allowed || _busy) return;
    setState(() => _busy = true);
    try {
      final now = widget.now();
      final draft = original ?? Note(
        id: notes.fold<int>(0, (id, note) => note.id > id ? note.id : id) + 1,
        itemId: widget.item().id, text: '', date: now.toIso8601String().substring(0, 10),
        time: '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
      );
      final result = await showDialog<Note>(context: context, barrierDismissible: false,
        builder: (_) => TravelNoteEditor(note: draft, editing: original != null, allowed: () => _allowed, pickPhoto: widget.pickPhoto));
      if (!mounted || result == null || !_allowed) return;
      final updated = [...notes];
      if (original == null) { updated.add(result); }
      else {
        final index = updated.indexOf(original);
        if (index < 0) return;
        updated[index] = result;
      }
      // STATE: 기록/독립 사진 편집 → 현재 상세의 메모리 기록만, 서버 전송 없음.
      setState(() => _future = Future.value(updated));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('여행 기록이 반영되었습니다. 이 화면에서만 유지됩니다.')));
    } finally { if (mounted) setState(() => _busy = false); }
  }
  Future<void> _remove(List<Note> notes, Note note) async {
    if (!_allowed || _busy) return;
    setState(() => _busy = true);
    try {
      final confirmed = await showDialog<bool>(context: context, builder: (dialogContext) => AlertDialog(
        title: const Text('여행 기록 삭제'),
        content: const Text('이 기록과 기록에 첨부한 사진을 삭제할까요? 이번 화면의 메모리에서만 삭제됩니다.'),
        actions: [TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('취소')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('삭제'))],
      ));
      if (!mounted || confirmed != true || !_allowed) return;
      // STATE: 기록 삭제 확인 → 해당 기록/독립 사진만 메모리에서 제거.
      setState(() => _future = Future.value([...notes]..remove(note)));
    } finally { if (mounted) setState(() => _busy = false); }
  }
  @override
  Widget build(BuildContext context) => FutureBuilder<List<Note>>(
    future: _future,
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) return const LoadingView(label: '여행 기록을 불러오는 중…');
      if (snapshot.hasError) return ErrorView(title: '여행 기록을 불러오지 못했어요.', message: '${snapshot.error}',
        onRetry: () => setState(() => _future = widget.load(widget.item().id)));
      final notes = snapshot.data ?? const <Note>[];
      final width = MediaQuery.sizeOf(context).width;
      return ListView(padding: EdgeInsets.symmetric(horizontal: width > 896 ? (width - 860) / 2 : 18, vertical: 22), children: [
        Row(children: [const Icon(Icons.auto_stories_outlined, color: _teal), const SizedBox(width: 10),
          Expanded(child: Text('여행의 순간들', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: _ink))),
          Text('${notes.length}', style: const TextStyle(color: _teal, fontWeight: FontWeight.w800))]),
        const SizedBox(height: 8), const Text('짧은 이야기와 한 장의 사진으로 남기는 나만의 여정', style: TextStyle(color: _muted, height: 1.5)),
        const SizedBox(height: 18),
        if (_allowed) Align(alignment: Alignment.centerLeft, child: FilledButton.icon(
          onPressed: _busy ? null : () => _edit(notes), icon: const Icon(Icons.add), label: const Text('여행 기록 추가')))
        else const Text('여행 시작 후 여행 기록을 남길 수 있어요.', key: ValueKey('notes-restricted')),
        const SizedBox(height: 24),
        if (notes.isEmpty) EmptyView(message: _allowed ? '아직 기록이 없어요. 여행의 순간을 남겨 보세요.' : '아직 여행 기록이 없어요.'),
        for (var i = 0; i < notes.length; i++) TravelNoteCard(
          note: notes[i], last: i == notes.length - 1,
          onEdit: _allowed && !_busy ? () => _edit(notes, notes[i]) : null,
          onDelete: _allowed && !_busy ? () => _remove(notes, notes[i]) : null,
        ),
      ]);
    },
  );
}

class TravelNoteCard extends StatelessWidget {
  const TravelNoteCard({super.key, required this.note, required this.last, this.onEdit, this.onDelete});
  final Note note;
  final bool last;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  @override
  Widget build(BuildContext context) => IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    SizedBox(width: 20, child: Column(children: [
      Container(width: 12, height: 12, margin: const EdgeInsets.only(top: 22), decoration: const BoxDecoration(color: _teal, shape: BoxShape.circle)),
      if (!last) Expanded(child: Container(width: 2, color: const Color(0xFFD5E4DE))),
    ])),
    const SizedBox(width: 12),
    Expanded(child: Container(
      key: ValueKey('note-card-${note.id}'), margin: const EdgeInsets.only(bottom: 20), padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE3EBE5))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Wrap(spacing: 12, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
          Text(note.date, style: const TextStyle(fontSize: 12, color: _teal, fontWeight: FontWeight.w800)),
          Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5), decoration: BoxDecoration(color: const Color(0xFFEAF1ED), borderRadius: BorderRadius.circular(9)),
            child: Text(note.time.isEmpty ? '시간 미기록' : formatPlanTime(note.time), style: const TextStyle(fontSize: 11, color: _teal))),
          if (onEdit != null) IconButton(key: ValueKey('edit-note-${note.id}'), tooltip: '기록 편집', onPressed: onEdit, icon: const Icon(Icons.edit_outlined, color: _teal, size: 20)),
          if (onDelete != null) IconButton(key: ValueKey('delete-note-${note.id}'), tooltip: '기록 삭제', onPressed: onDelete, icon: const Icon(Icons.delete_outline, color: _muted, size: 20)),
        ]),
        const SizedBox(height: 14), Text(note.text, style: const TextStyle(fontSize: 15, height: 1.65, color: _ink)),
        if (note.photo != null) ...[const SizedBox(height: 18), _notePhoto(note.photo!, key: ValueKey('note-photo-${note.id}'))],
      ]),
    )),
  ]));
}

class TravelNoteEditor extends StatefulWidget {
  const TravelNoteEditor({super.key, required this.note, required this.allowed, this.editing = false, this.pickPhoto});
  final Note note;
  final bool Function() allowed;
  final bool editing;
  final TripPhotoPicker? pickPhoto;
  @override
  State<TravelNoteEditor> createState() => _TravelNoteEditorState();
}
class _TravelNoteEditorState extends State<TravelNoteEditor> {
  late final _text = TextEditingController(text: widget.note.text);
  late Uint8List? _photo = widget.note.photo;
  bool _busy = false;
  String? _error;
  late final Timer _clock;
  @override
  void initState() {
    super.initState();
    _clock = Timer.periodic(const Duration(minutes: 1), (_) { if (mounted) setState(() {}); });
  }
  @override
  void dispose() { _clock.cancel(); _text.dispose(); super.dispose(); }
  Future<void> _pick() async {
    if (_busy || !widget.allowed()) return;
    setState(() { _busy = true; _error = null; });
    try {
      final selected = await (widget.pickPhoto ?? pickTripPhotos)(limit: 1);
      if (!mounted || !widget.allowed() || selected.isEmpty) return;
      if (selected.length != 1) throw const PhotoSelectionException('기록마다 사진 한 장만 선택해 주세요.');
      final bytes = await prepareTripPhoto(selected.single);
      if (mounted && widget.allowed()) setState(() => _photo = bytes);
    } catch (error) {
      if (mounted) setState(() => _error = error is PhotoSelectionException ? error.message : '사진을 읽지 못했어요. 다시 선택해 주세요.');
    } finally { if (mounted) setState(() => _busy = false); }
  }
  void _save() {
    if (_busy) return;
    if (!widget.allowed()) { Navigator.pop(context); return; }
    if (_text.text.trim().isEmpty) { setState(() => _error = '기록 내용을 입력해 주세요.'); return; }
    Navigator.pop(context, widget.note.copyWith(text: _text.text.trim(), photo: _photo, clearPhoto: _photo == null));
  }
  @override
  Widget build(BuildContext context) {
    final allowed = widget.allowed();
    final canPick = widget.pickPhoto != null || localPhotoPickingSupported;
    return PopScope(canPop: !_busy, child: AlertDialog(
      title: Row(children: [const Icon(Icons.edit_note_outlined, color: _teal), const SizedBox(width: 10), Expanded(child: Text(widget.editing ? '여행 기록 편집' : '새로운 여행 기록'))]),
      content: SizedBox(width: 500, child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('${widget.note.date} · ${widget.note.time.isEmpty ? '시간 미기록' : formatPlanTime(widget.note.time)}', style: const TextStyle(color: _teal, fontSize: 12, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8), const Text('기억하고 싶은 이야기와 사진 한 장을 남겨 보세요.', style: TextStyle(color: _muted, height: 1.5)),
        const SizedBox(height: 22),
        TextField(key: const ValueKey('note-text'), controller: _text, enabled: !_busy && allowed, minLines: 4, maxLines: 8,
          decoration: const InputDecoration(labelText: '여행 이야기', hintText: '오늘의 여행 순간을 기록해 보세요.', alignLabelWithHint: true,
            filled: true, prefixIcon: Icon(Icons.notes_outlined), border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(14))))),
        const SizedBox(height: 22),
        const Row(children: [Icon(Icons.photo_outlined, size: 19, color: _teal), SizedBox(width: 8), Text('이 기록의 사진', style: TextStyle(fontWeight: FontWeight.w700, color: _ink))]),
        const SizedBox(height: 10),
        if (_photo != null) _notePhoto(_photo!, key: const ValueKey('note-photo-preview'))
        else Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: const Color(0xFFF0F5F1), borderRadius: BorderRadius.circular(15)),
          child: const Column(children: [Icon(Icons.add_photo_alternate_outlined, color: _teal, size: 32), SizedBox(height: 10), Text('선택한 사진만 이 기록에 표시돼요.', style: TextStyle(fontSize: 12, color: _muted))])),
        const SizedBox(height: 10),
        Wrap(spacing: 8, runSpacing: 8, children: [
          OutlinedButton.icon(key: const ValueKey('pick-note-photo'), onPressed: !_busy && allowed && canPick ? _pick : null,
            icon: const Icon(Icons.add_photo_alternate_outlined), label: Text(_photo == null ? '사진 추가' : '사진 바꾸기')),
          if (_photo != null) TextButton.icon(key: const ValueKey('remove-note-photo'), onPressed: !_busy && allowed ? () => setState(() => _photo = null) : null,
            icon: const Icon(Icons.delete_outline), label: const Text('사진 삭제')),
        ]),
        const SizedBox(height: 8), const Text('최대 1장 · 10MB 이하 · 업로드 없이 메모리에서만 유지', style: TextStyle(fontSize: 11, color: _muted)),
        if (!canPick) const Text('로컬 사진 선택은 웹 브라우저에서 사용할 수 있어요.', style: TextStyle(fontSize: 11, color: _muted)),
        if (!allowed) const Text('여행 날짜가 변경되어 기록을 수정할 수 없어요.'),
        if (_busy) const LinearProgressIndicator(),
        if (_error != null) Padding(padding: const EdgeInsets.only(top: 10), child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error))),
      ]))),
      actions: [TextButton(onPressed: _busy ? null : () => Navigator.pop(context), child: const Text('취소')),
        FilledButton(key: const ValueKey('save-note'), onPressed: !_busy && allowed ? _save : null, child: const Text('저장'))],
    ));
  }
}
