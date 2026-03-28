import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:onepos_admin_app/core/theme/app_theme.dart';
import 'package:onepos_admin_app/shared/widgets/custom_app_bar.dart';
import 'package:onepos_admin_app/shared/widgets/loading_widget.dart';
import 'package:onepos_admin_app/shared/widgets/error_widget.dart';
import 'package:onepos_admin_app/shared/widgets/empty_state_widget.dart';
import '../../data/models/chat_contact_model.dart';
import '../providers/chat_provider.dart';
import '../../../../core/routes/app_routes.dart';

class ChatsScreen extends HookConsumerWidget {
  const ChatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactsAsync = ref.watch(chatContactsProvider);

    // Internal real-time updates (Polling every 5 seconds)
    useEffect(() {
      final timer = Timer.periodic(const Duration(seconds: 5), (_) {
        ref.invalidate(chatContactsProvider);
      });
      return timer.cancel;
    }, []);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: const CustomAppBar(title: 'Chats', centerTitle: false),
      body: contactsAsync.when(
        data: (contacts) {
          if (contacts.isEmpty) {
            return const EmptyStateWidget(
              message: 'No contacts available to chat',
              icon: Icons.chat_bubble_outline,
              title: 'No Contacts',
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.refresh(chatContactsProvider.future),
            color: AppTheme.primaryColor,
            child: ListView.separated(
              padding: const EdgeInsets.all(AppTheme.spacingMedium),
              itemCount: contacts.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final contact = contacts[index];
                return GestureDetector(
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.individualChat,
                    arguments: contact,
                  ),
                  child: _ContactCard(contact: contact),
                );
              },
            ),
          );
        },
        loading: () => const LoadingWidget(),
        error: (error, _) => CustomErrorWidget(
          message: error.toString(),
          onRetry: () => ref.refresh(chatContactsProvider.future),
        ),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final ChatContact contact;

  const _ContactCard({required this.contact});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        border: Border.all(color: AppTheme.grey200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_outline,
              color: AppTheme.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.fullName,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        contact.lastMessage ?? 'No messages yet',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: contact.unreadCount > 0
                              ? AppTheme.primaryColor
                              : AppTheme.textSecondary,
                          fontWeight: contact.unreadCount > 0
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  contact.email,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (contact.unreadCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                contact.unreadCount > 9 ? '9+' : '${contact.unreadCount}',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else
            const Icon(Icons.chevron_right, color: AppTheme.grey400, size: 20),
        ],
      ),
    );
  }
}
