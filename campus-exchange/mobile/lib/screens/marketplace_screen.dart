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

  bool _searchFocused = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final listingProvider =
          Provider.of<ListingProvider>(context, listen: false);

      listingProvider.fetchListings();

      final notifProvider =
          Provider.of<NotificationProvider>(context, listen: false);

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
      backgroundColor: const Color(0xFF0B1128),
      appBar: _buildAppBar(
        context,
        canAccessAdminPanel,
        notificationProvider.unreadCount,
        notificationProvider,
      ),
      body: Stack(
        children: [
          Positioned(
            top: -120,
            right: -100,
            child: _glowCircle(
              280,
              const Color(0xFF4338CA),
              0.15,
            ),
          ),
          Positioned(
            bottom: -100,
            left: -80,
            child: _glowCircle(
              300,
              const Color(0xFF2563EB),
              0.12,
            ),
          ),
          RefreshIndicator(
            onRefresh: () => listingProvider.fetchListings(isRefresh: true),
            color: const Color(0xFF38BDF8),
            backgroundColor: const Color(0xFF111936),
            displacement: 20,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                SliverToBoxAdapter(
                  child: _buildTopSection(
                    context,
                    student?.collegeName ?? AppConstants.pilotCollegeName,
                    listingProvider,
                  ),
                ),
                _buildSliverFeed(listingProvider),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 110),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildSellButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _glowCircle(
    double size,
    Color color,
    double opacity,
  ) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: opacity),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    bool canAccessAdminPanel,
    int unreadCount,
    NotificationProvider notificationProvider,
  ) {
    return AppBar(
      backgroundColor: const Color(0xFF0B1128),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      toolbarHeight: 64,
      titleSpacing: 16,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildBrandIcon(),
          const SizedBox(width: 10),
          const Flexible(
            child: Text(
              'Campus Exchange',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.4,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      actions: [
        if (canAccessAdminPanel)
          _buildHeaderAction(
            icon: Icons.admin_panel_settings_rounded,
            color: const Color(0xFFA78BFA),
            tooltip: 'Admin Panel',
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.adminPanel);
            },
          ),
        _buildHeaderAction(
          icon: Icons.notifications_none_rounded,
          color: const Color(0xFF38BDF8),
          tooltip: 'Notifications',
          badgeCount: unreadCount,
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRoutes.notifications,
            ).then((_) {
              notificationProvider.loadUnreadCount();
            });
          },
        ),
        _buildHeaderAction(
          icon: Icons.insights_rounded,
          color: const Color(0xFF2DD4BF),
          tooltip: 'Metrics & Performance',
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.metricsDashboard);
          },
        ),
        _buildHeaderAction(
          icon: Icons.chat_bubble_outline_rounded,
          color: const Color(0xFF818CF8),
          tooltip: 'Messages',
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.chatList);
          },
        ),
        _buildHeaderAction(
          icon: Icons.person_outline_rounded,
          color: const Color(0xFFF472B6),
          tooltip: 'Profile',
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.profile);
          },
        ),
        const SizedBox(width: 8),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
    );
  }

  Widget _buildBrandIcon() {
    return Container(
      width: 36,
      height: 36,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [
            Color(0xFF38BDF8),
            Color(0xFF6366F1),
            Color(0xFF8B5CF6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF111936),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.school_rounded,
          color: Colors.white,
          size: 18,
        ),
      ),
    );
  }

  Widget _buildHeaderAction({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onTap,
    int badgeCount = 0,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          IconButton(
            tooltip: tooltip,
            onPressed: onTap,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            splashRadius: 20,
            icon: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: color.withValues(alpha: 0.25),
                  width: 1,
                ),
              ),
              child: Icon(
                icon,
                color: color,
                size: 18,
              ),
            ),
          ),
          if (badgeCount > 0)
            Positioned(
              top: 2,
              right: 0,
              child: Container(
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 3,
                  vertical: 1,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE11D48),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF0B1128),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  badgeCount > 9 ? '9+' : '$badgeCount',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTopSection(
    BuildContext context,
    String collegeName,
    ListingProvider provider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildWelcomeSection(),
        _buildCollegeCard(collegeName),
        const SizedBox(height: 14),
        _buildSearchBar(provider),
        const SizedBox(height: 16),
        _buildSectionTitle(
          title: 'BROWSE CATEGORIES',
          action: provider.selectedCategory == 'All'
              ? null
              : () {
                  provider.setCategory('All');
                },
        ),
        const SizedBox(height: 8),
        CategoryFilterBar(
          categories: AppConstants.categories,
          selectedCategory: provider.selectedCategory,
          onSelected: provider.setCategory,
        ),
        const SizedBox(height: 14),
        _buildTrustBanner(),
        const SizedBox(height: 18),
        _buildListingsHeader(provider),
        const SizedBox(height: 6),
      ],
    );
  }

  Widget _buildWelcomeSection() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(18, 18, 18, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Campus Marketplace',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.6,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Buy, sell and exchange usable items with verified peers.',
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: Color(0xFF94A3B8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollegeCard(String collegeName) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF111936),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF1E1B4B),
                  Color(0xFF312E81),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF6366F1).withValues(alpha: 0.3),
              ),
            ),
            child: const Icon(
              Icons.location_on_rounded,
              color: Color(0xFF60A5FA),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'YOUR CAMPUS',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.9,
                    color: Color(0xFF818CF8),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  collegeName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: const Color(0x2B22C55E),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0x5922C55E),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.verified_rounded,
                  size: 13,
                  color: Color(0xFF22C55E),
                ),
                SizedBox(width: 4),
                Text(
                  'VERIFIED',
                  style: TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF86EFAC),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ListingProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Focus(
        onFocusChange: (focused) {
          if (mounted) {
            setState(() {
              _searchFocused = focused;
            });
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: const Color(0xFF0B1228),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: _searchFocused
                  ? const Color(0xFF6366F1)
                  : Colors.white.withValues(alpha: 0.08),
              width: _searchFocused ? 1.4 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: _searchFocused
                    ? const Color(0xFF6366F1).withValues(alpha: 0.18)
                    : Colors.black.withValues(alpha: 0.2),
                blurRadius: _searchFocused ? 16 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            textInputAction: TextInputAction.search,
            onSubmitted: provider.setSearchQuery,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            decoration: InputDecoration(
              hintText: 'Search books, drafters, calculators, cycles...',
              hintStyle: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
              ),
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: Color(0xFF60A5FA),
                size: 21,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      tooltip: 'Clear search',
                      onPressed: () {
                        _searchController.clear();
                        provider.setSearchQuery('');
                        setState(() {});
                      },
                      icon: const Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: Color(0xFF94A3B8),
                      ),
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
            ),
            onChanged: (_) {
              if (mounted) {
                setState(() {});
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle({
    required String title,
    VoidCallback? action,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: Color(0xFFCBD5E1),
            ),
          ),
          const Spacer(),
          if (action != null)
            TextButton(
              onPressed: action,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: const Size(0, 30),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Show all',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF60A5FA),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTrustBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF062E28),
            Color(0xFF0F3830),
          ],
        ),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: const Color(0xFF10B981).withValues(alpha: 0.3),
        ),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.shield_rounded,
            color: Color(0xFF34D399),
            size: 19,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Verified campus-only marketplace. Direct peer-to-peer exchange.',
              style: TextStyle(
                fontSize: 11,
                height: 1.35,
                fontWeight: FontWeight.w700,
                color: Color(0xFFA7F3D0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListingsHeader(ListingProvider provider) {
    final title = provider.selectedCategory == 'All'
        ? 'Campus Listings'
        : provider.selectedCategory;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.4,
                color: Colors.white,
              ),
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: Container(
              key: ValueKey(provider.listings.length),
              padding: const EdgeInsets.symmetric(
                horizontal: 9,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF17224D),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                '${provider.listings.length} available',
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF818CF8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSellButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.buttonGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.glowButtonShadow,
      ),
      child: FloatingActionButton.extended(
        heroTag: 'marketplace_sell_button',
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.createListing);
        },
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        highlightElevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        icon: const Icon(
          Icons.add_rounded,
          size: 20,
        ),
        label: const Text(
          'Sell Item',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.1,
          ),
        ),
      ),
    );
  }

  Widget _buildSliverFeed(ListingProvider provider) {
    if (provider.isLoading && provider.listings.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Padding(
            padding: EdgeInsets.only(top: 40),
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: Color(0xFF60A5FA),
            ),
          ),
        ),
      );
    }

    if (provider.errorMessage != null && provider.listings.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: ErrorStateView(
          message: provider.errorMessage!,
          onRetry: () => provider.fetchListings(),
        ),
      );
    }

    if (provider.listings.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: EmptyStateView(
          title: 'No Listings Found',
          message:
              'No active items are available in this category yet. Be the first to list something useful for your campus peers!',
          icon: Icons.inventory_2_outlined,
          actionLabel: 'Create First Listing',
          onAction: () {
            Navigator.pushNamed(
              context,
              AppRoutes.createListing,
            );
          },
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.only(
        top: 8,
        left: 12,
        right: 12,
      ),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final item = provider.listings[index];

            return TweenAnimationBuilder<double>(
              key: ValueKey(item),
              duration: Duration(
                milliseconds: 280 + (index.clamp(0, 5) * 45),
              ),
              curve: Curves.easeOutCubic,
              tween: Tween(
                begin: 0,
                end: 1,
              ),
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(
                    0,
                    14 * (1 - value),
                  ),
                  child: Opacity(
                    opacity: value,
                    child: child,
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: ListingCard(
                  listing: item,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.listingDetail,
                      arguments: item,
                    );
                  },
                ),
              ),
            );
          },
          childCount: provider.listings.length,
        ),
      ),
    );
  }
}
