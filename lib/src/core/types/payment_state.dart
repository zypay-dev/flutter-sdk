/// Payment state management for Zypay SDK
library;

import 'package:equatable/equatable.dart';
import 'payment_types.dart';
import 'transaction_types.dart';

/// Main payment state interface
class PaymentState extends Equatable {
  const PaymentState({
    this.isOpen = false,
    this.status = PaymentStatus.idle,
    this.userId,
    this.blockchain,
    this.packageType,
    this.blockchains = const [],
    this.packages = const [],
    this.transaction,
    this.recentTransactions,
    this.paymentExpiryMinutes = 15,
    this.error,
    this.loading = false,
    this.onPaymentComplete,
    this.onPaymentExpired,
    this.onPaymentFailed,
    this.onPaymentCancelled,
  });

  /// Whether the payment modal is open
  final bool isOpen;

  /// Current payment status
  final PaymentStatus status;

  /// User identifier
  final String? userId;

  /// Selected blockchain
  final BlockchainType? blockchain;

  /// Package type for payment
  final PackageType? packageType;

  /// Available blockchains
  final List<BlockchainType> blockchains;

  /// Available packages
  final List<Package> packages;

  /// Current transaction
  final Transaction? transaction;

  /// Recent transactions
  final List<Transaction>? recentTransactions;

  /// Payment expiry time in minutes
  final int paymentExpiryMinutes;

  /// Current error if any
  final PaymentError? error;

  /// Loading state
  final bool loading;

  /// Callback when payment completes
  final void Function()? onPaymentComplete;

  /// Callback when payment expires
  final void Function()? onPaymentExpired;

  /// Callback when payment fails
  final void Function(PaymentError error)? onPaymentFailed;

  /// Callback when payment is cancelled
  final void Function()? onPaymentCancelled;

  /// Create a copy of the state with updated fields
  PaymentState copyWith({
    bool? isOpen,
    PaymentStatus? status,
    String? userId,
    BlockchainType? blockchain,
    PackageType? packageType,
    List<BlockchainType>? blockchains,
    List<Package>? packages,
    Transaction? transaction,
    List<Transaction>? recentTransactions,
    int? paymentExpiryMinutes,
    PaymentError? error,
    bool? loading,
    void Function()? onPaymentComplete,
    void Function()? onPaymentExpired,
    void Function(PaymentError error)? onPaymentFailed,
    void Function()? onPaymentCancelled,
    bool clearError = false,
    bool clearTransaction = false,
  }) {
    return PaymentState(
      isOpen: isOpen ?? this.isOpen,
      status: status ?? this.status,
      userId: userId ?? this.userId,
      blockchain: blockchain ?? this.blockchain,
      packageType: packageType ?? this.packageType,
      blockchains: blockchains ?? this.blockchains,
      packages: packages ?? this.packages,
      transaction: clearTransaction ? null : (transaction ?? this.transaction),
      recentTransactions: recentTransactions ?? this.recentTransactions,
      paymentExpiryMinutes: paymentExpiryMinutes ?? this.paymentExpiryMinutes,
      error: clearError ? null : (error ?? this.error),
      loading: loading ?? this.loading,
      onPaymentComplete: onPaymentComplete ?? this.onPaymentComplete,
      onPaymentExpired: onPaymentExpired ?? this.onPaymentExpired,
      onPaymentFailed: onPaymentFailed ?? this.onPaymentFailed,
      onPaymentCancelled: onPaymentCancelled ?? this.onPaymentCancelled,
    );
  }

  /// Check if in error state
  bool get hasError => error != null;

  /// Check if transaction is active
  bool get hasActiveTransaction => transaction != null;

  /// Check if options are loaded
  bool get hasOptions => blockchains.isNotEmpty;

  @override
  List<Object?> get props => [
        isOpen,
        status,
        userId,
        blockchain,
        packageType,
        blockchains,
        packages,
        transaction,
        recentTransactions,
        paymentExpiryMinutes,
        error,
        loading,
      ];

  @override
  String toString() {
    return 'PaymentState(isOpen: $isOpen, status: $status, userId: $userId, '
        'blockchain: $blockchain, hasTransaction: $hasActiveTransaction, '
        'hasError: $hasError, loading: $loading)';
  }
}
