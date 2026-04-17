import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:onepos_admin_app/core/theme/app_theme.dart';

/// source options for picking an image
enum ImagePickSource { camera, gallery }

/// reusable image picker utility for the entire app
class AppImagePicker {
  // private constructor
  AppImagePicker._();

  static final ImagePicker _picker = ImagePicker();

  /// pick a single image from camera or gallery.
  /// returns the file path or null if cancelled.
  static Future<String?> pickImage({
    ImagePickSource source = ImagePickSource.gallery,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source == ImagePickSource.camera
            ? ImageSource.camera
            : ImageSource.gallery,
        maxWidth: maxWidth ?? 1024,
        maxHeight: maxHeight ?? 1024,
        imageQuality: imageQuality ?? 85,
      );
      return image?.path;
    } catch (e) {
      debugPrint('image picker error: $e');
      return null;
    }
  }

  /// pick multiple images from gallery.
  /// returns a list of file paths.
  static Future<List<String>> pickMultipleImages({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: maxWidth ?? 1024,
        maxHeight: maxHeight ?? 1024,
        imageQuality: imageQuality ?? 85,
      );
      return images.map((img) => img.path).toList();
    } catch (e) {
      debugPrint('multi image picker error: $e');
      return [];
    }
  }

  static Future<String?> showPickerBottomSheet(BuildContext context) async {
    final source = await showModalBottomSheet<ImagePickSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.borderRadiusLarge),
        ),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingMedium),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.grey300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppTheme.spacingMedium),
              Text(
                'Upload Image',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: AppTheme.spacingMedium),

              // camera option
              ListTile(
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.grey100,
                    borderRadius:
                        BorderRadius.circular(AppTheme.borderRadiusMedium),
                  ),
                  child: const Icon(Icons.camera_alt_outlined,
                      color: AppTheme.textPrimary),
                ),
                title: Text(
                  'Take a photo',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () =>
                    Navigator.pop(context, ImagePickSource.camera),
              ),

              // gallery option
              ListTile(
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.grey100,
                    borderRadius:
                        BorderRadius.circular(AppTheme.borderRadiusMedium),
                  ),
                  child: const Icon(Icons.photo_library_outlined,
                      color: AppTheme.textPrimary),
                ),
                title: Text(
                  'Choose from gallery',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () =>
                    Navigator.pop(context, ImagePickSource.gallery),
              ),
              const SizedBox(height: AppTheme.spacingSmall),
            ],
          ),
        ),
      ),
    );

    if (source == null) return null;
    return pickImage(source: source);
  }
}

/// reusable image upload widget that can be used across all screens.
/// shows a placeholder with + icon when no image, or the picked image preview.
class ImageUploadBox extends StatelessWidget {
  final String? imagePath;
  final VoidCallback onTap;
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const ImageUploadBox({
    super.key,
    this.imagePath,
    required this.onTap,
    this.width = 80,
    this.height = 80,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final radius =
        borderRadius ?? BorderRadius.circular(AppTheme.borderRadiusMedium);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: radius,
          border: Border.all(color: AppTheme.grey300),
        ),
        child: imagePath != null
            ? ClipRRect(
                borderRadius: radius,
                child: Image.file(
                  File(imagePath!),
                  fit: BoxFit.cover,
                  width: width,
                  height: height,
                  errorBuilder: (_, __, ___) => _buildPlaceholder(),
                ),
              )
            : _buildPlaceholder(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return const Center(
      child: Icon(
        Icons.add,
        size: 28,
        color: AppTheme.textSecondary,
      ),
    );
  }
}
