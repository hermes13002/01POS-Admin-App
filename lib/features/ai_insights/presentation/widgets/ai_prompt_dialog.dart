import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:onepos_admin_app/core/theme/app_theme.dart';
import 'package:onepos_admin_app/features/ai_insights/data/models/ai_insight_model.dart';
import 'package:onepos_admin_app/features/ai_insights/presentation/providers/ai_insights_provider.dart';
import 'package:onepos_admin_app/features/ai_insights/presentation/widgets/ai_insight_card.dart';
import 'package:onepos_admin_app/shared/widgets/custom_button.dart';
import 'package:onepos_admin_app/core/errors/exceptions.dart';

class AiPromptDialog extends HookConsumerWidget {
  const AiPromptDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = useState(false);
    final insights = useState<List<AiInsight>>([]);
    final errorMessage = useState<String?>(null);

    final analyzeStore = useCallback(() async {
      isLoading.value = true;
      errorMessage.value = null;

      try {
        final repo = ref.read(aiInsightsRepositoryProvider);
        final result = await repo.getRealTimePrompt('');
        insights.value = result;
        
        // invalidate history provider to instantly refresh the Reports screen behind this dialog
        ref.invalidate(historicalInsightsProvider);
      } on AppException catch (e) {
        errorMessage.value = e.message;
      } catch (e) {
        errorMessage.value = e.toString();
      } finally {
        isLoading.value = false;
      }
    }, []);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
      ),
      backgroundColor: AppTheme.surfaceColor,
      insetPadding: const EdgeInsets.all(AppTheme.spacingLarge),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'AI Store Analysis',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingMedium),
            if (insights.value.isEmpty) ...[
              const Text(
                'Generate real-time insights for your store based on recent data.',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: AppTheme.spacingLarge),
              CustomButton(
                text: 'Analyze Store',
                onPressed: analyzeStore,
                isLoading: isLoading.value,
                icon: Icons.auto_awesome,
              ),
            ],
            if (errorMessage.value != null) ...[
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingMedium),
                color: AppTheme.errorColor.withValues(alpha: 0.1),
                child: Text(
                  errorMessage.value!,
                  style: const TextStyle(color: AppTheme.errorColor),
                ),
              ),
            ],
            if (insights.value.isNotEmpty) ...[
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: insights.value.length,
                  itemBuilder: (context, index) {
                    return AiInsightCard(insight: insights.value[index]);
                  },
                ),
              ),
              const SizedBox(height: AppTheme.spacingMedium),
              CustomButton(
                text: 'Done',
                onPressed: () {
                  // refresh history screen upon closing
                  ref.invalidate(historicalInsightsProvider);
                  Navigator.pop(context);
                },
                isOutlined: true,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
