import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../widgets/alert_card.dart';
import '../widgets/drawer.dart';

class HomePage extends StatefulWidget {
  final String token;
  final Map<String, dynamic>? newAlert;

  HomePage({Key? key, required this.token, this.newAlert}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> alerts = [];
  List<dynamic> assets = [];
  bool isLoading = true;
  String username = "";

  @override
  void initState() {
    super.initState();
    fetchUserData();
    fetchAssets();
    fetchAlerts();
    if (widget.newAlert != null) {
      _addOrUpdateAlert(widget.newAlert!);
    }
  }

  void _addOrUpdateAlert(Map<String, dynamic> newAlert) {
    final existingIndex =
        alerts.indexWhere((alert) => alert['symbol'] == newAlert['symbol']);
    if (existingIndex >= 0) {
      setState(() {
        alerts[existingIndex] = newAlert;
      });
    } else {
      setState(() {
        alerts.add(newAlert);
      });
    }
  }

  Future<void> fetchAssets() async {
    const url = 'http://localhost:3002/api/assets/all';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          assets = data['data'] ?? [];
        });
        print('Assets: $assets');
      } else {
        throw Exception('Failed to load assets');
      }
    } catch (error) {
      final alert = error.toString();
      AlertDialog warning = AlertDialog(
        title: const Text("Error"),
        content: Text(alert),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("OK"),
          ),
        ],
      );
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return warning;
        },
      );
    }
  }

  Future<void> UpdateAlert(String symbol, double targetPrice) async {
    final asset = assets.firstWhere((asset) => asset['asset_symbol'] == symbol,
        orElse: () => null);
    if (asset == null) {
      return;
    }
    final assetId = asset['id'];

    const url = 'http://localhost:3002/api/alerts/update';
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'asset_id': assetId,
          'symbol': symbol,
          'target_price': targetPrice,
        }),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _addOrUpdateAlert(data['data']);
      } else {
        throw Exception('Failed to update alert');
      }
    } catch (error) {
      final alert = error.toString();
      AlertDialog warning = AlertDialog(
        title: const Text("Error"),
        content: Text(alert),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("OK"),
          ),
        ],
      );
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return warning;
        },
      );
    }
  }

  void _showAssetDetails(String symbol, dynamic quantity, dynamic value) {
    final TextEditingController targetPriceController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          titlePadding: EdgeInsets.zero,
          contentPadding: EdgeInsets.zero,
          content: Container(
            width: double.maxFinite,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          symbol,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'Company Name',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'QNTY ${quantity.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'CURRENT PRICE',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '\$${value.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'TARGET ALERT PRICE',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: targetPriceController,
                  decoration: const InputDecoration(
                    hintText: 'PRICE ALERT',
                    contentPadding: EdgeInsets.symmetric(horizontal: 8),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    double? targetPrice =
                        double.tryParse(targetPriceController.text);
                    if (targetPrice != null) {
                      UpdateAlert(symbol, targetPrice);
                      Navigator.of(context).pop();
                    } else {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Invalid Price'),
                            content: const Text(
                                'Please enter a valid target price.'),
                            actions: [
                              TextButton(
                                child: const Text('OK'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 36),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('UPDATE'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 36),
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('DELETE'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> fetchUserData() async {
    setState(() {});
    const url = 'http://localhost:3002/api/user/mobile';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final user = data['user'];
        setState(() {
          username = "${user['name']} ${user['surname']}";
        });
      } else {}
    } catch (error) {
      final alert = error.toString();
      AlertDialog warning = AlertDialog(
        title: const Text("Error"),
        content: Text(alert),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("OK"),
          ),
        ],
      );
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return warning;
        },
      );
    }
  }

  Future<void> fetchAlerts() async {
    const url = 'http://localhost:3002/api/alerts/all';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );
      print(response.body);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(data);
        setState(() {
          alerts = data['data'] ?? [];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load alerts');
      }
    } catch (error) {
      final alert = error.toString();
      AlertDialog warning = AlertDialog(
        title: const Text("Error"),
        content: Text(alert),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("OK"),
          ),
        ],
      );
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return warning;
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Your Alerts'),
      ),
      drawer: DrawerWidget(token: widget.token, username: username),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: alerts.length,
              itemBuilder: (context, index) {
                final alert = alerts[index];
                return AlertCard(
                  symbol: alert['asset_symbol'] ?? '',
                  companyName: alert['companyName'] ?? '',
                  quantity: alert['quantity'] ?? 0,
                  currentPrice: alert['currentPrice'] ?? 0,
                  targetPrice: alert['target_price'] ?? 0,
                  onTapDetails: () {
                    _showAssetDetails(
                      alert['asset_symbol'],
                      alert['quantity'],
                      alert['currentPrice'],
                    );
                  },
                );
              },
            ),
    );
  }
}
