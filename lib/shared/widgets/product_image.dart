import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';

class ProductImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final double borderRadius;

  const ProductImage({
    super.key,
    this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.borderRadius = 0,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return placeholder ?? _buildDefaultPlaceholder();
    }

    // handle local file URIs
    if (imageUrl!.startsWith('file://') ||
        imageUrl!.startsWith('/data/') ||
        imageUrl!.startsWith('/tmp/') ||
        imageUrl!.startsWith('content://')) {
      final path = imageUrl!.startsWith('file://')
          ? Uri.parse(imageUrl!).toFilePath()
          : imageUrl!;

      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.file(
          File(path),
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (_, __, ___) =>
              placeholder ?? _buildDefaultPlaceholder(),
        ),
      );
    }

    // handle network images
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: CachedNetworkImage(
        imageUrl: imageUrl!,
        width: width,
        height: height,
        fit: fit,
        placeholder: (_, __) => _buildShimmer(),
        errorWidget: (_, __, ___) => placeholder ?? _buildDefaultPlaceholder(),
      ),
    );
  }

  Widget _buildDefaultPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: Icon(Icons.image_outlined, color: Colors.grey[400], size: 20),
    );
  }

  Widget _buildShimmer() {
    return Container(width: width, height: height, color: Colors.grey[100]);
  }
}
