import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:typed_data';

@JS('Blob')
extension type _Blob._(JSObject _) implements JSObject {
  external factory _Blob(JSArray<JSAny> parts, JSObject options);
}
@JS('URL.createObjectURL')
external String _createObjectUrl(JSAny blob);
@JS('URL.revokeObjectURL')
external void _revokeObjectUrl(String url);
@JS('document')
external JSObject get _document;

const pngDownloadSupported = true;

/// Only an explicit user export downloads a PNG. Trip data is never persisted.
Future<void> downloadPng(Uint8List bytes, String filename) async {
  final options = JSObject()..setProperty('type'.toJS, 'image/png'.toJS);
  final url = _createObjectUrl(_Blob([bytes.toJS].toJS, options));
  final anchor = _document.callMethod<JSObject>('createElement'.toJS, 'a'.toJS)
    ..setProperty('href'.toJS, url.toJS)
    ..setProperty('download'.toJS, filename.toJS);
  try {
    anchor.callMethod<JSAny?>('click'.toJS);
  } finally {
    // Give browsers time to consume the Blob before releasing it.
    Timer(const Duration(seconds: 30), () => _revokeObjectUrl(url));
  }
}
