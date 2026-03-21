import 'package:flutter/material.dart';
import 'package:pictotap/l10n/app_localizations.dart';

class BoardEmptyHint extends StatefulWidget {
  final bool isKeyboardVisible;
  const BoardEmptyHint({super.key, required this.isKeyboardVisible});

  @override
  State<BoardEmptyHint> createState() => _BoardEmptyHintState();
}

class _BoardEmptyHintState extends State<BoardEmptyHint>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _bounce;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _bounce = Tween(begin: 0.0, end: -12.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hint =
        widget.isKeyboardVisible ? l10n.hintSelectIcon : l10n.hintTapToOpen;

    return Semantics(
      label: hint,
      child: AnimatedBuilder(
        animation: _bounce,
        builder: (context, child) => Transform.translate(
          offset: Offset(0, _bounce.value),
          child: child,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(180),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.touch_app_rounded,
                size: 56,
                color: Colors.deepPurple.shade300,
              ),
              const SizedBox(height: 10),
              Text(
                hint,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
