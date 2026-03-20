import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/models/chat_contact_model.dart';
import '../../data/models/chat_message_model.dart';
import '../../data/repositories/chat_repository.dart';
import '../../data/sources/chat_remote_source.dart';

part 'chat_provider.g.dart';

@riverpod
ChatRepository chatRepository(ChatRepositoryRef ref) {
  return ChatRepositoryImpl(ChatRemoteSource(DioClient()));
}

@riverpod
Future<List<ChatMessage>> individualChat(
  IndividualChatRef ref,
  int receiverId,
) async {
  final repo = ref.watch(chatRepositoryProvider);
  final result = await repo.getMessages(receiverId);

  return result.fold(
    (failure) => throw Exception(failure.message),
    (messages) => messages,
  );
}

@riverpod
class ChatNotifier extends _$ChatNotifier {
  @override
  FutureOr<void> build() {}

  Future<String?> sendMessage(int receiverId, String message) async {
    final repo = ref.read(chatRepositoryProvider);
    final result = await repo.sendMessage(receiverId, message);

    return result.fold((failure) => failure.message, (_) {
      // refresh messages for this user
      ref.invalidate(individualChatProvider(receiverId));
      return null;
    });
  }

  Future<String?> markAsRead(int messageId) async {
    final repo = ref.read(chatRepositoryProvider);
    final result = await repo.markAsRead(messageId);

    return result.fold((failure) => failure.message, (_) => null);
  }

  Future<void> markAllAsRead(int receiverId, List<int> messageIds) async {
    if (messageIds.isEmpty) return;

    final repo = ref.read(chatRepositoryProvider);

    // Perform all calls sequentially to avoid overwhelming the server
    // but in a real-world scenario we might want a batch endpoint
    for (final id in messageIds) {
      await repo.markAsRead(id);
    }

    // After all messages are marked, refresh the providers
    ref.invalidate(individualChatProvider(receiverId));
    ref.invalidate(chatContactsProvider);
  }

  Future<String?> deleteMessage(int receiverId, int messageId) async {
    final repo = ref.read(chatRepositoryProvider);
    final result = await repo.deleteMessage(messageId);

    return result.fold((failure) => failure.message, (_) {
      // refresh messages for this user
      ref.invalidate(individualChatProvider(receiverId));
      return null;
    });
  }
}

@riverpod
Future<List<ChatContact>> chatContacts(ChatContactsRef ref) async {
  final repo = ref.watch(chatRepositoryProvider);
  final result = await repo.getContacts();

  return result.fold((failure) => throw Exception(failure.message), (contacts) {
    // sort contacts by updated_at descending
    final sortedContacts = List<ChatContact>.from(contacts);
    sortedContacts.sort((a, b) {
      if (a.updatedAt == null && b.updatedAt == null) return 0;
      if (a.updatedAt == null) return 1;
      if (b.updatedAt == null) return -1;

      try {
        final dateA = DateTime.parse(a.updatedAt!);
        final dateB = DateTime.parse(b.updatedAt!);
        return dateB.compareTo(dateA);
      } catch (e) {
        return 0;
      }
    });
    return sortedContacts;
  });
}

@riverpod
int totalUnreadCount(TotalUnreadCountRef ref) {
  final contactsAsync = ref.watch(chatContactsProvider);
  return contactsAsync.maybeWhen(
    data: (contacts) =>
        contacts.fold(0, (sum, contact) => sum + contact.unreadCount),
    orElse: () => 0,
  );
}
