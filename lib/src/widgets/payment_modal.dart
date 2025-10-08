/// Payment modal widget
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/types/payment_state.dart';
import '../core/types/payment_types.dart';
import '../services/zypay_service.dart';
import 'blockchain_selector.dart';
import 'package_selector.dart';
import 'payment_details_view.dart';

/// Main payment modal widget
class PaymentModal extends StatelessWidget {
  const PaymentModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PaymentState>(
      builder: (context, state, child) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              _buildHeader(context, state),
              Expanded(
                child: _buildContent(context, state),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, PaymentState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Payment',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getStatusText(state.status),
                  style: TextStyle(
                    fontSize: 14,
                    color: _getStatusColor(state.status),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, PaymentState state) {
    if (state.status == PaymentStatus.loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state.status == PaymentStatus.failed && state.error != null) {
      return _buildError(context, state.error!);
    }

    if (state.status == PaymentStatus.selecting) {
      // Show blockchain and package selection
      if (state.packageType == PackageType.multiple &&
          state.packages.isNotEmpty) {
        return PackageSelector(
          packages: state.packages,
          blockchains: state.blockchains,
        );
      } else {
        return BlockchainSelector(blockchains: state.blockchains);
      }
    }

    if (state.status == PaymentStatus.processing ||
        state.status == PaymentStatus.pending) {
      return PaymentDetailsView(transaction: state.transaction!);
    }

    return const Center(
      child: Text('Unknown state'),
    );
  }

  Widget _buildError(BuildContext context, PaymentError error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Payment Error',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              error.message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            if (error.retryable) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  context.read<ZypayService>().reconnect();
                },
                child: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getStatusText(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.idle:
        return 'Ready';
      case PaymentStatus.loading:
        return 'Loading...';
      case PaymentStatus.selecting:
        return 'Select payment method';
      case PaymentStatus.processing:
        return 'Processing payment';
      case PaymentStatus.pending:
        return 'Pending confirmation';
      case PaymentStatus.confirmed:
        return 'Payment confirmed';
      case PaymentStatus.expired:
        return 'Payment expired';
      case PaymentStatus.failed:
        return 'Payment failed';
      case PaymentStatus.cancelled:
        return 'Payment cancelled';
    }
  }

  Color _getStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.confirmed:
        return Colors.green;
      case PaymentStatus.failed:
      case PaymentStatus.expired:
      case PaymentStatus.cancelled:
        return Colors.red;
      case PaymentStatus.processing:
      case PaymentStatus.pending:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
