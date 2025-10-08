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
      config: const ZypayConfig(
        token: 'your-api-token-here', // Replace with your actual token
        hostUrl: 'https://api.zypay.app',
        debug: DebugConfig(
          enabled: true,
          level: DebugLevel.info,
          logNetwork: true,
          logState: true,
        ),
      ),
      child: MaterialApp(
        title: 'Zypay Flutter SDK Example',
        theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
        home: const HomePage(),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zypay Flutter SDK Example'),
        elevation: 2,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.payment, size: 100, color: Colors.blue),
            const SizedBox(height: 32),
            const Text(
              'Zypay Payment Example',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Click the button below to initialize a payment with Zypay',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 48),
            ElevatedButton.icon(
              onPressed: () => _initializePayment(context),
              icon: const Icon(Icons.account_balance_wallet),
              label: const Text('Make Payment'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => _checkHealth(context),
              icon: const Icon(Icons.health_and_safety),
              label: const Text('Check Health'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _initializePayment(BuildContext context) async {
    final zypay = ZypayProvider.of(context);

    try {
      await zypay.initializePayment(
        userId: 'demo-user-${DateTime.now().millisecondsSinceEpoch}',
        onPaymentComplete: () {
          _showSnackBar(
            context,
            'Payment completed successfully!',
            Colors.green,
          );
        },
        onPaymentFailed: (error) {
          _showSnackBar(
            context,
            'Payment failed: ${error.message}',
            Colors.red,
          );
        },
        onPaymentExpired: () {
          _showSnackBar(
            context,
            'Payment expired. Please try again.',
            Colors.orange,
          );
        },
        onPaymentCancelled: () {
          _showSnackBar(context, 'Payment cancelled', Colors.grey);
        },
      );

      // Show the payment widget
      if (context.mounted) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const PaymentWidget(),
        );
      }
    } catch (e) {
      if (context.mounted) {
        _showSnackBar(
          context,
          'Error initializing payment: ${e.toString()}',
          Colors.red,
        );
      }
    }
  }

  Future<void> _checkHealth(BuildContext context) async {
    final zypay = ZypayProvider.of(context);

    try {
      // Note: Health check requires an initialized client
      // You may need to initialize payment first or modify the SDK
      // to allow health checks without initialization

      _showSnackBar(
        context,
        'Health check: Initialize payment first to check service health',
        Colors.blue,
      );
    } catch (e) {
      if (context.mounted) {
        _showSnackBar(
          context,
          'Health check failed: ${e.toString()}',
          Colors.red,
        );
      }
    }
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
