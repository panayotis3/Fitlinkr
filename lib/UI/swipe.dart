import 'package:flutter/material.dart'; // Απαραίτητο import

class RegisterPage extends StatelessWidget {
  final String mode;
  const RegisterPage({super.key, required this.mode});
  
  @override
  
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // Το AppBar προσθέτει αυτόματα το κουμπί "Back" για να γυρνάς στο Login
      appBar: AppBar(
        backgroundColor: Colors.black, 
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Text(
          mode, 
          style: TextStyle(color: Colors.white, fontSize: 30),
        ),
      ),
    );
  }
}