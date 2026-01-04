import 'package:flutter/material.dart'; // Απαραίτητο import

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // Το AppBar προσθέτει αυτόματα το κουμπί "Back" για να γυρνάς στο Login
      appBar: AppBar(
        backgroundColor: Colors.black, 
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: const Center(
        child: Text(
          "REGISTER PAGE", 
          style: TextStyle(color: Colors.white, fontSize: 30),
        ),
      ),
    );
  }
}