import 'package:flutter_test/flutter_test.dart';
import 'package:zypay_flutter_sdk/zypay_flutter_sdk.dart';

void main() {
  group('BlockchainType', () {
    test('should convert from string correctly', () {
      expect(BlockchainType.fromString('Ton'), BlockchainType.ton);
      expect(BlockchainType.fromString('BSC'), BlockchainType.bsc);
    });

    test('should throw error for invalid string', () {
      expect(
        () => BlockchainType.fromString('INVALID'),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('PaymentStatus', () {
    test('should convert from string correctly', () {
      expect(PaymentStatus.fromString('idle'), PaymentStatus.idle);
      expect(PaymentStatus.fromString('loading'), PaymentStatus.loading);
      expect(PaymentStatus.fromString('processing'), PaymentStatus.processing);
    });

    test('should default to idle for invalid string', () {
      expect(PaymentStatus.fromString('INVALID'), PaymentStatus.idle);
    });
  });

  group('PaymentAuth', () {
    test('should create PaymentAuth correctly', () {
      const auth = PaymentAuth(
        userId: 'user123',
        token: 'token123',
      );

      expect(auth.userId, 'user123');
      expect(auth.token, 'token123');
    });

    test('should convert to JSON correctly', () {
      const auth = PaymentAuth(
        userId: 'user123',
        token: 'token123',
      );

      final json = auth.toJson();

      expect(json['user_id'], 'user123');
      expect(json['token'], 'token123');
    });
  });

  group('PaymentError', () {
    test('should create PaymentError correctly', () {
      const error = PaymentError(
        code: 'ERROR_CODE',
        message: 'Error message',
        retryable: true,
      );

      expect(error.code, 'ERROR_CODE');
      expect(error.message, 'Error message');
      expect(error.retryable, true);
    });

    test('should convert from JSON correctly', () {
      final json = {
        'code': 'ERROR_CODE',
        'message': 'Error message',
        'field': 'test_field',
        'retryable': true,
      };

      final error = PaymentError.fromJson(json);

      expect(error.code, 'ERROR_CODE');
      expect(error.message, 'Error message');
      expect(error.field, 'test_field');
      expect(error.retryable, true);
    });
  });

  group('PaymentState', () {
    test('should create PaymentState with defaults', () {
      const state = PaymentState();

      expect(state.isOpen, false);
      expect(state.status, PaymentStatus.idle);
      expect(state.loading, false);
      expect(state.blockchains, isEmpty);
      expect(state.packages, isEmpty);
    });

    test('should copy with new values', () {
      const state = PaymentState();
      final newState = state.copyWith(
        isOpen: true,
        status: PaymentStatus.loading,
      );

      expect(newState.isOpen, true);
      expect(newState.status, PaymentStatus.loading);
    });

    test('should clear error when requested', () {
      const state = PaymentState(
        error: PaymentError(
          code: 'ERROR',
          message: 'Error message',
        ),
      );

      final newState = state.copyWith(clearError: true);

      expect(newState.error, isNull);
    });
  });

  group('SelectBlockchain', () {
    test('should convert to JSON correctly', () {
      const select = SelectBlockchain(
        blockchain: BlockchainType.ton,
        packageName: PackageName.basic,
      );

      final json = select.toJson();

      expect(json['blockchain'], 'Ton');
      expect(json['package_name'], 'basic');
    });

    test('should convert to JSON without package name', () {
      const select = SelectBlockchain(
        blockchain: BlockchainType.bsc,
      );

      final json = select.toJson();

      expect(json['blockchain'], 'BSC');
      expect(json.containsKey('package_name'), false);
    });
  });
}
