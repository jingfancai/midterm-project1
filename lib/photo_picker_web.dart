import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:typed_data';
import 'photo_picker_types.dart';

@JS('document')
external JSObject get _document;
const localPhotoPickingSupported = true;

/// Read only user-selected bytes; no URLs, uploads or browser storage.
Future<List<Uint8List>> pickTripPhotos({required int limit}) async {
  final input =
      _document.callMethod<JSObject>('createElement'.toJS, 'input'.toJS)
        ..setProperty('type'.toJS, 'file'.toJS)
        ..setProperty('accept'.toJS, 'image/*'.toJS)
        ..setProperty('multiple'.toJS, (limit > 1).toJS)
        ..setProperty('hidden'.toJS, true.toJS);
  _document
      .getProperty<JSObject>('body'.toJS)
      .callMethod<JSAny?>('appendChild'.toJS, input);
  final result = Completer<List<Uint8List>>();
  final changed = (() {
    Future<void>(() async {
      try {
        final files = input.getProperty<JSObject?>('files'.toJS);
        final count =
            files?.getProperty<JSNumber>('length'.toJS).toDartInt ?? 0;
        if (count > limit) {
          throw PhotoSelectionException('사진은 $limit장까지 선택해 주세요. 여행당 최대 5장이에요.');
        }
        final photos = <Uint8List>[];
        for (var index = 0; index < count; index++) {
          final file = files!.getProperty<JSObject>('$index'.toJS);
          if (file.getProperty<JSNumber>('size'.toJS).toDartDouble >
              maxPhotoFileBytes) {
            throw const PhotoSelectionException('사진 한 장은 10MB 이하로 선택해 주세요.');
          }
          final buffer = await file
              .callMethod<JSPromise<JSArrayBuffer>>('arrayBuffer'.toJS)
              .toDart;
          photos.add(Uint8List.fromList(buffer.toDart.asUint8List()));
        }
        if (!result.isCompleted) result.complete(photos);
      } catch (error, stack) {
        if (!result.isCompleted) result.completeError(error, stack);
      }
    });
  }).toJS;
  final cancelled = (() {
    if (!result.isCompleted) result.complete([]);
  }).toJS;
  input.callMethod<JSAny?>('addEventListener'.toJS, 'change'.toJS, changed);
  input.callMethod<JSAny?>('addEventListener'.toJS, 'cancel'.toJS, cancelled);
  try {
    input.callMethod<JSAny?>('click'.toJS);
    return await result.future;
  } finally {
    input.callMethod<JSAny?>('remove'.toJS);
    input.callMethod<JSAny?>(
      'removeEventListener'.toJS,
      'change'.toJS,
      changed,
    );
    input.callMethod<JSAny?>(
      'removeEventListener'.toJS,
      'cancel'.toJS,
      cancelled,
    );
  }
}
