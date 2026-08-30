import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/notification_model.dart';

class NotificationService {
  final ApiClient _apiClient = ApiClient();

  /// Retrieves paginated notifications
  Future<Map<String, dynamic>> getNotifications({int page = 1, int limit = 50}) async {
    final response = await _apiClient.get(
      ApiConstants.notifications,
      queryParams: {
        'page': page.toString(),
        'limit': limit.toString(),
      },
    );

    final rawList = (response['notifications'] as List?) ?? [];
    final notifications = rawList
        .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
        .toList();

    final unreadCount = (response['unreadCount'] as num?)?.toInt() ?? 0;

    return {
      'notifications': notifications,
      'unreadCount': unreadCount,
    };
  }

  /// Retrieves unread notification count
  Future<int> getUnreadCount() async {
    try {
      final response = await _apiClient.get(ApiConstants.unreadNotificationsCount);
      return (response['unreadCount'] as num?)?.toInt() ?? 0;
    } catch (_) {
      return 0;
    }
  }

  /// Marks a specific notification as read
  Future<void> markAsRead(String notificationId) async {
    await _apiClient.patch('${ApiConstants.notifications}/$notificationId/read');
  }

  /// Marks all notifications as read
  Future<void> markAllAsRead() async {
    await _apiClient.patch('${ApiConstants.notifications}/read-all');
  }
}
