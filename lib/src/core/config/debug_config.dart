/// Debug configuration for Zypay SDK
library;

/// Debug log levels
enum DebugLevel {
  error,
  warn,
  info,
  debug;

  int get priority {
    switch (this) {
      case DebugLevel.error:
        return 0;
      case DebugLevel.warn:
        return 1;
      case DebugLevel.info:
        return 2;
      case DebugLevel.debug:
        return 3;
    }
  }

  bool shouldLog(DebugLevel level) {
    return level.priority <= priority;
  }
}

/// Custom logger function type
typedef CustomLogger = void Function(
    DebugLevel level, String message, dynamic data);

/// Debug configuration options
class DebugConfig {
  const DebugConfig({
    this.enabled = false,
    this.level = DebugLevel.info,
    this.timestamps = true,
    this.includeComponent = true,
    this.logNetwork = true,
    this.logState = true,
    this.logPerformance = false,
    this.customLogger,
  });

  /// Create a debug config with all features enabled
  const DebugConfig.verbose({
    this.enabled = true,
    this.level = DebugLevel.debug,
    this.timestamps = true,
    this.includeComponent = true,
    this.logNetwork = true,
    this.logState = true,
    this.logPerformance = true,
    this.customLogger,
  });

  /// Create a minimal debug config
  const DebugConfig.minimal({
    this.enabled = true,
    this.level = DebugLevel.error,
    this.timestamps = false,
    this.includeComponent = false,
    this.logNetwork = false,
    this.logState = false,
    this.logPerformance = false,
    this.customLogger,
  });

  /// Enable debug logging (default: false)
  final bool enabled;

  /// Log level: error, warn, info, debug (default: info)
  final DebugLevel level;

  /// Include timestamps in logs (default: true)
  final bool timestamps;

  /// Include component names in logs (default: true)
  final bool includeComponent;

  /// Log network requests and responses (default: true)
  final bool logNetwork;

  /// Log state changes (default: true)
  final bool logState;

  /// Log performance metrics (default: false)
  final bool logPerformance;

  /// Custom logger function (optional)
  final CustomLogger? customLogger;

  /// Copy with updated fields
  DebugConfig copyWith({
    bool? enabled,
    DebugLevel? level,
    bool? timestamps,
    bool? includeComponent,
    bool? logNetwork,
    bool? logState,
    bool? logPerformance,
    CustomLogger? customLogger,
  }) {
    return DebugConfig(
      enabled: enabled ?? this.enabled,
      level: level ?? this.level,
      timestamps: timestamps ?? this.timestamps,
      includeComponent: includeComponent ?? this.includeComponent,
      logNetwork: logNetwork ?? this.logNetwork,
      logState: logState ?? this.logState,
      logPerformance: logPerformance ?? this.logPerformance,
      customLogger: customLogger ?? this.customLogger,
    );
  }

  /// Check if a log level should be logged
  bool shouldLog(DebugLevel logLevel) {
    return enabled && level.shouldLog(logLevel);
  }

  @override
  String toString() {
    return 'DebugConfig(enabled: $enabled, level: $level, timestamps: $timestamps, '
        'includeComponent: $includeComponent, logNetwork: $logNetwork, '
        'logState: $logState, logPerformance: $logPerformance)';
  }
}

/// Default debug configuration
const kDefaultDebugConfig = DebugConfig(
  level: DebugLevel.info,
);
