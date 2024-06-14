import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'pages/registration_page.dart';
import 'pages/assets_page.dart';

void main() async {
  runApp(CoyoteTradingApp());
}

class CoyoteTradingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coyote Trading',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/login',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/home':
            final args = settings.arguments as String;
            return MaterialPageRoute(
              builder: (context) => HomePage(token: args),
            );
          case '/assets':
            final args = settings.arguments as String;
            return MaterialPageRoute(
              builder: (context) => AssetsPage(token: args),
            );
          default:
            return null;
        }
      },
      routes: {
        '/login': (context) => LoginPage(),
        '/register': (context) => RegistrationPage(),
      },
    );
  }
}
