import 'package:flutter/material.dart';
import '../models/listing.dart';
import '../services/listing_service.dart';

class ListingProvider with ChangeNotifier {
  final ListingService _listingService = ListingService();

  List<Listing> _listings = [];
  List<Listing> _myListings = [];
  bool _isLoading = false;
  String? _errorMessage;

  String _selectedCategory = 'All';
  String _selectedCondition = 'All';
  String _searchQuery = '';

  List<Listing> get listings => _listings;
  List<Listing> get myListings => _myListings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedCategory => _selectedCategory;
  String get selectedCondition => _selectedCondition;
  String get searchQuery => _searchQuery;

  Future<void> fetchListings({bool isRefresh = false}) async {
    if (!isRefresh && _listings.isNotEmpty) {
      // Optional cache hit
    }
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _listings = await _listingService.getListings(
        category: _selectedCategory,
        condition: _selectedCondition,
        search: _searchQuery,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMyListings() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _myListings = await _listingService.getMyListings();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void setCategory(String category) {
    if (_selectedCategory != category) {
      _selectedCategory = category;
      fetchListings();
    }
  }

  void setCondition(String condition) {
    if (_selectedCondition != condition) {
      _selectedCondition = condition;
      fetchListings();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    fetchListings();
  }

  Future<Listing> createListing({
    required String title,
    required String description,
    required String category,
    required double price,
    required String condition,
    required List<String> photoRefs,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newListing = await _listingService.createListing(
        title: title,
        description: description,
        category: category,
        price: price,
        condition: condition,
        photoRefs: photoRefs,
      );

      // Prepend to current feed so it displays immediately (Critical test requirement)
      _listings.insert(0, newListing);
      _myListings.insert(0, newListing);

      _isLoading = false;
      notifyListeners();
      return newListing;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<Listing> closeListing(String listingId, String finalStatus) async {
    _isLoading = true;
    notifyListeners();

    try {
      final updated = await _listingService.closeListing(
        listingId: listingId,
        finalStatus: finalStatus,
      );

      // Update in local lists
      _listings.removeWhere((l) => l.listingId == listingId);
      final myIndex = _myListings.indexWhere((l) => l.listingId == listingId);
      if (myIndex != -1) {
        _myListings[myIndex] = updated;
      }

      _isLoading = false;
      notifyListeners();
      return updated;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}
