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
        title: Text(
          'Settings',
          style: TextStyle(fontFamily: 'ComicSans', fontSize: 24, color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.purple[400],
      ),
      body: ListView(
        children: ListTile.divideTiles(
          context: context,
          tiles: [
            ListTile(
              leading: Icon(Icons.security, color: Colors.purple[400], size: 30),
              title: Text('Parental Controls', style: TextStyle(fontFamily: 'ComicSans', fontSize: 18)),
              subtitle: Text('Secure access to parental controls', style: TextStyle(fontFamily: 'ComicSans', fontSize: 14)),
              trailing: Icon(Icons.chevron_right, color: Colors.purple[400]),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => AuthScreen(),
                ));
              },
            ),
            ListTile(
              leading: Icon(Icons.vpn_key, color: Colors.purple[400], size: 30),
              title: Text('Set Password', style: TextStyle(fontFamily: 'ComicSans', fontSize: 18)),
              trailing: Icon(Icons.chevron_right, color: Colors.purple[400]),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => SetupPasswordScreen(initialPassword: '',),
                ));
              },
            ),
            ListTile(
              leading: Icon(Icons.fingerprint, color: Colors.purple[400], size: 30),
              title: Text('Biometric Authentication', style: TextStyle(fontFamily: 'ComicSans', fontSize: 18)),
              trailing: Icon(Icons.chevron_right, color: Colors.purple[400]),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => BiometricAuthScreen(),
                ));
              },
            ),

            ListTile(
              leading: Icon(Icons.notifications, color: Colors.purple[400], size: 30),
              title: Text('Notifications', style: TextStyle(fontFamily: 'ComicSans', fontSize: 18)),
              trailing: Icon(Icons.chevron_right, color: Colors.purple[400]),
              onTap: () {
                // Placeholder for notification settings
              },
            ),
            ListTile(
              leading: Icon(Icons.feedback, color: Colors.purple[400], size: 30),
              title: Text('Feedback', style: TextStyle(fontFamily: 'ComicSans', fontSize: 18)),
              trailing: Icon(Icons.chevron_right, color: Colors.purple[400]),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => FeedbackScreen(),
                ));
              },
            ),
            ListTile(
              leading: Icon(Icons.help_outline, color: Colors.purple[400], size: 30),
              title: Text('Help & Support', style: TextStyle(fontFamily: 'ComicSans', fontSize: 18)),
              trailing: Icon(Icons.chevron_right, color: Colors.purple[400]),
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
          child: Text('Sign Out', style: TextStyle(fontFamily: 'ComicSans', fontSize: 18)),
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
            padding: EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
      ),
    );
  }
}
