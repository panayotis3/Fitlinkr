import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A0505),
      body: Center(
        child: SizedBox(
          width: 350, // This keeps the content from touching the screen edges
          child: SingleChildScrollView(
            child: Column(
              // THIS IS THE KEY: Aligns the logo, text, and fields to the left
              crossAxisAlignment: CrossAxisAlignment.start, 
              children: [
                const SizedBox(height: 60),
                
                // Logo Section
                Center( // Wrap only the logo in Center to keep it in the middle
                  child: Image.asset('assets/logo.png', height: 120),
                ),
                const SizedBox(height: 20),
                
                // Tagline
                const Text(
                  'Swipe, chat, train',
                  style: TextStyle(fontFamily: 'IstokWeb', color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'Your Fitness Buddy, Just a Tap Away...',
                  style: TextStyle(fontFamily: 'IstokWeb', color: Color.fromARGB(255, 255, 255, 255), fontSize: 14),
                ),

                const SizedBox(height: 50),
                
                // "ARE YOU READY" - centered manually
                const Center(
                  child: Text(
                    "ARE YOU READY?",
                    style: TextStyle(fontFamily: 'Jura', color: Colors.white, fontSize: 18),
                  ),
                ),
                const SizedBox(height: 30),

                // Input Fields
                _buildField(context, "Email", "email@email.com"),
                const SizedBox(height: 25),
                _buildField(context, "Password", "password", isPass: true),

                const SizedBox(height: 40),

                // Buttons - centered manually
                Center(
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.red,
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                        ),
                        child: const Text('LOGIN', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text('I forgot my password!!', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 40),
                      const Text("You do not have an account?", style: TextStyle(color: Colors.white)),
                      const SizedBox(height: 10),
                      OutlinedButton(
                        onPressed: () {},
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
    );
  }

  Widget _buildField(BuildContext context, String label, String hint, {bool isPass = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // Keeps label and field aligned left
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        TextField(
          obscureText: isPass,
          style: Theme.of(context).textTheme.bodyMedium,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFD9D9D9), // Light grey background
            hintText: hint,
            hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15), // Softer rounded corners
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}