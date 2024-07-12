import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ParentalControlScreen.dart';
import 'BiometricConfirmationScreen.dart'; // Screen for confirming biometric auth
import 'PasswordConfirmationScreen.dart'; // Screen for confirming password auth

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _biometricEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadBiometricPreference();
  }

  Future<void> _loadBiometricPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _biometricEnabled = prefs.getBool('biometricEnabled') ?? false;
    });
  }

  Future<void> _authenticate(BuildContext context, String method) async {
    bool authenticated = false;
    if (method == 'biometric') {
      if (_biometricEnabled) {
        // Navigate to Biometric Confirmation Screen
        authenticated = await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => BiometricConfirmationScreen(),
        ));
      } else {
        authenticated = true;
      }
    } else if (method == 'password') {
      // Navigate to Password Confirmation Screen
      authenticated = await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => PasswordConfirmationScreen(),
      ));
    }

    // If authentication is successful, navigate to Parental Control Screen
    if (authenticated) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ParentalControlScreen(),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Authentication"),
        backgroundColor: Colors.deepPurple, // Updated to a more vibrant color
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: ElevatedButton.icon(
                icon: Icon(Icons.fingerprint, size: 28),
                label: Text("Biometric Authentication", style: TextStyle(fontSize: 16)),
                onPressed: _biometricEnabled ? () => _authenticate(context, 'biometric') : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _biometricEnabled ? Colors.indigo : Colors.grey,  // Change color based on enabled state
                  foregroundColor: Colors.white,  // Previously 'onPrimary'
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 8,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: ElevatedButton.icon(
                icon: Icon(Icons.lock, size: 28),
                label: Text("Password Authentication", style: TextStyle(fontSize: 16)),
                onPressed: () => _authenticate(context, 'password'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,  // Previously 'primary'
                  foregroundColor: Colors.white,  // Previously 'onPrimary'
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
