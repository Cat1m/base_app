import 'package:flutter/material.dart';
import '../models/image_item.dart';

/// Widget để hiển thị preview của ảnh
class ImagePreview extends StatelessWidget {
  final ImageItem imageItem;
  final BorderRadius? borderRadius;
  final BoxFit fit;
  final VoidCallback? onCropPressed;

  const ImagePreview({
    super.key,
    required this.imageItem,
    this.borderRadius,
    this.fit = BoxFit.cover,
    this.onCropPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.file(
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
          // Crop button
          if (onCropPressed != null)
            Positioned(
              bottom: 4,
              right: 4,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(128),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.crop, size: 16),
                  color: Colors.white,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 24,
                    minHeight: 24,
                  ),
                  onPressed: onCropPressed,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
