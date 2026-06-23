import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:onepos_admin_app/core/theme/app_theme.dart';
import 'package:onepos_admin_app/features/ai_insights/data/models/ai_insight_model.dart';
import 'package:onepos_admin_app/features/ai_insights/presentation/providers/ai_insights_provider.dart';
import 'package:onepos_admin_app/features/ai_insights/presentation/widgets/ai_insight_card.dart';
import 'package:onepos_admin_app/shared/widgets/custom_button.dart';
import 'package:onepos_admin_app/shared/widgets/loading_widget.dart';
import 'package:onepos_admin_app/core/errors/exceptions.dart';

class AiPromptBottomSheet extends HookConsumerWidget {
  const AiPromptBottomSheet({super.key});

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
      } on AppException catch (e) {
        errorMessage.value = e.message;
      } catch (e) {
        errorMessage.value = e.toString();
      } finally {
        isLoading.value = false;
      }
    }, []);

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: AppTheme.spacingLarge,
        left: AppTheme.spacingMedium,
        right: AppTheme.spacingMedium,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.borderRadiusLarge),
        ),
      ),
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
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          if (insights.value.isEmpty) ...[
            CustomButton(
              text: 'Analyze Store',
              onPressed: analyzeStore,
              isLoading: isLoading.value,
              icon: Icons.auto_awesome,
            ),
            const SizedBox(height: AppTheme.spacingLarge),
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
            const SizedBox(height: AppTheme.spacingLarge),
          ],
          if (isLoading.value) ...[
            const Padding(
              padding: EdgeInsets.all(AppTheme.spacingLarge),
              child: Center(child: LoadingWidget()),
            ),
          ] else if (insights.value.isNotEmpty) ...[
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
              onPressed: () => Navigator.pop(context),
              isOutlined: true,
            ),
            const SizedBox(height: AppTheme.spacingLarge),
          ],
        ],
      ),
    );
  }
}
