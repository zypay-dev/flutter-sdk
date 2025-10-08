import 'package:flutter_test/flutter_test.dart';
import 'package:zypay_flutter_sdk/zypay_flutter_sdk.dart';

void main() {
  group('DebugConfig', () {
    test('should create with defaults', () {
      const config = DebugConfig();

      expect(config.enabled, false);
      expect(config.level, DebugLevel.info);
      expect(config.timestamps, true);
      expect(config.includeComponent, true);
      expect(config.logNetwork, true);
      expect(config.logState, true);
      expect(config.logPerformance, false);
    });

    test('should create verbose config', () {
      const config = DebugConfig.verbose();

      expect(config.enabled, true);
      expect(config.level, DebugLevel.debug);
    });

    test('should create minimal config', () {
      const config = DebugConfig.minimal();

      expect(config.enabled, true);
      expect(config.level, DebugLevel.error);
    });

    test('should copy with new values', () {
      const config = DebugConfig();
      final newConfig = config.copyWith(
        enabled: true,
        level: DebugLevel.debug,
      );

      expect(newConfig.enabled, true);
      expect(newConfig.level, DebugLevel.debug);
      expect(newConfig.timestamps, true); // unchanged
    });
  });

  group('ZypayConfig', () {
    test('should create with required token', () {
      const config = ZypayConfig(
        token: 'test-token',
      );

      expect(config.token, 'test-token');
      expect(config.hostUrl, 'https://api.zypay.app');
      expect(config.timeout, const Duration(seconds: 30));
      expect(config.retryAttempts, 3);
      expect(config.debug.enabled, false);
    });

    test('should create development config', () {
      const config = ZypayConfig.development(
        token: 'test-token',
      );

      expect(config.debug.enabled, true);
      expect(config.debug.level, DebugLevel.debug);
    });

    test('should copy with new values', () {
      const config = ZypayConfig(
        token: 'test-token',
      );

      final newConfig = config.copyWith(
        timeout: const Duration(seconds: 60),
        retryAttempts: 5,
      );

      expect(newConfig.timeout, const Duration(seconds: 60));
      expect(newConfig.retryAttempts, 5);
      expect(newConfig.hostUrl, 'https://api.zypay.app'); // unchanged
    });
  });
}
