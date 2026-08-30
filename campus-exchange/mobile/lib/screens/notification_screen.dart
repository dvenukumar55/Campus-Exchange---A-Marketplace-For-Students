import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../models/notification_model.dart';
import '../providers/notification_provider.dart';
import '../routes/app_routes.dart';
import '../services/listing_service.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/error_state_view.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final ListingService _listingService = ListingService();
  bool _isOpeningListing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotificationProvider>(context, listen: false).loadNotifications();
    });
  }

  Future<void> _handleNotificationTap(NotificationModel notif) async {
    final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);

    // Mark as read
    if (!notif.isRead) {
      await notificationProvider.markAsRead(notif.notificationId);
    }

    if (notif.type == 'NEW_LISTING' && notif.listingId.isNotEmpty) {
      if (_isOpeningListing) return;

      setState(() {
        _isOpeningListing = true;
      });

      try {
        final listing = await _listingService.getListingById(notif.listingId);
        if (!mounted) return;

        setState(() {
          _isOpeningListing = false;
        });

        Navigator.pushNamed(
          context,
          AppRoutes.listingDetail,
          arguments: listing,
        );
      } catch (e) {
        if (!mounted) return;

        setState(() {
          _isOpeningListing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('This listing is no longer available.'),
            backgroundColor: AppTheme.warningColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final notificationProvider = Provider.of<NotificationProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Row(
          children: [
            const Text(
              'Notifications',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            if (notificationProvider.unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.royalBlue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${notificationProvider.unreadCount} new',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (notificationProvider.unreadCount > 0)
            TextButton(
              onPressed: () => notificationProvider.markAllAsRead(),
              child: const Text(
                'Mark all read',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.royalBlue,
                ),
              ),
            ),
          const SizedBox(width: 8),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(height: 1, color: AppTheme.dividerColor),
        ),
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () => notificationProvider.loadNotifications(isRefresh: true),
            color: AppTheme.royalBlue,
            child: _buildBody(notificationProvider),
          ),
          if (_isOpeningListing)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody(NotificationProvider provider) {
    if (provider.isLoading && provider.notifications.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: AppTheme.royalBlue,
        ),
      );
    }

    if (provider.errorMessage != null && provider.notifications.isEmpty) {
      return Center(
        child: ErrorStateView(
          message: provider.errorMessage!,
          onRetry: () => provider.loadNotifications(),
        ),
      );
    }

    if (provider.notifications.isEmpty) {
      return const EmptyStateView(
        title: 'No Notifications Yet',
        message: 'You will receive notifications here when peers in your college post new academic items or updates.',
        icon: Icons.notifications_none_rounded,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: provider.notifications.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final notif = provider.notifications[index];
        return _buildNotificationCard(notif);
      },
    );
  }

  Widget _buildNotificationCard(NotificationModel notif) {
    final formattedTime = _formatTimestamp(notif.createdAt);

    return InkWell(
      onTap: () => _handleNotificationTap(notif),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: notif.isRead ? Colors.white : const Color(0xFFF0F7FF),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: notif.isRead ? AppTheme.dividerColor : const Color(0xFFBFDBFE),
            width: notif.isRead ? 1 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: notif.isRead
                  ? const Color(0xFF0F172A).withValues(alpha: 0.02)
                  : const Color(0xFF1E3A8A).withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notification Type Icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: notif.isRead ? const Color(0xFFF1F5F9) : const Color(0xFFDBEAFE),
                shape: BoxShape.circle,
              ),
              child: Icon(
                notif.type == 'NEW_LISTING'
                    ? Icons.inventory_2_outlined
                    : Icons.notifications_active_outlined,
                size: 20,
                color: notif.isRead ? AppTheme.textSecondary : AppTheme.royalBlue,
              ),
            ),

            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notif.title,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: notif.isRead ? FontWeight.w600 : FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      if (!notif.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(left: 6),
                          decoration: const BoxDecoration(
                            color: AppTheme.royalBlue,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notif.message,
                    style: TextStyle(
                      fontSize: 12,
                      color: notif.isRead ? AppTheme.textSecondary : const Color(0xFF1E293B),
                      fontWeight: notif.isRead ? FontWeight.w400 : FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    formattedTime,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${DateFormat.jm().format(date)} • ${DateFormat.MMMd().format(date)}';
    }
  }
}
