import 'package:flutter/material.dart';
import 'register.dart'; // Βεβαιώσου ότι το import είναι σωστό

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();

  void _dummySend() {
    // Προσομοίωση αποστολής για τη σχολή
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("A code will be provided shortly to your email!"),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A0505),
      body: Stack(
        children: [
          Center(
            child: SizedBox(
              width: 350, // Ίδιο πλάτος με το Login Page
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // Στοίχιση αριστερά όπως στο Login
                  children: [
                    const SizedBox(height: 60),
                    // Λογότυπο κεντραρισμένο
                    Center(child: Image.asset('assets/logo.png', height: 120)),
                    const SizedBox(height: 20),
                    
                    // Fonts και Styles όπως στο Login
                    const Text(
                      'Swipe, chat, train',
                      style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      'Your Fitness Buddy, Just a Tap Away...',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    
                    const SizedBox(height: 50),

                    // Κείμενο οδηγιών (χωρίς το "ARE YOU READY?")
                    const Center(
                      child: Text(
                        "Enter your email and a code will\nbe provided shortly",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white, 
                          fontFamily: 'Jura', // Διορθωμένο String
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Email Field με στοίχιση αριστερά
                    const Text(
                      "Email",
                      style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _emailController,
                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFD9D9D9),
                        hintText: "email@email.com",
                        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Κουμπί SEND κεντραρισμένο
                    Center(
                      child: Column(
                        children: [
                          ElevatedButton(
                            onPressed: _dummySend,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.red,
                              shape: const StadiumBorder(),
                              side: const BorderSide(color: Colors.red, width: 2),
                              padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                            ),
                            child: const Text('SEND', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          ),
                          const SizedBox(height: 40),
                          const Text("You do not have an account?", style: TextStyle(color: Colors.white)),
                          const SizedBox(height: 10),
                          // Κουμπί REGISTER
                          OutlinedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const RegisterPage()),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              shape: const StadiumBorder(),
                              side: const BorderSide(color: Colors.red, width: 2),
                              padding: const EdgeInsets.symmetric(horizontal: 40),
                            ),
                            child: const Text('REGISTER', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
          
          // Το κόκκινο βελάκι κάτω αριστερά
          Positioned(
            bottom: 30,
            left: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 25),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
