# Zypay Flutter SDK Example

This is an example application demonstrating how to use the Zypay Flutter SDK for blockchain payment processing.

## Getting Started

### Prerequisites

- Flutter SDK 3.0.0 or higher
- Dart SDK 3.0.0 or higher
- A Zypay API token (get one from [zypay.app](https://zypay.app))

### Installation

1. Clone the repository and navigate to the example directory:

```bash
cd example
```

2. Install dependencies:

```bash
flutter pub get
```

3. Update the API token in `lib/main.dart`:

```dart
ZypayConfig(
  token: 'your-api-token-here', // Replace with your actual token
  hostUrl: 'https://api.zypay.app',
)
```

### Running the Example

Run on an emulator or physical device:

```bash
flutter run
```

For web:

```bash
flutter run -d chrome
```

## Features Demonstrated

- **Payment Initialization**: Initialize a payment session for a user
- **Blockchain Selection**: Allow users to select from available blockchains
- **Package Selection**: Display and select payment packages
- **QR Code Payment**: Generate QR codes for easy payment
- **Real-time Updates**: Monitor payment status in real-time
- **Error Handling**: Handle various payment errors gracefully
- **Debug Logging**: Enable comprehensive debug logging

## Code Structure

```
lib/
  └── main.dart          # Main application entry point
```

## Usage Examples

### Basic Payment Flow

```dart
final zypay = ZypayProvider.of(context);

await zypay.initializePayment(
  userId: 'user-123',
  onPaymentComplete: () {
    print('Payment completed!');
  },
  onPaymentFailed: (error) {
    print('Payment failed: ${error.message}');
  },
);

// Show payment widget
showDialog(
  context: context,
  builder: (context) => const PaymentWidget(),
);
```

### Custom Configuration

```dart
ZypayProvider(
  config: ZypayConfig(
    token: 'your-token',
    hostUrl: 'https://api.zypay.app',
    timeout: const Duration(seconds: 60),
    retryAttempts: 5,
    debug: const DebugConfig(
      enabled: true,
      level: DebugLevel.debug,
      logNetwork: true,
      logState: true,
      logPerformance: true,
    ),
  ),
  child: MyApp(),
)
```

### Monitoring Payment State

```dart
ZypayConsumer(
  builder: (context, state, child) {
    if (state.status == PaymentStatus.confirmed) {
      return Text('Payment confirmed!');
    }
    return Text('Status: ${state.status}');
  },
)
```

## Testing

The example includes test payment functionality. In development mode, you can use the "Stimulate Payment" feature to test the payment flow without real transactions.

## Troubleshooting

### Common Issues

1. **Connection Failed**: Ensure your API token is valid and the host URL is correct
2. **Payment Not Loading**: Check your internet connection and debug logs
3. **Widget Not Showing**: Ensure ZypayProvider is properly configured in your widget tree

### Debug Mode

Enable detailed logging to troubleshoot issues:

```dart
debug: const DebugConfig(
  enabled: true,
  level: DebugLevel.debug,
  logNetwork: true,
  logState: true,
  logPerformance: true,
)
```

## Support

For issues and questions:
- 📧 Email: support@zypay.app
- 📖 Documentation: [docs.zypay.app](https://docs.zypay.app)
- 🐛 Issues: [GitHub Issues](https://github.com/zypay-dev/flutter-sdk/issues)

## License

MIT License - see LICENSE file for details
