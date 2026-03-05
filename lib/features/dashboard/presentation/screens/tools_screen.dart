import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:onepos_admin_app/core/theme/app_theme.dart';
import 'package:onepos_admin_app/data/models/tool_model.dart';

/// Tools screen showing all available tools
class ToolsScreen extends HookConsumerWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchQuery = useState('');
    final filteredTools = useMemoized(() {
      if (searchQuery.value.isEmpty) {
        return AppTools.allTools;
      }
      return AppTools.allTools
          .where(
            (tool) => tool.name.toLowerCase().contains(
              searchQuery.value.toLowerCase(),
            ),
          )
          .toList();
    }, [searchQuery.value]);

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
                    : GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: AppTheme.spacingMedium,
                              mainAxisSpacing: AppTheme.spacingMedium,
                              childAspectRatio: 0.9,
                            ),
                        itemCount: filteredTools.length,
                        itemBuilder: (context, index) {
                          final tool = filteredTools[index];
                          return _buildToolItem(context, tool);
                        },
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // icon with light blue background
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color.fromRGBO(83, 157, 243, 0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  tool.icon,
                  size: 32,
                  color: const Color(0xFF2196F3),
                ),
              ),
            ),

            // label
            Text(
              tool.name,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
