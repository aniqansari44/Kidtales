import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'HomePage.dart'; // Make sure the path to this file is correct
import 'login_page.dart'; // Ensure the path to this file is correct
import 'signup_page.dart'; // Ensure the path to this file is correct
import 'SettingsScreen.dart';
import 'SetupPasswordScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KidTales',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LandingPage(),
        '/home': (context) => HomePage(),
        '/login': (context) => LoginPage(onLoginSuccess: () => Navigator.of(context).pushReplacementNamed('/home')),
        '/signup': (context) => SignupPage(),
        '/settings': (context) => SettingsScreen(),
        '/setupPassword': (context) => SetupPasswordScreen(),
      },
    );
  }
}

class LandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset('assets/images/welcome.png', height: 200),
            SizedBox(height: 50),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              child: Text('Start now'),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/signup'),
              child: Text('Ready for an adventure? Sign up'),
            ),
          ],
        ),
      ),
    );
  }
}
