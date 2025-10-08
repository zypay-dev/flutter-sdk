/// Basic usage example for Zypay Flutter SDK
library;

import 'package:flutter/material.dart';
import 'package:zypay_flutter_sdk/zypay_flutter_sdk.dart';

/// Basic example showing simple payment integration
class BasicUsageExample extends StatelessWidget {
  const BasicUsageExample({super.key});

  @override
  Widget build(BuildContext context) {
    return ZypayProvider(
      config: const ZypayConfig(
        token: 'your-api-token',
        debug: DebugConfig(enabled: true),
      ),
      child: MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: const Text('Basic Payment Example')),
          body: Center(
            child: ZypayPaymentButton(
              userId: 'user123',
              buttonText: 'Pay Now',
              onPaymentComplete: () {
                debugPrint('Payment completed!');
              },
              onPaymentFailed: (error) {
                debugPrint('Payment failed: ${error.message}');
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Example using ZypayService directly
class ServiceUsageExample extends StatefulWidget {
  const ServiceUsageExample({super.key});

  @override
  State<ServiceUsageExample> createState() => _ServiceUsageExampleState();
}

class _ServiceUsageExampleState extends State<ServiceUsageExample> {
  late ZypayService _service;

  @override
  void initState() {
    super.initState();
    _service = ZypayService(
      token: 'your-api-token',
      config: const ZypayConfig(
        token: 'your-api-token',
        debug: DebugConfig(enabled: true),
      ),
    );
    _initializePayment();
  }

  Future<void> _initializePayment() async {
    try {
      await _service.initialize('user123');

      // Get available options
      final options = await _service.getOptions();
      debugPrint('Available blockchains: ${options.blockchains}');

      // Get recent transactions
      final transactions = await _service.getRecentTransactions();
      debugPrint('Recent transactions: ${transactions.length}');

      // Process a transaction
      final transaction = await _service.processTransaction(
        blockchain: BlockchainType.ton,
      );
      debugPrint('Transaction created: ${transaction.id}');
    } catch (error) {
      debugPrint('Error: $error');
    }
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PaymentState>(
      stream: _service.stateStream,
      initialData: const PaymentState(),
      builder: (context, snapshot) {
        final state = snapshot.data!;

        return Scaffold(
          appBar: AppBar(title: const Text('Service Usage Example')),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Status: ${state.status}'),
                Text('Loading: ${state.loading}'),
                if (state.error != null) Text('Error: ${state.error!.message}'),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Example with custom styling
class StyledPaymentButton extends StatelessWidget {
  const StyledPaymentButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ZypayPaymentButton(
      userId: 'user123',
      buttonText: 'Complete Purchase',
      buttonStyle: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
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
        debugPrint('Payment completed successfully!');
      },
      onPaymentFailed: (error) {
        debugPrint('Payment failed: ${error.message}');
        if (error.retryable) {
          debugPrint('You can retry this payment');
        }
      },
    );
  }
}

/// Example with state consumer
class StateConsumerExample extends StatelessWidget {
  const StateConsumerExample({super.key});

  @override
  Widget build(BuildContext context) {
    return ZypayProvider(
      config: const ZypayConfig(
        token: 'your-api-token',
      ),
      child: MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: const Text('State Consumer Example')),
          body: ZypayConsumer(
            builder: (context, state, child) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Payment Status: ${state.status}'),
                  if (state.loading) const CircularProgressIndicator(),
                  if (state.error != null)
                    Text(
                      'Error: ${state.error!.message}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  const SizedBox(height: 20),
                  child!,
                ],
              );
            },
            child: ZypayPaymentButton(
              userId: 'user123',
              onPaymentComplete: () {
                debugPrint('Payment completed!');
              },
            ),
          ),
        ),
      ),
    );
  }
}
