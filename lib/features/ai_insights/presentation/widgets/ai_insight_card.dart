import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:onepos_admin_app/core/theme/app_theme.dart';
import 'package:onepos_admin_app/features/ai_insights/data/models/ai_insight_model.dart';

class AiInsightCard extends StatelessWidget {
  final AiInsight insight;
  final int? maxLines;
  final VoidCallback? onTap;

  const AiInsightCard({
    super.key, 
    required this.insight,
    this.maxLines,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDanger = insight.type.toLowerCase() == 'danger';
    final Color accentColor = isDanger ? AppTheme.errorColor : Colors.orange;
    final IconData icon =
        isDanger ? Icons.warning_rounded : Icons.info_outline_rounded;
    final Color backgroundColor = accentColor.withValues(alpha: 0.1);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingMedium),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          child: Container(
            padding: const EdgeInsets.all(AppTheme.spacingMedium),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
              border: Border.all(color: accentColor.withValues(alpha: 0.5)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: accentColor, size: 24),
                const SizedBox(width: AppTheme.spacingMedium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        insight.title,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingXSmall),
                      Text(
                        insight.detail,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                        maxLines: maxLines,
                        overflow: maxLines != null ? TextOverflow.ellipsis : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
