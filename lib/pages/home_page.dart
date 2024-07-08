import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../widgets/alert_card.dart';
import '../widgets/drawer.dart';

class HomePage extends StatefulWidget {
  final String token;
  final Map<String, dynamic>? newAlert;

  const HomePage({Key? key, required this.token, this.newAlert})
      : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

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
    _initializeNotifications();
    Timer.periodic(const Duration(seconds: 10), (timer) {
      fetchAlerts();
    });
  }

  void _initializeNotifications() async {
    const IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: (String? payload) async {
        if (payload != null) {
          debugPrint('notification payload: $payload');
        }
      },
    );
  }

  void _showNotification(
      String symbol, double currentPrice, String message) async {
    const IOSNotificationDetails iOSPlatformChannelSpecifics =
        IOSNotificationDetails();
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      iOS: iOSPlatformChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin.show(
      0,
      'Price Alert 🚀',
      '$symbol $message at \$$currentPrice',
      platformChannelSpecifics,
      payload: 'item x',
    );
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

  Future<void> deleteAlert(int assetId) async {
    final url = 'http://192.168.0.8:3002/api/alerts/delete/$assetId';
    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      if (response.statusCode == 200) {
        await fetchAlerts();
      } else {
        throw Exception('Failed to delete alert');
      }
    } catch (error) {
      _showErrorDialog(error.toString());
    }
  }

  Future<void> fetchAssets() async {
    const url = 'http://192.168.0.8:3002/api/assets/all';
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
      } else {
        throw Exception('Failed to load assets');
      }
    } catch (error) {
      _showErrorDialog(error.toString());
    }
  }

  void UpdateAlert(
      String symbol, double targetPrice, double lowerThreshold) async {
    final asset = assets.firstWhere((asset) => asset['asset_symbol'] == symbol,
        orElse: () => null);
    if (asset == null) {
      return;
    }
    final assetId = asset['id'];

    const url = 'http://192.168.0.8:3002/api/alerts/update';
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
          'lower_threshold': lowerThreshold,
        }),
      );
      if (response.statusCode == 200) {
        await fetchAlerts();
      } else {
        throw Exception('Failed to update alert');
      }
    } catch (error) {
      _showErrorDialog(error.toString());
    }
  }

  void _showAssetDetails(
    String symbol,
    dynamic quantity,
    dynamic value,
    int assetId,
  ) {
    final TextEditingController targetPriceController = TextEditingController();
    final TextEditingController lowerThresholdController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
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
                    'LOWER TARGET PRICE',
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
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          double? targetPrice =
                              double.tryParse(targetPriceController.text);
                          double? lowerThreshold =
                              double.tryParse(lowerThresholdController.text);
                          if (targetPrice != null && lowerThreshold != null) {
                            UpdateAlert(symbol, targetPrice, lowerThreshold);
                            Navigator.of(context).pop();
                          } else {
                            _showErrorDialog('Please enter valid prices.');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(100, 36),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('UPDATE'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          deleteAlert(assetId);
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(100, 36),
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('DELETE'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> fetchUserData() async {
    const url = 'http://192.168.0.8:3002/api/user/mobile';
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
        throw Exception('Failed to load user data');
      }
    } catch (error) {
      _showErrorDialog(error.toString());
    }
  }

  Future<void> fetchAlerts() async {
    const url = 'http://192.168.0.8:3002/api/alerts/all';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          alerts = (data['data'] as List<dynamic>)
              .map((alert) => {
                    ...alert,
                    'currentPrice': (alert['currentPrice'] ?? 0).toDouble(),
                    'asset_id': alert['asset_id'],
                  })
              .toList();
          isLoading = false;
        });

        for (var alert in alerts) {
          final currentPrice = (alert['currentPrice'] ?? 0).toDouble();
          if (currentPrice >= alert['target_price']) {
            _showNotification(
                alert['asset_symbol'], currentPrice, "hit the target price");
          } else if (currentPrice <= alert['lower_threshold']) {
            _showNotification(alert['asset_symbol'], currentPrice,
                "dropped below the threshold");
          }
        }
      } else {
        throw Exception('Failed to load alerts');
      }
    } catch (error) {
      _showErrorDialog(error.toString());
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Your Alerts'),
      ),
      drawer: DrawerWidget(token: widget.token, username: username),
      body: RefreshIndicator(
        onRefresh: fetchAlerts,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: alerts.length,
                itemBuilder: (context, index) {
                  final alert = alerts[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: AlertCard(
                      symbol: alert['asset_symbol'] ?? '',
                      companyName: alert['companyName'] ?? '',
                      quantity: alert['quantity'] ?? 0,
                      currentPrice: alert['currentPrice'] ?? 0,
                      targetPrice: alert['target_price'] ?? 0,
                      lowerThreshold: alert['lower_threshold'] ?? 0,
                      onTapDetails: () {
                        _showAssetDetails(
                          alert['asset_symbol'],
                          alert['quantity'],
                          alert['currentPrice'],
                          alert['id'],
                        );
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }
}
