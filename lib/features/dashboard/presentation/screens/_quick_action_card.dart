import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/tool_model.dart';

class QuickActionCard extends StatelessWidget {
  final ToolModel tool;
  final Color color;
  final VoidCallback? onTap;

  const QuickActionCard({
    super.key,
    required this.tool,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade100),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // circular icon container
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: Center(
                child: Icon(tool.icon, size: 26, color: Colors.black54),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              tool.name,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary.withValues(alpha: 0.65),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
