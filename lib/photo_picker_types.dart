import 'dart:typed_data';

typedef TripPhotoPicker =
    Future<List<Uint8List>> Function({required int limit});
const maxPhotoFileBytes = 10 * 1024 * 1024;

class PhotoSelectionException implements Exception {
  const PhotoSelectionException(this.message);
  final String message;
  @override
  String toString() => message;
}
