# Getting Started with Zypay Flutter SDK

This guide will help you get started with the Zypay Flutter SDK for blockchain payment processing.

## Installation

### Step 1: Add Dependency

Add the following to your `pubspec.yaml`:

```yaml
dependencies:
  zypay_flutter_sdk: ^1.0.3
```

Or run:

```bash
flutter pub add zypay_flutter_sdk
```

### Step 2: Install Dependencies

```bash
flutter pub get
```

## Quick Start

### 1. Wrap Your App with ZypayProvider

```dart
import 'package:flutter/material.dart';
import 'package:zypay_flutter_sdk/zypay_flutter_sdk.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ZypayProvider(
      token: 'your-api-token',  // Replace with your actual token
      config: const ZypayConfig(
        hostUrl: 'https://api.zypay.app',
        debug: DebugConfig(enabled: true),
      ),
      child: MaterialApp(
        title: 'My App',
        home: const HomePage(),
      ),
    );
  }
}
```

### 2. Add Payment Button

```dart
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
      ),
      body: Center(
        child: ZypayPaymentButton(
          userId: 'user123',
          buttonText: 'Make Payment',
          onPaymentComplete: () {
            // Handle successful payment
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Payment successful!'),
                backgroundColor: Colors.green,
              ),
            );
          },
          onPaymentFailed: (error) {
            // Handle failed payment
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Payment failed: ${error.message}'),
                backgroundColor: Colors.red,
              ),
            );
          },
        ),
      ),
    );
  }
}
```

## Configuration Options

### Debug Configuration

Enable debug logging to help with development:

```dart
ZypayProvider(
  token: 'your-api-token',
  config: const ZypayConfig(
    hostUrl: 'https://api.zypay.app',
    timeout: Duration(seconds: 30),
    retryAttempts: 3,
    debug: DebugConfig(
      enabled: true,
      level: LogLevel.info,
      timestamps: true,
      includeComponent: true,
      logNetwork: true,
      logState: true,
      logPerformance: false,
    ),
  ),
  child: MyApp(),
)
```

### Custom Styling

Customize the payment button appearance:

```dart
ZypayPaymentButton(
  userId: 'user123',
  buttonText: 'Complete Purchase',
  buttonStyle: ElevatedButton.styleFrom(
    backgroundColor: Colors.blue,
    padding: const EdgeInsets.symmetric(
      horizontal: 48,
      vertical: 20,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),
  textStyle: const TextStyle(
    color: Colors.white,
    fontSize: 18,
    fontWeight: FontWeight.bold,
  ),
  onPaymentComplete: () {
    // Handle success
  },
)
```

## Advanced Usage

### Using ZypayService Directly

For more control over the payment flow:

```dart
class PaymentService {
  late ZypayService _zypayService;

  void initialize() {
    _zypayService = ZypayService(
      token: 'your-api-token',
      config: const ZypayConfig(
        hostUrl: 'https://api.zypay.app',
        debug: DebugConfig(enabled: true),
      ),
    );
  }

  Future<void> processPayment(String userId) async {
    try {
      // Initialize payment
      await _zypayService.initialize(userId);

      // Get available options
      final options = await _zypayService.getOptions();
      print('Available blockchains: ${options['blockchains']}');

      // Process transaction
      final transaction = await _zypayService.processTransaction(
        blockchain: BlockchainType.ton,
        packageName: PackageName.basic,
      );
      
      print('Transaction created: ${transaction.id}');
    } catch (error) {
      print('Payment error: $error');
    }
  }

  void dispose() {
    _zypayService.dispose();
  }
}
```

### Monitoring Payment State

Use `ZypayConsumer` to monitor payment state changes:

```dart
class PaymentStatusWidget extends StatelessWidget {
  const PaymentStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ZypayConsumer(
      builder: (context, state, child) {
        return Column(
          children: [
            Text('Status: ${state.status.value}'),
            if (state.loading) const CircularProgressIndicator(),
            if (state.error != null)
              Text(
                'Error: ${state.error!.message}',
                style: const TextStyle(color: Colors.red),
              ),
            if (state.transaction != null)
              Text('Transaction: ${state.transaction!.id}'),
          ],
        );
      },
    );
  }
}
```

## Error Handling

Handle different types of payment errors:

```dart
onPaymentFailed: (error) {
  switch (error.code) {
    case 'CONNECTION_FAILED':
      // Handle connection errors
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Connection Error'),
          content: const Text('Please check your internet connection'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      break;
      
    case 'TIMEOUT_ERROR':
      // Handle timeout errors
      if (error.retryable) {
        // Show retry option
      }
      break;
      
    default:
      // Handle other errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
  }
}
```

## Supported Blockchains

- **TON** - The Open Network
- **BSC** - Binance Smart Chain

More blockchains coming soon!

## Payment Flow

1. User taps payment button
2. SDK initializes connection to Zypay service
3. Available payment options are fetched
4. User selects blockchain (and package if applicable)
5. Transaction is created
6. QR code and payment details are displayed
7. User completes payment in their wallet
8. SDK receives payment confirmation via WebSocket
9. Success callback is triggered

## API Reference

### ZypayProvider

Main provider widget that should wrap your app.

**Properties:**

- `token` (String, required) - Your Zypay API token
- `config` (ZypayConfig?, optional) - Configuration options
- `child` (Widget, required) - Your app widget

### ZypayPaymentButton

Pre-built payment button widget.

**Properties:**

- `userId` (String, required) - User identifier
- `buttonText` (String?, optional) - Button text (default: "Make Payment")
- `buttonStyle` (ButtonStyle?, optional) - Custom button style
- `textStyle` (TextStyle?, optional) - Custom text style
- `onPaymentComplete` (VoidCallback?, optional) - Success callback
- `onPaymentFailed` (Function(PaymentError)?, optional) - Failure callback
- `onPaymentCancelled` (VoidCallback?, optional) - Cancellation callback
- `onPaymentExpired` (VoidCallback?, optional) - Expiration callback
- `showLoading` (bool, optional) - Show loading indicator (default: true)

### ZypayService

Service class for direct API access.

**Methods:**

- `initialize(String userId)` - Initialize payment for a user
- `getOptions()` - Get available payment options
- `getRecentTransactions()` - Get recent transactions
- `processTransaction({required BlockchainType blockchain, PackageName? packageName})` - Process a transaction
- `simulatePayment()` - Simulate payment (testing)
- `disconnect()` - Disconnect from service
- `reconnect()` - Reconnect to service
- `dispose()` - Clean up resources

## Testing

Run the example app to test the integration:

```bash
cd example
flutter run
```

## Common Issues

### Issue: Dependencies not found

**Solution:** Run `flutter pub get` to install all dependencies.

### Issue: Socket connection fails

**Solution:**

- Check your internet connection
- Verify the `hostUrl` in your configuration
- Ensure your API token is valid

### Issue: Payment modal not showing

**Solution:**

- Make sure your widget is wrapped with `ZypayProvider`
- Ensure the `userId` is valid
- Check debug logs for initialization errors

## Support

- **Documentation:** <https://docs.zypay.app>
- **GitHub:** <https://github.com/zypay-dev/flutter-sdk>
- **Issues:** <https://github.com/zypay-dev/flutter-sdk/issues>
- **Email:** <support@zypay.app>
- **Discord:** <https://discord.gg/zypay>

## Next Steps

1. Get your API token from the Zypay dashboard
2. Integrate the SDK into your app
3. Test with the sandbox environment
4. Deploy to production

For more examples and advanced usage, check out the [examples](lib/examples/basic_usage.dart) directory and the [API documentation](README.md).
