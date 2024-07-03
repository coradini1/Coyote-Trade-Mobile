import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widgets/drawer.dart';
import '../widgets/asset_item.dart';
import 'home_page.dart';

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
    const url = 'http://localhost:3002/api/assets/all';
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

  void _showAssetDetails(String symbol, double quantity, double value) {
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
                      Navigator.of(context).pop();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomePage(
                            token: widget.token,
                            newAlert: {
                              'symbol': symbol,
                              'companyName': 'NVIDIA',
                              'quantity': quantity,
                              'currentPrice': value,
                              'targetPrice': targetPrice,
                            },
                          ),
                        ),
                      );
                    } else {}
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 36),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('CREATE'),
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
                    "Assets",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListView.builder(
                          itemCount: assets.length,
                          itemBuilder: (context, index) {
                            final asset = assets[index];
                            if (asset["asset_symbol"] != null &&
                                asset["quantity"] != null &&
                                asset["buy_price"] != null) {
                              return AssetItem(
                                symbol: asset["asset_symbol"],
                                quantity: asset["quantity"].toDouble(),
                                value: asset["buy_price"].toDouble(),
                                change: 0,
                                changePercentage: 0,
                                onTapDetails: () {
                                  _showAssetDetails(
                                    asset["asset_symbol"],
                                    asset["quantity"].toDouble(),
                                    asset["buy_price"].toDouble(),
                                  );
                                },
                              );
                            } else {
                              return SizedBox();
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
