import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:onepos_admin_app/core/theme/app_theme.dart';
import 'package:onepos_admin_app/shared/widgets/custom_app_bar.dart';
import 'package:onepos_admin_app/shared/widgets/loading_widget.dart';
import 'package:onepos_admin_app/shared/widgets/error_widget.dart';
import 'package:onepos_admin_app/shared/widgets/app_snackbar.dart';
import '../providers/chat_provider.dart';
import '../../data/models/chat_contact_model.dart';

class IndividualChatScreen extends HookConsumerWidget {
  final ChatContact contact;

  const IndividualChatScreen({super.key, required this.contact});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messagesAsync = ref.watch(individualChatProvider(contact.id));
    final messageController = TextEditingController();

    // Internal real-time updates (Polling every 5 seconds)
    useEffect(() {
      final timer = Timer.periodic(const Duration(seconds: 5), (_) {
        ref.invalidate(individualChatProvider(contact.id));
      });
      return timer.cancel;
    }, [contact.id]);

    // Reactively mark as read when messages load or change
    ref.listen(individualChatProvider(contact.id), (previous, next) {
      next.whenData((messages) {
        final unreadIds = messages
            .where((m) => !m.isRead && m.role == 'receiver')
            .map((m) => m.id)
            .toList();

        if (unreadIds.isNotEmpty) {
          ref
              .read(chatNotifierProvider.notifier)
              .markAllAsRead(contact.id, unreadIds);
        }
      });
    });

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: CustomAppBar(
        title: contact.fullName,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              // Show contact info
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              data: (messages) {
                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 48,
                          color: AppTheme.grey400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No messages yet.\nStart the conversation!',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  reverse: true, // Show latest messages at the bottom
                  padding: const EdgeInsets.all(AppTheme.spacingMedium),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    // Reverse the list since ListView is reversed
                    final message = messages[messages.length - 1 - index];
                    return _MessageBubble(
                      message: message,
                      onLongPress: () =>
                          _showDeleteDialog(context, ref, message),
                    );
                  },
                );
              },
              loading: () => const LoadingWidget(),
              error: (error, _) => CustomErrorWidget(
                message: error.toString(),
                onRetry: () =>
                    ref.invalidate(individualChatProvider(contact.id)),
              ),
            ),
          ),

          // Message Input Field
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingMedium,
              vertical: AppTheme.spacingSmall,
            ),
            decoration: BoxDecoration(
              color: AppTheme.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      style: GoogleFonts.poppins(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: GoogleFonts.poppins(color: AppTheme.grey400),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: AppTheme.backgroundColor,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                      onSubmitted: (value) =>
                          _sendMessage(context, ref, messageController),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _sendMessage(context, ref, messageController),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage(
    BuildContext context,
    WidgetRef ref,
    TextEditingController controller,
  ) async {
    final text = controller.text.trim();
    if (text.isEmpty) return;

    controller.clear();
    final error = await ref
        .read(chatNotifierProvider.notifier)
        .sendMessage(contact.id, text);

    if (error != null && context.mounted) {
      AppSnackbar.showError(context, error);
      // Restore the text if it failed
      controller.text = text;
    }
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, dynamic message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Message',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure you want to delete this message?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: AppTheme.grey600),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final error = await ref
                  .read(chatNotifierProvider.notifier)
                  .deleteMessage(contact.id, message.id);
              if (error != null && context.mounted) {
                AppSnackbar.showError(context, error);
              }
            },
            child: Text(
              'Delete',
              style: GoogleFonts.poppins(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final dynamic message;
  final VoidCallback? onLongPress;

  const _MessageBubble({required this.message, this.onLongPress});

  @override
  Widget build(BuildContext context) {
    final bool isMe = message.isMe;

    // Parse time
    String time = '';
    try {
      final date = DateTime.tryParse(message.createdAt);
      if (date != null) {
        time = DateFormat('hh:mm a').format(date);
      } else {
        time = message.createdAt;
      }
    } catch (_) {
      time = message.createdAt;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onLongPress: onLongPress,
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isMe
                    ? AppTheme.primaryColor
                    : AppTheme.primaryColor.withOpacity(0.12),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 16),
                ),
              ),
              child: Text(
                message.message,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: isMe ? Colors.white : AppTheme.primaryColor,
                  fontWeight: isMe ? FontWeight.normal : FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  time,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: AppTheme.grey500,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    message.isRead ? Icons.done_all : Icons.done,
                    size: 14,
                    color: message.isRead
                        ? AppTheme.primaryColor
                        : AppTheme.grey400,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
