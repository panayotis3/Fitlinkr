import 'package:flutter/material.dart';
import 'register.dart';
import 'editprofile.dart';
import 'forgot_password.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Dummy Συνάρτηση Login για την παρουσίαση
  Future<void> _handleLogin() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    // Προσομοίωση καθυστέρησης δικτύου (κάνει την εφαρμογή να φαίνεται αληθινή)
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Colors.red)),
    );

    await Future.delayed(const Duration(seconds: 2)); // Περιμένουμε 2 δευτερόλεπτα
    if (!mounted) return;
    Navigator.pop(context); // Κλείνουμε το Loading spinner

    // Έλεγχος Dummy Στοιχείων
    if (email == "admin@fitlinkr.gr" && password == "123456") {
      // ΕΠΙΤΥΧΙΑ: Πάμε στο Profile
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const EditProfilePage()),
      );
    } else if (email == "admin@fitlinkr.gr" && password != "123456"){
      // ΣΦΑΛΜΑ: Λάθος κωδικός
      _showErrorSnackBar("Wrong email or password. Please try again.");
      
    } else {
      // ΣΦΑΛΜΑ: Χρήστης δεν υπάρχει
      _showErrorSnackBar("This user does not exist.");
    }
  }

  // Συνάρτηση για το ΚΟΚΚΙΝΟ SnackBar
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
      backgroundColor: const Color.fromARGB(255, 26, 5, 5),
      body: Center(
        child: SizedBox(
          width: 350,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60),
                Center(child: Image.asset('assets/logo.png', height: 120)),
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

                // Forgot Password Button
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
                      style: TextStyle(color: Color.fromARGB(255, 244, 67, 54), decoration: TextDecoration.underline),
                    ),
                  ),
                ),

                const SizedBox(height: 30),
                Center(
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: _handleLogin, 
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.red,
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                        ),
                        child: const Text('LOGIN', style: TextStyle(fontWeight: FontWeight.bold)),
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
    );
  }

  Widget _buildField(String label, String hint, TextEditingController controller, {bool isPass = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPass,
          style: const TextStyle(color: Colors.black, fontSize: 15),
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