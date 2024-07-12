import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'signup_page.dart';
import 'SetupPasswordScreen.dart'; // Import the SetupPasswordScreen

class LoginPage extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  LoginPage({required this.onLoginSuccess});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loginUser() async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (userCredential.user != null) {
        Fluttertoast.showToast(msg: 'Login Successful!');

        // Check if password setup has already been completed
        String? isPasswordSetupDone = await _secureStorage.read(key: 'is_password_setup_done');
        if (isPasswordSetupDone == null) {
          // Store the password securely
          await _secureStorage.write(key: 'user_password', value: _passwordController.text);

          // Navigate to the SetupPasswordScreen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SetupPasswordScreen(initialPassword: _passwordController.text),
            ),
          );
        } else {
          // Trigger the callback on successful login
          widget.onLoginSuccess();
        }
      }
    } on FirebaseAuthException catch (e) {
      Fluttertoast.showToast(msg: e.message ?? 'An error occurred during login.');
    } catch (e) {
      Fluttertoast.showToast(msg: 'An error occurred during login.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[50], // Light background color
      body: SingleChildScrollView( // Make the body scrollable
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 50),
              Text('Welcome to KidTales!', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, fontFamily: 'ComicSans', color: Colors.purple[400])),
              SizedBox(height: 20),
              Image.asset('assets/images/logo.png', height: 150),
              SizedBox(height: 50),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Enter your email',
                  labelStyle: TextStyle(fontFamily: 'ComicSans', fontSize: 18, color: Colors.purple[400]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  prefixIcon: Icon(Icons.email, color: Colors.purple[400]),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Enter your password',
                  labelStyle: TextStyle(fontFamily: 'ComicSans', fontSize: 18, color: Colors.purple[400]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  prefixIcon: Icon(Icons.lock, color: Colors.purple[400]),
                ),
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: _loginUser,
                child: Text('Log in', style: TextStyle(fontFamily: 'ComicSans', fontSize: 18, color: Colors.black)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[400],
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignupPage()),
                  );
                },
                child: Text(
                  "Don't have an account? Sign up",
                  style: TextStyle(fontFamily: 'ComicSans', fontSize: 16, color: Colors.purple[400]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
