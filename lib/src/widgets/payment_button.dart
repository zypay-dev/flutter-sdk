/// Payment button widget
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/types/payment_state.dart';
import '../core/types/payment_types.dart';
import '../services/zypay_service.dart';
import 'payment_modal.dart';

/// A button widget that initializes and manages the payment flow
class ZypayPaymentButton extends StatelessWidget {
  const ZypayPaymentButton({
    required this.userId,
    this.buttonText,
    this.buttonStyle,
    this.textStyle,
    this.onPaymentComplete,
    this.onPaymentFailed,
    this.onPaymentCancelled,
    this.onPaymentExpired,
    this.showLoading = true,
    super.key,
  });

  /// User ID for the payment
  final String userId;

  /// Button text
  final String? buttonText;

  /// Button style
  final ButtonStyle? buttonStyle;

  /// Text style
  final TextStyle? textStyle;

  /// Callback when payment is completed
  final VoidCallback? onPaymentComplete;

  /// Callback when payment fails
  final void Function(PaymentError error)? onPaymentFailed;

  /// Callback when payment is cancelled
  final VoidCallback? onPaymentCancelled;

  /// Callback when payment expires
  final VoidCallback? onPaymentExpired;

  /// Whether to show loading indicator
  final bool showLoading;

  Future<void> _handlePayment(BuildContext context) async {
    final service = context.read<ZypayService>();

    try {
      await service.initialize(userId);

      if (!context.mounted) return;

      // Show payment modal
      final _ = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => const PaymentModal(),
      );

      if (!context.mounted) return;

      // Handle result based on payment state
      final state = service.currentState;

      if (state.status == PaymentStatus.confirmed) {
        onPaymentComplete?.call();
      } else if (state.status == PaymentStatus.failed && state.error != null) {
        onPaymentFailed?.call(state.error!);
      } else if (state.status == PaymentStatus.cancelled) {
        onPaymentCancelled?.call();
      } else if (state.status == PaymentStatus.expired) {
        onPaymentExpired?.call();
      }
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      onPaymentFailed?.call(
        PaymentError(
          code: 'INITIALIZATION_ERROR',
          message: error.toString(),
          retryable: true,
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to initialize payment: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PaymentState>(
      builder: (context, state, child) {
        final isLoading = state.loading && showLoading;

        return ElevatedButton(
          style: buttonStyle ??
              ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
          onPressed: isLoading ? null : () => _handlePayment(context),
          child: isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  buttonText ?? 'Make Payment',
                  style: textStyle ??
                      const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                ),
        );
      },
    );
  }
}
