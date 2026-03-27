import 'package:supabase_flutter/supabase_flutter.dart';

/// Utility class to handle and map Supabase authentication errors to user-friendly messages
class AuthErrorHandler {
  /// Maps an exception to a human-readable error message
  static String mapError(dynamic error) {
    if (error is AuthException) {
      switch (error.code) {
        case 'invalid_credentials':
          return 'Incorrect email or password. Please try again.';
        case 'email_not_confirmed':
          return 'Please confirm your email address before logging in.';
        case 'user_not_found':
          return 'No account found with this email.';
        case 'invalid_grant':
          return 'Invalid login credentials.';
        case 'email_exists':
          return 'This email is already registered. Try logging in instead.';
        case 'over_email_send_rate_limit':
          return 'Too many attempts. Please wait a while before trying again.';
        case 'network_error':
          return 'Network error. Please check your internet connection.';
        case 'unexpected_failure':
          return 'An unexpected error occurred. Please try again later.';
        default:
          // Handle specific message-based checks if code is generic
          final message = error.message.toLowerCase();
          if (message.contains('rate limit')) {
            return 'Too many requests. Please wait a few minutes.';
          }
          if (message.contains('invalid login credentials')) {
            return 'Incorrect email or password.';
          }
          return error.message;
      }
    }

    // Fallback for non-AuthException errors
    final errorMessage = error.toString().toLowerCase();

    // Handle Cloudflare 525 (SSL Handshake Failed)
    if (errorMessage.contains('525') ||
        errorMessage.contains('handshake') ||
        errorMessage.contains('ssl')) {
      return 'Connection error (code: 525). Please check if your Supabase project is paused or if your system clock is incorrect.';
    }

    if (errorMessage.contains('network') || errorMessage.contains('socket')) {
      return 'Network error. Please check your connection.';
    }

    return 'An error occurred. Please try again.';
  }
}
