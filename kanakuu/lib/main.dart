import 'package:flutter/material.dart';
import 'main_navigation_router.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kanaku',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: Color(0xFF1A1D29),
        fontFamily: 'SF Pro Display',
      ),
      home: MainNavigationRouter(),
      debugShowCheckedModeBanner: false,
    );
  }
}