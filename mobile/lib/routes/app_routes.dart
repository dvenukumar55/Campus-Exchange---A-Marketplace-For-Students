import 'package:flutter/material.dart';
import '../models/listing.dart';
import '../screens/admin_panel_screen.dart';
import '../screens/chat_list_screen.dart';
import '../screens/chat_screen.dart';
import '../screens/create_listing_screen.dart';
import '../screens/edit_listing_screen.dart';
import '../screens/listing_detail_screen.dart';
import '../screens/marketplace_screen.dart';
import '../screens/metrics_dashboard_screen.dart';
import '../screens/my_listings_screen.dart';
import '../screens/notification_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/report_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/verification_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String verification = '/verification';
  static const String marketplace = '/marketplace';
  static const String listingDetail = '/listing-detail';
  static const String createListing = '/create-listing';
  static const String editListing = '/edit-listing';
  static const String myListings = '/my-listings';
  static const String chat = '/chat';
  static const String chatList = '/chat-list';
  static const String notifications = '/notifications';
  static const String report = '/report';
  static const String profile = '/profile';
  static const String metricsDashboard = '/metrics-dashboard';
  static const String adminPanel = '/admin-panel';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case verification:
        return MaterialPageRoute(builder: (_) => const VerificationScreen());
      case marketplace:
        return MaterialPageRoute(builder: (_) => const MarketplaceScreen());
      case listingDetail:
        if (settings.arguments is Listing) {
          return MaterialPageRoute(
            builder: (_) => ListingDetailScreen(
              listing: settings.arguments as Listing,
            ),
          );
        } else if (settings.arguments is String) {
          return MaterialPageRoute(
            builder: (_) => ListingDetailScreen(
              listingId: settings.arguments as String,
            ),
          );
        } else if (settings.arguments is Map<String, dynamic>) {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (_) => ListingDetailScreen(
              listing: args['listing'] as Listing?,
              listingId: args['listingId']?.toString(),
            ),
          );
        }
        return MaterialPageRoute(
          builder: (_) => const ListingDetailScreen(),
        );
      case createListing:
        return MaterialPageRoute(builder: (_) => const CreateListingScreen());
      case editListing:
        final listing = settings.arguments as Listing;
        return MaterialPageRoute(builder: (_) => EditListingScreen(listing: listing));
      case myListings:
        return MaterialPageRoute(builder: (_) => const MyListingsScreen());
      case chat:
        final args = settings.arguments as Map<String, dynamic>;
        final listing = args['listing'] as Listing;
        return MaterialPageRoute(builder: (_) => ChatScreen(listing: listing));
      case chatList:
        return MaterialPageRoute(builder: (_) => const ChatListScreen());
      case notifications:
        return MaterialPageRoute(builder: (_) => const NotificationScreen());
      case report:
        final listing = settings.arguments as Listing;
        return MaterialPageRoute(builder: (_) => ReportScreen(listing: listing));
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case metricsDashboard:
        return MaterialPageRoute(builder: (_) => const MetricsDashboardScreen());
      case adminPanel:
        return MaterialPageRoute(builder: (_) => const AdminPanelScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
