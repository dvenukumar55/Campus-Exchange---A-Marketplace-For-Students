import 'package:socket_io_client/socket_io_client.dart' as io;
import '../core/constants/api_constants.dart';
import '../core/storage/secure_storage.dart';
import '../models/message.dart';
import '../models/notification_model.dart';

typedef OnMessageReceived = void Function(Message message);
typedef OnNotificationReceived = void Function(NotificationModel notification);

class SocketService {
  io.Socket? _socket;
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  Future<void> connect() async {
    final token = await SecureStorage.getToken();
    if (token == null || token.isEmpty) return;

    _socket = io.io(
      ApiConstants.socketUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .setAuth({'token': token})
          .build(),
    );

    _socket?.onConnect((_) {
      _isConnected = true;
    });

    _socket?.onDisconnect((_) {
      _isConnected = false;
    });
  }

  void joinListingChat(String listingId) {
    if (_socket != null && _isConnected) {
      _socket?.emit('join_listing_chat', {'listingId': listingId});
    }
  }

  void listenForMessages(OnMessageReceived onMessage) {
    _socket?.on('new_message', (data) {
      if (data is Map<String, dynamic>) {
        onMessage(Message.fromJson(data));
      }
    });
  }

  void listenForNotifications(OnNotificationReceived onNotification) {
    _socket?.on('new_notification', (data) {
      if (data is Map<String, dynamic>) {
        onNotification(NotificationModel.fromJson(data));
      }
    });
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _isConnected = false;
  }
}
