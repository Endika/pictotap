import 'dart:js_interop';
import 'dart:typed_data';
import 'package:web/web.dart' as web;

Future<void> saveAndShareImage(
    Uint8List bytes, String fileName, String shareText) async {
  final shared = await _tryNativeShare(bytes, fileName, shareText);
  if (!shared) {
    _download(bytes, fileName);
  }
}

/// Uses the Web Share API to open the native share sheet on mobile browsers.
/// Returns false if the API is not available or the share was cancelled.
Future<bool> _tryNativeShare(
    Uint8List bytes, String fileName, String shareText) async {
  try {
    final file = web.File(
      <JSAny>[bytes.toJS].toJS,
      fileName,
      web.FilePropertyBag(type: 'image/png'),
    );
    final data = web.ShareData(
      files: <web.File>[file].toJS,
      text: shareText,
    );
    if (!web.window.navigator.canShare(data)) return false;
    await web.window.navigator.share(data).toDart;
    return true;
  } catch (_) {
    return false;
  }
}

/// Fallback: triggers a file download (used on desktop browsers).
void _download(Uint8List bytes, String fileName) {
  final blob = web.Blob(
    <JSAny>[bytes.toJS].toJS,
    web.BlobPropertyBag(type: 'image/png'),
  );
  final url = web.URL.createObjectURL(blob);
  final anchor = web.HTMLAnchorElement()
    ..href = url
    ..download = fileName;
  anchor.click();
  web.URL.revokeObjectURL(url);
}
