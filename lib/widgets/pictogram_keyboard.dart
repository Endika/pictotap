import 'package:flutter/material.dart';
import 'package:pictotap/data/pictogram_data.dart';
import 'package:pictotap/l10n/app_localizations.dart';
import 'package:pictotap/utils/pictogram_utils.dart';
import 'package:pictotap/widgets/pictogram_icon.dart';

class PictogramKeyboard extends StatelessWidget {
  final ValueChanged<String> onIconSelected;
  final VoidCallback onSpace;
  final VoidCallback onBackspace;
  final List<String> recommendations;
  final bool showLimitBanner;

  static const double height = 310;
  static const double _gridMaxCellExtent = 56.0;

  const PictogramKeyboard({
    super.key,
    required this.onIconSelected,
    required this.onSpace,
    required this.onBackspace,
    required this.recommendations,
    this.showLimitBanner = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFD4D6DC),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(40),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: DefaultTabController(
        length: keyboardCategories.length,
        child: Stack(
          children: [
            Column(
              children: [
                _RecommendationBar(
                  recommendations: recommendations,
                  onIconSelected: onIconSelected,
                ),
                TabBar(
                  tabs: keyboardCategories
                      .map((c) => Tab(height: 34, text: c.label))
                      .toList(),
                  isScrollable: true,
                  labelColor: Colors.black87,
                  unselectedLabelColor: Colors.black45,
                  indicatorColor: Colors.deepPurple,
                  indicatorWeight: 2.5,
                  dividerHeight: 0,
                ),
                Expanded(
                  child: TabBarView(
                    children: keyboardCategories.map((category) {
                      return GridView.builder(
                        physics: const ClampingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 3, vertical: 3),
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: _gridMaxCellExtent,
                          crossAxisSpacing: 4,
                          mainAxisSpacing: 4,
                        ),
                        itemCount: category.icons.length,
                        itemBuilder: (context, index) {
                          return _KeyButton(
                            icon: category.icons[index],
                            onTap: onIconSelected,
                          );
                        },
                      );
                    }).toList(),
                  ),
                ),
                _BottomBar(
                  onSpace: onSpace,
                  onBackspace: onBackspace,
                  l10n: l10n,
                ),
              ],
            ),
            if (showLimitBanner) _LimitBanner(l10n: l10n),
          ],
        ),
      ),
    );
  }
}

class _KeyButton extends StatelessWidget {
  final String icon;
  final ValueChanged<String> onTap;

  const _KeyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final name = displayNameForIcon(icon);
    return Semantics(
      label: name,
      button: true,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        elevation: 1,
        shadowColor: Colors.black26,
        child: InkWell(
          onTap: () => onTap(icon),
          borderRadius: BorderRadius.circular(6),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(3),
                child: PictogramIcon(icon: icon),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RecommendationBar extends StatelessWidget {
  final List<String> recommendations;
  final ValueChanged<String> onIconSelected;

  const _RecommendationBar({
    required this.recommendations,
    required this.onIconSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFAEB2BA),
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade500, width: 0.5),
        ),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: recommendations.length,
        separatorBuilder: (_, __) => const SizedBox(width: 5),
        itemBuilder: (context, index) {
          final icon = recommendations[index];
          final name = displayNameForIcon(icon);
          return Semantics(
            label: name,
            button: true,
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              elevation: 1,
              shadowColor: Colors.black26,
              child: InkWell(
                onTap: () => onIconSelected(icon),
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  width: 40,
                  height: 40,
                  padding: const EdgeInsets.all(4),
                  child: Center(
                    child: PictogramIcon(icon: icon, size: 28),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final VoidCallback onSpace;
  final VoidCallback onBackspace;
  final AppLocalizations l10n;

  const _BottomBar({
    required this.onSpace,
    required this.onBackspace,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFD4D6DC),
        border: Border(
          top: BorderSide(color: Colors.grey.shade400, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              label: l10n.space,
              button: true,
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                elevation: 1,
                shadowColor: Colors.black26,
                child: InkWell(
                  onTap: onSpace,
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    height: 36,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Semantics(
            label: l10n.backspace,
            button: true,
            child: Material(
              color: const Color(0xFFADB0B8),
              borderRadius: BorderRadius.circular(6),
              elevation: 1,
              shadowColor: Colors.black26,
              child: InkWell(
                onTap: onBackspace,
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  width: 72,
                  height: 36,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: const Center(
                    child: Icon(Icons.backspace_outlined,
                        size: 22, color: Colors.black87),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LimitBanner extends StatelessWidget {
  final AppLocalizations l10n;
  const _LimitBanner({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 12,
      right: 12,
      top: 6,
      child: IgnorePointer(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withAlpha(160),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            l10n.limitReached,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
