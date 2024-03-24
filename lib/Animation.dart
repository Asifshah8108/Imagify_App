import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'main.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Add any additional initialization logic if needed
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    // Simulate some delay before navigating (e.g., the duration of your animation)
    await Future.delayed(Duration(seconds: 3));

    // Navigate to the next screen (replace HomeWrapper with your desired screen)
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeWrapper()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Lottie.asset('assets/Animations/Animation - 1706446527696.json'),
      ),
    );
  }
}
