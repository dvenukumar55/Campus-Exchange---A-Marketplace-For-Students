import 'package:flutter/material.dart';
import '../models/conversation.dart';
import '../models/message.dart';
import '../services/chat_service.dart';
import '../services/socket_service.dart';

class ChatProvider with ChangeNotifier {
  final ChatService _chatService = ChatService();
  final SocketService _socketService = SocketService();

  List<Message> _currentMessages = [];
  List<Conversation> _userConversations = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Message> get currentMessages => _currentMessages;
  List<Conversation> get userConversations => _userConversations;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> initSocket() async {
    await _socketService.connect();
    _socketService.listenForMessages((message) {
      _currentMessages.add(message);
      notifyListeners();
    });
  }

  void joinListing(String listingId) {
    _socketService.joinListingChat(listingId);
  }

  Future<void> fetchMessages(String listingId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentMessages = await _chatService.getMessages(listingId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendMessage({
    required String listingId,
    required String messageText,
    String? conversationId,
  }) async {
    try {
      final msg = await _chatService.sendMessage(
        listingId: listingId,
        message: messageText,
        conversationId: conversationId,
      );

      // Add to local state
      if (!_currentMessages.any((m) => m.messageId == msg.messageId)) {
        _currentMessages.add(msg);
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> fetchUserConversations() async {
    _isLoading = true;
    notifyListeners();

    try {
      _userConversations = await _chatService.getUserConversations();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _socketService.disconnect();
    super.dispose();
  }
}
