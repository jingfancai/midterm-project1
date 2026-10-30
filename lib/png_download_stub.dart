import 'dart:typed_data';

const pngDownloadSupported = false;
Future<void> downloadPng(Uint8List bytes, String filename) async {
  throw UnsupportedError('PNG 다운로드는 웹 브라우저에서 사용할 수 있어요.');
}
