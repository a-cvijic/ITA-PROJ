import 'package:flutter/material.dart';
import 'screens/add_issue_screen.dart';
import 'screens/sign_in_screen.dart';
import 'screens/sign_up_screen.dart';
import 'screens/map_screen.dart';
import 'screens/message_screen.dart';
import 'screens/admin_message_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Problem Map',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => SplashScreen(),
        '/signin': (context) => SignInScreen(),
        '/signup': (context) => SignUpScreen(),
        '/map': (context) => MapScreen(),
        '/add_problem': (context) => AddProblemScreen(),
        '/message': (context) => MessageScreen(),
        '/admin_messages': (context) => AdminMessageScreen(),
        '/profile': (context) => ProfileScreen(),
      },
    );
  }
}
