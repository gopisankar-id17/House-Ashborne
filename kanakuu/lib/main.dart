import 'package:flutter/material.dart';
import 'main_navigation_router.dart';
import 'screens/loading_page.dart'; // Add this import

void main() {
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
      home: LoadingPage(), // Changed from MainNavigationRouter() to LoadingPage()
      debugShowCheckedModeBanner: false,
    );
  }
}