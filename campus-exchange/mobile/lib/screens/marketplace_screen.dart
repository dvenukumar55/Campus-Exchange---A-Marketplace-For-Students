import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/listing_provider.dart';
import '../routes/app_routes.dart';
import '../widgets/category_filter_bar.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/error_state_view.dart';
import '../widgets/listing_card.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({Key? key}) : super(key: key);

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ListingProvider>(
        context,
        listen: false,
      ).fetchListings();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final listingProvider = Provider.of<ListingProvider>(context);

    final student = authProvider.currentStudent;
    final canAccessAdminPanel = student?.canAccessAdminPanel ?? false;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Campus Exchange',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppTheme.textPrimary,
              ),
            ),
            Row(
              children: [
                const Icon(Icons.location_on_rounded, size: 14, color: AppTheme.tealAccent),
                const SizedBox(width: 4),
                Text(
                  student?.collegeName ?? 'AVIH Pilot',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          if (canAccessAdminPanel)
            _buildHeaderIconButton(
              icon: Icons.admin_panel_settings_rounded,
              color: AppTheme.primaryColor,
              onPressed: () => Navigator.pushNamed(context, AppRoutes.adminPanel),
            ),
          _buildHeaderIconButton(
            icon: Icons.analytics_rounded,
            color: AppTheme.tealAccent,
            onPressed: () => Navigator.pushNamed(context, AppRoutes.metricsDashboard),
          ),
          _buildHeaderIconButton(
            icon: Icons.chat_bubble_rounded,
            color: AppTheme.violetAccent,
            onPressed: () => Navigator.pushNamed(context, AppRoutes.chatList),
          ),
          _buildHeaderIconButton(
            icon: Icons.person_rounded,
            color: AppTheme.warningColor,
            onPressed: () => Navigator.pushNamed(context, AppRoutes.profile),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => listingProvider.fetchListings(isRefresh: true),
        color: AppTheme.primaryColor,
        child: Column(
          children: [
            // Search Input Field
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.06),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onSubmitted: (val) {
                    listingProvider.setSearchQuery(val);
                  },
                  decoration: InputDecoration(
                    hintText: 'Search books, lab tools, etc...',
                    prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.primaryColor),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 20),
                            onPressed: () {
                              _searchController.clear();
                              listingProvider.setSearchQuery('');
                              setState(() {});
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppTheme.surfaceColor,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),

            // Category Filter Bar
            CategoryFilterBar(
              categories: AppConstants.categories,
              selectedCategory: listingProvider.selectedCategory,
              onSelected: (cat) {
                listingProvider.setCategory(cat);
              },
            ),

            const SizedBox(height: 12),

            // Listing Feed
            Expanded(
              child: _buildFeed(listingProvider),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.createListing);
        },
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: const Icon(Icons.add_shopping_cart_rounded),
        label: const Text(
          'Sell Item',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildHeaderIconButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: color, size: 22),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildFeed(ListingProvider provider) {
    if (provider.isLoading && provider.listings.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null && provider.listings.isEmpty) {
      return ErrorStateView(
        message: provider.errorMessage!,
        onRetry: () => provider.fetchListings(),
      );
    }

    if (provider.listings.isEmpty) {
      return EmptyStateView(
        title: 'No Listings Found',
        message: 'No active items listed in this category yet. Be the first to list an academic item for your campus peers!',
        icon: Icons.inventory_2_rounded,
        actionLabel: 'Create First Listing',
        onAction: () {
          Navigator.pushNamed(context, AppRoutes.createListing);
        },
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: provider.listings.length,
      itemBuilder: (context, index) {
        final item = provider.listings[index];
        return ListingCard(
          listing: item,
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.listingDetail, arguments: item);
          },
        );
      },
    );
  }
}