import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widgets/drawer.dart';
import '../widgets/asset_item.dart';

class AssetsPage extends StatefulWidget {
  final String token;

  const AssetsPage({Key? key, required this.token}) : super(key: key);

  @override
  _AssetsPageState createState() => _AssetsPageState();
}

class _AssetsPageState extends State<AssetsPage> {
  List<dynamic> assets = [];
  bool isLoading = true;
  String username = "";

  @override
  void initState() {
    super.initState();
    fetchUserData();
    getAssetsData();
  }

  Future<void> getAssetsData() async {
    const url = 'http://172.21.8.213:3002/api/assets/all';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          assets = data['data'];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load assets');
      }
    } catch (error) {
      print(error);
    }
  }

  Future<void> fetchUserData() async {
    const url = 'http://172.21.8.213:3002/api/user/mobile';
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
      } else {
        setState(() {
          username = "User";
        });
      }
    } catch (error) {
      setState(() {
        username = "User";
      });
    }
  }

  Future<void> createAlert(int assetId, String symbol, dynamic targetPrice,
      dynamic lowerThreshold) async {
    const url = 'http://172.21.8.213:3002/api/alerts/create';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
        body: jsonEncode({
          'assetId': assetId,
          'assetSymbol': symbol,
          'targetPrice': targetPrice,
          'lowerThreshold': lowerThreshold,
        }),
      );

      if (response.statusCode == 200) {
        print('Alert created successfully');
      } else {
        throw Exception('Failed to create alert');
      }
    } catch (error) {
      print(error);
    }
  }

  void _showAssetDetails(
      int assetId, String symbol, dynamic quantity, dynamic value) {
    final TextEditingController targetPriceController = TextEditingController();
    final TextEditingController lowerThresholdController =
        TextEditingController();

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
                          'NVIDIA',
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
                  'HIGH TARGET PRICE',
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
                const Text(
                  'LOWER THRESHOLD PRICE',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: lowerThresholdController,
                  decoration: const InputDecoration(
                    hintText: 'PRICE ALERT',
                    contentPadding: EdgeInsets.symmetric(horizontal: 8),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    dynamic targetPrice =
                        double.tryParse(targetPriceController.text);
                    dynamic lowerThreshold =
                        double.tryParse(lowerThresholdController.text);
                    if (targetPrice != null) {
                      createAlert(assetId, symbol, targetPrice, lowerThreshold);
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
                    minimumSize: const Size(double.infinity, 36),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('CREATE'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assets'),
      ),
      drawer: DrawerWidget(
        token: widget.token,
        username: username,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "CREATE ALERTS FOR YOUR ASSETS",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Your Assets",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: assets.length,
                      itemBuilder: (context, index) {
                        final asset = assets[index];
                        return AssetItem(
                          assetId: asset['id'],
                          symbol: asset['asset_symbol'],
                          quantity: asset['quantity'],
                          value: asset['buy_price'],
                          change: 0,
                          changePercentage: 0,
                          onTapDetails: () {
                            _showAssetDetails(
                              asset['id'],
                              asset['asset_symbol'],
                              asset['quantity'],
                              asset['buy_price'],
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
