import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pictotap/data/pictogram_data.dart';
import 'package:pictotap/services/image_saver.dart';
import 'package:pictotap/l10n/app_localizations.dart';
import 'package:pictotap/utils/pictogram_utils.dart';
import 'package:pictotap/widgets/board_empty_hint.dart';
import 'package:pictotap/widgets/pictogram_icon.dart';
import 'package:pictotap/widgets/pictogram_keyboard.dart';

class PictoTapScreen extends StatefulWidget {
  const PictoTapScreen({super.key});

  @override
  State<PictoTapScreen> createState() => _PictoTapScreenState();
}

class _PictoTapScreenState extends State<PictoTapScreen> {
  final List<String> _selectedIcons = [];
  bool _isKeyboardVisible = false;
  int? _lastAddedIndex;
  int? _lastRemovedIndex;
  bool _showLimitReachedBanner = false;
  Timer? _limitReachedTimer;
  final GlobalKey _boardBoundaryKey = GlobalKey();

  static const String _backgroundAssetPath =
      'assets/background/background.webp';
  static const double _boardIconSize = 110;
  static const int _shareImageSize = 1080;
  static const Color _backgroundFallback = Color(0xFFF5F0EB);
  static const Duration _animationDuration = Duration(milliseconds: 450);

  void _addIcon(String icon) {
    if (_selectedIcons.length >= defaultBoardMaxIcons) {
      _showLimitReachedMessage();
      return;
    }
    final newIndex = _selectedIcons.length;
    final newLength = newIndex + 1;
    setState(() {
      _selectedIcons.add(icon);
      _lastAddedIndex = newIndex;
    });

    if (newLength == defaultBoardMaxIcons) {
      _showLimitReachedMessage();
    }

    Future.delayed(_animationDuration).then((_) {
      if (!mounted) return;
      setState(() {
        if (_lastAddedIndex == newIndex) _lastAddedIndex = null;
      });
    });
  }

  void _removeLast() {
    if (_selectedIcons.isEmpty) return;
    if (_lastRemovedIndex != null) return;

    final removedIndex = _selectedIcons.length - 1;
    setState(() {
      _lastAddedIndex = null;
      _lastRemovedIndex = removedIndex;
    });

    Future.delayed(_animationDuration).then((_) {
      if (!mounted) return;
      setState(() {
        if (_lastRemovedIndex == removedIndex &&
            _selectedIcons.length > removedIndex) {
          _selectedIcons.removeAt(removedIndex);
        }
        if (_lastRemovedIndex == removedIndex) _lastRemovedIndex = null;
      });
    });
  }

  void _showLimitReachedMessage() {
    if (!_isKeyboardVisible) return;
    _limitReachedTimer?.cancel();
    setState(() => _showLimitReachedBanner = true);
    _limitReachedTimer = Timer(const Duration(milliseconds: 1600), () {
      if (!mounted) return;
      setState(() => _showLimitReachedBanner = false);
    });
  }

  @override
  void dispose() {
    _limitReachedTimer?.cancel();
    super.dispose();
  }

  void _addSpace() => _addIcon(spaceIcon);

  void _toggleKeyboard() =>
      setState(() => _isKeyboardVisible = !_isKeyboardVisible);

  Future<void> _share() async {
    if (_selectedIcons.isEmpty) return;

    final l10n = AppLocalizations.of(context)!;
    final shareText =
        _selectedIcons.map((icon) => displayNameForIcon(icon)).join(' ');

    try {
      final boundary = _boardBoundaryKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return;

      const int out = _shareImageSize;
      final bSize = boundary.size;
      final pixelRatio = out / math.min(bSize.width, bSize.height);
      final rawImage = await boundary.toImage(pixelRatio: pixelRatio);

      final srcW = rawImage.width;
      final srcH = rawImage.height;
      final rawBytes = await rawImage.toByteData(
        format: ui.ImageByteFormat.rawStraightRgba,
      );
      if (rawBytes == null) return;
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
      if (pngData == null) return;

      final pngBytes = pngData.buffer.asUint8List();
      final fileName =
          'pictotap-board-${DateTime.now().millisecondsSinceEpoch}.png';
      await saveAndShareImage(pngBytes, fileName, shareText);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.shareFailed),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildBoardIcon(String icon) {
    if (icon == spaceIcon) {
      return const SizedBox(
          width: _boardIconSize * 0.5, height: _boardIconSize);
    }
    final name = displayNameForIcon(icon);
    return Semantics(
      label: name,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: isAssetIcon(icon)
            ? PictogramIcon(icon: icon, size: _boardIconSize)
            : Text(icon, style: const TextStyle(fontSize: _boardIconSize)),
      ),
    );
  }

  Widget _buildAnimatedIcon(int index, String icon) {
    final iconWidget = _buildBoardIcon(icon);

    if (_lastAddedIndex == index) {
      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: _animationDuration,
        curve: Curves.easeOutCubic,
        child: iconWidget,
        builder: (context, t, child) {
          return Opacity(
            opacity: t,
            child: Transform.translate(
              offset: Offset(0, (1 - t) * -45.0),
              child: child,
            ),
          );
        },
      );
    }

    if (_lastRemovedIndex == index) {
      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 1, end: 0),
        duration: _animationDuration,
        curve: Curves.easeInCubic,
        child: iconWidget,
        builder: (context, t, child) {
          return Opacity(
            opacity: t,
            child: Transform.translate(
              offset: Offset(0, (1 - t) * -45.0),
              child: child,
            ),
          );
        },
      );
    }

    return iconWidget;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.appTitle,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        elevation: 0,
        scrolledUnderElevation: 4,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black54,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.deepPurple.shade300,
                Colors.deepPurple.shade500,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.deepPurple.shade900.withAlpha(80),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
        ),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: _toggleKeyboard,
              child: RepaintBoundary(
                key: _boardBoundaryKey,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.asset(
                        _backgroundAssetPath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(color: _backgroundFallback);
                        },
                      ),
                    ),
                    Positioned.fill(
                      child: Container(color: Colors.white.withAlpha(140)),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: _selectedIcons.isEmpty
                          ? Center(
                              child: BoardEmptyHint(
                                isKeyboardVisible: _isKeyboardVisible,
                              ),
                            )
                          : Align(
                              alignment: Alignment.center,
                              child: Wrap(
                                alignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: _selectedIcons
                                    .asMap()
                                    .entries
                                    .map((e) =>
                                        _buildAnimatedIcon(e.key, e.value))
                                    .toList(),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isKeyboardVisible)
            PictogramKeyboard(
              onIconSelected: _addIcon,
              onSpace: _addSpace,
              onBackspace: _removeLast,
              recommendations: buildRecommendations(_selectedIcons),
              showLimitBanner: _showLimitReachedBanner,
            ),
        ],
      ),
      floatingActionButton: _isKeyboardVisible
          ? null
          : Semantics(
              label: l10n.shareBoard,
              child: FloatingActionButton(
                onPressed: _share,
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                elevation: 4,
                child: const Icon(Icons.send),
              ),
            ),
    );
  }
}
