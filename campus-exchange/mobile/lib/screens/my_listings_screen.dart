import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../providers/listing_provider.dart';
import '../routes/app_routes.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/listing_card.dart';

class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({Key? key}) : super(key: key);

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ListingProvider>(context, listen: false).fetchMyListings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final listingProvider = Provider.of<ListingProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Posted Listings'),
      ),
      body: listingProvider.isLoading && listingProvider.myListings.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : listingProvider.myListings.isEmpty
              ? EmptyStateView(
                  title: 'No Listings Yet',
                  message: 'You have not listed any academic or hostel items for sale yet.',
                  actionLabel: 'Post an Item',
                  onAction: () => Navigator.pushNamed(context, AppRoutes.createListing),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemCount: listingProvider.myListings.length,
                  itemBuilder: (context, index) {
                    final item = listingProvider.myListings[index];
                    return ListingCard(
                      listing: item,
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.editListing, arguments: item);
                      },
                    );
                  },
                ),
    );
  }
}
