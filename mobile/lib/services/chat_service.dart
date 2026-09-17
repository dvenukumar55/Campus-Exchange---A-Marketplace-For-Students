import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/conversation.dart';
import '../models/message.dart';

class ChatService {
  final ApiClient _apiClient = ApiClient();

  Future<List<Message>> getMessages(String listingId) async {
    final response = await _apiClient.get('${ApiConstants.listings}/$listingId/chat');
    final messages = response['messages'] as List? ?? [];
    return messages.map((json) => Message.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<Message> sendMessage({
    required String listingId,
    required String message,
    String? conversationId,
  }) async {
    final response = await _apiClient.post(
      '${ApiConstants.listings}/$listingId/chat',
      body: {
        'message': message,
        if (conversationId != null) 'conversationId': conversationId,
      },
    );

    return Message.fromJson(response['message'] as Map<String, dynamic>);
  }

  Future<List<Conversation>> getUserConversations() async {
    final response = await _apiClient.get(ApiConstants.userChats);
    final items = response['items'] as List? ?? [];
    return items.map((json) => Conversation.fromJson(json as Map<String, dynamic>)).toList();
  }
}
