import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pictotap/data/pictogram_data.dart';
import 'package:pictotap/image_saver.dart';
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
  static const double _boardIconSize = 80;
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

      final image = await boundary.toImage(pixelRatio: 3);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final pngBytes = byteData.buffer.asUint8List();
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
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              _backgroundAssetPath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(color: const Color(0xFFF5F0EB));
              },
            ),
          ),
          Positioned.fill(
            child: Container(color: Colors.white.withAlpha(140)),
          ),
          Column(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _toggleKeyboard,
                  child: RepaintBoundary(
                    key: _boardBoundaryKey,
                    child: Container(
                      width: double.infinity,
                      color: Colors.transparent,
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
