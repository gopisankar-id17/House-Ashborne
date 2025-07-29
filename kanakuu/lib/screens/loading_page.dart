import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:kanakuu/main_navigation_router.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({Key? key}) : super(key: key);

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _logoController;
  late AnimationController _dotsController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _logoAnimation;
  late Animation<double> _dotOneAnimation;
  late Animation<double> _dotTwoAnimation;
  late Animation<double> _dotThreeAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 600));
    _logoController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 800));
    _dotsController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 1000));

    _fadeAnimation =
        Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));
    _logoAnimation =
        Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _logoController, curve: Curves.elasticOut));
    _dotOneAnimation =
        Tween<double>(begin: 0, end: 8).animate(CurvedAnimation(parent: _dotsController, curve: Interval(0.0, 0.3, curve: Curves.easeIn)));
    _dotTwoAnimation =
        Tween<double>(begin: 0, end: 8).animate(CurvedAnimation(parent: _dotsController, curve: Interval(0.2, 0.5, curve: Curves.easeIn)));
    _dotThreeAnimation =
        Tween<double>(begin: 0, end: 8).animate(CurvedAnimation(parent: _dotsController, curve: Interval(0.4, 0.7, curve: Curves.easeIn)));

    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(Duration(milliseconds: 200));
    if (!mounted) return;
    _fadeController.forward();

    await Future.delayed(Duration(milliseconds: 300));
    if (!mounted) return;
    _logoController.forward();

    await Future.delayed(Duration(milliseconds: 800));
    if (!mounted) return;
    _dotsController.repeat();

    // Navigate to main app after loading
    await Future.delayed(Duration(seconds: 3));
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MainNavigationRouter()),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _logoController.dispose();
    _dotsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141416),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeTransition(
              opacity: _fadeAnimation,
              child: Text(
                'KANAKUU',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2.0,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ScaleTransition(
              scale: _logoAnimation,
              child: Lottie.asset(
                'assets/Ahorra_logo.png',
                width: 120,
                height: 120,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 20),
            AnimatedBuilder(
              animation: _dotsController,
              builder: (context, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Dot(offset: _dotOneAnimation.value),
                    const SizedBox(width: 8),
                    Dot(offset: _dotTwoAnimation.value),
                    const SizedBox(width: 8),
                    Dot(offset: _dotThreeAnimation.value),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class Dot extends StatelessWidget {
  final double offset;

  const Dot({Key? key, required this.offset}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, -offset),
      child: Container(
        width: 10,
        height: 10,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
