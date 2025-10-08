/// Zypay provider widget for Flutter integration
library;

import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../core/config/zypay_config.dart';
import '../core/types/payment_state.dart';
import 'zypay_service.dart';

/// Provider widget for Zypay SDK integration
class ZypayProvider extends StatefulWidget {
  const ZypayProvider({
    required this.token,
    required this.child,
    this.config,
    super.key,
  });

  /// API token for authentication
  final String token;

  /// SDK configuration
  final ZypayConfig? config;

  /// Child widget
  final Widget child;

  @override
  State<ZypayProvider> createState() => _ZypayProviderState();

  /// Get ZypayService from context
  static ZypayService of(BuildContext context) {
    final provider = context.read<ZypayService>();
    return provider;
  }

  /// Try to get ZypayService from context (returns null if not found)
  static ZypayService? maybeOf(BuildContext context) {
    try {
      return context.read<ZypayService>();
    } catch (e) {
      return null;
    }
  }
}

class _ZypayProviderState extends State<ZypayProvider> {
  late ZypayService _service;

  @override
  void initState() {
    super.initState();
    _service = ZypayService(
      token: widget.token,
      config: widget.config,
    );
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Provider<ZypayService>.value(
      value: _service,
      child: StreamProvider<PaymentState>.value(
        value: _service.stateStream,
        initialData: const PaymentState(),
        child: widget.child,
      ),
    );
  }
}

/// Consumer widget for payment state
class ZypayConsumer extends StatelessWidget {
  const ZypayConsumer({
    required this.builder,
    this.child,
    super.key,
  });

  /// Builder function
  final Widget Function(
    BuildContext context,
    PaymentState state,
    Widget? child,
  ) builder;

  /// Optional child widget
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Consumer<PaymentState>(
      builder: (context, state, child) => builder(context, state, child),
      child: child,
    );
  }
}
