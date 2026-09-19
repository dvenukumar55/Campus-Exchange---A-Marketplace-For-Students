import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../constants/api_constants.dart';
import '../error/app_exception.dart';
import '../storage/secure_storage.dart';

class ApiClient {
  static const Duration timeoutDuration = Duration(seconds: 25);

  Future<Map<String, String>> _getHeaders({bool requiresAuth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requiresAuth) {
      final token = await SecureStorage.getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  Future<dynamic> get(
    String endpoint, {
    Map<String, String>? queryParams,
    bool requiresAuth = true,
  }) async {
    try {
      var uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final headers = await _getHeaders(requiresAuth: requiresAuth);
      final response =
          await http.get(uri, headers: headers).timeout(timeoutDuration);

      return _processResponse(response);
    } catch (e) {
      _handleNetworkError(e);
    }
  }

  Future<dynamic> post(
    String endpoint, {
    dynamic body,
    bool requiresAuth = true,
  }) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final headers = await _getHeaders(requiresAuth: requiresAuth);

      final response = await http
          .post(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(timeoutDuration);

      return _processResponse(response);
    } catch (e) {
      _handleNetworkError(e);
    }
  }

  Future<dynamic> patch(
    String endpoint, {
    dynamic body,
    bool requiresAuth = true,
  }) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final headers = await _getHeaders(requiresAuth: requiresAuth);

      final response = await http
          .patch(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(timeoutDuration);

      return _processResponse(response);
    } catch (e) {
      _handleNetworkError(e);
    }
  }

  /// Uploads raw image bytes via multipart/form-data.
  /// Works consistently across Flutter Web, Android, iOS, and Desktop.
  Future<Map<String, dynamic>> uploadBytes(
    String endpoint,
    Uint8List bytes, {
    required String filename,
    String? mimeType,
    String fieldName = 'photo',
    bool requiresAuth = true,
  }) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final request = http.MultipartRequest('POST', uri);

      request.headers['Accept'] = 'application/json';

      if (requiresAuth) {
        final token = await SecureStorage.getToken();
        if (token != null && token.isNotEmpty) {
          request.headers['Authorization'] = 'Bearer $token';
        }
      }

      final mediaType = _resolveMediaType(filename, mimeType);

      request.files.add(
        http.MultipartFile.fromBytes(
          fieldName,
          bytes,
          filename: filename,
          contentType: mediaType,
        ),
      );

      final streamedResponse = await request.send().timeout(timeoutDuration);
      final response = await http.Response.fromStream(streamedResponse);

      return Map<String, dynamic>.from(
        _processResponse(response) as Map,
      );
    } catch (e) {
      _handleNetworkError(e);
      rethrow;
    }
  }

  MediaType _resolveMediaType(String filename, String? mimeType) {
    if (mimeType != null && mimeType.contains('/')) {
      final parts = mimeType.split('/');
      return MediaType(parts[0], parts[1]);
    }

    final ext = filename.split('.').last.toLowerCase();
    switch (ext) {
      case 'png':
        return MediaType('image', 'png');
      case 'webp':
        return MediaType('image', 'webp');
      case 'gif':
        return MediaType('image', 'gif');
      case 'bmp':
        return MediaType('image', 'bmp');
      case 'heic':
        return MediaType('image', 'heic');
      case 'heif':
        return MediaType('image', 'heif');
      case 'tiff':
      case 'tif':
        return MediaType('image', 'tiff');
      case 'svg':
        return MediaType('image', 'svg+xml');
      case 'jpg':
      case 'jpeg':
      default:
        return MediaType('image', 'jpeg');
    }
  }

  dynamic _processResponse(http.Response response) {
    dynamic jsonBody;
    try {
      jsonBody = jsonDecode(response.body);
    } catch (_) {
      jsonBody = null;
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonBody;
    }

    final errorObj =
        jsonBody is Map && jsonBody['error'] is Map ? jsonBody['error'] : null;
    final message =
        errorObj?['message'] ?? 'An error occurred (${response.statusCode})';
    final code = errorObj?['code'] ?? 'UNKNOWN_ERROR';
    final requestId = errorObj?['requestId'];

    if (response.statusCode == 401) {
      throw UnauthorizedException(message, requestId: requestId);
    } else if (response.statusCode == 403) {
      if (code == 'CROSS_COLLEGE_DENIED') {
        throw CrossCollegeException(
          message,
          requestId: requestId,
        );
      } else if (code == 'STUDENT_UNVERIFIED') {
        throw UnverifiedException(message, requestId: requestId);
      }
      throw AppException(message, code: code, requestId: requestId);
    } else if (response.statusCode == 404) {
      throw NotFoundException(message, requestId: requestId);
    } else if (response.statusCode == 409) {
      throw ConflictException(message, requestId: requestId);
    } else {
      throw AppException(
        message,
        code: code,
        requestId: requestId,
      );
    }
  }

  void _handleNetworkError(dynamic e) {
    if (e is AppException) {
      throw e;
    }

    print('API NETWORK ERROR: $e');

    throw NetworkException('Network error: $e');
  }
}
