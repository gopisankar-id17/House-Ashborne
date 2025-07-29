import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/sign_in_screen.dart';
import 'screens/createaccount.dart';
import 'main_navigation_router.dart'; // Import the navigation router

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ahorra',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: InitialLoadingWrapper(),
      routes: {
        '/signin': (context) => const SignInScreen(),
        '/createaccount': (context) => const CreateAccountPage(),
        '/home': (context) => MainNavigationRouter(), // Changed this line
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class InitialLoadingWrapper extends StatefulWidget {
  @override
  _InitialLoadingWrapperState createState() => _InitialLoadingWrapperState();
}

class _InitialLoadingWrapperState extends State<InitialLoadingWrapper>
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

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _dotsController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    _logoAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _dotOneAnimation = Tween<double>(begin: 0.0, end: 15.0).animate(
      CurvedAnimation(
        parent: _dotsController,
        curve: const Interval(0.0, 0.33, curve: Curves.easeInOut),
      ),
    );

    _dotTwoAnimation = Tween<double>(begin: 0.0, end: 15.0).animate(
      CurvedAnimation(
        parent: _dotsController,
        curve: const Interval(0.33, 0.66, curve: Curves.easeInOut),
      ),
    );

    _dotThreeAnimation = Tween<double>(begin: 0.0, end: 15.0).animate(
      CurvedAnimation(
        parent: _dotsController,
        curve: const Interval(0.66, 1.0, curve: Curves.easeInOut),
      ),
    );

    _startAnimations();
  }

  void _startAnimations() async {
    _fadeController.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    _logoController.forward();
    _dotsController.repeat(reverse: true);

    // Navigate to auth wrapper after 3 seconds
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AuthWrapper()),
      );
    }
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
                'AHORRA',
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
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(60),
                  child: Image.asset(
                    'assets/Ahorra_logo.png',
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ),
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
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: Colors.orange,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: const Color(0xFF1A1D29),
            body: Center(
              child: CircularProgressIndicator(
                color: Colors.orange,
              ),
            ),
          );
        }

        if (snapshot.hasData) {
          // User is signed in - Navigate to MainNavigationRouter
          return MainNavigationRouter(); // Changed this line too
        } else {
          // User is not signed in
          return const SignInScreen();
        }
      },
    );
  }
}