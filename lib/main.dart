import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'HomePage.dart';  // Adjust the path as necessary
import 'login_page.dart';  // Adjust the path as necessary
import 'signup_page.dart';  // Adjust the path as necessary
import 'SettingsScreen.dart';
import 'SetupPasswordScreen.dart';
import 'FeedbackScreen.dart';

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
        '/setupPassword': (context) => SetupPasswordScreen(initialPassword: '',),
        '/feedback': (context) => FeedbackScreen(),
      },
    );
  }
}

class LandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: _checkCurrentUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasData) {
          // If the user is already logged in, navigate to HomePage
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed('/home');
          });
          return Container(); // Return an empty container while waiting for navigation
        } else {
          // If no user is logged in, show the LandingPage UI
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
      },
    );
  }

  Future<User?> _checkCurrentUser() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    return _auth.currentUser;
  }
}
