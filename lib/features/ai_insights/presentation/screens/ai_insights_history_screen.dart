import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:onepos_admin_app/core/routes/app_routes.dart';
import 'package:onepos_admin_app/core/theme/app_theme.dart';
import 'package:onepos_admin_app/features/ai_insights/presentation/providers/ai_insights_provider.dart';
import 'package:onepos_admin_app/features/ai_insights/presentation/widgets/ai_insight_card.dart';
import 'package:onepos_admin_app/features/ai_insights/presentation/widgets/ai_prompt_dialog.dart';
import 'package:onepos_admin_app/features/online_store/presentation/providers/profile_provider.dart';
import 'package:onepos_admin_app/shared/widgets/custom_app_bar.dart';
import 'package:onepos_admin_app/shared/widgets/empty_state_widget.dart';
import 'package:onepos_admin_app/shared/widgets/error_widget.dart' as custom_error;
import 'package:onepos_admin_app/shared/widgets/shimmer_loader.dart';

class AiInsightsHistoryScreen extends HookConsumerWidget {
  const AiInsightsHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final hasShownDialog = useState(false);

    final plan = profileAsync.valueOrNull?.plan?.toLowerCase() ?? 'standard';
    final hasAccess = profileAsync.isLoading || plan == 'pro' || plan == 'ai';

    useEffect(() {
      final profile = profileAsync.valueOrNull;
      if (profile != null && !hasShownDialog.value) {
        if (!hasAccess) {
          hasShownDialog.value = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!context.mounted) return;
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => PopScope(
                canPop: false,
                child: AlertDialog(
                  backgroundColor: AppTheme.backgroundColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                title: Text(
                  'Upgrade Required',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                content: Text(
                  'AI Insights is available on the Pro Plan.\nUpgrade to receive AI-powered insights for your store.',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // dismiss dialog
                      Navigator.of(context).pop(); // go back
                    },
                    child: Text(
                      'Go Back',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // dismiss dialog
                        Navigator.of(context).pushReplacementNamed(AppRoutes.subscriptionDetails);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Upgrade',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            );
          });
        }
      }
      return null;
    }, [profileAsync.value, hasShownDialog.value]);

    final insightsAsync = ref.watch(historicalInsightsProvider);

    Widget bodyContent = insightsAsync.when(
        data: (insights) {
          if (insights.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => ref.refresh(historicalInsightsProvider.future),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: const EmptyStateWidget(
                    title: 'No insights found',
                    message: 'Generate new insights to see them here',
                    icon: Icons.auto_awesome,
                  ),
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.refresh(historicalInsightsProvider.future),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: insights.length,
              itemBuilder: (context, index) {
                return AiInsightCard(insight: insights[index]);
              },
            ),
          );
        },
        loading: () => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: 5,
          itemBuilder: (context, index) => const ShimmerListItem(),
        ),
        error: (error, _) => custom_error.CustomErrorWidget(
          message: error.toString(),
          onRetry: () => ref.refresh(historicalInsightsProvider),
        ),
      );

    if (!hasAccess) {
      bodyContent = ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: IgnorePointer(child: bodyContent),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: 'AI Insights',
        actions: [
          if (hasAccess)
            IconButton(
              icon: const Icon(Icons.auto_awesome),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const AiPromptDialog(),
                );
              },
            ),
        ],
      ),
      body: bodyContent,
      floatingActionButton: hasAccess
          ? FloatingActionButton.extended(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const AiPromptDialog(),
                );
              },
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Analyze Store'),
            )
          : null,
    );
  }
}
