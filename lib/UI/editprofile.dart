import 'package:flutter/material.dart'; // Απαραίτητο import
import 'login_page.dart'; // Εισαγωγή για να μπορεί να γυρίσει στο Login

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        // Χρησιμοποιούμε pushReplacement για να αποφύγουμε την κόκκινη οθόνη σφάλματος
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          },
        ),
      ),
      body: const Center(
        child: Text(
          "EDIT PROFILE PAGE",
          style: TextStyle(color: Colors.white, fontSize: 30),
        ),
      ),
    );
  }
}