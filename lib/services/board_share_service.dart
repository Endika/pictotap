import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:pictotap/services/image_saver.dart';

class BoardShareService {
  static const int _outputSize = 1080;

  const BoardShareService();

  Future<void> share(
    RenderRepaintBoundary boundary,
    String shareText,
  ) async {
    final pngBytes = await _capture(boundary);
    final fileName =
        'pictotap-board-${DateTime.now().millisecondsSinceEpoch}.png';
    await saveAndShareImage(pngBytes, fileName, shareText);
  }

  Future<Uint8List> _capture(RenderRepaintBoundary boundary) async {
    const int out = _outputSize;
    final bSize = boundary.size;
    final pixelRatio = out / math.min(bSize.width, bSize.height);
    final rawImage = await boundary.toImage(pixelRatio: pixelRatio);

    final srcW = rawImage.width;
    final srcH = rawImage.height;
    final rawBytes = await rawImage.toByteData(
      format: ui.ImageByteFormat.rawStraightRgba,
    );
    if (rawBytes == null) throw StateError('Failed to capture board pixels');
    final srcPixels = rawBytes.buffer.asUint8List();

    final cropSize = math.min(srcW, srcH);
    final cropX = (srcW - cropSize) ~/ 2;
    final cropY = (srcH - cropSize) ~/ 2;

    final outPixels = Uint8List(out * out * 4);
    for (var y = 0; y < out; y++) {
      final sy = (cropY + y * cropSize ~/ out).clamp(0, srcH - 1);
      for (var x = 0; x < out; x++) {
        final sx = (cropX + x * cropSize ~/ out).clamp(0, srcW - 1);
        final si = (sy * srcW + sx) * 4;
        final di = (y * out + x) * 4;
        outPixels[di] = srcPixels[si];
        outPixels[di + 1] = srcPixels[si + 1];
        outPixels[di + 2] = srcPixels[si + 2];
        outPixels[di + 3] = srcPixels[si + 3];
      }
    }

    final completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(
      outPixels,
      out,
      out,
      ui.PixelFormat.rgba8888,
      completer.complete,
    );
    final outputImage = await completer.future;
    final pngData =
        await outputImage.toByteData(format: ui.ImageByteFormat.png);
    if (pngData == null) throw StateError('Failed to encode PNG');
    return pngData.buffer.asUint8List();
  }
}
