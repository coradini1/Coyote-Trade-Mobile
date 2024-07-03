import 'package:flutter/material.dart';

class AssetItem extends StatelessWidget {
  final String symbol;
  final double quantity;
  final double value;
  final double change;
  final double changePercentage;
  final VoidCallback onTapDetails;

  AssetItem({
    required this.symbol,
    required this.quantity,
    required this.value,
    required this.change,
    required this.changePercentage,
    required this.onTapDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 2.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    symbol.isNotEmpty ? symbol : 'Unknown Symbol',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text('QNTY ${quantity.toStringAsFixed(2)}'),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'VALUE \$${value.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  'CHANGE \$${change.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16,
                    color: change >= 0 ? Colors.green : Colors.red,
                  ),
                ),
                Text(
                  '(${changePercentage.toStringAsFixed(2)}%)',
                  style: TextStyle(
                    fontSize: 12,
                    color: change >= 0 ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16.0),
            GestureDetector(
              onTap: onTapDetails,
              child: const Icon(Icons.visibility),
            ),
          ],
        ),
      ),
    );
  }
}
