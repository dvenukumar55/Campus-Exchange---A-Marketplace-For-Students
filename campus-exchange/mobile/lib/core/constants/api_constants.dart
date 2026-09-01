import 'package:flutter/foundation.dart';

class ApiConstants {
  // In web environment use localhost; in Android emulator use 10.0.2.2
  static String get baseUrl => kIsWeb ? 'http://localhost:5000/api/v1' : 'http://10.0.2.2:5000/api/v1';
  static String get socketUrl => kIsWeb ? 'http://localhost:5000' : 'http://10.0.2.2:5000';
  static String get uploadsUrl => kIsWeb ? 'http://localhost:5000/uploads' : 'http://10.0.2.2:5000/uploads';

  // Auth endpoints
  static const String requestOtp = '/auth/request-otp';
  static const String verifyOtp = '/auth/verify-otp';
  static const String completeRegistration = '/auth/complete-registration';
  static const String verifyAuth = '/auth/verify';
  static const String getProfile = '/auth/me';
  static const String logout = '/auth/logout';

  // Listings endpoints
  static const String listings = '/listings';
  static const String myListings = '/listings/my';
  static const String uploadImage = '/listings/upload-image';

  // Admin
  static const String admin = '/admin';

  // Chat & Reports & Notifications
  static const String userChats = '/chats';
  static const String reports = '/reports';
  static const String notifications = '/notifications';
  static const String unreadNotificationsCount = '/notifications/unread-count';


  // Telemetry & Metrics
  static const String events = '/events';
  static const String metrics = '/metrics';
  static const String health = '/health';
}
