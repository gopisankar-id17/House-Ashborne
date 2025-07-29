import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main_navigation_router.dart';
import 'screens/loading_page.dart';
import 'screens/sign_in_screen.dart';
import 'screens/createaccount.dart';

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
        brightness: Brightness.dark,
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: Color(0xFF1A1D29),
        fontFamily: 'SF Pro Display',
      ),
      home: AuthWrapper(),
      routes: {
        '/signin': (context) => SignInScreen(),
        '/createaccount': (context) => CreateAccountPage(),
        '/home': (context) => MainNavigationRouter(),
        '/loading': (context) => LoadingPage(),
      },
      debugShowCheckedModeBanner: false,
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
          return LoadingPage();
        }
        
        if (snapshot.hasData && snapshot.data != null) {
          return MainNavigationRouter(); // User is signed in
        }
        
        return SignInScreen(); // User is not signed in
      },
    );
  }
}