# Zypay Flutter SDK API Reference

## Table of Contents

- [Configuration](#configuration)
- [Provider](#provider)
- [Payment Client](#payment-client)
- [Types](#types)
- [Widgets](#widgets)
- [Utilities](#utilities)

## Configuration

### ZypayConfig

Main configuration class for the SDK.

```dart
class ZypayConfig {
  final String token;
  final String hostUrl;
  final Duration timeout;
  final int retryAttempts;
  final DebugConfig debug;

  const ZypayConfig({
    required this.token,
    this.hostUrl = 'https://api.zypay.app',
    this.timeout = const Duration(seconds: 30),
    this.retryAttempts = 3,
    this.debug = kDefaultDebugConfig,
  });
}
```

**Named Constructors:**

- `ZypayConfig.development()` - Optimized for development
- `ZypayConfig.production()` - Optimized for production

### DebugConfig

Debug configuration for logging.

```dart
class DebugConfig {
  final bool enabled;
  final DebugLevel level;
  final bool timestamps;
  final bool includeComponent;
  final bool logNetwork;
  final bool logState;
  final bool logPerformance;
  final CustomLogger? customLogger;
}
```

**Debug Levels:**

- `DebugLevel.error` - Only errors
- `DebugLevel.warn` - Warnings and errors
- `DebugLevel.info` - Info, warnings, and errors
- `DebugLevel.debug` - All logs

## Provider

### ZypayProvider

Main provider widget for state management.

```dart
class ZypayProvider extends InheritedWidget {
  const ZypayProvider({
    required Widget child,
    required ZypayConfig config,
  });

  static ZypayNotifier of(BuildContext context);
}
```

### ZypayNotifier

Manages payment state and operations.

**Properties:**

- `PaymentState state` - Current payment state
- `bool isPaymentOpen` - Whether payment modal is open

**Methods:**

```dart
Future<void> initializePayment({
  required String userId,
  void Function()? onPaymentComplete,
  void Function()? onPaymentExpired,
  void Function(PaymentError error)? onPaymentFailed,
  void Function()? onPaymentCancelled,
});
```

```dart
Future<Transaction> processTransaction({
  required BlockchainType blockchain,
  PackageName? packageName,
});
```

```dart
Future<Transaction> stimulatePayment();
```

```dart
Future<Map<String, dynamic>> getHealth();
```

```dart
void closePayment();
void cancelPayment();
void disconnect();
void reconnect();
void reset();
```

## Payment Client

### PaymentClient

Low-level client for payment operations.

**Constructor:**

```dart
PaymentClient({
  required ZypayConfig config,
  required PaymentState initialState,
  required void Function(PaymentState) onStateUpdate,
});
```

**Methods:**

```dart
Future<BlockchainResponse> getOptions();
Future<List<Transaction>> getRecentTransactions();
Future<Transaction> processTransaction({
  required BlockchainType blockchain,
  PackageName? packageName,
});
Future<Transaction> stimulatePayment();
Future<Map<String, dynamic>> getHealth();
void disconnect();
void reconnect();
void dispose();
```

## Types

### PaymentState

Main state object for payment flow.

```dart
class PaymentState {
  final bool isOpen;
  final PaymentStatus status;
  final String? userId;
  final BlockchainType? blockchain;
  final PackageType? packageType;
  final List<BlockchainType> blockchains;
  final List<Package> packages;
  final Transaction? transaction;
  final List<Transaction>? recentTransactions;
  final int paymentExpiryMinutes;
  final PaymentError? error;
  final bool loading;
  // ... callbacks
}
```

### PaymentStatus

```dart
enum PaymentStatus {
  idle,
  loading,
  selecting,
  processing,
  pending,
  confirmed,
  expired,
  failed,
  cancelled,
}
```

### BlockchainType

```dart
enum BlockchainType {
  ton('Ton'),
  bsc('BSC'),
}
```

### PackageType

```dart
enum PackageType {
  single('single'),
  multiple('multiple'),
}
```

### PackageName

```dart
enum PackageName {
  basic('basic'),
  pro('pro'),
  enterprise('enterprise'),
}
```

### Transaction

```dart
class Transaction {
  final String id;
  final TransactionFrom from;
  final TransactionTo to;
  final TransactionType type;
  final BlockchainType blockchain;
  final int timeout;
  final Package package;
  final TransactionStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  int get paymentExpirySeconds;
  bool get isExpired;
}
```

### PaymentError

```dart
class PaymentError {
  final String code;
  final String message;
  final String? field;
  final bool retryable;
}
```

## Widgets

### PaymentWidget

Main payment interface widget.

```dart
class PaymentWidget extends StatelessWidget {
  const PaymentWidget({
    VoidCallback? onClose,
  });
}
```

### OptionSelectionWidget

Blockchain and package selection widget.

```dart
class OptionSelectionWidget extends StatefulWidget {
  const OptionSelectionWidget({
    required List<BlockchainType> blockchains,
    required List<Package> packages,
    List<Transaction>? recentTransactions,
    required Future<void> Function(BlockchainType, PackageName?) onSelectBlockchain,
  });
}
```

### PaymentDetailsWidget

Transaction details with QR code.

```dart
class PaymentDetailsWidget extends StatefulWidget {
  const PaymentDetailsWidget({
    required Transaction transaction,
    required int expiryMinutes,
  });
}
```

### LoadingWidget

Simple loading indicator.

```dart
class LoadingWidget extends StatelessWidget {
  const LoadingWidget({
    String? message,
  });
}
```

### PaymentErrorWidget

Error display widget.

```dart
class PaymentErrorWidget extends StatelessWidget {
  const PaymentErrorWidget({
    required PaymentError error,
    VoidCallback? onRetry,
    VoidCallback? onClose,
  });
}
```

## Utilities

### DebugLogger

Logging utility for development.

```dart
class DebugLogger {
  void error(String message, [dynamic data]);
  void warn(String message, [dynamic data]);
  void info(String message, [dynamic data]);
  void debug(String message, [dynamic data]);
  
  void logNetworkRequest(String method, String url, [dynamic data]);
  void logNetworkResponse(String method, String url, int status, [dynamic data]);
  void logStateChange(dynamic oldState, dynamic newState, [String? action]);
  void logPerformance(String operation, Duration duration, [dynamic data]);
  void logSocketEvent(String event, [dynamic data]);
  void logSocketConnection(String status, [dynamic data]);
  
  PerformanceTimer startTimer(String operation);
}
```

### DebugUtils

Utility functions for debugging.

```dart
class DebugUtils {
  static dynamic sanitizeData(dynamic data);
  static String formatObject(dynamic obj, [int maxDepth = 3]);
  static bool isDebugEnabled(DebugConfig config);
}
```

## Consumer Widgets

### ZypayConsumer

Rebuild widget when state changes.

```dart
class ZypayConsumer extends StatelessWidget {
  const ZypayConsumer({
    required Widget Function(BuildContext, PaymentState, Widget?) builder,
    Widget? child,
  });
}
```

### ZypaySelector

Rebuild widget when selected value changes.

```dart
class ZypaySelector<T> extends StatelessWidget {
  const ZypaySelector({
    required T Function(PaymentState) selector,
    required Widget Function(BuildContext, T, Widget?) builder,
    Widget? child,
  });
}
```

## Error Codes

Common error codes:

- `SERVER_DISCONNECT` - Server disconnected
- `CONNECTION_FAILED` - Failed to connect
- `TIMEOUT_ERROR` - Request timeout
- `OPTIONS_ERROR` - Failed to get options
- `PROCESSING_ERROR` - Transaction processing failed
- `INITIALIZATION_ERROR` - Payment initialization failed

## Events

Socket.IO events:

- `connect` - Connected to server
- `disconnect` - Disconnected from server
- `connect_error` - Connection error
- `payment_status_update` - Real-time payment update

## Best Practices

1. **Initialize once**: Call `initializePayment` only when needed
2. **Handle callbacks**: Always provide error callbacks
3. **Dispose properly**: Reset state when done
4. **Debug mode**: Enable debug in development
5. **Error handling**: Handle all error cases
6. **State monitoring**: Use ZypayConsumer for reactive UI
7. **Performance**: Use ZypaySelector for specific state slices

## Examples

See [example/](../example/) directory for complete examples.
