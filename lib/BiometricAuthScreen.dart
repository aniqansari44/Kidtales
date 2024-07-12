import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ParentalControlScreen.dart';  // Ensure this import matches the location of your ParentalControlScreen

class BiometricAuthScreen extends StatefulWidget {
  @override
  _BiometricAuthScreenState createState() => _BiometricAuthScreenState();
}

class _BiometricAuthScreenState extends State<BiometricAuthScreen> {
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

  Future<void> _saveBiometricPreference(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('biometricEnabled', value);
    setState(() {
      _biometricEnabled = value;
    });
    if (value) {
      _authenticate();
    }
  }

  Future<void> _authenticate() async {
    final LocalAuthentication auth = LocalAuthentication();
    bool authenticated = false;
    try {
      authenticated = await auth.authenticate(
        localizedReason: 'Scan your fingerprint to authenticate',
        options: const AuthenticationOptions(biometricOnly: true),
      );
      if (authenticated) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => ParentalControlScreen(),  // Direct to Parental Control Screen upon success
        ));
      }
    } catch (e) {
      print('Error using biometric authentication: $e');
      _showErrorDialog(e.toString());
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Authentication Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Biometric Authentication'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SwitchListTile(
              title: Text('Enable Biometric Authentication for Parental Control'),
              value: _biometricEnabled,
              onChanged: (bool value) {
                _saveBiometricPreference(value);
              },
              activeColor: Colors.indigo,
              inactiveThumbColor: Colors.grey,
              inactiveTrackColor: Colors.grey.shade300,
            ),
            AnimatedContainer(
              duration: Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: _biometricEnabled ? Colors.indigo.shade50 : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    _biometricEnabled ? Icons.fingerprint : Icons.fingerprint_outlined,
                    color: _biometricEnabled ? Colors.indigo : Colors.grey,
                    size: 48,
                  ),
                  SizedBox(width: 10),
                  Text(
                    _biometricEnabled ? 'Biometric Authentication Enabled' : 'Biometric Authentication Disabled',
                    style: TextStyle(
                      fontSize: 18,
                      color: _biometricEnabled ? Colors.indigo : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
