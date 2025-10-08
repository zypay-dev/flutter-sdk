/// Blockchain selector widget
library;

import 'package:flutter/material.dart';
import '../core/types/payment_types.dart';
import '../provider/zypay_provider.dart';

/// Widget for selecting blockchain
class BlockchainSelector extends StatelessWidget {
  const BlockchainSelector({required this.blockchains, super.key});

  final List<BlockchainType> blockchains;

  Future<void> _handleBlockchainSelect(
    BuildContext context,
    BlockchainType blockchain,
  ) async {
    final zypay = ZypayProvider.of(context);

    try {
      await zypay.processTransaction(blockchain: blockchain);
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to process transaction: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Select Blockchain',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...blockchains.map(
          (blockchain) => _buildBlockchainCard(context, blockchain),
        ),
      ],
    );
  }

  Widget _buildBlockchainCard(BuildContext context, BlockchainType blockchain) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _handleBlockchainSelect(context, blockchain),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getBlockchainColor(blockchain).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getBlockchainIcon(blockchain),
                  color: _getBlockchainColor(blockchain),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getBlockchainName(blockchain),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getBlockchainDescription(blockchain),
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  String _getBlockchainName(BlockchainType blockchain) {
    switch (blockchain) {
      case BlockchainType.ton:
        return 'TON';
      case BlockchainType.bsc:
        return 'Binance Smart Chain';
    }
  }

  String _getBlockchainDescription(BlockchainType blockchain) {
    switch (blockchain) {
      case BlockchainType.ton:
        return 'The Open Network';
      case BlockchainType.bsc:
        return 'BSC Network';
    }
  }

  IconData _getBlockchainIcon(BlockchainType blockchain) {
    switch (blockchain) {
      case BlockchainType.ton:
        return Icons.currency_bitcoin;
      case BlockchainType.bsc:
        return Icons.account_balance_wallet;
    }
  }

  Color _getBlockchainColor(BlockchainType blockchain) {
    switch (blockchain) {
      case BlockchainType.ton:
        return Colors.blue;
      case BlockchainType.bsc:
        return Colors.amber;
    }
  }
}
