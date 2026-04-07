import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:onepos_admin_app/core/theme/app_theme.dart';
import 'package:onepos_admin_app/features/reports/presentation/providers/reports_provider.dart';
import 'package:onepos_admin_app/shared/widgets/custom_button.dart';
import 'package:onepos_admin_app/shared/widgets/app_snackbar.dart';

class LoanScreen extends HookConsumerWidget {
  final bool isActive;
  const LoanScreen({super.key, this.isActive = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsState = ref.watch(reportsProvider);
    final score = reportsState.fundingReadinessScore;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Funding Readiness',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: AppTheme.textPrimary,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        //   onPressed: () => Navigator.of(context).pop(),
        //   color: AppTheme.textPrimary,
        // ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Column(
          children: [
            // score card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'Funding Readiness Score',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _FundingBatteryIndicator(score: score, isActive: isActive),
                  const SizedBox(height: 32),
                  Text(
                    _getStatusText(score),
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _getScoreColor(score),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Based on your business performance',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 48),

            // action section
            Column(
              children: [
                CustomButton(
                  text: 'Notify me when funding is available',
                  onPressed: () {
                    AppSnackbar.showSuccess(
                      context,
                      "We've added you to the waitlist!",
                    );
                  },
                  backgroundColor: const Color(0xFF3B82F6),
                  borderRadius: BorderRadius.circular(16),
                ),
                const SizedBox(height: 16),
                Text(
                  "We're working on connecting businesses like yours to funding partners. You'll be the first to know.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // calculation note
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.grey100.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.auto_graph, size: 20, color: AppTheme.grey500),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your score is calculated in real-time using your sales volume, consistency, and profitability data.',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusText(int score) {
    if (score >= 81) return 'Excellent';
    if (score >= 61) return 'Good';
    if (score >= 41) return 'Average';
    if (score >= 21) return 'Fair';
    return 'Low';
  }

  Color _getScoreColor(int score) {
    if (score >= 81) return const Color(0xFF1DD1A1); // Green
    if (score >= 61) return const Color(0xFF4CAF50); // Light Green
    if (score >= 41) return const Color(0xFFFFD93D); // Yellow
    if (score >= 21) return const Color(0xFFFF9F43); // Orange
    return const Color(0xFFFF4757); // Red
  }
}

class _FundingBatteryIndicator extends HookWidget {
  final int score;
  final bool isActive;

  const _FundingBatteryIndicator({required this.score, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 1500),
    );

    final curvedAnimation = useMemoized(
      () =>
          CurvedAnimation(parent: animationController, curve: Curves.easeInOut),
      [animationController],
    );

    useEffect(() {
      if (isActive) {
        animationController.forward(from: 0.0);
      }
      return null;
    }, [score, isActive]);

    return AnimatedBuilder(
      animation: curvedAnimation,
      builder: (context, child) {
        final animatedScore = (curvedAnimation.value * score).round();
        return Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                // battery shell
                Container(
                  width: 140,
                  height: 240,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.grey300, width: 4),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      // battery tip
                      Container(
                        width: 40,
                        height: 10,
                        decoration: BoxDecoration(
                          color: AppTheme.grey300,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      // battery levels
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                // fill background
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: AppTheme.grey100,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                // animated fill
                                Container(
                                  width: double.infinity,
                                  height:
                                      constraints.maxHeight *
                                      curvedAnimation.value *
                                      (score / 100),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        _getScoreColor(score),
                                        _getScoreColor(
                                          score,
                                        ).withValues(alpha: 0.7),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                // score text overlay
                Positioned(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$animatedScore',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 48,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        '/100',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 81) return const Color(0xFF1DD1A1);
    if (score >= 61) return const Color(0xFF4CAF50);
    if (score >= 41) return const Color(0xFFFFD93D);
    if (score >= 21) return const Color(0xFFFF9F43);
    return const Color(0xFFFF4757);
  }
}
