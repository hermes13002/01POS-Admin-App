import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:onepos_admin_app/core/theme/app_theme.dart';
import '../../presentation/providers/tutorial_keys_provider.dart';
import 'app_showcase.dart';

/// Custom bottom navigation bar
class CustomBottomNavigationBar extends ConsumerWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final keys = ref.read(tutorialKeysProvider);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context: context,
                iconPath: 'assets/icons/home.png',
                inactiveIconPath: 'assets/icons/home-outline.png',
                label: 'Home',
                index: 0,
                showcaseKey: keys.homeTab,
                showcaseDesc:
                    'Access your quick actions and performance overview here.',
              ),
              _buildNavItem(
                context: context,
                iconPath: 'assets/icons/loan.png',
                inactiveIconPath: 'assets/icons/loan.png',
                label: 'Loan',
                index: 1,
                showcaseKey: keys.loanTab,
                showcaseDesc: 'Manage and request loans for your business.',
              ),
              _buildNavItem(
                context: context,
                iconPath: 'assets/icons/tools.png',
                inactiveIconPath: 'assets/icons/tools-outline.png',
                label: 'Tools',
                index: 2,
                showcaseKey: keys.toolsTab,
                showcaseDesc: 'Explore all available tools and settings.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required String iconPath,
    required String inactiveIconPath,
    required String label,
    required int index,
    required GlobalKey showcaseKey,
    required String showcaseDesc,
  }) {
    final isActive = currentIndex == index;
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: AppShowcase(
        targetBorderRadius: AppTheme.borderRadiusMedium,
        showcaseKey: showcaseKey,
        description: showcaseDesc,
        child: InkWell(
          onTap: () => onTap(index),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  isActive ? iconPath : inactiveIconPath,
                  width: 28,
                  height: 28,
                  color: isActive ? colorScheme.primary : Colors.grey,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                    color: isActive ? colorScheme.primary : Colors.grey,
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
