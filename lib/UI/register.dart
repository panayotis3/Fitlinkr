import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:bcrypt/bcrypt.dart'; 
import '../models/tester.dart'; 

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();
  

  //  Μεταβλητές για τα Dropdowns
  String? selectedCountry;
  List <String> selectedInterests = [];
  String? selectedLevel;
  String? selectedGender;

  //  Λίστες Επιλογών
  final List<String> countries = ['Greece', 'USA', 'UK', 'Germany', 'France'];
  // Φρόντισα τα interests να ταιριάζουν με αυτά που έχεις στο main.dart (αν χρειάζεται)
  final List<String> interests = ['Gym', 'Yoga', 'Running', 'Crossfit']; 
  final List<String> levels = ['Beginner', 'Intermediate', 'Expert'];
  final List<String> genders = ['Male', 'Female', 'Other'];

  // Καθαρισμός μνήμης όταν κλείνει η σελίδα
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    // 1. Έλεγχος αν ταιριάζουν οι κωδικοί
    if (_passController.text != _confirmPassController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match!")),
      );
      return;
    }

    if (_nameController.text.isEmpty || 
        _emailController.text.isEmpty || 
        selectedCountry == null || selectedGender == null|| selectedInterests.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }

    final box = Hive.box<Tester>('testers_v2');
    
    bool emailExists = box.values.any((user) => user.email == _emailController.text);
    
    if (emailExists){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.orange,
          content: Text("This email is already registered! Try logging in"), 
        )
      );
      return;
    }
    final String hashedPassword = BCrypt.hashpw(_passController.text, BCrypt.gensalt());
    
    final newTester = Tester(
      name: _nameController.text,
      email: _emailController.text,
      passwordHash: hashedPassword,
      country: selectedCountry!,
      interests: selectedInterests.join(', '),
      age: 25, 
      level: selectedLevel ?? 'Beginner',
      gender: selectedGender!,
    );

    try {
      await box.add(newTester); 

      print("SUCCESS: User ${newTester.name} added to Hive! Total users: ${box.length}");

      if (!mounted) return; // Έλεγχος ασφαλείας ότι η σελίδα υπάρχει ακόμα

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green, 
          content: Text("Registration Successful!")
        ),
      );
      
      Navigator.pop(context); 

    } catch (e) {
      print("Error saving user: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.red, content: Text("Error: $e")),
      );
    }
  }

  // UI CREATE 
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:  () =>FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFF1A0505),
            appBar: AppBar(
              automaticallyImplyLeading: false, 
              backgroundColor: Colors.transparent,
              elevation: 0,
              toolbarHeight: 40,
            ),
            body: Center(
              child: SizedBox(
                width: 350,
                child: SingleChildScrollView(
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height > 750 
                        ? MediaQuery.of(context).size.height - 80 
                        : 750,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Logo
                        Image.asset('assets/logo.png', height: 60), 

                        // Title
                        const Text(
                          "Register",
                          style: TextStyle(
                            fontFamily: 'IstokWeb', 
                            color: Colors.white, 
                            fontSize: 24, 
                            fontWeight: FontWeight.bold 
                          ),
                        ),
                        
                        Column(
                          children: [
                            _buildLabel("Name (* required field)"),
                            _buildTextField("Name", _nameController),

                            _buildLabel("Email", isRequired: true),
                            _buildTextField("email@email.com", _emailController),

                            _buildLabel("Password", isRequired: true),
                            _buildTextField("password", _passController, isPass: true),

                            _buildLabel("Confirm Password", isRequired: true),
                            _buildTextField("confirm password", _confirmPassController, isPass: true),

                            _buildLabel("Country", isRequired: true),
                            _buildDropdown(
                              value: selectedCountry,
                              items: countries,
                              hint: "Select Country",
                              onChanged: (val) => setState(() => selectedCountry = val),
                            ),

                            _buildLabel("Interests (select up to 3)", isRequired: true),
                            _buildMultiSelectField(
                              items: interests,
                              selectedItems: selectedInterests,
                              hint: "Select Interests",
                              onTap: _showMultiSelectDialog, 
                            ),

                            _buildLabel("Level", isRequired: true),
                            _buildDropdown(
                              value: selectedLevel,
                              items: levels,
                              hint: "Select Level",
                              onChanged: (val) => setState(() => selectedLevel = val),
                            ),

                            _buildLabel("Gender", isRequired: true),
                            _buildDropdown(
                              value: selectedGender,
                              items: genders,
                              hint: "Select Gender",
                              onChanged: (val) => setState(() => selectedGender = val),
                            ),
                          ],
                        ),

                        // Buttons Stack
                        Padding(
                          padding: const EdgeInsets.only(top: 10, bottom: 10),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Back Button (Left)
                              Align(
                                alignment: Alignment.centerLeft,
                                child: InkWell(
                                  onTap: () => Navigator.pop(context),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                                  ),
                                ),
                              ),

                              // Register Button (Center)
                              ElevatedButton(
                                onPressed: _handleRegister,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.red,
                                  shape: const StadiumBorder(),
                                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                                ),
                                child: const Text(
                                  'REGISTER', 
                                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
      ),   
    );  
  }
    
  Widget _buildLabel(String text, {bool isRequired = false}) {
    
    if (text.contains("(*")) {
      List<String> parts = text.split("(*");
      return Padding(
        padding: const EdgeInsets.only(top: 2, bottom: 2),
        child: Align(
          alignment: Alignment.centerLeft,
          child: RichText(
            text: TextSpan(
              text: "*",
              style: const TextStyle(fontFamily: 'IstokWeb', color: Colors.red, fontWeight: FontWeight.bold, fontSize: 14),
              children: [
                TextSpan(text: parts[0] + "(", style: const TextStyle(color: Colors.white)),
                const TextSpan(text: "*", style: const TextStyle(color: Colors.red)),
                TextSpan(text: parts[1], style: const TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ),
      );
    }
  
    return Padding(
      padding: const EdgeInsets.only(top: 2, bottom: 2),
      child: Align(
        alignment: Alignment.centerLeft,
        child: RichText(
          text: TextSpan(
            text: isRequired ? "*" : "",
            style: const TextStyle(fontFamily: 'IstokWeb', color: Colors.red, fontWeight: FontWeight.bold, fontSize: 14),
            children: [
              TextSpan(
                text: isRequired ? text : text,
                style: const TextStyle(fontFamily: 'IstokWeb', color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller, {bool isPass = false}) {
    return SizedBox(
      height: 35,
      child: TextField(
        controller: controller,
        obscureText: isPass,
        style: const TextStyle(fontFamily: 'IstokWeb', color: Colors.black, fontSize: 13),
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFFD9D9D9),
          hintText: hint,
          hintStyle: TextStyle(fontFamily: 'IstokWeb', color: Colors.grey[600], fontSize: 13),
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required String hint,
    required Function(String?) onChanged,
  }) {
    return Container(
      height: 35,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: const Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint, style: TextStyle(fontFamily: 'IstokWeb', color: Colors.grey[600], fontSize: 13)),
          isExpanded: true,
          dropdownColor: const Color(0xFFD9D9D9),
          borderRadius: BorderRadius.circular(20), // Στρογγυλεμένη λίστα
          icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: const TextStyle(fontFamily: 'IstokWeb', color: Colors.black, fontSize: 13)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
  
  Widget _buildMultiSelectField({
    required List<String> items,
    required List<String> selectedItems,
    required String hint,
    required VoidCallback onTap,
  }) {
    String displayText = selectedItems.isEmpty 
        ? hint 
        : selectedItems.join(', '); // Ενώνει τις επιλογές (π.χ. "Gym, Yoga")

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 35,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: const Color(0xFFD9D9D9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                displayText,
                style: TextStyle(
                  fontFamily: 'IstokWeb',
                  color: selectedItems.isEmpty ? Colors.grey[600] : Colors.black,
                  fontSize: 13,
                  overflow: TextOverflow.ellipsis, // Αν είναι πολλά, βάζει ...
                ),
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: Colors.black),
          ],
        ),
      ),
    );
  }

  void _showMultiSelectDialog() async {
    await showDialog(
      context: context,
      builder: (ctx) {
        // Χρησιμοποιούμε StatefulBuilder για να ενημερώνεται το Dialog όταν τσεκάρεις
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: const Color(0xFFD9D9D9),
              title: const Text("Select up to 3 Interests", style: TextStyle(fontFamily: 'Jura', fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: ListBody(
                  children: interests.map((item) {
                    final isSelected = selectedInterests.contains(item);
                    return CheckboxListTile(
                      value: isSelected,
                      title: Text(item, style: const TextStyle(fontFamily: 'IstokWeb')),
                      activeColor: Colors.red,
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: (bool? checked) {
                        setStateDialog(() {
                          if (checked == true) {
                            // Έλεγχος: Μόνο αν είναι λιγότερα από 3 προσθέτουμε
                            if (selectedInterests.length < 3) {
                              selectedInterests.add(item);
                            } else {
                              // Προαιρετικά: Μήνυμα ότι έφτασε το όριο
                            }
                          } else {
                            selectedInterests.remove(item);
                          }
                        });
                       
                        setState(() {}); 
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("OK", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
