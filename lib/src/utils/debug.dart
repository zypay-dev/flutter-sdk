/// Debug utilities for Zypay SDK
library;

import 'package:flutter/foundation.dart';
import '../models/config.dart';

/// Debug logger class for component-specific logging
class DebugLogger {
  final DebugConfig config;
  final String componentName;

  DebugLogger(this.config, this.componentName);

  /// Check if should log based on level
  bool _shouldLog(LogLevel level) {
    if (!config.enabled) return false;

    const levelOrder = {
      LogLevel.error: 0,
      LogLevel.warn: 1,
      LogLevel.info: 2,
      LogLevel.debug: 3,
    };

    return (levelOrder[level] ?? 0) <= (levelOrder[config.level] ?? 2);
  }

  /// Format log message
  String _formatMessage(LogLevel level, String message) {
    final buffer = StringBuffer();

    if (config.timestamps) {
      buffer.write('[${DateTime.now().toIso8601String()}] ');
    }

    buffer.write('[${level.value.toUpperCase()}]');

    if (config.includeComponent) {
      buffer.write(' [$componentName]');
    }

    buffer.write(' $message');

    return buffer.toString();
  }

  /// Log message with optional data
  void _log(LogLevel level, String message, [dynamic data]) {
    if (!_shouldLog(level)) return;

    final formattedMessage = _formatMessage(level, message);

    if (config.logger != null) {
      config.logger!(level, formattedMessage, data);
    } else {
      if (data != null) {
        debugPrint('$formattedMessage\n${_formatData(data)}');
      } else {
        debugPrint(formattedMessage);
      }
    }
  }

  /// Format data for logging
  String _formatData(dynamic data) {
    if (data == null) return '';
    try {
      return '  Data: ${data.toString()}';
    } catch (e) {
      return '  Data: [Unable to format]';
    }
  }

  /// Log error message
  void error(String message, [dynamic data]) {
    _log(LogLevel.error, message, data);
  }

  /// Log warning message
  void warn(String message, [dynamic data]) {
    _log(LogLevel.warn, message, data);
  }

  /// Log info message
  void info(String message, [dynamic data]) {
    _log(LogLevel.info, message, data);
  }

  /// Log debug message
  void debug(String message, [dynamic data]) {
    _log(LogLevel.debug, message, data);
  }

  /// Log network request
  void logNetworkRequest(String method, String event, dynamic data) {
    if (!config.logNetwork) return;

    info(
      'Network Request: $method $event',
      sanitizeData(data),
    );
  }

  /// Log network response
  void logNetworkResponse(
    String method,
    String event,
    int statusCode,
    dynamic data,
  ) {
    if (!config.logNetwork) return;

    final level = statusCode >= 400 ? LogLevel.error : LogLevel.info;
    _log(
      level,
      'Network Response: $method $event [Status: $statusCode]',
      sanitizeData(data),
    );
  }

  /// Log socket connection events
  void logSocketConnection(String status, dynamic data) {
    if (!config.logNetwork) return;

    info('Socket Connection: $status', sanitizeData(data));
  }

  /// Log socket event
  void logSocketEvent(String event, dynamic data) {
    if (!config.logNetwork) return;

    info('Socket Event: $event', sanitizeData(data));
  }

  /// Log state change
  void logStateChange(dynamic oldState, dynamic newState, String reason) {
    if (!config.logState) return;

    debug('State Change: $reason', {
      'old': sanitizeData(oldState),
      'new': sanitizeData(newState),
    });
  }

  /// Start a performance timer
  PerformanceTimer startTimer(String operation) {
    return PerformanceTimer(this, operation);
  }

  /// Log performance metric
  void logPerformance(String operation, Duration duration) {
    if (!config.logPerformance) return;

    info('Performance: $operation took ${duration.inMilliseconds}ms');
  }
}

/// Performance timer for measuring operation duration
class PerformanceTimer {
  final DebugLogger logger;
  final String operation;
  final DateTime startTime;

  PerformanceTimer(this.logger, this.operation) : startTime = DateTime.now();

  /// End the timer and log the duration
  void end() {
    final duration = DateTime.now().difference(startTime);
    logger.logPerformance(operation, duration);
  }
}

/// Sanitize sensitive data from logs
dynamic sanitizeData(dynamic data) {
  if (data == null) {
    return null;
  }

  try {
    if (data is Map) {
      final sanitized = <String, dynamic>{};
      data.forEach((key, value) {
        if (key is String) {
          if (_isSensitiveField(key)) {
            sanitized[key] = '***REDACTED***';
          } else {
            sanitized[key] = sanitizeData(value);
          }
        }
      });
      return sanitized;
    }

    if (data is List) {
      return data.map(sanitizeData).toList();
    }

    return data;
  } catch (e) {
    return '[Unable to sanitize data]';
  }
}

/// Check if field name is sensitive
bool _isSensitiveField(String fieldName) {
  final lowerField = fieldName.toLowerCase();
  const sensitiveFields = [
    'password',
    'token',
    'secret',
    'api_key',
    'apikey',
    'auth',
    'authorization',
    'private_key',
    'privatekey',
    'wallet_key',
    'seed',
    'mnemonic',
  ];

  return sensitiveFields.any((field) => lowerField.contains(field));
}

/// Create a debug logger instance
DebugLogger createDebugLogger(DebugConfig config, String componentName) {
  return DebugLogger(config, componentName);
}

/// Debug utilities namespace
class DebugUtils {
  /// Sanitize data for logging
  static dynamic sanitizeData(dynamic data) => sanitizeData(data);

  /// Format duration to readable string
  static String formatDuration(Duration duration) {
    if (duration.inMilliseconds < 1000) {
      return '${duration.inMilliseconds}ms';
    }
    if (duration.inSeconds < 60) {
      return '${duration.inSeconds}s';
    }
    return '${duration.inMinutes}m ${duration.inSeconds % 60}s';
  }

  /// Truncate string for logging
  static String truncateString(String str, [int maxLength = 100]) {
    if (str.length <= maxLength) return str;
    return '${str.substring(0, maxLength)}...';
  }
}
