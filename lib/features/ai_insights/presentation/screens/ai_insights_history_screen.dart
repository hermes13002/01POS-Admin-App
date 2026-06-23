import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:onepos_admin_app/features/ai_insights/presentation/providers/ai_insights_provider.dart';
import 'package:onepos_admin_app/features/ai_insights/presentation/widgets/ai_insight_card.dart';
import 'package:onepos_admin_app/features/ai_insights/presentation/widgets/ai_prompt_dialog.dart';
import 'package:onepos_admin_app/shared/widgets/custom_app_bar.dart';
import 'package:onepos_admin_app/shared/widgets/empty_state_widget.dart';
import 'package:onepos_admin_app/shared/widgets/error_widget.dart' as custom_error;
import 'package:onepos_admin_app/shared/widgets/shimmer_loader.dart';

class AiInsightsHistoryScreen extends ConsumerWidget {
  const AiInsightsHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insightsAsync = ref.watch(historicalInsightsProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'AI Insights',
        actions: [
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
      body: insightsAsync.when(
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
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const AiPromptDialog(),
          );
        },
        icon: const Icon(Icons.auto_awesome),
        label: const Text('Analyze Store'),
      ),
    );
  }
}
