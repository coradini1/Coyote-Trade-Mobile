// lib/widgets/asset_item.dart
import 'package:flutter/material.dart';

class AssetItem extends StatelessWidget {
  final String symbol;
  final double quantity;
  final double value;
  final double change;
  final double changePercentage;

  AssetItem({
    required this.symbol,
    required this.quantity,
    required this.value,
    required this.change,
    required this.changePercentage,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(symbol,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text(quantity.toString(), style: TextStyle(fontSize: 16)),
          Text('\$${value.toStringAsFixed(2)}', style: TextStyle(fontSize: 16)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${change.toStringAsFixed(2)}',
                style: TextStyle(
                    fontSize: 16,
                    color: change >= 0 ? Colors.green : Colors.red),
              ),
              Text(
                '(${changePercentage.toStringAsFixed(2)}%)',
                style: TextStyle(
                    fontSize: 12,
                    color: change >= 0 ? Colors.green : Colors.red),
              ),
            ],
          ),
          Icon(Icons.visibility, size: 20),
        ],
      ),
    );
  }
}
