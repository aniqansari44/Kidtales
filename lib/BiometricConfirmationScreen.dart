import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

class BiometricConfirmationScreen extends StatefulWidget {
  @override
  _BiometricConfirmationScreenState createState() => _BiometricConfirmationScreenState();
}

class _BiometricConfirmationScreenState extends State<BiometricConfirmationScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  String _authorized = 'Not Authorized';
  bool _isAuthenticating = false;

  Future<void> _authenticate() async {
    bool authenticated = false;
    try {
      setState(() {
        _isAuthenticating = true;
        _authorized = 'Authenticating...';
      });
      authenticated = await auth.authenticate(
        localizedReason: 'Please authenticate to access parental controls',
        options: const AuthenticationOptions(biometricOnly: true), // Ensure only biometric auth is used
      );
      if (authenticated) {
        Navigator.of(context).pop(true); // Return true if authentication is successful
      } else {
        _showErrorDialog("Authentication failed");
      }
    } catch (e) {
      print('Error using biometric authentication: $e');
      _showErrorDialog("Authentication Error: $e");
    } finally {
      setState(() {
        _isAuthenticating = false;
        _authorized = authenticated ? 'Authorized' : 'Not Authorized';
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
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Biometric Authentication'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            AnimatedSwitcher(
              duration: Duration(milliseconds: 500),
              child: Text(
                _authorized,
                key: ValueKey<String>(_authorized),
                style: TextStyle(fontSize: 24, color: theme.colorScheme.secondary),
              ),
            ),
            SizedBox(height: 40),
            ElevatedButton.icon(
              icon: _isAuthenticating ? CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)) : Icon(Icons.fingerprint),
              label: Text(_isAuthenticating ? 'Authenticating...' : 'Authenticate'),
              onPressed: _isAuthenticating ? null : _authenticate,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,  // Changed from 'primary'
                foregroundColor: Colors.white,  // Changed from 'onPrimary'
                textStyle: TextStyle(fontSize: 18),
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
