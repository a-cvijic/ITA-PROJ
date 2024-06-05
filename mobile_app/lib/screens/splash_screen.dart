
import 'package:flutter/material.dart';
import 'dart:async';
import 'sign_in_screen.dart';  // Import your sign-up screen



class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    _startFadeInAnimation();
    _navigateToNextScreen();
  }

  void _startFadeInAnimation() {
    Timer(Duration(milliseconds: 500), () {
      setState(() {
        _opacity = 1.0;
      });
    });
  }

  void _navigateToNextScreen() {
    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SignInScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(175, 194, 228, 1.0),
      body: Stack(
        children: [
          Center(
            child: AnimatedOpacity(
              opacity: _opacity,
              duration: Duration(seconds: 2),
              child: Image.asset(
                'assets/logo.png',  // Use your logo image
                width: 200,  // Adjust the width of the logo
                height: 200,  // Adjust the height of the logo
              ),
            ),
          ),
        ],
      ),
    );
  }
}
