/// Configuration for Zypay SDK
library;

import 'debug_config.dart';

/// Configuration interface for Zypay SDK
class ZypayConfig {
  const ZypayConfig({
    required this.token,
    this.hostUrl = 'https://api.zypay.app',
    this.timeout = const Duration(seconds: 30),
    this.retryAttempts = 3,
    this.debug = kDefaultDebugConfig,
  });

  /// Create a config for development
  const ZypayConfig.development({
    required this.token,
    this.hostUrl = 'https://dev-api.zypay.app',
    this.timeout = const Duration(seconds: 60),
    this.retryAttempts = 5,
    this.debug = const DebugConfig.verbose(),
  });

  /// Create a config for production
  const ZypayConfig.production({
    required this.token,
    this.hostUrl = 'https://api.zypay.app',
    this.timeout = const Duration(seconds: 30),
    this.retryAttempts = 3,
    this.debug = const DebugConfig.minimal(),
  });

  /// API token for authentication
  final String token;

  /// API host URL
  final String hostUrl;

  /// Request timeout duration (default: 30 seconds)
  final Duration timeout;

  /// Number of retry attempts (default: 3)
  final int retryAttempts;

  /// Debug configuration
  final DebugConfig debug;

  /// Copy with updated fields
  ZypayConfig copyWith({
    String? token,
    String? hostUrl,
    Duration? timeout,
    int? retryAttempts,
    DebugConfig? debug,
  }) {
    return ZypayConfig(
      token: token ?? this.token,
      hostUrl: hostUrl ?? this.hostUrl,
      timeout: timeout ?? this.timeout,
      retryAttempts: retryAttempts ?? this.retryAttempts,
      debug: debug ?? this.debug,
    );
  }

  /// Check if debug is enabled
  bool get isDebugEnabled => debug.enabled;

  /// Get timeout in milliseconds
  int get timeoutMs => timeout.inMilliseconds;

  @override
  String toString() {
    return 'ZypayConfig(hostUrl: $hostUrl, timeout: $timeout, '
        'retryAttempts: $retryAttempts, debug: ${debug.enabled})';
  }
}

/// Default configuration for Zypay SDK
ZypayConfig createDefaultConfig(String token) {
  return ZypayConfig(
    token: token,
  );
}
