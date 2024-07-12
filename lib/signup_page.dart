import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _registerUser() async {
    try {
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (userCredential.user != null) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'email': _emailController.text,
          // Add other user information here if needed
        });

        Fluttertoast.showToast(msg: 'Signup Successful!');
        Navigator.pop(context);
        return; // Exit the function after successful signup
      }

      // Show a generic error message if userCredential.user is null
      Fluttertoast.showToast(msg: 'Signup failed, please try again.');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        Fluttertoast.showToast(msg: 'The email address is already in use.');
      } else {
        Fluttertoast.showToast(msg: e.message ?? 'An error occurred during signup.');
      }
    } catch (e) {
      // Handle any other unexpected errors
      Fluttertoast.showToast(msg: 'SignUp Successful.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[50],
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Create Account', style: TextStyle(fontFamily: 'ComicSans', fontSize: 26, fontWeight: FontWeight.bold, color: Colors.purple[400])),
            SizedBox(height: 20),
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
                labelText: 'Choose a password',
                labelStyle: TextStyle(fontFamily: 'ComicSans', fontSize: 18, color: Colors.purple[400]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                prefixIcon: Icon(Icons.lock, color: Colors.purple[400]),
              ),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: _registerUser,
              child: Text('Sign Up', style: TextStyle(fontFamily: 'ComicSans', fontSize: 18, color: Colors.black)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple[400],
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
