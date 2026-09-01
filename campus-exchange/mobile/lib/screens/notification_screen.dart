import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

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
      Provider.of<NotificationProvider>(
        context,
        listen: false,
      ).loadNotifications();
    });
  }

  Future<void> _handleNotificationTap(NotificationModel notif) async {
    final notificationProvider = Provider.of<NotificationProvider>(
      context,
      listen: false,
    );

    if (!notif.isRead) {
      await notificationProvider.markAsRead(notif.notificationId);
    }

    if (notif.type == 'NEW_LISTING' && notif.listingId.isNotEmpty) {
      if (_isOpeningListing) return;

      setState(() {
        _isOpeningListing = true;
      });

      try {
        final listing = await _listingService.getListingById(
          notif.listingId,
        );

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
          SnackBar(
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            content: const Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'This listing is no longer available.',
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFFB923C),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final notificationProvider = Provider.of<NotificationProvider>(context);

    final unreadCount = notificationProvider.unreadCount;

    return Scaffold(
      backgroundColor: const Color(0xFF0B1128),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1128),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 68,
        leadingWidth: 56,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: _buildBackButton(),
        ),
        titleSpacing: 4,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Notifications',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -0.4,
                height: 1.1,
              ),
            ),
            if (unreadCount > 0) ...[
              const SizedBox(height: 3),
              Text(
                '$unreadCount unread ${unreadCount == 1 ? 'notification' : 'notifications'}',
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF60A5FA),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (unreadCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: _buildMarkAllButton(
                onPressed: () {
                  notificationProvider.markAllAsRead();
                },
              ),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.08),
          ),
        ),
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () => notificationProvider.loadNotifications(
              isRefresh: true,
            ),
            color: const Color(0xFF60A5FA),
            backgroundColor: const Color(0xFF111936),
            displacement: 18,
            child: _buildBody(notificationProvider),
          ),
          if (_isOpeningListing) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111936),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: IconButton(
        tooltip: 'Back',
        icon: const Icon(
          Icons.arrow_back_rounded,
          color: Colors.white,
          size: 19,
        ),
        onPressed: () => Navigator.maybePop(context),
      ),
    );
  }

  Widget _buildMarkAllButton({
    required VoidCallback onPressed,
  }) {
    return Material(
      color: const Color(0xFF6366F1).withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(11),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(11),
        child: const Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 11,
            vertical: 8,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.done_all_rounded,
                size: 16,
                color: Color(0xFF818CF8),
              ),
              SizedBox(width: 5),
              Text(
                'Mark read',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF818CF8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.6),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 22,
              vertical: 18,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF111936),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.3,
                    color: Color(0xFF60A5FA),
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  'Opening listing...',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(NotificationProvider provider) {
    if (provider.isLoading && provider.notifications.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: Color(0xFF60A5FA),
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
        message:
            'You will receive notifications here when peers in your college post new academic items or updates.',
        icon: Icons.notifications_none_rounded,
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
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
    final isUnread = !notif.isRead;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: isUnread ? const Color(0xFF131D3F) : const Color(0xFF111936),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isUnread
              ? const Color(0xFF6366F1).withValues(alpha: 0.35)
              : Colors.white.withValues(alpha: 0.08),
          width: isUnread ? 1.2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isUnread ? 0.28 : 0.18),
            blurRadius: isUnread ? 14 : 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: () => _handleNotificationTap(notif),
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildNotificationIcon(notif),
                const SizedBox(width: 13),
                Expanded(
                  child: _buildNotificationContent(
                    notif,
                    formattedTime,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(NotificationModel notif) {
    final isUnread = !notif.isRead;

    final isListing = notif.type == 'NEW_LISTING';

    final icon = isListing
        ? Icons.inventory_2_rounded
        : Icons.notifications_active_rounded;

    final background = isUnread
        ? const Color(0xFF6366F1).withValues(alpha: 0.18)
        : const Color(0xFF0B1228);

    final iconColor =
        isUnread ? const Color(0xFF60A5FA) : const Color(0xFF94A3B8);

    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isUnread
              ? const Color(0xFF6366F1).withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Icon(
        icon,
        size: 21,
        color: iconColor,
      ),
    );
  }

  Widget _buildNotificationContent(
    NotificationModel notif,
    String formattedTime,
  ) {
    final isUnread = !notif.isRead;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                notif.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: isUnread ? FontWeight.w800 : FontWeight.w700,
                  color: Colors.white,
                  height: 1.25,
                  letterSpacing: -0.15,
                ),
              ),
            ),
            if (isUnread) ...[
              const SizedBox(width: 8),
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF38BDF8),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF38BDF8).withValues(alpha: 0.6),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        Text(
          notif.message,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12.2,
            color: isUnread ? const Color(0xFFCBD5E1) : const Color(0xFF94A3B8),
            fontWeight: isUnread ? FontWeight.w500 : FontWeight.w400,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 9),
        Row(
          children: [
            const Icon(
              Icons.schedule_rounded,
              size: 13,
              color: Color(0xFF64748B),
            ),
            const SizedBox(width: 4),
            Text(
              formattedTime,
              style: const TextStyle(
                fontSize: 10.5,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w600,
              ),
            ),
            if (notif.type == 'NEW_LISTING') ...[
              const SizedBox(width: 9),
              Container(
                width: 3,
                height: 3,
                decoration: const BoxDecoration(
                  color: Color(0xFF64748B),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 9),
              const Text(
                'Tap to view',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF60A5FA),
                ),
              ),
            ],
          ],
        ),
      ],
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
