/// Zypay service for managing payment operations
library;

import 'dart:async';

import '../core/config/debug_config.dart';
import '../core/config/zypay_config.dart';
import '../core/payment_client.dart';
import '../core/types/payment_state.dart';
import '../core/types/payment_types.dart';
import '../core/types/transaction_types.dart';
import '../utils/debug_logger.dart';

/// Main service class for Zypay payment operations
class ZypayService {
  /// Creates a new ZypayService instance
  ///
  /// Example:
  /// ```dart
  /// final service = ZypayService(
  ///   token: 'your-api-token',
  ///   config: ZypayConfig(
  ///     hostUrl: 'https://api.zypay.app',
  ///     debug: true,
  ///   ),
  /// );
  /// ```
  ZypayService({
    required this.token,
    ZypayConfig? config,
  })  : config = config ?? createDefaultConfig(token),
        logger = createDebugLogger(
          config?.debug ?? kDefaultDebugConfig,
          'ZypayService',
        );
  final String token;
  final ZypayConfig config;
  final DebugLogger logger;

  PaymentClient? _client;

  final StreamController<PaymentState> _stateController =
      StreamController<PaymentState>.broadcast();

  /// Stream of payment state changes
  Stream<PaymentState> get stateStream => _stateController.stream;

  PaymentState _currentState = const PaymentState();

  /// Get current payment state
  PaymentState get currentState => _currentState;

  /// Initialize payment for a user
  ///
  /// [userId] - Unique identifier for the user
  ///
  /// Example:
  /// ```dart
  /// await service.initialize('user123');
  /// ```
  Future<void> initialize(String userId) async {
    final timer = logger.startTimer('initialize');

    try {
      logger.info('Initializing payment', {'userId': userId});

      _client = PaymentClient(
        config: config,
        initialState: _currentState.copyWith(userId: userId),
        onStateUpdate: (state) {
          _currentState = state;
          _stateController.add(state);
        },
      );

      logger.info('PaymentClient created, fetching options and transactions');

      final results = await Future.wait([
        _client!.getOptions(),
        _client!.getRecentTransactions(),
      ]);

      final options = results[0] as BlockchainResponse;
      final transactions = results[1] as List<Transaction>;

      logger.info('Successfully initialized payment', {
        'blockchains': options.blockchains,
        'packageType': options.packageType,
        'recentTransactionsCount': transactions.length,
      });

      timer.end();
    } catch (error) {
      logger.error('Failed to initialize payment', {
        'error': error.toString(),
        'userId': userId,
      });

      _currentState = _currentState.copyWith(
        status: PaymentStatus.failed,
        error: const PaymentError(
          code: 'INITIALIZATION_ERROR',
          message: 'Failed to initialize payment',
          retryable: true,
        ),
      );
      _stateController.add(_currentState);

      timer.end();
      rethrow;
    }
  }

  /// Get available payment options
  ///
  /// Example:
  /// ```dart
  /// final options = await service.getOptions();
  /// ```
  Future<BlockchainResponse> getOptions() async {
    if (_client == null) {
      throw StateError('Service not initialized. Call initialize() first.');
    }
    return _client!.getOptions();
  }

  /// Get recent transactions
  ///
  /// Example:
  /// ```dart
  /// final transactions = await service.getRecentTransactions();
  /// ```
  Future<List<Transaction>> getRecentTransactions() async {
    if (_client == null) {
      throw StateError('Service not initialized. Call initialize() first.');
    }
    return _client!.getRecentTransactions();
  }

  /// Process a payment transaction
  ///
  /// [blockchain] - Selected blockchain
  /// [packageName] - Optional package name
  ///
  /// Example:
  /// ```dart
  /// final transaction = await service.processTransaction(
  ///   blockchain: BlockchainType.ton,
  ///   packageName: PackageName.basic,
  /// );
  /// ```
  Future<Transaction> processTransaction({
    required BlockchainType blockchain,
    PackageName? packageName,
  }) async {
    if (_client == null) {
      throw StateError('Service not initialized. Call initialize() first.');
    }
    return _client!.processTransaction(
      blockchain: blockchain,
      packageName: packageName,
    );
  }

  /// Simulate a payment (for testing)
  ///
  /// Example:
  /// ```dart
  /// final transaction = await service.simulatePayment();
  /// ```
  Future<Transaction> simulatePayment() async {
    if (_client == null) {
      throw StateError('Service not initialized. Call initialize() first.');
    }
    return _client!.stimulatePayment();
  }

  /// Disconnect from payment service
  ///
  /// Example:
  /// ```dart
  /// service.disconnect();
  /// ```
  void disconnect() {
    logger.info('Disconnecting payment service');
    _client?.disconnect();
  }

  /// Reconnect to payment service
  ///
  /// Example:
  /// ```dart
  /// service.reconnect();
  /// ```
  void reconnect() {
    logger.info('Reconnecting payment service');
    _client?.reconnect();
  }

  /// Get health status
  ///
  /// Example:
  /// ```dart
  /// final health = await service.getHealth();
  /// ```
  Future<Map<String, dynamic>> getHealth() async {
    if (_client == null) {
      throw StateError('Service not initialized. Call initialize() first.');
    }
    return _client!.getHealth();
  }

  /// Dispose of resources
  void dispose() {
    logger.info('Disposing ZypayService');
    _client?.dispose();
    _stateController.close();
  }
}
