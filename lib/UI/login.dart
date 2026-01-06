// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:bcrypt/bcrypt.dart';
import 'register.dart';
import 'edit_profile.dart';
import '../models/tester.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);
    try {
      final email = _emailCtrl.text.trim();
      final pass = _passCtrl.text;

      final box = await Hive.openBox<Tester>('testers_v2');
      final tester = box.values.cast<Tester?>().firstWhere(
        (t) => t != null && t.email.toLowerCase() == email.toLowerCase(),
        orElse: () => null,
      );

      if (tester == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No account found for that email')));
        return;
      }

      final ok = BCrypt.checkpw(pass, tester.passwordHash);
      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Incorrect password')));
        return;
      }

      // Success: navigate to EditProfilePage with the tester
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => EditProfilePage(tester: tester)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login failed: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A0505),
      body: Center(
        child: SizedBox(
          width: 350, // This keeps the content from touching the screen edges
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
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
                  _buildField(context, "Email", "email@email.com", controller: _emailCtrl, validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Enter email';
                    return null;
                  }),
                  const SizedBox(height: 25),
                  _buildField(context, "Password", "password", isPass: true, controller: _passCtrl, validator: (v) {
                    if (v == null || v.isEmpty) return 'Enter password';
                    return null;
                  }),

                  const SizedBox(height: 40),

                  // Buttons - centered manually
                  Center(
                    child: Column(
                      children: [
                        ElevatedButton(
                          onPressed: _loading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.red,
                            shape: const StadiumBorder(),
                            padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                          ),
                          child: _loading ? const CircularProgressIndicator() : const Text('LOGIN', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text('I forgot my password!!', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 40),
                        const Text("You do not have an account?", style: TextStyle(color: Colors.white)),
                        const SizedBox(height: 10),
                        OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RegisterPage()));    
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

  Widget _buildField(BuildContext context, String label, String hint, {bool isPass = false, TextEditingController? controller, String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, 
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPass,
          validator: validator,
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