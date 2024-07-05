import 'package:flutter/material.dart';

class AlertCard extends StatelessWidget {
  final String symbol;
  final String companyName;
  final dynamic quantity;
  final dynamic currentPrice;
  final dynamic targetPrice;
  final VoidCallback onTapDetails;

  const AlertCard({
    super.key,
    required this.symbol,
    required this.companyName,
    required this.quantity,
    required this.currentPrice,
    required this.targetPrice,
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
                    symbol,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(companyName),
                  const SizedBox(height: 8.0),
                  Text('QNTY ${quantity?.toStringAsFixed(2) ?? '0.00'}'),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'CURRENT PRICE \$${currentPrice?.toStringAsFixed(2) ?? '0.00'}',
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  'TARGET PRICE \$${targetPrice?.toStringAsFixed(2) ?? '0.00'}',
                  style: const TextStyle(fontSize: 16),
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
