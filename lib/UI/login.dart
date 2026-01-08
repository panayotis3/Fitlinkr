
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:bcrypt/bcrypt.dart';


import 'register.dart';
import 'edit_profile.dart'; 
import 'forgot_password.dart';
import '../models/tester.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // INTEGRATED HIVE LOGIC
  Future<void> _handleLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      // Open Hive Box
      final box = await Hive.openBox<Tester>('testers_v2');
      
      // Find User
      final tester = box.values.cast<Tester?>().firstWhere(
        (t) => t != null && t.email.toLowerCase() == email.toLowerCase(),
        orElse: () => null,
      );

      // Simulate a small delay for UX (Optional, remove if you want it instant)
      await Future.delayed(const Duration(seconds: 1));

      if (tester == null) {
        _showErrorSnackBar("This user does not exist.");
        return;
      }

      // Check Password Hash
      final isPasswordCorrect = BCrypt.checkpw(password, tester.passwordHash);
      
      if (!isPasswordCorrect) {
        _showErrorSnackBar("Wrong email or password. Please try again.");
        return;
      }

      // SUCCESS: Navigate to Profile
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => EditProfilePage(tester: tester)),
      );
    } catch (e) {
      _showErrorSnackBar("Login failed: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 26, 5, 5), // Restored original dark red
      body: Center(
        child: SizedBox(
          width: 350,
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 50),
                  Center(child: Image.asset('assets/logo.png', height: 100)), // Restored original size
                  const SizedBox(height: 20),
                  const Text('Swipe, chat, train', 
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  const Text('Your Fitness Buddy...', 
                    style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 50),
                  const Center(child: Text("ARE YOU READY?", 
                    style: TextStyle(color: Colors.white, fontSize: 18))),
                  const SizedBox(height: 30),

                  _buildField("Email", "admin@fitlinkr.gr", _emailController),
                  const SizedBox(height: 25),
                  _buildField("Password", "******", _passwordController, isPass: true),

                  // RESTORED Forgot Password Button
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
                        );
                      },
                      child: const Text(
                        "Forgot Password?",
                        style: TextStyle(
                          color: Color.fromARGB(255, 244, 67, 54), 
                          decoration: TextDecoration.underline
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                  Center(
                    child: Column(
                      children: [
                        ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin, 
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.red,
                            shape: const StadiumBorder(),
                            padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                          ),
                          child: _isLoading 
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.red, strokeWidth: 2))
                            : const Text('LOGIN', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 40),
                        const Text("You do not have an account?", style: TextStyle(color: Colors.white)),
                        const SizedBox(height: 10),
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
      ),
    );
  }

  // Restored your original _buildField style but added the controller
  Widget _buildField(String label, String hint, TextEditingController controller, {bool isPass = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField( // Changed to TextFormField for validation support
          controller: controller,
          obscureText: isPass,
          style: const TextStyle(color: Colors.black, fontSize: 15),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Please fill this field';
            return null;
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFD9D9D9),
            hintText: hint,
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }
}
