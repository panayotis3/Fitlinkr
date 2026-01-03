import 'package:flutter/material.dart'; // This fixes StatelessWidget and MaterialApp
import 'UI/login.dart';           // This fixes the LoginPage error

class FitLinkrApp extends StatelessWidget {
  const FitLinkrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Inter', 
        textTheme: const TextTheme(
          // This will be for your Labels (Email/Password)
          headlineMedium: TextStyle(
            fontSize: 24, 
            fontWeight: FontWeight.bold, 
            color: Colors.white
          ),
          // This will be for the text typed inside the fields
          bodyMedium: TextStyle(
            fontSize: 15, 
            color: Colors.black
          ), 
        ),
      ),
      home: const LoginPage(),
    );
  }
}