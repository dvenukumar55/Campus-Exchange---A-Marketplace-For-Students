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
      Provider.of<ListingProvider>(context, listen: false).fetchListings();
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

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Campus Exchange',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              authProvider.currentStudent?.collegeName ?? 'AVIH Pilot',
              style: const TextStyle(fontSize: 11, color: Color(0xFF93C5FD)),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings_outlined),
            tooltip: 'Admin Panel',
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.adminPanel);
            },
          ),
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            tooltip: 'Pilot Metrics',
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.metricsDashboard);
            },
          ),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            tooltip: 'Messages',
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.chatList);
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Profile',
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.profile);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => listingProvider.fetchListings(isRefresh: true),
        child: Column(
          children: [
            // Search Input Field
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: _searchController,
                onSubmitted: (val) => listingProvider.setSearchQuery(val),
                decoration: InputDecoration(
                  hintText: 'Search books, lab tools, drawing kits...',
                  prefixIcon: const Icon(Icons.search, color: AppTheme.primaryColor),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            listingProvider.setSearchQuery('');
                          },
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),

            // Category Filter Bar
            CategoryFilterBar(
              categories: AppConstants.categories,
              selectedCategory: listingProvider.selectedCategory,
              onSelected: (cat) => listingProvider.setCategory(cat),
            ),
            const SizedBox(height: 4),

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
        icon: const Icon(Icons.add_shopping_cart),
        label: const Text('Sell Item', style: TextStyle(fontWeight: FontWeight.w600)),
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
        icon: Icons.inventory_2_outlined,
        actionLabel: 'Create First Listing',
        onAction: () => Navigator.pushNamed(context, AppRoutes.createListing),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 80),
      itemCount: provider.listings.length,
      itemBuilder: (context, index) {
        final item = provider.listings[index];
        return ListingCard(
          listing: item,
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRoutes.listingDetail,
              arguments: item,
            );
          },
        );
      },
    );
  }
}
