import 'package:flutter/material.dart';
import 'package:pictotap/utils/pictogram_utils.dart';

class PictogramIcon extends StatelessWidget {
  final String icon;
  final double size;

  const PictogramIcon({
    super.key,
    required this.icon,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    final assetPath = assetPathForIcon(icon);
    if (assetPath == null) {
      return SizedBox.square(
        dimension: size,
        child: FittedBox(
          fit: BoxFit.contain,
          child: Text(icon, style: TextStyle(fontSize: size * 0.9)),
        ),
      );
    }

    return SizedBox.square(
      dimension: size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Container(
          color: Colors.grey.shade200,
          child: Image.asset(
            assetPath,
            width: size,
            height: size,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Icon(Icons.broken_image, size: size * 0.6),
              );
            },
          ),
        ),
      ),
    );
  }
}
