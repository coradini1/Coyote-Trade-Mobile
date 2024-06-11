import 'package:flutter/material.dart';

class AlertCard extends StatelessWidget {
  final String symbol;
  final String companyName;
  final double quantity;
  final double currentPrice;
  final double targetPrice;

  AlertCard({
    required this.symbol,
    required this.companyName,
    required this.quantity,
    required this.currentPrice,
    required this.targetPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 2.0,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    symbol,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(companyName),
                  SizedBox(height: 8.0),
                  Text('QNTY ${quantity.toStringAsFixed(2)}'),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'CURRENT PRICE \$${currentPrice.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  'TARGET PRICE \$${targetPrice.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            SizedBox(width: 16.0),
            Icon(Icons.visibility),
          ],
        ),
      ),
    );
  }
}
