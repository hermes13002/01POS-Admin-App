import 'package:flutter/material.dart';

/// Custom button with icon on the left
class CustomButtonWithIcon extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isOutlined;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? iconColor;
  final Color? borderColor;
  final double? width;
  final double height;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final double iconSize;
  final double spacing;

  const CustomButtonWithIcon({
    super.key,
    required this.text,
    required this.icon,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.backgroundColor,
    this.textColor,
    this.iconColor,
    this.borderColor,
    this.width,
    this.height = 48,
    this.padding,
    this.borderRadius,
    this.iconSize = 20,
    this.spacing = 8,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveTextColor =
        textColor ??
        (isOutlined ? theme.colorScheme.primary : theme.colorScheme.onPrimary);
    final effectiveIconColor = iconColor ?? effectiveTextColor;

    if (isOutlined) {
      return OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          minimumSize: Size(width ?? double.infinity, height),
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(8),
          ),
          side: BorderSide(color: borderColor ?? theme.colorScheme.primary),
        ),
        child: _buildContent(effectiveTextColor, effectiveIconColor),
      );
    }

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? Colors.black,
        foregroundColor: textColor ?? Colors.white,
        minimumSize: Size(width ?? double.infinity, height),
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
      child: _buildContent(
        textColor ?? Colors.white,
        iconColor ?? Colors.white,
      ),
    );
  }

  Widget _buildContent(Color textColor, Color iconColor) {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(textColor),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: iconSize, color: iconColor),
        SizedBox(width: spacing),
        Text(text),
      ],
    );
  }
}
