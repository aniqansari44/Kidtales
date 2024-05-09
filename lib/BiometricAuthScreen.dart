import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'ParentalControlScreen.dart';  // Ensure this import matches the location of your ParentalControlScreen

class BiometricAuthScreen extends StatefulWidget {
  @override
  _BiometricAuthScreenState createState() => _BiometricAuthScreenState();
}

class _BiometricAuthScreenState extends State<BiometricAuthScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  String _authorized = 'Not Authorized';
  bool _isAuthenticating = false;

  Future<void> _authenticate() async {
    bool authenticated = false;
    try {
      setState(() {
        _isAuthenticating = true;
        _authorized = 'Authenticating';
      });
      authenticated = await auth.authenticate(
        localizedReason: 'Scan your fingerprint to authenticate',
        options: const AuthenticationOptions(biometricOnly: true),
      );
      if (authenticated) {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => ParentalControlScreen(),  // Direct to Parental Control Screen upon success
        ));
      }
      setState(() {
        _authorized = authenticated ? 'Authorized' : 'Not Authorized';
      });
    } catch (e) {
      print('Error using biometric authentication: $e');
      setState(() {
        _authorized = "Failed to authenticate: $e";
      });
      _showErrorDialog(e.toString());
    } finally {
      setState(() {
        _isAuthenticating = false;
      });
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
            Text('Authentication status: $_authorized'),
            ElevatedButton(
              onPressed: _isAuthenticating ? null : _authenticate,
              child: Text(_isAuthenticating ? 'Authenticating...' : 'Authenticate'),
            ),
          ],
        ),
      ),
    );
  }
}
