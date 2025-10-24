/// Configuration classes for Zypay SDK
library;

/// Log level for debug configuration
enum LogLevel {
  error('error'),
  warn('warn'),
  info('info'),
  debug('debug');

  const LogLevel(this.value);
  final String value;

  static LogLevel fromString(String value) {
    return LogLevel.values.firstWhere(
      (e) => e.value == value,
      orElse: () => LogLevel.info,
    );
  }
}

/// Debug configuration options
class DebugConfig {
  const DebugConfig({
    this.enabled = false,
    this.level = LogLevel.info,
    this.timestamps = true,
    this.includeComponent = true,
    this.logNetwork = true,
    this.logState = true,
    this.logPerformance = false,
    this.logger,
  });

  /// Create debug config from boolean
  factory DebugConfig.fromBool(bool enabled) {
    return DebugConfig(
      enabled: enabled,
    );
  }

  /// Enable debug logging (default: false)
  final bool enabled;

  /// Log level (default: info)
  final LogLevel level;

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
  final void Function(LogLevel level, String message, dynamic data)? logger;

  /// Default debug configuration
  static const DebugConfig defaultConfig = DebugConfig(
    enabled: true,
  );

  DebugConfig copyWith({
    bool? enabled,
    LogLevel? level,
    bool? timestamps,
    bool? includeComponent,
    bool? logNetwork,
    bool? logState,
    bool? logPerformance,
    void Function(LogLevel level, String message, dynamic data)? logger,
  }) {
    return DebugConfig(
      enabled: enabled ?? this.enabled,
      level: level ?? this.level,
      timestamps: timestamps ?? this.timestamps,
      includeComponent: includeComponent ?? this.includeComponent,
      logNetwork: logNetwork ?? this.logNetwork,
      logState: logState ?? this.logState,
      logPerformance: logPerformance ?? this.logPerformance,
      logger: logger ?? this.logger,
    );
  }

  @override
  String toString() => 'DebugConfig(enabled: $enabled, level: ${level.value})';
}

/// Configuration for Zypay SDK
class ZypayConfig {
  const ZypayConfig({
    required this.hostUrl,
    this.timeout = const Duration(seconds: 30),
    this.retryAttempts = 3,
    this.debug = const DebugConfig(),
  });

  /// Create config with debug boolean
  factory ZypayConfig.withDebug({
    required String hostUrl,
    Duration timeout = const Duration(seconds: 30),
    int retryAttempts = 3,
    bool debug = false,
  }) {
    return ZypayConfig(
      hostUrl: hostUrl,
      timeout: timeout,
      retryAttempts: retryAttempts,
      debug: DebugConfig.fromBool(debug),
    );
  }

  /// API host URL
  final String hostUrl;

  /// Request timeout (default: 30 seconds)
  final Duration timeout;

  /// Number of retry attempts (default: 3)
  final int retryAttempts;

  /// Debug configuration
  final DebugConfig debug;

  /// Default configuration
  static const ZypayConfig defaultConfig = ZypayConfig(
    hostUrl: 'https://api.zypay.app',
    debug: DebugConfig.defaultConfig,
  );

  ZypayConfig copyWith({
    String? hostUrl,
    Duration? timeout,
    int? retryAttempts,
    DebugConfig? debug,
  }) {
    return ZypayConfig(
      hostUrl: hostUrl ?? this.hostUrl,
      timeout: timeout ?? this.timeout,
      retryAttempts: retryAttempts ?? this.retryAttempts,
      debug: debug ?? this.debug,
    );
  }

  @override
  String toString() => 'ZypayConfig(hostUrl: $hostUrl, timeout: $timeout)';
}
