import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../widgets/alert_card.dart';
import '../widgets/drawer.dart';

class HomePage extends StatefulWidget {
  final String token;

  HomePage({Key? key, required this.token}) : super(key: key);

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
  }

  Future<void> fetchUserData() async {
    final url = 'http://localhost:3002/api/user/mobile';
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
        // Handle error
      }
    } catch (error) {
      // Handle error
    }
  }

  Future<void> fetchAlerts() async {
    final url = 'http://localhost:3002/api/alerts';
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

  void _logout(BuildContext context) async {
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Your Alerts'),
      ),
      drawer: DrawerWidget(username: username),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: EdgeInsets.all(16.0),
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
