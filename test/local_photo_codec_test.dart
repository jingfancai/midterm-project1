import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter_test/flutter_test.dart';
import 'package:mid_project_template/trip_photos.dart';

void main() {
  test(
    'local photo decoding preserves size and PNG pixels across runtimes',
    () async {
      final source = base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAACgAAAAeCAIAAADRv8uKAAAALElEQVR4nO3NMQEAAAQAMKTRP5EoKvg8W4HldMeHelnFYrFYLBaLxWKxWHyyjZgBbI/DawkAAAAASUVORK5CYII=',
      );
      final prepared = await prepareTripPhoto(source);
      expect(prepared.take(8), [137, 80, 78, 71, 13, 10, 26, 10]);
      final codec = await ui.instantiateImageCodec(prepared);
      final frame = await codec.getNextFrame();
      try {
        expect(frame.image.width, 40);
        expect(frame.image.height, 30);
        final pixels = await frame.image.toByteData(
          format: ui.ImageByteFormat.rawRgba,
        );
        expect(pixels!.buffer.asUint8List().take(4), [224, 40, 40, 255]);
      } finally {
        frame.image.dispose();
        codec.dispose();
      }
    },
  );
}
