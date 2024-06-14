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
    _mockAssetsData();
  }

  void _showAssetDetails(String symbol) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Asset Details'),
          content: Text('Detalhes da ação $symbol serão mostrados aqui.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
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

  Future<void> _mockAssetsData() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      assets = List.generate(
          12,
          (index) => {
                "symbol": "NVDA",
                "quantity": 1.54,
                "value": 950.84,
                "change": 399.09,
                "changePercentage": 72.33,
              });
      isLoading = false;
    });
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
                  Text(
                    "CREATE ALERTS FOR YOUR ASSETS",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Assets",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
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
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListView.builder(
                          itemCount: assets.length,
                          itemBuilder: (context, index) {
                            final asset = assets[index];
                            return AssetItem(
                              symbol: asset["symbol"],
                              quantity: asset["quantity"],
                              value: asset["value"],
                              change: asset["change"],
                              changePercentage: asset["changePercentage"],
                              onTapDetails: () {
                                _showAssetDetails(asset["symbol"]);
                              },
                            );
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
