/// Package selector widget
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/types/payment_types.dart';
import '../services/zypay_service.dart';

/// Widget for selecting package and blockchain
class PackageSelector extends StatefulWidget {
  const PackageSelector({
    required this.packages,
    required this.blockchains,
    super.key,
  });

  final List<Package> packages;
  final List<BlockchainType> blockchains;

  @override
  State<PackageSelector> createState() => _PackageSelectorState();
}

class _PackageSelectorState extends State<PackageSelector> {
  Package? _selectedPackage;
  BlockchainType? _selectedBlockchain;

  Future<void> _handleSubmit(BuildContext context) async {
    if (_selectedPackage == null || _selectedBlockchain == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a package and blockchain'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final service = context.read<ZypayService>();

    try {
      await service.processTransaction(
        blockchain: _selectedBlockchain!,
        packageName: _selectedPackage!.name,
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }

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
          'Select Package',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...widget.packages.map(_buildPackageCard),
        const SizedBox(height: 24),
        if (_selectedPackage != null) ...[
          const Text(
            'Select Blockchain',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...widget.blockchains.map(_buildBlockchainCard),
          const SizedBox(height: 24),
          if (_selectedBlockchain != null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _handleSubmit(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildPackageCard(Package package) {
    final isSelected = _selectedPackage == package;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isSelected ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color:
              isSelected ? Theme.of(context).primaryColor : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () => setState(() => _selectedPackage = package),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      package.name.value.toUpperCase(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Colors.black,
                      ),
                    ),
                    if (package.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        package.description!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      '\$${package.subscriptionFee.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).primaryColor,
                  size: 28,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBlockchainCard(BlockchainType blockchain) {
    final isSelected = _selectedBlockchain == blockchain;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isSelected ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color:
              isSelected ? Theme.of(context).primaryColor : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () => setState(() => _selectedBlockchain = blockchain),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getBlockchainColor(blockchain).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getBlockchainIcon(blockchain),
                  color: _getBlockchainColor(blockchain),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _getBlockchainName(blockchain),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.black,
                  ),
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
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
