import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    
    // Set up animation for the logo
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    
    _animationController.forward();
    
    // Navigate to home screen after 3 seconds
    Timer(const Duration(seconds: 3), () {
      //Navigator.of(context).pushReplacementNamed('/home');
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFEF9E7),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated mascot
            ScaleTransition(
              scale: _animation,
              child: Image.asset(
                'assets/images/mascot.png',
                height: 160,
                width: 160,
              ),
            ),
            const SizedBox(height: 0),
            // App name with custom font
            FadeTransition(
              opacity: _animation,
              child: const Text(
                'Attune',
                style: TextStyle(
                  fontFamily: 'LilitaOne',
                  fontSize: 46,
                  fontWeight: FontWeight.normal,
                  color: Color(0xFF333333),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}