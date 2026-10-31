// C-10 Wrap + ChoiceChip · 추억 카드 템플릿 · P03 · P06
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'models.dart';
import 'destinations.dart';
import 'png_download.dart';
import 'trip_insights.dart';
import 'trip_photos.dart';

enum MemoryTemplate { minimal, postcard, collage }
extension MemoryTemplateLabel on MemoryTemplate {
  String get label => switch (this) { MemoryTemplate.minimal => '심플', MemoryTemplate.postcard => '엽서', MemoryTemplate.collage => '사진 콜라주' };
}

typedef PngSaver = Future<void> Function(Uint8List bytes, String filename);

Future<void> showTravelMemory(BuildContext context, Item item) async {
  if (!canCreateMemory(item, DateTime.now())) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text(memoryRestriction)));
    return;
  }
  await showDialog<void>(
    context: context,
    builder: (_) => TravelMemoryDialog(item: item),
  );
}

/// Captures the complete card, including content outside its scroll viewport.
Future<Uint8List> captureMemoryPng(GlobalKey key) async {
  final boundary =
      key.currentContext!.findRenderObject() as RenderRepaintBoundary;
  final ratio = math.min(
    2.0,
    8192 / math.max(boundary.size.width, boundary.size.height),
  );
  final image = await boundary.toImage(pixelRatio: ratio);
  try {
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    if (data == null) throw StateError('PNG 변환 실패');
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  } finally {
    image.dispose();
  }
}

/// C-8/C-9, also reused by B-6; no route or persistent trip store.
class TravelMemoryDialog extends StatefulWidget {
  const TravelMemoryDialog({super.key, required this.item, this.savePng});
  final Item item;
  final PngSaver? savePng;
  @override
  State<TravelMemoryDialog> createState() => _TravelMemoryDialogState();
}

class _TravelMemoryDialogState extends State<TravelMemoryDialog> {
  final _cardKey = GlobalKey();
  bool _exporting = false;
  MemoryTemplate _template = MemoryTemplate.minimal;
  String? _message;

  Future<void> _export() async {
    if (_exporting || !canCreateMemory(widget.item, DateTime.now())) return;
    // STATE: 내보내기 중 → 버튼 잠금/진행 표시; PNG만 명시적으로 다운로드.
    setState(() {
      _exporting = true;
      _message = null;
    });
    try {
      // Wait for the same cached image used by NetImage before rasterizing.
      // If it fails, wait for its neutral fallback too; never export a loading gap.
      if (widget.item.photos.isNotEmpty) {
        for (final photo in widget.item.photos.take(_template == MemoryTemplate.collage ? 5 : 1)) {
          if (!mounted) return;
          await precacheImage(MemoryImage(photo), context).timeout(const Duration(seconds: 10));
        }
      } else {
        var failed = false;
        await precacheImage(
          NetworkImage(widget.item.photoUrl),
          context,
          onError: (_, _) => failed = true,
        ).timeout(const Duration(seconds: 10));
        if (failed && mounted && widget.item.photoUrl != defaultTripPhoto) {
          await precacheImage(
            NetworkImage(defaultTripPhoto),
            context,
            onError: (_, _) {},
          ).timeout(const Duration(seconds: 10));
        }
      }
      if (!mounted) return;
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted) return;
      final bytes = await captureMemoryPng(_cardKey);
      await (widget.savePng ?? downloadPng)(
        bytes,
        'polarsteps-memory-${widget.item.id}${_template == MemoryTemplate.minimal ? '' : '-${_template.name}'}.png',
      );
      if (mounted) {
        setState(() => _message = 'PNG 다운로드를 요청했어요. 브라우저의 다운로드 목록을 확인해 주세요.');
      }
    } catch (_) {
      if (mounted) {
        setState(() => _message = '이미지를 내보내지 못했어요. 사진을 확인한 뒤 다시 시도해 주세요.');
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final allowed = canCreateMemory(widget.item, DateTime.now());
    final supported = widget.savePng != null || pngDownloadSupported;
    return PopScope(
      canPop: !_exporting,
      child: AlertDialog(
        title: const Text('MY TRAVEL MEMORY'),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (allowed) ...[
                  Wrap(spacing: 8, runSpacing: 8, children: [for (final template in MemoryTemplate.values)
                    ChoiceChip(key: ValueKey('memory-select-${template.name}'), label: Text(template.label),
                      selected: template == _template, onSelected: _exporting ? null : (_) => setState(() {
                        // STATE: 템플릿 선택 → 동일한 미리보기/PNG 카드.
                        _template = template; _message = null;
                      })),
                  ]),
                  const SizedBox(height: 14),
                  RepaintBoundary(
                    key: _cardKey,
                    child: TravelMemoryCard(item: widget.item, template: _template),
                  ),
                ] else
                  const Text(memoryRestriction),
                if (!supported) const Text('PNG 다운로드는 웹 브라우저에서 사용할 수 있어요.'),
                if (_message != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(_message!),
                  ),
                if (_exporting) const LinearProgressIndicator(),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _exporting ? null : () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
          FilledButton.icon(
            key: const ValueKey('export-memory-png'),
            onPressed: allowed && supported && !_exporting ? _export : null,
            icon: const Icon(Icons.download_outlined),
            label: const Text('PNG 다운로드'),
          ),
        ],
      ),
    );
  }
}

class TravelMemoryCard extends StatelessWidget {
  final MemoryTemplate template;
  const TravelMemoryCard({super.key, required this.item, this.template = MemoryTemplate.minimal});
  final Item item;
  @override
  Widget build(BuildContext context) => Container(
    key: ValueKey('memory-template-${template.name}'),
    padding: const EdgeInsets.all(16),
    color: template == MemoryTemplate.postcard ? const Color(0xFFFFF8EB) : const Color(0xFFF0F3EF),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (template == MemoryTemplate.postcard) ...[
          const Row(children: [Expanded(child: Text('POSTCARD', style: TextStyle(letterSpacing: 3, color: Color(0xFF2D7770), fontWeight: FontWeight.w800))), Icon(Icons.local_post_office_outlined, color: Color(0xFF2D7770))]),
          const SizedBox(height: 14),
        ],
        if (template == MemoryTemplate.collage) ...[
          const Text('PHOTO DIARY', style: TextStyle(letterSpacing: 2, color: Color(0xFF2D7770), fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          if (item.photos.length > 1) LayoutBuilder(builder: (_, constraints) => Wrap(spacing: 8, runSpacing: 8,
            children: [for (final photo in item.photos.take(5)) SizedBox(width: (constraints.maxWidth - 8) / 2, height: 125,
              child: ClipRRect(borderRadius: BorderRadius.circular(12), child: tripPhotoImage(photo, item.photoUrl)))],
          )) else _hero(),
        ] else _hero(),
        const SizedBox(height: 12),
        Text(item.title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 6),
        Text(item.subtitle),
        const SizedBox(height: 10),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: [for (final tag in item.tags) Chip(label: Text(tag))],
        ),
        const SizedBox(height: 12),
        const Text(
          '여행 후기',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF183B3A),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          item.review.isEmpty ? '아직 작성한 후기가 없어요.' : item.review,
          key: const ValueKey('memory-review'),
        ),
      ],
    ),
  );
  Widget _hero() => Container(
    padding: template == MemoryTemplate.postcard ? const EdgeInsets.all(7) : EdgeInsets.zero,
    color: template == MemoryTemplate.postcard ? Colors.white : null,
    child: ClipRRect(borderRadius: BorderRadius.circular(template == MemoryTemplate.postcard ? 2 : 14),
      child: SizedBox(height: 180, width: double.infinity,
        child: tripPhotoImage(item.photos.isEmpty ? null : item.photos.first, item.photoUrl))),
  );

}
