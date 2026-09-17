import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../core/constants/api_constants.dart';
import '../core/theme/app_theme.dart';
import '../models/listing.dart';
import '../providers/auth_provider.dart';
import '../routes/app_routes.dart';
import '../services/listing_service.dart';
import '../widgets/condition_badge.dart';
import '../widgets/error_state_view.dart';
import '../widgets/status_badge.dart';

class ListingDetailScreen extends StatefulWidget {
  final Listing? listing;
  final String? listingId;

  const ListingDetailScreen({
    super.key,
    this.listing,
    this.listingId,
  });

  @override
  State<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends State<ListingDetailScreen> {
  final ListingService _listingService = ListingService();
  Listing? _listing;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isNotFound = false;

  @override
  void initState() {
    super.initState();
    _listing = widget.listing;

    final targetId = widget.listing?.listingId ?? widget.listingId;
    if (_listing == null && targetId != null && targetId.isNotEmpty) {
      _fetchListingDetails(targetId);
    }
  }

  Future<void> _fetchListingDetails(String listingId) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _isNotFound = false;
    });

    try {
      final fetched = await _listingService.getListingById(listingId);
      if (!mounted) return;
      setState(() {
        _listing = fetched;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      final errorStr = e.toString().toLowerCase();
      final notFound = errorStr.contains('404') ||
          errorStr.contains('not found') ||
          errorStr.contains('could not be found') ||
          errorStr.contains('unavailable');

      setState(() {
        _isLoading = false;
        if (notFound) {
          _isNotFound = true;
        } else {
          _errorMessage = e.toString();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (_isLoading && _listing == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0B1128),
        appBar: _buildBasicAppBar(context),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Color(0xFF60A5FA),
              ),
              SizedBox(height: 16),
              Text(
                'Loading listing details...',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_isNotFound && _listing == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0B1128),
        appBar: _buildBasicAppBar(context),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFB923C).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFFB923C).withValues(alpha: 0.35),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.inventory_2_outlined,
                    size: 40,
                    color: Color(0xFFFB923C),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Listing unavailable',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'This listing may have been removed, closed by the seller, or is no longer available.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(height: 28),
                ElevatedButton.icon(
                  onPressed: () => Navigator.maybePop(context),
                  icon: const Icon(Icons.arrow_back_rounded, size: 18),
                  label: const Text(
                    'Go Back',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E293B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 13,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_errorMessage != null && _listing == null) {
      final targetId = widget.listing?.listingId ?? widget.listingId ?? '';
      return Scaffold(
        backgroundColor: const Color(0xFF0B1128),
        appBar: _buildBasicAppBar(context),
        body: Center(
          child: ErrorStateView(
            message: _errorMessage!,
            onRetry: () => _fetchListingDetails(targetId),
          ),
        ),
      );
    }

    final listing = _listing!;
    final isSeller = authProvider.currentStudent?.studentId == listing.sellerId;
    final formattedDate = DateFormat.yMMMMd().format(listing.createdAt);
    final categoryColor = _getCategoryAccentColor(listing.category);

    return Scaffold(
      backgroundColor: const Color(0xFF0B1128),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1128),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          'Item Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          if (!isSeller)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                tooltip: 'Report Listing',
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.report,
                    arguments: listing,
                  );
                },
                icon: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE11D48).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(
                      color: const Color(0xFFE11D48).withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Icon(
                    Icons.flag_outlined,
                    color: Color(0xFFFB7185),
                    size: 18,
                  ),
                ),
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
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: RefreshIndicator(
              onRefresh: () => _fetchListingDetails(listing.listingId),
              color: const Color(0xFF60A5FA),
              backgroundColor: const Color(0xFF111936),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.only(bottom: 110),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeroSection(listing, categoryColor),
                    _buildMainInformation(
                      context,
                      listing,
                      categoryColor,
                      formattedDate,
                    ),
                    _buildDescriptionSection(listing),
                    _buildSellerSection(listing, categoryColor),
                    _buildSafetySection(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomAction(context, listing, isSeller),
    );
  }

  PreferredSizeWidget _buildBasicAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF0B1128),
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        tooltip: 'Back',
        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        onPressed: () => Navigator.maybePop(context),
      ),
      title: const Text(
        'Item Details',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: -0.3,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
    );
  }

  Widget _buildHeroSection(Listing listing, Color categoryColor) {
    return Container(
      height: 230,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            categoryColor.withValues(alpha: 0.22),
            const Color(0xFF111936),
            const Color(0xFF0B1128),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.08),
          ),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -40,
            right: -30,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: categoryColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -30,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          if (listing.photoRefs.isNotEmpty)
            Positioned.fill(
              child: Image.network(
                '${ApiConstants.uploadsUrl}/${listing.photoRefs.first}',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildCategoryIconHeroFallback(
                  listing,
                  categoryColor,
                ),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return _buildCategoryIconHeroFallback(listing, categoryColor);
                },
              ),
            )
          else
            _buildCategoryIconHeroFallback(listing, categoryColor),
          Positioned(
            top: 16,
            left: 16,
            child: ConditionBadge(
              condition: listing.condition,
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: StatusBadge(
              status: listing.status,
            ),
          ),
          Positioned(
            bottom: 14,
            left: 16,
            child: _buildHeroLabel(
              icon: Icons.verified_rounded,
              text: 'Campus Verified',
              color: categoryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryIconHeroFallback(Listing listing, Color categoryColor) {
    return Center(
      child: Container(
        width: 110,
        height: 110,
        decoration: BoxDecoration(
          color: const Color(0xFF111936),
          shape: BoxShape.circle,
          border: Border.all(
            color: categoryColor.withValues(alpha: 0.35),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: categoryColor.withValues(alpha: 0.3),
              blurRadius: 28,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Icon(
          _getCategoryIcon(listing.category),
          size: 48,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildHeroLabel({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1128).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: color,
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainInformation(
    BuildContext context,
    Listing listing,
    Color categoryColor,
    String formattedDate,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: categoryColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: categoryColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    listing.category.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w900,
                      color: categoryColor,
                      letterSpacing: 0.7,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Listed $formattedDate',
                textAlign: TextAlign.end,
                style: const TextStyle(
                  fontSize: 11.5,
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            listing.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.5,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '₹${listing.price.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3.5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF17224D),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.25),
                  ),
                ),
                child: const Text(
                  'FIXED PRICE',
                  style: TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF818CF8),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF111936),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: categoryColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.local_offer_rounded,
                    size: 16,
                    color: categoryColor,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Listed inside your verified campus marketplace',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFFCBD5E1),
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                ),
                Icon(
                  Icons.verified_rounded,
                  size: 17,
                  color: categoryColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(Listing listing) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            icon: Icons.description_outlined,
            title: 'Item Description',
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF111936),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              listing.description.isNotEmpty
                  ? listing.description
                  : 'No detailed description provided by seller.',
              style: const TextStyle(
                fontSize: 13.5,
                color: Color(0xFFCBD5E1),
                height: 1.6,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSellerSection(Listing listing, Color categoryColor) {
    final sellerInitial = listing.sellerName.isNotEmpty
        ? listing.sellerName.substring(0, 1).toUpperCase()
        : '?';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            icon: Icons.person_outline_rounded,
            title: 'Seller Information',
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF111936),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        categoryColor,
                        categoryColor.withValues(alpha: 0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: categoryColor.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      sellerInitial,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        listing.sellerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Color(0x2B22C55E),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              size: 11,
                              color: Color(0xFF22C55E),
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Text(
                            'Verified Campus Peer',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF86EFAC),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle({
    required IconData icon,
    required String title,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFF17224D),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: const Color(0xFF60A5FA),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildSafetySection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF062E28),
              Color(0xFF0F3830),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF10B981).withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.shield_rounded,
                size: 20,
                color: Color(0xFF34D399),
              ),
            ),
            const SizedBox(width: 11),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Campus Peer Exchange Safety',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFA7F3D0),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Meet in a safe campus location such as the library, canteen, or student lounge. Inspect the item before completing the handover.',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF6EE7B7),
                      height: 1.45,
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

  Widget _buildBottomAction(
    BuildContext context,
    Listing listing,
    bool isSeller,
  ) {
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            decoration: BoxDecoration(
              color: const Color(0xFF0B1128),
              border: Border(
                top: BorderSide(
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: isSeller
                ? SizedBox(
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.editListing,
                          arguments: listing,
                        );
                      },
                      icon: const Icon(
                        Icons.edit_outlined,
                        size: 19,
                      ),
                      label: const Text(
                        'Manage My Listing',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF60A5FA),
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.15),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  )
                : SizedBox(
                    height: 50,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient:
                            listing.isActive ? AppTheme.buttonGradient : null,
                        color:
                            listing.isActive ? null : const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow:
                            listing.isActive ? AppTheme.glowButtonShadow : null,
                      ),
                      child: ElevatedButton.icon(
                        onPressed: listing.isActive
                            ? () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.chat,
                                  arguments: {
                                    'listing': listing,
                                    'listingId': listing.listingId,
                                  },
                                );
                              }
                            : null,
                        icon: const Icon(
                          Icons.chat_bubble_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                        label: Text(
                          listing.isActive
                              ? 'Chat with Seller'
                              : 'Item Unavailable',
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          disabledBackgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    final value = category.toLowerCase();

    if (value == 'all') {
      return Icons.grid_view_rounded;
    }

    if (value.contains('book') || value.contains('academic')) {
      return Icons.menu_book_rounded;
    }

    if (value.contains('calculator')) {
      return Icons.calculate_rounded;
    }

    if (value.contains('drawing') || value.contains('graphics')) {
      return Icons.architecture_rounded;
    }

    if (value.contains('lab')) {
      return Icons.biotech_rounded;
    }

    if (value.contains('hostel')) {
      return Icons.bed_rounded;
    }

    if (value.contains('electronic')) {
      return Icons.devices_rounded;
    }

    if (value.contains('uniform') || value.contains('apron')) {
      return Icons.checkroom_rounded;
    }

    if (value.contains('sport')) {
      return Icons.sports_basketball_rounded;
    }

    return Icons.inventory_2_rounded;
  }

  Color _getCategoryAccentColor(String category) {
    final value = category.toLowerCase();

    if (value == 'all') {
      return const Color(0xFF6366F1);
    }

    if (value.contains('book') || value.contains('academic')) {
      return const Color(0xFF818CF8);
    }

    if (value.contains('calculator')) {
      return const Color(0xFF38BDF8);
    }

    if (value.contains('drawing') || value.contains('graphics')) {
      return const Color(0xFFA78BFA);
    }

    if (value.contains('lab')) {
      return const Color(0xFF2DD4BF);
    }

    if (value.contains('hostel')) {
      return const Color(0xFFFB923C);
    }

    if (value.contains('electronic')) {
      return const Color(0xFF60A5FA);
    }

    if (value.contains('uniform') || value.contains('apron')) {
      return const Color(0xFFF472B6);
    }

    if (value.contains('sport')) {
      return const Color(0xFFFB7185);
    }

    return const Color(0xFF6366F1);
  }
}
