import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'HomePage.dart';  // Adjust the path as necessary
import 'login_page.dart';  // Adjust the path as necessary
import 'signup_page.dart';  // Adjust the path as necessary
import 'SettingsScreen.dart';
import 'SetupPasswordScreen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env"); // Load environment variables
  await Firebase.initializeApp(); // Initialize Firebase
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
