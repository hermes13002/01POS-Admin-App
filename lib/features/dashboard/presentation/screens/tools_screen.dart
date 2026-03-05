import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:onepos_admin_app/core/theme/app_theme.dart';
import 'package:onepos_admin_app/data/models/tool_model.dart';
import 'package:onepos_admin_app/presentation/providers/quick_actions_provider.dart';

/// Tools screen showing all available tools
class ToolsScreen extends HookConsumerWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quickActions = ref.watch(quickActionsProvider);
    final searchQuery = useState('');

    final filteredTools = useMemoized(() {
      final availableTools = AppTools.allTools
          .where((tool) => !quickActions.any((q) => q.id == tool.id))
          .toList();

      if (searchQuery.value.isEmpty) {
        return availableTools;
      }
      return availableTools
          .where(
            (tool) => tool.name.toLowerCase().contains(
              searchQuery.value.toLowerCase(),
            ),
          )
          .toList();
    }, [searchQuery.value, quickActions]);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // header with title
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingMedium),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Tools',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
            ),

            // search bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingMedium,
              ),
              child: TextField(
                onChanged: (value) => searchQuery.value = value,
                decoration: InputDecoration(
                  hintText: 'Search',
                  prefixIcon: const Icon(Icons.search, color: AppTheme.grey500),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingMedium,
                    vertical: AppTheme.spacingSmall,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      AppTheme.borderRadiusMedium,
                    ),
                    borderSide: const BorderSide(color: AppTheme.grey300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      AppTheme.borderRadiusMedium,
                    ),
                    borderSide: const BorderSide(color: AppTheme.grey300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      AppTheme.borderRadiusMedium,
                    ),
                    borderSide: const BorderSide(
                      color: AppTheme.primaryColor,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppTheme.spacingLarge),

            // tools grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingMedium,
                ),
                child: filteredTools.isEmpty
                    ? Center(
                        child: Text(
                          'No tools found',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      )
                    : AnimationLimiter(
                        child: GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: AppTheme.spacingMedium,
                                mainAxisSpacing: AppTheme.spacingMedium,
                                mainAxisExtent:
                                    110 +
                                    (35 *
                                        MediaQuery.textScalerOf(
                                          context,
                                        ).scale(1)),
                              ),
                          itemCount: filteredTools.length,
                          itemBuilder: (context, index) {
                            final tool = filteredTools[index];
                            return AnimationConfiguration.staggeredGrid(
                              position: index,
                              duration: const Duration(milliseconds: 375),
                              columnCount: 3,
                              child: SlideAnimation(
                                verticalOffset: 50.0,
                                child: FadeInAnimation(
                                  child: _buildToolItem(context, tool),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolItem(BuildContext context, ToolModel tool) {
    return InkWell(
      onTap: () {
        // navigate to tool screen
        Navigator.pushNamed(context, tool.route);
      },
      borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // icon with light blue background
            Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                color: Color.fromRGBO(83, 157, 243, 0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  tool.icon,
                  size: 26,
                  color: const Color(0xFF2196F3),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // label
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Text(
                    tool.name,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
