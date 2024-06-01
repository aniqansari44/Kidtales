import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'AuthScreen.dart'; // Auth screen for initial security checks
import 'BiometricAuthScreen.dart';
import 'SetupPasswordScreen.dart';
import 'FeedbackScreen.dart';
import 'login_page.dart'; // Import your login page

class SettingsScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        children: ListTile.divideTiles(
          context: context,
          tiles: [
            ListTile(
              leading: Icon(Icons.security),
              title: Text('Parental Controls'),
              subtitle: Text('Secure access to parental controls'),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => AuthScreen(),
                ));
              },
            ),
            ListTile(
              leading: Icon(Icons.vpn_key),
              title: Text('Set Password'),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => SetupPasswordScreen(),
                ));
              },
            ),
            ListTile(
              leading: Icon(Icons.fingerprint),
              title: Text('Biometric Authentication'),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => BiometricAuthScreen(),
                ));
              },
            ),
            ListTile(
              leading: Icon(Icons.language),
              title: Text('Language'),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                // Placeholder for language settings
              },
            ),
            ListTile(
              leading: Icon(Icons.notifications),
              title: Text('Notifications'),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                // Placeholder for notification settings
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Feedback'),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => FeedbackScreen(),
                ));
              },
            ),
            ListTile(
              leading: Icon(Icons.help_outline),
              title: Text('Help & Support'),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                // Placeholder for help and support
              },
            ),
          ],
        ).toList(),
      ),
      bottomSheet: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16),
        child: ElevatedButton(
          child: Text('Sign Out'),
          onPressed: () async {
            await _auth.signOut();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginPage(onLoginSuccess: () => Navigator.of(context).pushReplacementNamed('/home'))),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
        ),
      ),
    );
  }
}
