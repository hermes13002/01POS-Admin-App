import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../models/chat_contact_model.dart';
import '../models/chat_message_model.dart';
import '../sources/chat_remote_source.dart';

/// repository for chat related data
abstract class ChatRepository {
  Future<Either<Failure, List<ChatContact>>> getContacts();
  Future<Either<Failure, List<ChatMessage>>> getMessages(int receiverId);
  Future<Either<Failure, SendMessageResponse>> sendMessage(
    int receiverId,
    String message,
  );
  Future<Either<Failure, void>> markAsRead(int messageId);
  Future<Either<Failure, void>> deleteMessage(int messageId);
}

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteSource _remoteSource;

  ChatRepositoryImpl(this._remoteSource);

  @override
  Future<Either<Failure, List<ChatContact>>> getContacts() async {
    try {
      final contacts = await _remoteSource.fetchContacts();
      return Right(contacts);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ChatMessage>>> getMessages(int receiverId) async {
    try {
      final messages = await _remoteSource.getMessages(receiverId);
      return Right(messages);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, SendMessageResponse>> sendMessage(
    int receiverId,
    String message,
  ) async {
    try {
      final response = await _remoteSource.sendMessage(receiverId, message);
      return Right(response);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead(int messageId) async {
    try {
      await _remoteSource.markAsRead(messageId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteMessage(int messageId) async {
    try {
      await _remoteSource.deleteMessage(messageId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
