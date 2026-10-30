import 'dart:typed_data';
import 'photo_picker_types.dart';

const localPhotoPickingSupported = false;
Future<List<Uint8List>> pickTripPhotos({required int limit}) async =>
    throw const PhotoSelectionException('로컬 사진 선택은 웹 브라우저에서 사용할 수 있어요.');
