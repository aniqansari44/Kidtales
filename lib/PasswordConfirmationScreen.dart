import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'ParentalControlScreen.dart'; // Import the ParentalControlScreen

class PasswordConfirmationScreen extends StatefulWidget {
  @override
  _PasswordConfirmationScreenState createState() => _PasswordConfirmationScreenState();
}

class _PasswordConfirmationScreenState extends State<PasswordConfirmationScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  bool _isCorrect = true;

  Future<void> _checkPassword() async {
    String? storedPassword = await _secureStorage.read(key: 'user_password');
    if (_passwordController.text == storedPassword) {
      // If password is correct, navigate to ParentalControlScreen
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ParentalControlScreen(),
      ));
    } else {
      setState(() {
        _isCorrect = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Confirm Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Current Password',
                errorText: _isCorrect ? null : 'Incorrect password',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _checkPassword,
              child: Text('Confirm'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,  // Previously 'primary'
                foregroundColor: Colors.white,  // Previously 'onPrimary' // Text color
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }
}
