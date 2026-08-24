import 'dart:io';
import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/listing.dart';

class ListingService {
  final ApiClient _apiClient = ApiClient();

  Future<List<Listing>> getListings({
    String? category,
    String? condition,
    String? search,
    int page = 1,
    int limit = 20,
    String sort = 'newest',
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
      'sort': sort,
    };

    if (category != null && category != 'All') {
      queryParams['category'] = category;
    }
    if (condition != null && condition != 'All') {
      queryParams['condition'] = condition;
    }
    if (search != null && search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }

    final response = await _apiClient.get(
      ApiConstants.listings,
      queryParams: queryParams,
    );

    final items = response['items'] as List? ?? [];
    return items.map((json) => Listing.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<List<Listing>> getMyListings() async {
    final response = await _apiClient.get(ApiConstants.myListings);
    final items = response['items'] as List? ?? [];
    return items.map((json) => Listing.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<Listing> getListingById(String listingId) async {
    final response = await _apiClient.get('${ApiConstants.listings}/$listingId');
    return Listing.fromJson(response['listing'] as Map<String, dynamic>);
  }
 Future<String> uploadListingImage(File file) async {
   final response = await _apiClient.uploadFile(
     ApiConstants.uploadImage,
     file,
     fieldName: 'photo',
   );

   final photoRef = response['photoRef'];

   if (photoRef == null || photoRef.toString().isEmpty) {
     throw Exception('Image upload succeeded but no photo reference was returned');
   }

   return photoRef.toString();
 }
  Future<Listing> createListing({
    required String title,
    required String description,
    required String category,
    required double price,
    required String condition,
    required List<String> photoRefs,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.listings,
      body: {
        'title': title,
        'description': description,
        'category': category,
        'price': price,
        'condition': condition,
        'photoRefs': photoRefs,
      },
    );

    return Listing.fromJson(response['listing'] as Map<String, dynamic>);
  }

  Future<Listing> updateListing({
    required String listingId,
    String? title,
    String? description,
    String? category,
    double? price,
    String? condition,
    List<String>? photoRefs,
  }) async {
    final body = <String, dynamic>{};
    if (title != null) body['title'] = title;
    if (description != null) body['description'] = description;
    if (category != null) body['category'] = category;
    if (price != null) body['price'] = price;
    if (condition != null) body['condition'] = condition;
    if (photoRefs != null) body['photoRefs'] = photoRefs;

    final response = await _apiClient.patch(
      '${ApiConstants.listings}/$listingId',
      body: body,
    );

    return Listing.fromJson(response['listing'] as Map<String, dynamic>);
  }

  Future<Listing> closeListing({
    required String listingId,
    required String finalStatus, // 'sold' or 'closed'
    String? closedReason,
  }) async {
    final response = await _apiClient.post(
      '${ApiConstants.listings}/$listingId/close',
      body: {
        'finalStatus': finalStatus,
        if (closedReason != null) 'closedReason': closedReason,
      },
    );

    return Listing.fromJson(response['listing'] as Map<String, dynamic>);
  }
}
