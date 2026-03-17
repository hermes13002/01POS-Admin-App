import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:onepos_admin_app/core/routes/app_routes.dart';
import 'package:onepos_admin_app/core/theme/app_theme.dart';
import 'package:onepos_admin_app/data/models/tool_model.dart';
import 'package:onepos_admin_app/features/dashboard/presentation/screens/_quick_action_card.dart';
import 'package:onepos_admin_app/features/online_store/presentation/providers/profile_provider.dart';
import 'package:onepos_admin_app/presentation/providers/quick_actions_provider.dart';
import 'package:onepos_admin_app/features/notifications/presentation/providers/notifications_provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

const List<String> _backgroundImages = [
  'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?ixlib=rb-4.0.3&auto=format&fit=crop&w=1920&q=80',
  'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?ixlib=rb-4.0.3&auto=format&fit=crop&w=1920&q=80',
  'https://images.unsplash.com/photo-1469474968028-56623f02e42e?ixlib=rb-4.0.3&auto=format&fit=crop&w=1920&q=80',
  'https://images.unsplash.com/photo-1472214103451-9374bd1c798e?ixlib=rb-4.0.3&auto=format&fit=crop&w=1920&q=80',
  'https://images.unsplash.com/photo-1501594907352-04cda38ebc29?ixlib=rb-4.0.3&auto=format&fit=crop&w=1920&q=80',
];

/// home screen
class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quickActions = ref.watch(quickActionsProvider);
    final selectedPeriod = useState<String>('This week');
    final bgIndex = useState(0);
    final profileAsync = ref.watch(userProfileProvider);

    // cycle background images every 5 seconds
    useEffect(() {
      final timer = Timer.periodic(const Duration(seconds: 5), (_) {
        bgIndex.value = (bgIndex.value + 1) % _backgroundImages.length;
      });
      return timer.cancel;
    }, []);

    final pastelColors = [
      const Color(0xFFDDE3FF), // soft blue-purple
      const Color(0xFFFFDFF0), // soft pink
      const Color(0xFFDCF0FF), // soft cyan
      const Color(0xFFFFEBD5), // soft orange
      const Color(0xFFDCF5E4), // soft green
      const Color(0xFFEFDCFF), // soft purple
    ];

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // header row
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        profileAsync.when(
                          data: (p) => 'Welcome, ${p.firstname}',
                          loading: () => 'Welcome...',
                          error: (_, __) => 'Welcome',
                        ),
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Image.asset(
                        'assets/icons/message.png',
                        width: 24,
                        height: 24,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.mail_outline, size: 24),
                      ),
                      onPressed: () {},
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.notifications),
                      child: Stack(
                        children: [
                          IconButton(
                            icon: Image.asset(
                              'assets/icons/notification.png',
                              width: 24,
                              height: 24,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.notifications_outlined,
                                size: 24,
                              ),
                            ),
                            onPressed: () => Navigator.pushNamed(
                              context,
                              AppRoutes.notifications,
                            ),
                          ),
                          Consumer(
                            builder: (context, ref, _) {
                              final unreadCount = ref.watch(
                                unreadNotificationsCountProvider,
                              );
                              if (unreadCount == 0) return const SizedBox();

                              return Positioned(
                                right: 8,
                                top: 8,
                                child: Container(
                                  width: 16,
                                  height: 16,
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      unreadCount > 9 ? '9+' : '$unreadCount',
                                      style: const TextStyle(
                                        fontSize: 9,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.onlineStore),
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: AppTheme.grey300,
                        child: const Icon(
                          Icons.person,
                          color: Colors.black,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // performance banner
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Stack(
                    children: [
                      // animated background image
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 800),
                        child: SizedBox(
                          key: ValueKey(bgIndex.value),
                          height: 260,
                          width: double.infinity,
                          child: CachedNetworkImage(
                            imageUrl: _backgroundImages[bgIndex.value],
                            fit: BoxFit.cover,
                            placeholder: (_, __) =>
                                Container(color: const Color(0xFF2D5A27)),
                            errorWidget: (_, __, ___) =>
                                Container(color: const Color(0xFF2D5A27)),
                            fadeInDuration: Duration.zero,
                          ),
                        ),
                      ),
                      // dark overlay
                      Container(
                        height: 260,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.30),
                        ),
                      ),
                      // content
                      SizedBox(
                        height: 260,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // period chips
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children:
                                      [
                                        'Today',
                                        'This week',
                                        'This month',
                                        'This year',
                                      ].map((period) {
                                        final isSelected =
                                            selectedPeriod.value == period;
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            right: 8,
                                          ),
                                          child: GestureDetector(
                                            onTap: () =>
                                                selectedPeriod.value = period,
                                            child: _buildChip(
                                              period,
                                              isSelected,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'A quick update on your\nbusiness performance',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18,
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'So far this week, your business has made',
                                style: GoogleFonts.poppins(
                                  color: Colors.white.withOpacity(0.9),
                                  fontWeight: FontWeight.w400,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '₦345,000',
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 30,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.info_outline,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'That\'s the same as last week',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white.withOpacity(0.85),
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              // view report button
                              SizedBox(
                                height: 40,
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    // foregroundColor: Colors.white,
                                    backgroundColor: Colors.white,
                                    side: const BorderSide(
                                      color: Colors.white,
                                      width: 1.5,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                  ),
                                  onPressed: () {},
                                  icon: const Icon(
                                    Icons.arrow_forward,
                                    size: 18,
                                    color: AppTheme.textPrimary,
                                  ),
                                  label: Text(
                                    'View Detailed Report',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // quick actions section header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Quick Actions',
                      style: GoogleFonts.poppins(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        _showEditQuickActionsBottomSheet(context, ref);
                      },
                      child: Text(
                        'Edit',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // quick actions grid — vertical card layout
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: AnimationLimiter(
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      mainAxisExtent:
                          100 +
                          (30 * MediaQuery.textScalerOf(context).scale(1)),
                    ),
                    itemCount: quickActions.length > 8
                        ? 8
                        : quickActions.length,
                    itemBuilder: (context, index) {
                      final tool = quickActions[index];
                      final color = pastelColors[index % pastelColors.length];
                      return AnimationConfiguration.staggeredGrid(
                        position: index,
                        duration: const Duration(milliseconds: 375),
                        columnCount: 2,
                        child: SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(
                            child: QuickActionCard(
                              tool: tool,
                              color: color,
                              onTap: () =>
                                  Navigator.pushNamed(context, tool.route),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(String label, bool selected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: selected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected ? Colors.white : Colors.white.withOpacity(0.6),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          color: selected ? Colors.black : Colors.white,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
    );
  }

  void _showEditQuickActionsBottomSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const EditQuickActionsSheet(),
    );
  }
}

/// edit quick actions bottom sheet
class EditQuickActionsSheet extends HookConsumerWidget {
  const EditQuickActionsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quickActions = ref.watch(quickActionsProvider);
    final availableTools = AppTools.allTools
        .where((tool) => !quickActions.any((q) => q.id == tool.id))
        .toList();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppTheme.borderRadiusLarge),
          topRight: Radius.circular(AppTheme.borderRadiusLarge),
        ),
      ),
      padding: const EdgeInsets.all(AppTheme.spacingLarge),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.grey300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacingLarge),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Add to Quick Actions',
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
          const SizedBox(height: AppTheme.spacingSmall),

          Text(
            'Select a tool to add. Max 8 tools allowed.',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: AppTheme.spacingLarge),

          // available tools grid
          Flexible(
            child: availableTools.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppTheme.spacingLarge),
                      child: Text(
                        'All tools are already in Quick Actions.',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  )
                : GridView.builder(
                    shrinkWrap: true,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: AppTheme.spacingSmall,
                          mainAxisSpacing: AppTheme.spacingSmall,
                          childAspectRatio: 0.8,
                        ),
                    itemCount: availableTools.length,
                    itemBuilder: (context, index) {
                      final tool = availableTools[index];

                      return GestureDetector(
                        onTap: () {
                          if (quickActions.length < 8) {
                            ref
                                .read(quickActionsProvider.notifier)
                                .addTool(tool);
                            Navigator.pop(context);
                          } else {
                            // Trigger replace dialog
                            _showReplaceDialog(
                              context,
                              ref,
                              tool,
                              quickActions,
                            );
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppTheme.white,
                            borderRadius: BorderRadius.circular(
                              AppTheme.borderRadiusMedium,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  color: const Color.fromRGBO(
                                    83,
                                    157,
                                    243,
                                    0.15,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Icon(
                                    tool.icon,
                                    size: 24,
                                    color: const Color(0xFF2196F3),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                child: Text(
                                  tool.name,
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.textPrimary.withOpacity(
                                      0.7,
                                    ),
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showReplaceDialog(
    BuildContext context,
    WidgetRef ref,
    ToolModel newTool,
    List<ToolModel> currentQuickActions,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
          ),
          title: Text(
            'Replace Tool',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quick Actions is full. Select a tool to replace with ${newTool.name}:',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: SizedBox(
                  width: double.maxFinite,
                  child: GridView.builder(
                    shrinkWrap: true,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 0.8,
                        ),
                    itemCount: currentQuickActions.length,
                    itemBuilder: (context, index) {
                      final tool = currentQuickActions[index];
                      return GestureDetector(
                        onTap: () {
                          ref
                              .read(quickActionsProvider.notifier)
                              .replaceTool(tool.id, newTool);
                          // Close dialog and bottom sheet
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppTheme.white,
                            borderRadius: BorderRadius.circular(
                              AppTheme.borderRadiusMedium,
                            ),
                            border: Border.all(
                              color: AppTheme.grey300,
                              width: 0.5,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color.fromRGBO(
                                    83,
                                    157,
                                    243,
                                    0.15,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Icon(
                                    tool.icon,
                                    size: 20,
                                    color: const Color(0xFF2196F3),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                child: Text(
                                  tool.name,
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.textPrimary.withOpacity(
                                      0.7,
                                    ),
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
