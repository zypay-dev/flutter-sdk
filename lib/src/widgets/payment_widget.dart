/// Main payment widget for Zypay SDK
library;

import 'package:flutter/material.dart';
import '../core/types/payment_state.dart';
import '../core/types/payment_types.dart';
import '../provider/zypay_provider.dart';
import 'option_selection_widget.dart';
import 'payment_details_widget.dart';
import 'loading_widget.dart';
import 'error_widget.dart' as zypay;

/// Main payment widget that manages the payment flow
class PaymentWidget extends StatelessWidget {
  const PaymentWidget({super.key, this.onClose});
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return ZypayConsumer(
      builder: (context, state, child) {
        if (!state.isOpen) {
          return const SizedBox.shrink();
        }

        return Material(
          color: Colors.black54,
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600, maxHeight: 800),
              margin: const EdgeInsets.all(16),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeader(context, state),
                    Expanded(child: _buildContent(context, state)),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, PaymentState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _getHeaderTitle(state.status),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () {
              final zypay = ZypayProvider.of(context);
              zypay.closePayment();
              onClose?.call();
            },
          ),
        ],
      ),
    );
  }

  String _getHeaderTitle(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.loading:
        return 'Loading...';
      case PaymentStatus.selecting:
        return 'Select Payment Option';
      case PaymentStatus.processing:
        return 'Payment Processing';
      case PaymentStatus.pending:
        return 'Payment Pending';
      case PaymentStatus.confirmed:
        return 'Payment Confirmed';
      case PaymentStatus.failed:
        return 'Payment Failed';
      case PaymentStatus.expired:
        return 'Payment Expired';
      case PaymentStatus.cancelled:
        return 'Payment Cancelled';
      default:
        return 'Zypay Payment';
    }
  }

  Widget _buildContent(BuildContext context, PaymentState state) {
    if (state.status == PaymentStatus.loading) {
      return const LoadingWidget(message: 'Initializing payment...');
    }

    if (state.hasError) {
      return zypay.PaymentErrorWidget(
        error: state.error!,
        onRetry: () {
          // Retry logic
          final zypay = ZypayProvider.of(context);
          if (state.userId != null) {
            zypay.initializePayment(userId: state.userId!);
          }
        },
        onClose: () {
          final zypay = ZypayProvider.of(context);
          zypay.closePayment();
        },
      );
    }

    switch (state.status) {
      case PaymentStatus.selecting:
        return OptionSelectionWidget(
          blockchains: state.blockchains,
          packages: state.packages,
          recentTransactions: state.recentTransactions,
          onSelectBlockchain: (blockchain, packageName) async {
            final zypay = ZypayProvider.of(context);
            try {
              await zypay.processTransaction(
                blockchain: blockchain,
                packageName: packageName,
              );
            } catch (e) {
              // Error handling is done in the client
            }
          },
        );

      case PaymentStatus.processing:
      case PaymentStatus.pending:
        if (state.transaction != null) {
          return PaymentDetailsWidget(
            transaction: state.transaction!,
            expiryMinutes: state.paymentExpiryMinutes,
          );
        }
        return const LoadingWidget(message: 'Processing payment...');

      case PaymentStatus.confirmed:
        return _buildSuccessWidget(context);

      case PaymentStatus.expired:
        return _buildExpiredWidget(context);

      case PaymentStatus.failed:
        if (state.error != null) {
          return zypay.PaymentErrorWidget(
            error: state.error!,
            onRetry: () {
              final zypay = ZypayProvider.of(context);
              if (state.userId != null) {
                zypay.initializePayment(userId: state.userId!);
              }
            },
            onClose: () {
              final zypay = ZypayProvider.of(context);
              zypay.closePayment();
            },
          );
        }
        return const Center(child: Text('Payment failed'));

      default:
        return const Center(child: Text('Zypay Payment'));
    }
  }

  Widget _buildSuccessWidget(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 80),
          const SizedBox(height: 24),
          const Text(
            'Payment Confirmed!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'Your payment has been successfully processed.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              final zypay = ZypayProvider.of(context);
              zypay.closePayment();
              onClose?.call();
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildExpiredWidget(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.timer_off, color: Colors.orange, size: 80),
          const SizedBox(height: 24),
          const Text(
            'Payment Expired',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'The payment window has expired. Please try again.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              final zypay = ZypayProvider.of(context);
              zypay.closePayment();
              onClose?.call();
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
