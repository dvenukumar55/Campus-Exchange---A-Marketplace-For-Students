import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationService _notificationService = NotificationService();

  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _errorMessage;

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Loads student's notifications and updates unread badge count
  Future<void> loadNotifications({bool isRefresh = false}) async {
    if (!isRefresh) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      final result = await _notificationService.getNotifications();
      _notifications = result['notifications'] as List<NotificationModel>;
      _unreadCount = result['unreadCount'] as int;
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetches unread count
  Future<void> loadUnreadCount() async {
    try {
      final count = await _notificationService.getUnreadCount();
      _unreadCount = count;
      notifyListeners();
    } catch (_) {}
  }

  /// Marks a specific notification as read
  Future<void> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.notificationId == notificationId);
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index] = _notifications[index].copyWith(
        isRead: true,
        readAt: DateTime.now(),
      );
      if (_unreadCount > 0) _unreadCount--;
      notifyListeners();

      try {
        await _notificationService.markAsRead(notificationId);
      } catch (_) {}
    }
  }

  /// Marks all notifications as read
  Future<void> markAllAsRead() async {
    if (_unreadCount == 0 && _notifications.every((n) => n.isRead)) return;

    _notifications = _notifications.map((n) => n.copyWith(isRead: true, readAt: DateTime.now())).toList();
    _unreadCount = 0;
    notifyListeners();

    try {
      await _notificationService.markAllAsRead();
    } catch (_) {}
  }

  /// Handles incoming real-time socket notification
  void onRealtimeNotification(NotificationModel notif) {
    // Avoid duplicate
    if (_notifications.any((n) => n.notificationId == notif.notificationId)) return;

    _notifications.insert(0, notif);
    _unreadCount++;
    notifyListeners();
  }
}
