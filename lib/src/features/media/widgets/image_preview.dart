import 'package:base_app/src/features/media/media.dart';
import 'package:flutter/material.dart';

class ImagePreview extends StatelessWidget {
  final ImageItem imageItem;
  final BorderRadius? borderRadius;
  final BoxFit fit;

  const ImagePreview({
    super.key,
    required this.imageItem,
    this.borderRadius,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: Image.file(
        imageItem.file,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[300],
            child: const Center(
              child: Icon(Icons.broken_image, color: Colors.grey),
            ),
          );
        },
      ),
    );
  }
}
