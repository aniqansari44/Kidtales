import 'package:flutter/material.dart';
import 'ParentalControlScreen.dart';
import 'BiometricConfirmationScreen.dart'; // Screen for confirming biometric auth
import 'PasswordConfirmationScreen.dart'; // Screen for confirming password auth

class AuthScreen extends StatelessWidget {
  void _authenticate(BuildContext context, String method) async {
    bool authenticated = false;
    if (method == 'biometric') {
      // Navigate to Biometric Confirmation Screen
      authenticated = await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => BiometricConfirmationScreen(),
      ));
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
                onPressed: () => _authenticate(context, 'biometric'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.indigo,
                  onPrimary: Colors.white,
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
                  primary: Colors.teal,
                  onPrimary: Colors.white,
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
