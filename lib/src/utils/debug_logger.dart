/// Debug logger for Zypay SDK
library;

import 'dart:developer' as developer;
import '../core/config/debug_config.dart';

/// Debug logger class for Zypay SDK
class DebugLogger {
  DebugLogger(this.config, [this.componentName = 'ZypaySDK']);

  final DebugConfig config;
  final String componentName;

  /// Check if logging is enabled for the given level
  bool _isLevelEnabled(DebugLevel level) {
    return config.shouldLog(level);
  }

  /// Format log message with timestamp and component name
  String _formatMessage(DebugLevel level, String message) {
    final buffer = StringBuffer();

    if (config.timestamps) {
      final timestamp = DateTime.now().toIso8601String();
      buffer.write('[$timestamp] ');
    }

    if (config.includeComponent) {
      buffer.write('[$componentName] ');
    }

    buffer.write('[${level.name.toUpperCase()}] $message');

    return buffer.toString();
  }

  /// Log a message with the given level
  void _log(DebugLevel level, String message, [dynamic data]) {
    if (!_isLevelEnabled(level)) return;

    final formattedMessage = _formatMessage(level, message);

    if (config.customLogger != null) {
      config.customLogger!(level, formattedMessage, data);
    } else {
      // Use developer.log for better debugging in Flutter
      developer.log(
        formattedMessage,
        name: componentName,
        level: _getLogLevel(level),
        error: data is Exception ? data : null,
      );

      // Also print for console output
      if (data != null) {
        print('$formattedMessage\nData: $data');
      } else {
        print(formattedMessage);
      }
    }
  }

  /// Get numeric log level for developer.log
  int _getLogLevel(DebugLevel level) {
    switch (level) {
      case DebugLevel.error:
        return 1000;
      case DebugLevel.warn:
        return 900;
      case DebugLevel.info:
        return 800;
      case DebugLevel.debug:
        return 500;
    }
  }

  /// Log an error message
  void error(String message, [dynamic data]) {
    _log(DebugLevel.error, message, data);
  }

  /// Log a warning message
  void warn(String message, [dynamic data]) {
    _log(DebugLevel.warn, message, data);
  }

  /// Log an info message
  void info(String message, [dynamic data]) {
    _log(DebugLevel.info, message, data);
  }

  /// Log a debug message
  void debug(String message, [dynamic data]) {
    _log(DebugLevel.debug, message, data);
  }

  /// Log network request
  void logNetworkRequest(String method, String url, [dynamic data]) {
    if (!config.logNetwork) return;
    debug('Network Request: $method $url', data);
  }

  /// Log network response
  void logNetworkResponse(
    String method,
    String url,
    int status, [
    dynamic data,
  ]) {
    if (!config.logNetwork) return;

    final level = status >= 400 ? DebugLevel.error : DebugLevel.debug;
    _log(level, 'Network Response: $method $url - $status', data);
  }

  /// Log state change
  void logStateChange(dynamic oldState, dynamic newState, [String? action]) {
    if (!config.logState) return;

    final message = action != null ? 'State Change: $action' : 'State Change';
    debug(message, {'oldState': oldState, 'newState': newState});
  }

  /// Log performance metric
  void logPerformance(String operation, Duration duration, [dynamic data]) {
    if (!config.logPerformance) return;

    debug('Performance: $operation took ${duration.inMilliseconds}ms', data);
  }

  /// Create a performance timer
  PerformanceTimer startTimer(String operation) {
    return PerformanceTimer(this, operation);
  }

  /// Log socket event
  void logSocketEvent(String event, [dynamic data]) {
    if (!config.logNetwork) return;
    debug('Socket Event: $event', data);
  }

  /// Log socket connection status
  void logSocketConnection(String status, [dynamic data]) {
    if (!config.logNetwork) return;

    final level = status == 'error' ? DebugLevel.error : DebugLevel.info;
    _log(level, 'Socket Connection: $status', data);
  }
}

/// Performance timer for measuring operation duration
class PerformanceTimer {
  PerformanceTimer(this.logger, this.operation) : startTime = DateTime.now();
  final DebugLogger logger;
  final String operation;
  final DateTime startTime;

  /// End the timer and log the duration
  void end([dynamic data]) {
    final duration = DateTime.now().difference(startTime);
    logger.logPerformance(operation, duration, data);
  }
}

/// Create a debug logger instance
DebugLogger createDebugLogger(
  DebugConfig config, [
  String componentName = 'ZypaySDK',
]) {
  return DebugLogger(config, componentName);
}

/// Global debug logger instance
DebugLogger? _globalLogger;

/// Set the global debug logger
void setGlobalDebugLogger(
  DebugConfig config, [
  String componentName = 'ZypaySDK',
]) {
  _globalLogger = createDebugLogger(config, componentName);
}

/// Get the global debug logger
DebugLogger? getGlobalDebugLogger() {
  return _globalLogger;
}

/// Debug utility functions
class DebugUtils {
  /// Sanitize sensitive data for logging
  static dynamic sanitizeData(dynamic data) {
    if (data == null) return null;

    if (data is! Map) return data;

    final sanitized = Map<String, dynamic>.from(data);
    final sensitiveKeys = [
      'token',
      'password',
      'secret',
      'key',
      'auth',
      'authorization',
    ];

    for (final key in sanitized.keys) {
      if (sensitiveKeys.any(
        (sensitive) => key.toLowerCase().contains(sensitive),
      )) {
        sanitized[key] = '[REDACTED]';
      } else if (sanitized[key] is Map) {
        sanitized[key] = sanitizeData(sanitized[key]);
      }
    }

    return sanitized;
  }

  /// Format object for logging
  static String formatObject(dynamic obj, [int maxDepth = 3]) {
    try {
      return obj.toString();
    } catch (e) {
      return '[Error formatting object]';
    }
  }

  /// Check if debug is enabled
  static bool isDebugEnabled(DebugConfig config) {
    return config.enabled;
  }
}
