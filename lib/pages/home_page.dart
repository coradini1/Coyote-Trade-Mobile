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
  bool isLoading = true;
  String username = "";

  @override
  void initState() {
    super.initState();
    fetchUserData();
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
    const url = 'http://localhost:3002/api/alerts';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      setState(() {
        alerts = json.decode(response.body);
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
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
                  symbol: alert['symbol'],
                  companyName: alert['companyName'],
                  quantity: alert['quantity'],
                  currentPrice: alert['currentPrice'],
                  targetPrice: alert['targetPrice'],
                );
              },
            ),
    );
  }
}
