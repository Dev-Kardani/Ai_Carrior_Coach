import 'package:flutter/foundation.dart';

/// Defines the status levels for the debug logger
enum LogStatus {
  info,
  success,
  failed,
  warning,
}

/// A structured logging utility to ensure consistent debugging formats across the app.
class DebugLogger {
  /// Private constructor to prevent instantiation
  DebugLogger._();

  /// Core logging method that formats and outputs the message
  static void _log(String module, String step, LogStatus status, {String? reason, Object? error}) {
    if (!kDebugMode) return;

    final statusString = status.name.toUpperCase();
    
    // Base format: [MODULE] → [STEP] → [STATUS]
    var logMessage = '[$module] → $step → [$statusString]';

    // Append reason if provided: [MODULE] → [STEP] → [STATUS] → [REASON]
    if (reason != null && reason.isNotEmpty) {
      logMessage += ' → $reason';
    }

    // Output using debugPrint
    debugPrint(logMessage);

    // Optionally attach an original error instance log if present for stack traces
    if (error != null) {
      debugPrint('↳ Error Details: $error');
    }
  }

  /// Log general information, e.g., tracking a button click or initialization
  static void info(String module, String step, [String? message]) {
    _log(module, step, LogStatus.info, reason: message);
  }

  /// Log a successful operation
  static void success(String module, String step, [String? message]) {
    _log(module, step, LogStatus.success, reason: message);
  }

  /// Log a failed operation with the exact reason
  static void failed(String module, String step, String reason, {Object? error}) {
    _log(module, step, LogStatus.failed, reason: reason, error: error);
  }

  /// Log a warning or potential issue before it becomes an error
  static void warning(String module, String step, String warningMessage) {
    _log(module, step, LogStatus.warning, reason: warningMessage);
  }
}
