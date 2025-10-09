# Zypay Flutter SDK

A comprehensive Flutter SDK for blockchain payment processing with support for multiple blockchains including TON and BSC.

## Features

- 🔗 **Multi-blockchain support** - TON, BSC, and more
- 💳 **Payment processing** - Secure transaction handling
- 🎨 **Modern UI components** - Beautiful, responsive payment interface
- 🔒 **Security first** - Built with security best practices
- 📱 **Mobile responsive** - Works seamlessly on all devices
- 🚀 **Type safety** - Full Dart type safety
- ⚡ **Real-time updates** - Live payment status updates via WebSocket
- 🎯 **Easy integration** - Simple Flutter provider API

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  zypay_flutter_sdk: ^1.0.1
```

Then run:

```bash
flutter pub get
```

## Quick Start

### 1. Wrap your app with ZypayProvider

```dart
import 'package:flutter/material.dart';
import 'package:zypay_flutter_sdk/zypay_flutter_sdk.dart';

void main() {
  runApp(
    ZypayProvider(
      config: ZypayConfig(
        token: 'your-api-token',
        hostUrl: 'https://api.zypay.app',
        debug: DebugConfig(
          enabled: true,
          level: DebugLevel.info,
        ),
      ),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zypay Demo',
      home: HomePage(),
    );
  }
}
```

### 2. Initialize and use the payment widget

```dart
import 'package:flutter/material.dart';
import 'package:zypay_flutter_sdk/zypay_flutter_sdk.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final zypay = ZypayProvider.of(context);
    
    return Scaffold(
      appBar: AppBar(title: Text('Zypay Payment')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await zypay.initializePayment(
              userId: 'user-123',
              onPaymentComplete: () {
                print('Payment completed successfully!');
              },
              onPaymentFailed: (error) {
                print('Payment failed: ${error.message}');
              },
              onPaymentCancelled: () {
                print('Payment cancelled');
              },
            );
          },
          child: Text('Make Payment'),
        ),
      ),
    );
  }
}
```

### 3. Display the payment widget

The payment modal will automatically appear when you call `initializePayment`. You can also manually show it:

```dart
// Access payment state
final paymentState = zypay.state;

// Show payment widget manually
if (paymentState.isOpen) {
  return PaymentWidget();
}
```

## Configuration

### Basic Configuration

```dart
ZypayConfig(
  token: 'your-api-token',
  hostUrl: 'https://api.zypay.app',
  timeout: Duration(seconds: 30),
  retryAttempts: 3,
  debug: DebugConfig(
    enabled: true,
    level: DebugLevel.info,
    logNetwork: true,
    logState: true,
    logPerformance: false,
  ),
)
```

### Debug Configuration

The SDK includes comprehensive debug logging capabilities:

```dart
DebugConfig(
  enabled: true,                    // Enable debug logging
  level: DebugLevel.debug,          // Log level: error, warn, info, debug
  timestamps: true,                 // Include timestamps in logs
  includeComponent: true,           // Include component names in logs
  logNetwork: true,                 // Log network requests and responses
  logState: true,                   // Log state changes
  logPerformance: true,             // Log performance metrics
  customLogger: (level, message, data) {
    // Custom logger function
    print('[$level] $message');
  },
)
```

## API Reference

### ZypayProvider

The main provider for integrating Zypay payments into your Flutter application.

#### Methods

- `initializePayment({required String userId, ...})` - Initialize payment for a user
- `disconnect()` - Disconnect from the payment service
- `reconnect()` - Reconnect to the payment service
- `getHealth()` - Check service health status

#### State

Access the current payment state:

```dart
final zypay = ZypayProvider.of(context);
final state = zypay.state;

// Check payment status
if (state.status == PaymentStatus.confirmed) {
  print('Payment confirmed!');
}
```

### Payment States

The SDK manages various payment states:

- `idle` - Initial state
- `loading` - Loading payment options
- `selecting` - User selecting payment options
- `processing` - Payment being processed
- `pending` - Payment pending confirmation
- `confirmed` - Payment confirmed
- `expired` - Payment expired
- `failed` - Payment failed
- `cancelled` - Payment cancelled

### Error Handling

```dart
await zypay.initializePayment(
  userId: 'user-123',
  onPaymentFailed: (error) {
    // Handle payment error
    print('Error: ${error.message}');
    print('Code: ${error.code}');
    print('Retryable: ${error.retryable}');
  },
);
```

## Supported Blockchains

- **TON** - The Open Network
- **BSC** - Binance Smart Chain
- More blockchains coming soon!

## UI Widgets

### PaymentWidget

The main payment interface widget that handles the complete payment flow.

```dart
PaymentWidget(
  onClose: () {
    // Handle modal close
  },
)
```

### Custom Styling

You can customize the appearance of the payment widgets:

```dart
ZypayTheme(
  primaryColor: Colors.blue,
  accentColor: Colors.blueAccent,
  errorColor: Colors.red,
  backgroundColor: Colors.white,
  textColor: Colors.black,
  cardRadius: 12.0,
  child: PaymentWidget(),
)
```

## Examples

Check out the [example](example/) directory for complete working examples:

- Basic payment integration
- Custom styling
- Error handling
- State management

## Development

### Prerequisites

- Flutter SDK 3.0.0 or higher
- Dart SDK 3.0.0 or higher

### Setup

```bash
git clone https://github.com/zypay-dev/flutter-sdk.git
cd flutter-sdk
flutter pub get
```

### Run Example

```bash
cd example
flutter run
```

### Testing

```bash
flutter test
```

### Linting

```bash
flutter analyze
```

## Security

The Zypay Flutter SDK is built with security in mind:

- All API communications are encrypted
- Tokens are securely handled
- No sensitive data is stored locally
- Regular security audits and updates

## Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

- 📧 Email: <support@zypay.app>
- 💬 Discord: [Join our community](https://discord.gg/zypay)
- 📖 Documentation: [docs.zypay.app](https://docs.zypay.app)
- 🐛 Issues: [GitHub Issues](https://github.com/zypay-dev/flutter-sdk/issues)

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for a list of changes and version history.

---

Made with ❤️ by the Zypay Team
