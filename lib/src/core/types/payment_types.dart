/// Payment types for Zypay SDK
library;

import 'package:equatable/equatable.dart';

/// Blockchain types supported by Zypay
enum BlockchainType {
  ton('Ton'),
  bsc('BSC');

  const BlockchainType(this.value);

  factory BlockchainType.fromString(String value) {
    return BlockchainType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => throw ArgumentError('Invalid blockchain type: $value'),
    );
  }

  final String value;
}

/// Package types for payment processing
enum PackageType {
  single('single'),
  multiple('multiple');

  const PackageType(this.value);

  factory PackageType.fromString(String value) {
    return PackageType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => throw ArgumentError('Invalid package type: $value'),
    );
  }

  final String value;
}

/// Available package names
enum PackageName {
  basic('basic'),
  pro('pro'),
  enterprise('enterprise');

  const PackageName(this.value);

  factory PackageName.fromString(String value) {
    return PackageName.values.firstWhere(
      (e) => e.value == value,
      orElse: () => throw ArgumentError('Invalid package name: $value'),
    );
  }

  final String value;
}

/// Payment processing status
enum PaymentStatus {
  idle,
  loading,
  selecting,
  processing,
  pending,
  confirmed,
  expired,
  failed,
  cancelled;

  factory PaymentStatus.fromString(String value) {
    return PaymentStatus.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => PaymentStatus.idle,
    );
  }
}

/// Authentication credentials for Zypay SDK
class PaymentAuth extends Equatable {
  /// Unique identifier for the user
  final String userId;

  /// API token for authentication
  final String token;

  const PaymentAuth({required this.userId, required this.token});

  Map<String, dynamic> toJson() => {'user_id': userId, 'token': token};

  factory PaymentAuth.fromJson(Map<String, dynamic> json) => PaymentAuth(
        userId: json['user_id'] as String,
        token: json['token'] as String,
      );

  @override
  List<Object?> get props => [userId, token];
}

/// Payment error interface
class PaymentError extends Equatable {
  /// Error code
  final String code;

  /// Error message
  final String message;

  /// Field that caused the error
  final String? field;

  /// Whether the error is retryable
  final bool retryable;

  const PaymentError({
    required this.code,
    required this.message,
    this.field,
    this.retryable = false,
  });

  Map<String, dynamic> toJson() => {
        'code': code,
        'message': message,
        if (field != null) 'field': field,
        'retryable': retryable,
      };

  factory PaymentError.fromJson(Map<String, dynamic> json) => PaymentError(
        code: json['code'] as String,
        message: json['message'] as String,
        field: json['field'] as String?,
        retryable: json['retryable'] as bool? ?? false,
      );

  @override
  List<Object?> get props => [code, message, field, retryable];

  @override
  String toString() =>
      'PaymentError(code: $code, message: $message, field: $field, retryable: $retryable)';
}

/// Package information
class Package extends Equatable {
  final PackageName name;
  final String? description;
  final double subscriptionFee;

  const Package({
    required this.name,
    this.description,
    required this.subscriptionFee,
  });

  Map<String, dynamic> toJson() => {
        'name': name.value,
        if (description != null) 'description': description,
        'subscription_fee': subscriptionFee,
      };

  factory Package.fromJson(Map<String, dynamic> json) => Package(
        name: PackageName.fromString(json['name'] as String),
        description: json['description'] as String?,
        subscriptionFee: (json['subscription_fee'] as num).toDouble(),
      );

  @override
  List<Object?> get props => [name, description, subscriptionFee];
}

/// Response wrapper
class ApiResponse<T> {
  final bool status;
  final String? message;
  final T? data;
  final List<ApiError>? errors;

  const ApiResponse({
    required this.status,
    this.message,
    this.data,
    this.errors,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse(
      status: json['status'] as bool,
      message: json['message'] as String?,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : null,
      errors: json['error'] != null
          ? (json['error'] as List)
              .map((e) => ApiError.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  bool get isSuccess => status;
  bool get isError => !status;
}

/// API error
class ApiError extends Equatable {
  final String? field;
  final String message;

  const ApiError({this.field, required this.message});

  Map<String, dynamic> toJson() => {
        if (field != null) 'field': field,
        'message': message,
      };

  factory ApiError.fromJson(Map<String, dynamic> json) => ApiError(
        field: json['field'] as String?,
        message: json['message'] as String,
      );

  @override
  List<Object?> get props => [field, message];
}

/// Paginated response
class PaginatedResponse<T> extends Equatable {
  final int total;
  final List<T> list;
  final bool hasNext;

  const PaginatedResponse({
    required this.total,
    required this.list,
    required this.hasNext,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PaginatedResponse(
      total: json['total'] as int,
      list: (json['list'] as List)
          .map((e) => fromJsonT(e as Map<String, dynamic>))
          .toList(),
      hasNext: json['has_next'] as bool,
    );
  }

  @override
  List<Object?> get props => [total, list, hasNext];
}

/// Select blockchain request
class SelectBlockchain extends Equatable {
  final BlockchainType blockchain;
  final PackageName? packageName;

  const SelectBlockchain({required this.blockchain, this.packageName});

  Map<String, dynamic> toJson() => {
        'blockchain': blockchain.value,
        if (packageName != null) 'package_name': packageName!.value,
      };

  @override
  List<Object?> get props => [blockchain, packageName];
}

/// Blockchain response
class BlockchainResponse extends Equatable {
  const BlockchainResponse({
    required this.packageType,
    required this.blockchains,
    this.packages,
  });

  factory BlockchainResponse.fromJson(Map<String, dynamic> json) {
    return BlockchainResponse(
      packageType: PackageType.fromString(json['package_type'] as String),
      blockchains: (json['blockchains'] as List)
          .map((e) => BlockchainType.fromString(e as String))
          .toList(),
      packages: json['packages'] != null
          ? (json['packages'] as List)
              .map((e) => Package.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  final PackageType packageType;
  final List<BlockchainType> blockchains;
  final List<Package>? packages;

  @override
  List<Object?> get props => [packageType, blockchains, packages];
}
