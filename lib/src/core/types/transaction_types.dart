/// Transaction types for Zypay SDK
library;

import 'package:equatable/equatable.dart';
import 'payment_types.dart';

/// Wallet information
class Wallet extends Equatable {
  const Wallet({
    required this.id,
    required this.address,
    required this.publicKey,
    required this.blockchain,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) => Wallet(
        id: json['id'] as String,
        address: json['address'] as String,
        publicKey: json['public_key'] as String,
        blockchain: BlockchainType.fromString(json['blockchain'] as String),
      );
  final String id;
  final String address;
  final String publicKey;
  final BlockchainType blockchain;

  Map<String, dynamic> toJson() => {
        'id': id,
        'address': address,
        'public_key': publicKey,
        'blockchain': blockchain.value,
      };

  @override
  List<Object?> get props => [id, address, publicKey, blockchain];
}

/// Payment account information
class PaymentAccount extends Equatable {
  const PaymentAccount({
    required this.id,
    required this.name,
    required this.plan,
    required this.subscriptionFee,
    required this.balance,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PaymentAccount.fromJson(Map<String, dynamic> json) => PaymentAccount(
        id: json['id'] as String,
        name: json['name'] as String,
        plan: json['plan'] as String,
        subscriptionFee: (json['subscription_fee'] as num).toDouble(),
        balance: json['balance'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );
  final String id;
  final String name;
  final String plan;
  final double subscriptionFee;
  final String balance;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'plan': plan,
        'subscription_fee': subscriptionFee,
        'balance': balance,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  @override
  List<Object?> get props => [
        id,
        name,
        plan,
        subscriptionFee,
        balance,
        createdAt,
        updatedAt,
      ];
}

/// User wallet information
class UserWallet extends Equatable {
  const UserWallet({
    required this.id,
    required this.email,
    required this.accountId,
    required this.wallet,
    required this.account,
  });

  factory UserWallet.fromJson(Map<String, dynamic> json) => UserWallet(
        id: json['id'] as String,
        email: json['email'] as String,
        accountId: json['account_id'] as String,
        wallet: Wallet.fromJson(json['wallet'] as Map<String, dynamic>),
        account:
            PaymentAccount.fromJson(json['account'] as Map<String, dynamic>),
      );
  final String id;
  final String email;
  final String accountId;
  final Wallet wallet;
  final PaymentAccount account;

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'account_id': accountId,
        'wallet': wallet.toJson(),
        'account': account.toJson(),
      };

  @override
  List<Object?> get props => [id, email, accountId, wallet, account];
}

/// Account wallet information
class AccountWallet extends Equatable {
  const AccountWallet({
    required this.id,
    required this.blockchain,
    required this.wallet,
    required this.account,
  });

  factory AccountWallet.fromJson(Map<String, dynamic> json) => AccountWallet(
        id: json['id'] as String,
        blockchain: BlockchainType.fromString(json['blockchain'] as String),
        wallet: Wallet.fromJson(json['wallet'] as Map<String, dynamic>),
        account:
            PaymentAccount.fromJson(json['account'] as Map<String, dynamic>),
      );

  final String id;
  final BlockchainType blockchain;
  final Wallet wallet;
  final PaymentAccount account;

  Map<String, dynamic> toJson() => {
        'id': id,
        'blockchain': blockchain.value,
        'wallet': wallet.toJson(),
        'account': account.toJson(),
      };

  @override
  List<Object?> get props => [id, blockchain, wallet, account];
}

/// Transaction status
enum TransactionStatus {
  success,
  pending,
  failed;

  factory TransactionStatus.fromString(String value) {
    return TransactionStatus.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => TransactionStatus.pending,
    );
  }
}

/// Transaction type
enum TransactionType {
  sandbox,
  production;

  factory TransactionType.fromString(String value) {
    return TransactionType.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => TransactionType.sandbox,
    );
  }
}

/// Transaction from information
class TransactionUser extends Equatable {
  const TransactionUser({
    required this.email,
    required this.address,
    required this.userWallet,
  });

  factory TransactionUser.fromJson(Map<String, dynamic> json) =>
      TransactionUser(
        email: json['email'] as String,
        address: json['address'] as String,
        userWallet: UserWallet.fromJson(
          json['user_wallet'] as Map<String, dynamic>,
        ),
      );

  final String email;
  final String address;
  final UserWallet userWallet;

  Map<String, dynamic> toJson() => {
        'email': email,
        'address': address,
        'user_wallet': userWallet.toJson(),
      };

  @override
  List<Object?> get props => [email, address, userWallet];
}

/// Transaction to information
class TransactionAccount extends Equatable {
  const TransactionAccount({required this.walletAddress, this.accountWallet});

  factory TransactionAccount.fromJson(Map<String, dynamic> json) =>
      TransactionAccount(
        walletAddress: json['wallet_address'] as String,
        accountWallet: json['account_wallet'] != null
            ? AccountWallet.fromJson(
                json['account_wallet'] as Map<String, dynamic>,
              )
            : null,
      );
  final String walletAddress;
  final AccountWallet? accountWallet;

  Map<String, dynamic> toJson() => {
        'wallet_address': walletAddress,
        if (accountWallet != null) 'account_wallet': accountWallet!.toJson(),
      };

  @override
  List<Object?> get props => [walletAddress, accountWallet];
}

/// Transaction information
class Transaction extends Equatable {
  const Transaction({
    required this.id,
    required this.user,
    required this.account,
    required this.type,
    required this.blockchain,
    required this.timeout,
    required this.package,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        id: json['id'] as String,
        user: TransactionUser.fromJson(json['user'] as Map<String, dynamic>),
        account: TransactionAccount.fromJson(
            json['account'] as Map<String, dynamic>),
        type: TransactionType.fromString(json['type'] as String),
        blockchain: BlockchainType.fromString(json['blockchain'] as String),
        timeout: json['timeout'] as int,
        package: Package.fromJson(json['package'] as Map<String, dynamic>),
        status: TransactionStatus.fromString(json['status'] as String),
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );
  final String id;
  final TransactionUser user;
  final TransactionAccount account;
  final TransactionType type;
  final BlockchainType blockchain;
  final int timeout;
  final Package package;
  final TransactionStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'user': user.toJson(),
        'account': account.toJson(),
        'type': type.name,
        'blockchain': blockchain.value,
        'timeout': timeout,
        'package': package.toJson(),
        'status': status.name,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  /// Calculate payment expiry time in seconds
  int get paymentExpirySeconds {
    final timeoutMs = timeout;
    final createdMs = createdAt.millisecondsSinceEpoch;
    return (timeoutMs - (DateTime.now().millisecondsSinceEpoch - createdMs)) ~/
        1000;
  }

  /// Check if transaction is expired
  bool get isExpired {
    return paymentExpirySeconds <= 0;
  }

  @override
  List<Object?> get props => [
        id,
        user,
        account,
        type,
        blockchain,
        timeout,
        package,
        status,
        createdAt,
        updatedAt,
      ];
}
