import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/listing_provider.dart';
import '../providers/notification_provider.dart';
import '../routes/app_routes.dart';
import '../services/socket_service.dart';
import '../widgets/category_filter_bar.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/error_state_view.dart';
import '../widgets/listing_card.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  final TextEditingController _searchController = TextEditingController();
  final SocketService _socketService = SocketService();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ListingProvider>(
        context,
        listen: false,
      ).fetchListings();

      final notifProvider = Provider.of<NotificationProvider>(context, listen: false);
      notifProvider.loadUnreadCount();

      _socketService.connect().then((_) {
        _socketService.listenForNotifications((notif) {
          notifProvider.onRealtimeNotification(notif);
        });
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _socketService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final listingProvider = Provider.of<ListingProvider>(context);
    final notificationProvider = Provider.of<NotificationProvider>(context);

    final student = authProvider.currentStudent;
    final canAccessAdminPanel = student?.canAccessAdminPanel ?? false;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        titleSpacing: 12,
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F2744), Color(0xFF1E3A8A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1E3A8A).withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.school_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
            const Flexible(
              child: Text(
                'Campus Exchange',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.4,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
          ],
        ),
        actions: [
          if (canAccessAdminPanel)
            _buildHeaderIconButton(
              icon: Icons.admin_panel_settings_outlined,
              tooltip: 'Admin Panel',
              badgeColor: const Color(0xFF38BDF8),
              onPressed: () => Navigator.pushNamed(context, AppRoutes.adminPanel),
            ),
          _buildHeaderIconButton(
            icon: Icons.notifications_none_rounded,
            tooltip: 'Notifications',
            badgeCount: notificationProvider.unreadCount,
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.notifications).then((_) {
                notificationProvider.loadUnreadCount();
              });
            },
          ),
          _buildHeaderIconButton(
            icon: Icons.analytics_outlined,
            tooltip: 'Metrics',
            onPressed: () => Navigator.pushNamed(context, AppRoutes.metricsDashboard),
          ),
          _buildHeaderIconButton(
            icon: Icons.chat_bubble_outline_rounded,
            tooltip: 'Messages',
            onPressed: () => Navigator.pushNamed(context, AppRoutes.chatList),
          ),
          _buildHeaderIconButton(
            icon: Icons.person_outline_rounded,
            tooltip: 'Profile',
            onPressed: () => Navigator.pushNamed(context, AppRoutes.profile),
          ),
          const SizedBox(width: 4),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(height: 1, color: AppTheme.dividerColor),
        ),
      ),


      body: RefreshIndicator(
        onRefresh: () => listingProvider.fetchListings(isRefresh: true),
        color: AppTheme.royalBlue,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Top Multi-tier Section Container
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. College Context Card
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.dividerColor),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.location_on_rounded,
                            size: 16,
                            color: AppTheme.royalBlue,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                student?.collegeName ?? AppConstants.pilotCollegeName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const Text(
                                'Exclusive Verified Student Exchange',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppTheme.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFA7F3D0)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle_rounded, size: 10, color: AppTheme.successColor),
                              SizedBox(width: 3),
                              Text(
                                'PILOT',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF047857),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 2. Search Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.dividerColor),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        onSubmitted: (val) {
                          listingProvider.setSearchQuery(val);
                        },
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        decoration: InputDecoration(
                          hintText: 'Search books, lab tools, calculators...',
                          hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                          filled: false,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          prefixIcon: Container(
                            margin: const EdgeInsets.only(left: 12, right: 8),
                            child: const Icon(Icons.search_rounded, color: AppTheme.royalBlue, size: 22),
                          ),
                          prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded, size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                    listingProvider.setSearchQuery('');
                                    setState(() {});
                                  },
                                )
                              : null,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),
                  ),

                  // 3. Category Filter Bar
                  const SizedBox(height: 8),
                  CategoryFilterBar(
                    categories: AppConstants.categories,
                    selectedCategory: listingProvider.selectedCategory,
                    onSelected: (cat) {
                      listingProvider.setCategory(cat);
                    },
                  ),

                  // 4. Campus Trust & Safety Banner
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                    decoration: BoxDecoration(
                      gradient: AppTheme.trustGradient,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFA7F3D0)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.shield_rounded, size: 16, color: AppTheme.successColor),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Campus Exclusive: 100% Peer-to-peer verified exchange inside college.',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF065F46),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 5. Listing Count & Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 12, 18, 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          listingProvider.selectedCategory == 'All'
                              ? 'Campus Listings'
                              : listingProvider.selectedCategory,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                            letterSpacing: -0.2,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppTheme.dividerColor),
                          ),
                          child: Text(
                            '${listingProvider.listings.length} available',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.royalBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 6. Listings Feed or States
            _buildSliverFeed(listingProvider),

            // Bottom Spacing for Floating Sell Button
            const SliverToBoxAdapter(
              child: SizedBox(height: 90),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.buttonGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppTheme.glowButtonShadow,
        ),
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.createListing);
          },
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          highlightElevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          icon: const Icon(Icons.add_shopping_cart_rounded, size: 19),
          label: const Text(
            'Sell Item',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, letterSpacing: 0.2),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderIconButton({
    required IconData icon,
    required String tooltip,
    Color? badgeColor,
    int badgeCount = 0,
    required VoidCallback onPressed,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 1),
      child: Stack(
        alignment: Alignment.center,
        children: [
          IconButton(
            icon: Icon(icon, color: badgeColor ?? AppTheme.textPrimary, size: 20),
            tooltip: tooltip,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
            visualDensity: VisualDensity.compact,
            onPressed: onPressed,
          ),
          if (badgeCount > 0)
            Positioned(
              right: 0,
              top: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: AppTheme.royalBlue,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white, width: 1.5),
                ),

                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Text(
                  badgeCount > 99 ? '99+' : '$badgeCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }


  Widget _buildSliverFeed(ListingProvider provider) {
    if (provider.isLoading && provider.listings.isEmpty) {
      return const SliverFillRemaining(
        child: Center(
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
      );
    }

    if (provider.errorMessage != null && provider.listings.isEmpty) {
      return SliverFillRemaining(
        child: ErrorStateView(
          message: provider.errorMessage!,
          onRetry: () => provider.fetchListings(),
        ),
      );
    }

    if (provider.listings.isEmpty) {
      return SliverFillRemaining(
        child: EmptyStateView(
          title: 'No Listings Found',
          message: 'No active items listed in this category yet. Be the first to list an academic item for your campus peers!',
          icon: Icons.inventory_2_outlined,
          actionLabel: 'Create First Listing',
          onAction: () {
            Navigator.pushNamed(context, AppRoutes.createListing);
          },
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final item = provider.listings[index];
          return ListingCard(
            listing: item,
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.listingDetail, arguments: item);
            },
          );
        },
        childCount: provider.listings.length,
      ),
    );
  }
}