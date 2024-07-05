import 'package:flutter/material.dart';

class AssetItem extends StatelessWidget {
  final int assetId;
  final String symbol;
  final dynamic quantity;
  final dynamic value;
  final double change;
  final double changePercentage;
  final VoidCallback onTapDetails;

  const AssetItem({
    Key? key,
    required this.assetId,
    required this.symbol,
    required this.quantity,
    required this.value,
    required this.change,
    required this.changePercentage,
    required this.onTapDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTapDetails,
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                symbol,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text('Quantity: ${quantity.toStringAsFixed(2)}'),
              Text('Value: \$${value.toStringAsFixed(2)}'),
              Text(
                  'Change: ${change >= 0 ? '+' : ''}${change.toStringAsFixed(2)} (${changePercentage.toStringAsFixed(2)}%)'),
            ],
          ),
        ),
      ),
    );
  }
}
