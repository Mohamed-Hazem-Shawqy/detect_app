import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:detector_app/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class Splash extends StatelessWidget {
  const Splash({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Lottie.asset('assets/Animation - 1725306730862.json'),
      nextScreen: const Home(),
      splashTransition: SplashTransition.scaleTransition,
      curve: Curves.bounceInOut,
      animationDuration: const Duration(seconds: 1),
      backgroundColor: const Color.fromARGB(255, 239, 159, 159),
      splashIconSize: 200,
    );
  }
}
