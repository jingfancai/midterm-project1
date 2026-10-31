// B-11 ListView + InkWell · 여행 사진 미리보기 탐색 · P03 · P06
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'models.dart';
import 'photo_picker.dart';
import 'widgets.dart';
import 'trip_insights.dart';

/// Bound memory use and keep only a decoded, static image, never its file path.
Future<Uint8List> prepareTripPhoto(Uint8List bytes) async {
  if (bytes.isEmpty || bytes.length > maxPhotoFileBytes) {
    throw const PhotoSelectionException('사진 한 장은 10MB 이하로 선택해 주세요.');
  }
  final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
  ui.Codec? codec;
  ui.Image? image;
  try {
    // This SDK entry point also supports Web, where ImageDescriptor.width/height do not.
    // It owns and disposes the ImmutableBuffer on both success and failure.
    codec = await ui.instantiateImageCodecWithSize(
      buffer,
      getTargetSize: (width, height) {
        if (width * height > 60000000) {
          throw const PhotoSelectionException('사진 해상도가 너무 커요. 작은 사진을 선택해 주세요.');
        }
        final ratio = math.min(1.0, 1920 / math.max(width, height));
        return ui.TargetImageSize(
          width: math.max(1, (width * ratio).round()),
          height: math.max(1, (height * ratio).round()),
        );
      },
    );
    image = (await codec.getNextFrame()).image;
    final encoded = await image.toByteData(format: ui.ImageByteFormat.png);
    if (encoded == null) throw const PhotoSelectionException('사진을 읽지 못했어요.');
    return Uint8List.fromList(
      encoded.buffer.asUint8List(encoded.offsetInBytes, encoded.lengthInBytes),
    );
  } on PhotoSelectionException {
    rethrow;
  } catch (_) {
    throw const PhotoSelectionException(
      '지원하지 않거나 손상된 사진이에요. JPG, PNG 등 다른 사진을 선택해 주세요.',
    );
  } finally {
    image?.dispose();
    codec?.dispose();
  }
}

Widget tripPhotoImage(Uint8List? bytes, String fallback) => bytes == null
    ? NetImage(fallback)
    : Image.memory(
        bytes,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => NetImage(fallback),
      );

/// B-3/B-10: title and gallery replace the one existing hero image.
class TripPhotoGallery extends StatefulWidget {
  const TripPhotoGallery({
    super.key,
    required this.item,
    required this.onChanged,
    this.pickPhotos,
    this.enabled = true,
  });
  final Item item;
  final Future<void> Function(List<Uint8List>) onChanged;
  final TripPhotoPicker? pickPhotos;
  final bool enabled;
  @override
  State<TripPhotoGallery> createState() => _TripPhotoGalleryState();
}

class _TripPhotoGalleryState extends State<TripPhotoGallery> {
  var _pages = PageController(keepPage: false);
  int _page = 0;
  bool _busy = false;
  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant TripPhotoGallery oldWidget) {
    super.didUpdateWidget(oldWidget);
    final today = DateTime.now();
    if (canManageTripPhotos(oldWidget.item, today) !=
        canManageTripPhotos(widget.item, today)) {
      final old = _pages;
      _page = 0;
      _pages = PageController(keepPage: false);
      WidgetsBinding.instance.addPostFrameCallback((_) => old.dispose());
    }
  }

  void _showPage(int index, int count) {
    final target = index.clamp(0, math.max(0, count - 1)).toInt();
    final old = _pages;
    // A fresh position avoids clamping against the previous photo count's extent.
    setState(() {
      _page = target;
      _pages = PageController(initialPage: target, keepPage: false);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => old.dispose());
  }

  void _error(Object error) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(
            error is PhotoSelectionException
                ? error.message
                : '사진을 변경하지 못했어요. 다시 시도해 주세요.',
          ),
        ),
      );
  }

  Future<void> _pick({bool replace = false}) async {
    if (_busy ||
        !widget.enabled ||
        !canManageTripPhotos(widget.item, DateTime.now())) {
      return;
    }
    final limit = replace ? 1 : maxTripPhotos - widget.item.photos.length;
    if (limit <= 0) return;
    setState(() => _busy = true);
    try {
      final picked = await (widget.pickPhotos ?? pickTripPhotos)(limit: limit);
      if (picked.isEmpty ||
          !mounted ||
          !canManageTripPhotos(widget.item, DateTime.now())) {
        return;
      }
      if (picked.length > limit) {
        throw PhotoSelectionException('사진은 $limit장까지 선택해 주세요.');
      }
      final prepared = <Uint8List>[];
      for (final bytes in picked) {
        prepared.add(await prepareTripPhoto(bytes));
      }
      if (!mounted || !canManageTripPhotos(widget.item, DateTime.now())) return;
      final photos = [...widget.item.photos];
      final target = replace ? _page : photos.length;
      if (replace && photos.isNotEmpty) {
        photos[_page] = prepared.single;
      } else {
        photos.addAll(prepared);
      }
      if (photos.length > maxTripPhotos) {
        throw const PhotoSelectionException('여행당 사진은 최대 5장이에요.');
      }
      // STATE: 선택한 이미지 바이트 → 현재 여행의 메모리 사진 목록, B/C에 전달.
      await widget.onChanged(photos);
      if (mounted) _showPage(target, photos.length);
    } catch (error) {
      _error(error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _remove() async {
    if (_busy ||
        !widget.enabled ||
        widget.item.photos.isEmpty ||
        !canManageTripPhotos(widget.item, DateTime.now())) {
      return;
    }
    setState(() => _busy = true);
    try {
      final photos = [...widget.item.photos]..removeAt(_page);
      await widget.onChanged(photos);
      if (mounted) _showPage(_page, photos.length);
    } catch (error) {
      _error(error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final eligible = canManageTripPhotos(widget.item, DateTime.now());
    final photos = eligible ? widget.item.photos : const <Uint8List>[];
    final canPick = widget.pickPhotos != null || localPhotoPickingSupported;
    final active = !_busy && widget.enabled && eligible;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(
              Icons.photo_library_outlined,
              color: Color(0xFF2D7770),
              size: 25,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '순간을 다시 꺼내 보기',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF183B3A),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '사진과 짧은 기록으로 여행의 흐름을 돌아보세요.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF687775)),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: AspectRatio(
            aspectRatio: 4 / 3,
            child: PageView.builder(
              key: const ValueKey('trip-photo-pages'),
              controller: _pages,
              itemCount: math.max(1, photos.length),
              onPageChanged: (value) => setState(() => _page = value),
              itemBuilder: (_, index) => Semantics(
                label: photos.isEmpty ? '목적지 기본 사진' : '여행 사진 ${index + 1}',
                child: tripPhotoImage(
                  photos.isEmpty ? null : photos[index],
                  widget.item.photoUrl,
                ),
              ),
            ),
          ),
        ),
        if (photos.isNotEmpty) ...[
          const SizedBox(height: 10),
          SizedBox(
            height: 68,
            child: ListView.separated( // B-11 P06
              key: const ValueKey('photo-thumbnails'),
              scrollDirection: Axis.horizontal,
              itemCount: photos.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (_, index) => Semantics(
                selected: _page == index,
                button: true,
                label: '사진 ${index + 1} 보기',
                child: InkWell(
                  key: ValueKey('photo-thumbnail-$index'),
                  onTap: _busy ? null : () {
                    // STATE: 썸네일 선택 → 큰 사진과 선택 테두리 동기화.
                    _pages.animateToPage(index,
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeInOut);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 80,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _page == index ? const Color(0xFF2D7770) : const Color(0xFFDDEAE3),
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: tripPhotoImage(photos[index], widget.item.photoUrl),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
        if (eligible) ...[
          const SizedBox(height: 8),
          Center(
            child: Text(
              '${_page + 1} / ${math.max(1, photos.length)}',
              key: const ValueKey('photo-page-indicator'),
            ),
          ),
          Wrap(
            spacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              TextButton.icon(
                key: const ValueKey('add-trip-photo'),
                onPressed: active && canPick && photos.length < maxTripPhotos
                    ? () => _pick()
                    : null,
                icon: const Icon(Icons.add_photo_alternate_outlined),
                label: const Text('사진 추가'),
              ),
              IconButton(
                tooltip: '현재 사진 바꾸기',
                onPressed: active && canPick && photos.isNotEmpty
                    ? () => _pick(replace: true)
                    : null,
                icon: const Icon(Icons.swap_horiz),
              ),
              IconButton(
                tooltip: '현재 사진 삭제',
                onPressed: active && photos.isNotEmpty ? _remove : null,
                icon: const Icon(Icons.delete_outline),
              ),
              Text(
                '${photos.length} / 5장',
                style: const TextStyle(fontSize: 12, color: Color(0xFF687775)),
              ),
            ],
          ),
          if (photos.isEmpty)
            const Text(
              '사진을 추가하면 목적지 기본 사진 대신 표시해요.',
              style: TextStyle(fontSize: 11, color: Color(0xFF687775)),
            ),
          if (!canPick)
            const Text(
              '로컬 사진 선택은 웹 브라우저에서 사용할 수 있어요.',
              style: TextStyle(fontSize: 11),
            ),
          if (_busy) const LinearProgressIndicator(),
        ] else
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              tripStatus(widget.item, DateTime.now()) == TripStatus.upcoming
                  ? '예정된 여행은 목적지 기본 사진만 표시해요. 여행 시작 후 사진을 추가할 수 있어요.'
                  : '여행 날짜를 확인하면 사진을 추가할 수 있어요.',
              style: const TextStyle(fontSize: 11, color: Color(0xFF687775)),
            ),
          ),
      ],
    );
  }
}
