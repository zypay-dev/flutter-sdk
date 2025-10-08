/// Payment client for Zypay SDK
library;

import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as io;

import '../utils/debug_logger.dart';
import 'config/zypay_config.dart';
import 'types/payment_state.dart';
import 'types/payment_types.dart';
import 'types/transaction_types.dart';

/// PaymentClient handles all communication with the Zypay payment service
class PaymentClient {
  /// Creates a new PaymentClient instance
  PaymentClient({
    required this.config,
    required PaymentState initialState,
    required this.onStateUpdate,
  }) : _state = initialState {
    _logger = DebugLogger(config.debug, 'PaymentClient');

    _logger.info('Initializing PaymentClient', {
      'hostUrl': config.hostUrl,
      'debug': config.debug.enabled,
    });

    _initializeSocket();
    _setupEventListeners();
  }
  late io.Socket _socket;
  final ZypayConfig config;
  final void Function(PaymentState) onStateUpdate;
  int _reconnectAttempts = 0;
  final int _maxReconnectAttempts = 5;
  late final DebugLogger _logger;

  PaymentState _state;

  /// Get current state
  PaymentState get state => _state;

  /// Update state and notify listeners
  void _updateState(PaymentState newState) {
    final oldState = _state;
    _state = newState;
    _logger.logStateChange(oldState, newState, 'State updated');
    onStateUpdate(newState);
  }

  /// Initialize Socket.IO connection
  void _initializeSocket() {
    final timer = _logger.startTimer('Socket initialization');

    _logger.logNetworkRequest('CONNECT', config.hostUrl, {
      'timeout': config.timeoutMs,
      'transports': ['websocket', 'polling'],
    });

    _socket = io.io(
      config.hostUrl,
      io.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .enableAutoConnect()
          .enableForceNew()
          .setTimeout(config.timeoutMs)
          .setAuth({'user_id': _state.userId, 'token': config.token})
          .build(),
    );

    timer.end();
  }

  /// Setup Socket.IO event listeners
  void _setupEventListeners() {
    _socket
      ..onConnect((_) {
        _reconnectAttempts = 0;
        _logger.logSocketConnection('connected', {
          'reconnectAttempts': _reconnectAttempts,
        });
      })
      ..onDisconnect((reason) {
        _logger.logSocketConnection('disconnected', {'reason': reason});

        if (reason == 'io server disconnect') {
          // Server initiated disconnect, don't reconnect
          _logger.warn('Server initiated disconnect', {'reason': reason});
          _updateState(
            _state.copyWith(
              status: PaymentStatus.failed,
              error: const PaymentError(
                code: 'SERVER_DISCONNECT',
                message: 'Server disconnected the connection',
              ),
            ),
          );
        }
      })
      ..onConnectError((error) {
        _reconnectAttempts++;
        _logger.logSocketConnection('error', {
          'error': error.toString(),
          'reconnectAttempts': _reconnectAttempts,
          'maxAttempts': _maxReconnectAttempts,
        });

        if (_reconnectAttempts >= _maxReconnectAttempts) {
          _logger.error('Max reconnection attempts reached', {
            'attempts': _reconnectAttempts,
            'maxAttempts': _maxReconnectAttempts,
          });

          _updateState(
            _state.copyWith(
              status: PaymentStatus.failed,
              error: const PaymentError(
                code: 'CONNECTION_FAILED',
                message: 'Failed to connect to server after multiple attempts',
                retryable: true,
              ),
            ),
          );
        }
      })
      ..on('payment_status_update', (data) {
        _logger.logSocketEvent(
          'payment_status_update',
          DebugUtils.sanitizeData(data),
        );

        try {
          final transaction =
              Transaction.fromJson(data as Map<String, dynamic>);
          _updateState(_state.copyWith(transaction: transaction));
        } catch (e) {
          _logger.error('Failed to parse payment_status_update', {'error': e});
        }
      });
  }

  /// Retrieves available payment options (blockchains and packages)
  Future<BlockchainResponse> getOptions() async {
    final timer = _logger.startTimer('get_options');
    final completer = Completer<BlockchainResponse>();

    _logger
        .logNetworkRequest('SOCKET_EMIT', 'get_options', <String, dynamic>{});

    Timer? timeout;
    timeout = Timer(config.timeout, () {
      if (!completer.isCompleted) {
        _logger.error('get_options timeout', {'timeout': config.timeoutMs});
        completer.completeError(Exception('Request timeout'));
      }
    });

    _socket.emitWithAck(
      'get_options',
      <String, dynamic>{},
      ack: (Map<String, dynamic> response) {
        timeout?.cancel();
        timer.end();

        try {
          final res = ApiResponse<BlockchainResponse>.fromJson(
              response,
              (data) =>
                  BlockchainResponse.fromJson(data as Map<String, dynamic>));

          _logger.logNetworkResponse(
            'SOCKET_EMIT',
            'get_options',
            res.status ? 200 : 400,
            DebugUtils.sanitizeData(response),
          );

          if (!res.status || res.data == null) {
            final error = PaymentError(
              code: 'OPTIONS_ERROR',
              message: res.message ?? 'Failed to get payment options',
              retryable: true,
            );

            _logger.error('Failed to get payment options', {
              'error': error,
              'response': response,
            });

            _updateState(
              _state.copyWith(status: PaymentStatus.failed, error: error),
            );

            completer.completeError(Exception(error.message));
            return;
          }

          _logger.info('Successfully retrieved payment options', {
            'blockchains': res.data!.blockchains,
            'packageType': res.data!.packageType,
            'packageCount': res.data!.packages?.length ?? 0,
          });

          _updateState(
            _state.copyWith(
              blockchains: res.data!.blockchains,
              packages: res.data!.packages ?? [],
              status: PaymentStatus.selecting,
              clearError: true,
            ),
          );

          completer.complete(res.data!);
        } catch (e) {
          _logger.error('Error parsing get_options response', {'error': e});
          completer.completeError(e);
        }
      },
    );

    return completer.future;
  }

  /// Retrieves recent transactions for the user
  Future<List<Transaction>> getRecentTransactions() async {
    final timer = _logger.startTimer('get_recent_transactions');
    final completer = Completer<List<Transaction>>();

    _logger.logNetworkRequest(
        'SOCKET_EMIT', 'get_recent_transactions', <String, dynamic>{});

    Timer? timeout;
    timeout = Timer(config.timeout, () {
      if (!completer.isCompleted) {
        _logger.error('get_recent_transactions timeout', {
          'timeout': config.timeoutMs,
        });
        completer.completeError(Exception('Request timeout'));
      }
    });

    _socket.emitWithAck(
      'get_recent_transactions',
      <String, dynamic>{},
      ack: (Map<String, dynamic> response) {
        timeout?.cancel();
        timer.end();

        try {
          final res = ApiResponse<PaginatedResponse<Transaction>>.fromJson(
            response,
            (data) => PaginatedResponse<Transaction>.fromJson(
              data as Map<String, dynamic>,
              Transaction.fromJson,
            ),
          );

          _logger.logNetworkResponse(
            'SOCKET_EMIT',
            'get_recent_transactions',
            res.status ? 200 : 400,
            DebugUtils.sanitizeData(response),
          );

          if (!res.status || res.data == null) {
            _logger.warn('Failed to get recent transactions', {
              'message': res.message,
              'response': response,
            });
            completer.complete([]);
            return;
          }

          _logger.info('Successfully retrieved recent transactions', {
            'count': res.data!.list.length,
            'hasNext': res.data!.hasNext,
            'total': res.data!.total,
          });

          _updateState(
            _state.copyWith(
              recentTransactions: res.data!.list,
              status: PaymentStatus.selecting,
            ),
          );

          completer.complete(res.data!.list);
        } catch (e) {
          _logger.error('Error parsing get_recent_transactions response', {
            'error': e,
          });
          completer.complete([]);
        }
      },
    );

    return completer.future;
  }

  /// Processes a new payment transaction
  Future<Transaction> processTransaction({
    required BlockchainType blockchain,
    PackageName? packageName,
  }) async {
    final request = SelectBlockchain(
      blockchain: blockchain,
      packageName: packageName,
    );
    final timer = _logger.startTimer('process_transaction');

    _logger.info('Processing transaction', {
      'blockchain': blockchain.value,
      'packageName': packageName?.value,
    });

    _updateState(
      _state.copyWith(
        status: PaymentStatus.loading,
        loading: true,
        clearError: true,
      ),
    );

    final completer = Completer<Transaction>();

    Timer? timeout;
    timeout = Timer(config.timeout, () {
      if (!completer.isCompleted) {
        final error = const PaymentError(
          code: 'TIMEOUT_ERROR',
          message: 'Request timed out. Please try again.',
          retryable: true,
        );

        _logger.error('process_transaction timeout', {
          'timeout': config.timeoutMs,
          'request': request.toJson(),
        });

        _updateState(
          _state.copyWith(
            status: PaymentStatus.failed,
            error: error,
            loading: false,
          ),
        );

        _state.onPaymentFailed?.call(error);
        completer.completeError(Exception(error.message));
      }
    });

    _logger.logNetworkRequest(
      'SOCKET_EMIT',
      'process_transaction',
      request.toJson(),
    );

    _socket.emitWithAck(
      'process_transaction',
      request.toJson(),
      ack: (Map<String, dynamic> response) {
        timeout?.cancel();
        timer.end();

        try {
          final res = ApiResponse<Transaction>.fromJson(
            response,
            (data) => Transaction.fromJson(data as Map<String, dynamic>),
          );

          _logger.logNetworkResponse(
            'SOCKET_EMIT',
            'process_transaction',
            res.status ? 200 : 400,
            DebugUtils.sanitizeData(response),
          );

          if (!res.status || res.data == null) {
            final error = PaymentError(
              code: 'PROCESSING_ERROR',
              message: res.message ?? 'Failed to process transaction',
              retryable: true,
            );

            _logger.error('Failed to process transaction', {
              'error': error,
              'response': response,
              'request': request.toJson(),
            });

            _updateState(
              _state.copyWith(
                status: PaymentStatus.failed,
                error: error,
                loading: false,
              ),
            );

            _state.onPaymentFailed?.call(error);
            completer.completeError(Exception(error.message));
            return;
          }

          _logger.info('Successfully processed transaction', {
            'transactionId': res.data!.id,
            'blockchain': res.data!.blockchain.value,
            'status': res.data!.status.name,
            'timeout': res.data!.timeout,
          });

          final expiryMinutes =
              res.data!.timeout ~/ 60000; // Convert ms to minutes

          _updateState(
            _state.copyWith(
              transaction: res.data,
              blockchain: res.data!.blockchain,
              paymentExpiryMinutes: expiryMinutes,
              status: PaymentStatus.processing,
              loading: false,
            ),
          );

          completer.complete(res.data!);
        } catch (e) {
          _logger.error('Error parsing process_transaction response', {
            'error': e,
          });
          completer.completeError(e);
        }
      },
    );

    return completer.future;
  }

  /// Simulates a payment for testing purposes
  Future<Transaction> stimulatePayment() async {
    final timer = _logger.startTimer('stimulate_payment');

    _logger.info('Stimulating payment', <String, dynamic>{});

    _updateState(_state.copyWith(status: PaymentStatus.loading));

    final completer = Completer<Transaction>();

    Timer? timeout;
    timeout = Timer(config.timeout, () {
      if (!completer.isCompleted) {
        _logger.error('stimulate_payment timeout', {
          'timeout': config.timeoutMs,
        });
        completer.completeError(Exception('Request timeout'));
      }
    });

    _logger.logNetworkRequest(
        'SOCKET_EMIT', 'stimulate_payment', <String, dynamic>{});

    _socket.emitWithAck(
      'stimulate_payment',
      <String, dynamic>{},
      ack: (Map<String, dynamic> response) {
        timeout?.cancel();
        timer.end();

        try {
          final res = ApiResponse<Transaction>.fromJson(
            response,
            (data) => Transaction.fromJson(data as Map<String, dynamic>),
          );

          _logger.logNetworkResponse(
            'SOCKET_EMIT',
            'stimulate_payment',
            res.status ? 200 : 400,
            DebugUtils.sanitizeData(response),
          );

          if (!res.status || res.data == null) {
            _logger.error('Failed to stimulate payment', {
              'message': res.message,
              'response': response,
            });

            _updateState(_state.copyWith(status: PaymentStatus.selecting));
            completer.completeError(
              Exception(res.message ?? 'Failed to stimulate payment'),
            );
            return;
          }

          _logger.info('Successfully stimulated payment', {
            'transactionId': res.data!.id,
            'blockchain': res.data!.blockchain.value,
            'status': res.data!.status.name,
          });

          final expiryMinutes = res.data!.timeout ~/ 60000;

          _updateState(
            _state.copyWith(
              transaction: res.data,
              blockchain: res.data!.blockchain,
              paymentExpiryMinutes: expiryMinutes,
              status: PaymentStatus.processing,
            ),
          );

          completer.complete(res.data!);
        } catch (e) {
          _logger.error('Error parsing stimulate_payment response', {
            'error': e,
          });
          completer.completeError(e);
        }
      },
    );

    return completer.future;
  }

  /// Check service health status
  Future<Map<String, dynamic>> getHealth() async {
    final timer = _logger.startTimer('get_health');
    final completer = Completer<Map<String, dynamic>>();

    _logger.logNetworkRequest('SOCKET_EMIT', 'get_health', <String, dynamic>{});

    Timer? timeout;
    timeout = Timer(config.timeout, () {
      if (!completer.isCompleted) {
        _logger.error('get_health timeout', {'timeout': config.timeoutMs});
        completer.completeError(Exception('Request timeout'));
      }
    });

    _socket.emitWithAck(
      'get_health',
      <String, dynamic>{},
      ack: (Map<String, dynamic> response) {
        timeout?.cancel();
        timer.end();

        final res = response;

        _logger.logNetworkResponse(
          'SOCKET_EMIT',
          'get_health',
          res['status'] == true ? 200 : 400,
          DebugUtils.sanitizeData(response),
        );

        completer.complete(res);
      },
    );

    return completer.future;
  }

  /// Disconnects from the payment service
  void disconnect() {
    _logger.info('Disconnecting from payment service');

    if (_socket.connected) {
      _socket.disconnect();
      _logger.logSocketConnection('disconnected', {'reason': 'manual'});
    }
  }

  /// Reconnects to the payment service
  void reconnect() {
    _logger.info('Reconnecting to payment service');

    if (!_socket.connected) {
      _socket.connect();
      _logger.logSocketConnection('reconnecting', <String, dynamic>{});
    }
  }

  /// Dispose resources
  void dispose() {
    _logger.info('Disposing PaymentClient');
    disconnect();
    _socket.dispose();
  }
}
