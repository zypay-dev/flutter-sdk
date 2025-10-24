/// Option selection widget for blockchain and package selection
library;

import 'package:flutter/material.dart';
import '../core/types/payment_types.dart';
import '../core/types/transaction_types.dart';

/// Widget for selecting blockchain and package options
class OptionSelectionWidget extends StatefulWidget {
  const OptionSelectionWidget({
    super.key,
    required this.blockchains,
    required this.packages,
    this.recentTransactions,
    required this.onSelectBlockchain,
  });
  final List<BlockchainType> blockchains;
  final List<Package> packages;
  final List<Transaction>? recentTransactions;
  final Future<void> Function(
    BlockchainType blockchain,
    PackageName? packageName,
  ) onSelectBlockchain;

  @override
  State<OptionSelectionWidget> createState() => _OptionSelectionWidgetState();
}

class _OptionSelectionWidgetState extends State<OptionSelectionWidget> {
  BlockchainType? _selectedBlockchain;
  PackageName? _selectedPackage;
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.recentTransactions != null &&
              widget.recentTransactions!.isNotEmpty)
            _buildRecentTransactions(),
          const SizedBox(height: 24),
          _buildBlockchainSelection(),
          if (widget.packages.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildPackageSelection(),
          ],
          const SizedBox(height: 32),
          _buildContinueButton(),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Transactions',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.recentTransactions!.length,
            itemBuilder: (context, index) {
              final transaction = widget.recentTransactions![index];
              return _buildTransactionCard(transaction);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionCard(Transaction transaction) {
    Color statusColor;
    switch (transaction.status) {
      case TransactionStatus.success:
        statusColor = Colors.green;
        break;
      case TransactionStatus.pending:
        statusColor = Colors.orange;
        break;
      case TransactionStatus.failed:
        statusColor = Colors.red;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(right: 12),
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  transaction.status.name.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              transaction.blockchain.value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              '\$${transaction.package.subscriptionFee.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const Spacer(),
            Text(
              transaction.id.substring(0, 8),
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlockchainSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Blockchain',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: widget.blockchains.map((blockchain) {
            final isSelected = _selectedBlockchain == blockchain;
            return ChoiceChip(
              label: Text(blockchain.value),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedBlockchain = selected ? blockchain : null;
                });
              },
              selectedColor: Theme.of(context).primaryColor,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.w600,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPackageSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Package',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...widget.packages.map((package) {
          final isSelected = _selectedPackage == package.name;
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            color: isSelected
                ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                : null,
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedPackage = isSelected ? null : package.name;
                });
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Radio<PackageName>(
                      value: package.name,
                      groupValue: _selectedPackage,
                      onChanged: (value) {
                        setState(() {
                          _selectedPackage = value;
                        });
                      },
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            package.name.value.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (package.description != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              package.description!,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Text(
                      '\$${package.subscriptionFee.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildContinueButton() {
    final canContinue = _selectedBlockchain != null &&
        (widget.packages.isEmpty || _selectedPackage != null);

    return ElevatedButton(
      onPressed: canContinue && !_isProcessing ? _handleContinue : null,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: _isProcessing
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Text(
              'Continue',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
    );
  }

  Future<void> _handleContinue() async {
    if (_selectedBlockchain == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      await widget.onSelectBlockchain(_selectedBlockchain!, _selectedPackage);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
}
