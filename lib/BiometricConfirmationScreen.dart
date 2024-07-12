import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'ParentalControlScreen.dart';  // Ensure this import matches the location of your ParentalControlScreen

class BiometricConfirmationScreen extends StatefulWidget {
  @override
  _BiometricConfirmationScreenState createState() => _BiometricConfirmationScreenState();
}

class _BiometricConfirmationScreenState extends State<BiometricConfirmationScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  String _authorized = 'Not Authorized';
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    _authenticate();
  }

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
        Navigator.of(context).pushReplacement(MaterialPageRoute(
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
        child: _isAuthenticating
            ? CircularProgressIndicator()
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Authentication status: $_authorized'),
          ],
        ),
      ),
    );
  }
}
