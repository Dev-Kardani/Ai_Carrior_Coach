import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ai_career_coach/core/theme/app_colors.dart';
import 'package:ai_career_coach/core/utils/debug_logger.dart';

class ErrorHandler {
  /// Show a success SnackBar
  static void showSuccess(BuildContext context, String message) {
    _showSnackBar(
      context,
      message,
      backgroundColor: AppColors.success,
      icon: Icons.check_circle_outline,
    );
  }

  /// Show an error SnackBar
  static void showError(BuildContext context, String message,
      {Duration? duration}) {
    DebugLogger.failed('ERROR_HANDLER', 'SHOW_ERROR', message);
    _showSnackBar(
      context,
      message,
      backgroundColor: AppColors.error,
      icon: Icons.error_outline,
      duration: duration ?? const Duration(seconds: 4),
    );
  }

  /// Show a warning SnackBar
  static void showWarning(BuildContext context, String message) {
    _showSnackBar(
      context,
      message,
      backgroundColor: AppColors.warning,
      icon: Icons.warning_amber_rounded,
      color: Colors.white,
    );
  }

  /// Format error objects into user-friendly strings
  static String formatError(dynamic error) {
    final formatted = _getFormattedMessage(error);
    DebugLogger.warning('ERROR_HANDLER', 'FORMAT_ERROR', formatted);
    return formatted;
  }

  static String _getFormattedMessage(dynamic error) {
    if (error is SocketException) {
      return 'No internet connection. Please check your network.';
    } else if (error is TimeoutException) {
      return 'The request timed out. Please try again later.';
    } else if (error.toString().contains('525') || 
               error.toString().contains('AuthRetryableFetchException') ||
               error.toString().contains('PostgrestException')) {
      if (error.toString().contains('525') || error.toString().contains('503')) {
        return 'Server is waking up from sleep. Please wait a few seconds and try again.';
      }
      return 'Network error communicating with the server. Please try again.';
    } else if (error.runtimeType.toString() == 'AuthException') {
      try {
        return (error as dynamic).message;
      } catch (_) {
        return 'Authentication failed. Please check your credentials.';
      }
    } else if (error is Exception) {
      return error.toString().replaceAll('Exception: ', '');
    }
    return 'An unexpected error occurred: ${error.toString()}';
  }

  static void _showSnackBar(
    BuildContext context,
    String message, {
    required Color backgroundColor,
    required IconData icon,
    Color color = Colors.white,
    Duration duration = const Duration(seconds: 4),
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: color, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: duration,
      ),
    );
  }
}
