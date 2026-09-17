library display_utils;

/// UI display utility functions for Campus Exchange.
///
/// NOTE: This only affects user-facing string formatting and display.
/// It does NOT alter backend requests, auth payloads, or database storage.

/// Formats an email for UI display only, replacing institutional domain names
/// (.in, .edu.in, .ac.in, etc.) with a clean @gmail.com display format.
String formatDisplayEmail(String? email) {
  if (email == null || email.trim().isEmpty) return '';
  final trimmed = email.trim();
  final atIndex = trimmed.indexOf('@');
  if (atIndex == -1) return trimmed;

  final user = trimmed.substring(0, atIndex);
  final domain = trimmed.substring(atIndex + 1).toLowerCase();

  // If domain ends with .in, .edu.in, .ac.in, or contains institutional markers
  if (domain.endsWith('.in') ||
      domain.endsWith('.edu.in') ||
      domain.endsWith('.ac.in') ||
      domain.contains('avih') ||
      domain.contains('college') ||
      domain.contains('campus') ||
      domain.contains('.edu')) {
    return '$user@gmail.com';
  }
  return trimmed;
}
