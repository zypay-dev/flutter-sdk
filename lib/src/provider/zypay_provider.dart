/// Zypay provider for state management
library;

import 'package:flutter/material.dart';

import '../core/config/zypay_config.dart';
import '../core/payment_client.dart';
import '../core/types/payment_state.dart';
import '../core/types/payment_types.dart';
import '../core/types/transaction_types.dart';
import '../utils/debug_logger.dart';

/// Zypay provider for managing payment state
class ZypayProvider extends InheritedWidget {
  ZypayProvider({
    required super.child,
    required ZypayConfig config,
    super.key,
  }) : notifier = ZypayNotifier._(config);

  final ZypayNotifier notifier;

  /// Access ZypayNotifier from context
  static ZypayNotifier of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<ZypayProvider>();
    assert(provider != null, 'No ZypayProvider found in context');
    return provider!.notifier;
  }

  @override
  bool updateShouldNotify(ZypayProvider oldWidget) => false;
}

/// Notifier for managing Zypay state
class ZypayNotifier extends ChangeNotifier {
  ZypayNotifier._(this.config) {
    _logger = DebugLogger(config.debug, 'ZypayNotifier');
    _logger.info('ZypayNotifier initialized', {'config': config.toString()});
  }

  final ZypayConfig config;
  PaymentClient? _client;
  PaymentState _state = const PaymentState();
  late final DebugLogger _logger;

  /// Current payment state
  PaymentState get state => _state;

  /// Check if payment modal is open
  bool get isPaymentOpen => _state.isOpen;

  /// Update state and notify listeners
  void _updateState(PaymentState newState) {
    _logger.logStateChange(_state, newState, 'State updated');
    _state = newState;
    notifyListeners();
  }

  /// Initialize payment for a specific user
  Future<void> initializePayment({
    required String userId,
    void Function()? onPaymentComplete,
    void Function()? onPaymentExpired,
    void Function(PaymentError error)? onPaymentFailed,
    void Function()? onPaymentCancelled,
  }) async {
    final timer = _logger.startTimer('initializePayment');

    try {
      _logger.info('Initializing payment', {'userId': userId});

      // Update state to show loading
      _updateState(
        PaymentState(
          isOpen: true,
          status: PaymentStatus.loading,
          userId: userId,
          onPaymentComplete: onPaymentComplete,
          onPaymentExpired: onPaymentExpired,
          onPaymentFailed: onPaymentFailed,
          onPaymentCancelled: onPaymentCancelled,
        ),
      );

      // Create payment client
      _client = PaymentClient(
        config: config,
        initialState: _state,
        onStateUpdate: _updateState,
      );

      _logger.info('PaymentClient created, fetching options and transactions');

      // Fetch options and transactions in parallel
      final results = await Future.wait([
        _client!.getOptions(),
        _client!.getRecentTransactions(),
      ]);

      final options = results[0] as BlockchainResponse;
      final transactions = results[1] as List<Transaction>;

      _logger.info('Successfully initialized payment', {
        'blockchains': options.blockchains.map((b) => b.value).toList(),
        'packageType': options.packageType.value,
        'recentTransactionsCount': transactions.length,
      });

      _updateState(
        _state.copyWith(
          blockchains: options.blockchains,
          packages: options.packages ?? [],
          recentTransactions: transactions,
          status: PaymentStatus.selecting,
        ),
      );

      timer.end();
    } catch (error) {
      _logger.error('Failed to initialize payment', {
        'error': error.toString(),
        'userId': userId,
      });

      _updateState(
        _state.copyWith(
          status: PaymentStatus.failed,
          error: PaymentError(
            code: 'INITIALIZATION_ERROR',
            message: 'Failed to initialize payment: ${error.toString()}',
            retryable: true,
          ),
        ),
      );

      timer.end();
      rethrow;
    }
  }

  /// Process transaction with selected blockchain and package
  Future<Transaction> processTransaction({
    required BlockchainType blockchain,
    PackageName? packageName,
  }) async {
    if (_client == null) {
      throw Exception(
        'Payment client not initialized. Call initializePayment first.',
      );
    }

    return _client!.processTransaction(
      blockchain: blockchain,
      packageName: packageName,
    );
  }

  /// Simulate payment for testing
  Future<Transaction> stimulatePayment() async {
    if (_client == null) {
      throw Exception(
        'Payment client not initialized. Call initializePayment first.',
      );
    }

    return _client!.stimulatePayment();
  }

  /// Get service health status
  Future<Map<String, dynamic>> getHealth() async {
    if (_client == null) {
      throw Exception(
        'Payment client not initialized. Call initializePayment first.',
      );
    }

    return _client!.getHealth();
  }

  /// Close payment modal
  void closePayment() {
    _logger.info('Closing payment modal');

    _updateState(
      _state.copyWith(isOpen: false, status: PaymentStatus.cancelled),
    );

    _state.onPaymentCancelled?.call();
  }

  /// Cancel payment and close modal
  void cancelPayment() {
    _logger.info('Cancelling payment');
    closePayment();
  }

  /// Disconnect from payment service
  void disconnect() {
    _logger.info('Disconnecting from payment service');
    _client?.disconnect();
  }

  /// Reconnect to payment service
  void reconnect() {
    _logger.info('Reconnecting to payment service');
    _client?.reconnect();
  }

  /// Reset payment state
  void reset() {
    _logger.info('Resetting payment state');

    _client?.disconnect();
    _client = null;

    _updateState(const PaymentState());
  }

  @override
  void dispose() {
    _logger.info('Disposing ZypayNotifier');
    _client?.dispose();
    super.dispose();
  }
}

/// Consumer widget for ZypayProvider
class ZypayConsumer extends StatelessWidget {
  const ZypayConsumer({super.key, required this.builder, this.child});
  final Widget Function(BuildContext context, PaymentState state, Widget? child)
      builder;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ZypayProvider.of(context),
      builder: (context, child) {
        final state = ZypayProvider.of(context).state;
        return builder(context, state, child);
      },
      child: child,
    );
  }
}

/// Selector widget for ZypayProvider
class ZypaySelector<T> extends StatelessWidget {
  const ZypaySelector({
    super.key,
    required this.selector,
    required this.builder,
    this.child,
  });
  final T Function(PaymentState state) selector;
  final Widget Function(BuildContext context, T value, Widget? child) builder;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ZypayProvider.of(context),
      builder: (context, child) {
        final state = ZypayProvider.of(context).state;
        final value = selector(state);
        return builder(context, value, child);
      },
      child: child,
    );
  }
}
