// 화면 B — 여행 상세 · 디자인 가이드 대응표
// B-1 AppBar + BackButton · 여행 제목줄 · P03
// B-2 TabBar + TabBarView · 여행 정보·여행 기록 탭 · P04
// B-3 TripPhotoGallery + Text · 대표 사진·여행 제목 · P02 · P08
// B-4 Wrap(Chip) · 여행 태그 · P06
// B-5 OutlinedButton · 여행 즐겨찾기 · P03
// B-6 FilledButton + AlertDialog · 여행 추억 카드 만들기 · P07
// B-7 TravelNotesTimeline · 여행 기록 타임라인 · P01 · P09
// B-8 IconButton + TripEditor · 여행 정보 수정 · P05
// B-9 Text · 여행 후기 · P02
// B-10 TripPhotoGallery · 여행 사진 슬라이드 · P03 · P06
// B-12 TravelPlansSection · 여행 일정 카드 · P01 · P03
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../api.dart';
import '../models.dart';
import '../trip_editor.dart';
import '../trip_insights.dart';
import '../travel_memory_card.dart';
import '../trip_photos.dart';
import '../photo_picker.dart';
import '../trip_plans.dart';
import '../travel_plans_section.dart';
import '../travel_notes.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({
    super.key,
    required this.item,
    this.loadNotes = fetchNotes,
    this.save = previewTripChange,
    this.pickPhotos,
    this.pickNotePhoto,
    this.plans,
    this.onPlansChanged,
    this.now = DateTime.now,
  });

  final Map<int, List<TravelPlan>>? plans;
  final bool Function(int, List<TravelPlan>)? onPlansChanged;
  final DateTime Function() now;
  final Item item;
  final NotesLoader loadNotes;
  final TripChange save;
  final TripPhotoPicker? pickNotePhoto;
  final TripPhotoPicker? pickPhotos;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  // STATE: 상세 편집·즐겨찾기 → A에 전달한 메모리 콜백과 상세 표시만 갱신.
  late Item _item = widget.item;
  bool _saving = false;
  final Map<int, List<TravelPlan>> _localPlans = {};
  late final Timer _clock;
  @override
  void initState() {
    super.initState();
    _clock = Timer.periodic(const Duration(minutes: 1), (_) { if (mounted) setState(() {}); });
  }
  @override
  void dispose() { _clock.cancel(); super.dispose(); }
  bool _changePlans(List<TravelPlan> plans) {
    if (!canChangeTravelPlans(_item, (widget.plans ?? _localPlans)[_item.id] ?? const [], plans, widget.now())) return false;
    if (widget.onPlansChanged != null && !widget.onPlansChanged!(_item.id, plans)) return false;
    // STATE: 상세 계획 → A와 공유한 여행 ID별 메모리 목록.
    setState(() => (widget.plans ?? _localPlans)[_item.id] = sortedTravelPlans(plans));
    return true;
  }


  Future<void> _editTrip() async {
    final saved = await showDialog<Item>(
      context: context,
      barrierDismissible: false,
      builder: (_) => TripEditor(item: _item, save: widget.save),
    );
    if (saved != null && mounted) setState(() => _item = saved);
  }

  Future<void> _favorite() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final saved = await widget.save(
        _item.copyWith(favorite: !_item.favorite),
      );
      if (mounted) setState(() => _item = saved);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$error')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _changePhotos(List<Uint8List> photos) async {
    if (_saving || !canManageTripPhotos(_item, DateTime.now())) return;
    setState(() => _saving = true);
    try {
      final saved = await widget.save(_item.copyWith(photos: photos));
      if (mounted) setState(() => _item = saved);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _item.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            IconButton(
              onPressed: _saving ? null : _editTrip, // B-8 P05
              icon: const Icon(Icons.edit_outlined),
              tooltip: '여행 정보 수정',
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: '여행 정보'),
              Tab(text: '여행 기록'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _InfoTab(
              item: _item,
              title: _item.title,
              onFavorite: _saving ? null : _favorite,
              onPhotosChanged: _changePhotos,
              pickPhotos: widget.pickPhotos,
              photosEnabled: !_saving,
              plans: showTravelPlans(_item, widget.now()) ? TravelPlansSection(
                item: () => _item,
                plans: () => (widget.plans ?? _localPlans)[_item.id] ?? const [],
                onChanged: _changePlans,
                now: widget.now,
              ) : null,
            ),
            TravelNotesTimeline(item: () => _item, load: widget.loadNotes, now: widget.now, pickPhoto: widget.pickNotePhoto),
          ],
        ),
      ),
    );
  }
}

class _InfoTab extends StatelessWidget {
  const _InfoTab({
    required this.item,
    required this.title,
    required this.onFavorite,
    required this.onPhotosChanged,
    this.pickPhotos,
    required this.photosEnabled,
    required this.plans,
  });

  final Item item;
  final String title;
  final VoidCallback? onFavorite;
  final Future<void> Function(List<Uint8List>) onPhotosChanged;
  final TripPhotoPicker? pickPhotos;
  final bool photosEnabled;
  final Widget? plans;
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final width = MediaQuery.sizeOf(context).width;
    final horizontal = width > 896 ? (width - 860) / 2 : 18.0;
    return ListView(
      padding: EdgeInsets.fromLTRB(horizontal, 12, horizontal, 24),
      children: [
        // B-3 P02 · P08 / B-10 P03 · P06: the single existing hero photo location.
        TripPhotoGallery(
          item: item,
          onChanged: onPhotosChanged,
          pickPhotos: pickPhotos,
          enabled: photosEnabled,
        ),
        const SizedBox(height: 20),
        const Row(
          children: [
            Icon(Icons.auto_awesome, color: Color(0xFF2D7770), size: 18),
            SizedBox(width: 6),
            Text(
              'A JOURNEY TO REMEMBER',
              style: TextStyle(
                letterSpacing: 1.3,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: Color(0xFF2D7770),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(title, style: text.headlineMedium?.copyWith(fontSize: 27)),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(
              Icons.location_on_outlined,
              color: Color(0xFF64817A),
              size: 18,
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                item.subtitle,
                style: const TextStyle(color: Color(0xFF687775)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: [
            for (final tag in item.tags)
              Chip(
                avatar: const Icon(Icons.sell_outlined, size: 14),
                label: Text(tag),
                visualDensity: VisualDensity.compact,
                backgroundColor: const Color(0xFFEAF1ED),
                side: BorderSide.none,
              ),
          ],
        ),
        if (plans != null) ...[
          const SizedBox(height: 24),
          plans!, // B-12 P03
        ],
        // B-9 P02: 전체 후기, 줄 수 제한/말줄임 없음.
        const SizedBox(height: 14),
        const Text(
          '여행 후기',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF183B3A),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          canReviewTrip(item, DateTime.now())
              ? (item.review.isEmpty ? '아직 작성한 후기가 없어요.' : item.review)
              : reviewRestriction(item, DateTime.now()),
          key: const ValueKey('detail-review'),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: onFavorite, // B-5 P03
          icon: Icon(item.favorite ? Icons.bookmark : Icons.bookmark_border),
          label: Text(item.favorite ? '즐겨찾기 해제' : '이 여행 보관하기'),
        ),
        const SizedBox(height: 8),
        FilledButton.icon(
          onPressed: canCreateMemory(item, DateTime.now())
              ? () => showTravelMemory(context, item)
              : null,
          icon: const Icon(Icons.auto_awesome),
          label: const Text('여행 추억 카드 만들기'),
        ),
        if (!canCreateMemory(item, DateTime.now()))
          const Text(
            memoryRestriction,
            style: TextStyle(fontSize: 12, color: Color(0xFF687775)),
          ),
      ],
    );
  }
}
