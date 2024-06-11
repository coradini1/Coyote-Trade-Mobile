import 'package:flutter/material.dart';

class DrawerWidget extends StatelessWidget {
  final String username;

  DrawerWidget({required this.username});
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, $username',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    _logout(context);
                  },
                  child: Text('Log Out'),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.account_balance_wallet),
            title: Text('Assets'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  // Function to handle logout
  void _logout(BuildContext context) {
    // Print the context for debugging
    print("Logout context: $context");

    // Perform any logout actions here, such as clearing user data, etc.
    // After that, navigate back to the login page or any other initial page.
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }
}
