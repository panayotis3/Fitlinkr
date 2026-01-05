import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; 
import 'editprofile.dart'; 

class VerificationProcessPage extends StatefulWidget {
  final String userMode; 

  const VerificationProcessPage({super.key, required this.userMode});

  @override
  State<VerificationProcessPage> createState() => _VerificationProcessPageState();
}

class _VerificationProcessPageState extends State<VerificationProcessPage> {
  final ImagePicker _picker = ImagePicker();
  bool _isSubmitted = false; 
  bool _isLoading = false; // Νέα μεταβλητή για το loading state
  XFile? _idImage;
  XFile? _certImage;

  Future<void> _pickImage(ImageSource source, bool isID) async {
    final XFile? selected = await _picker.pickImage(source: source);
    if (selected != null) {
      setState(() {
        if (isID) _idImage = selected; else _certImage = selected;
      });
    }
  }

  void _showPickerOptions(bool isID) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () { _pickImage(ImageSource.gallery, isID); Navigator.pop(context); },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a Picture'),
              onTap: () { _pickImage(ImageSource.camera, isID); Navigator.pop(context); },
            ),
          ],
        ),
      ),
    );
  }

  Widget _getModeButton() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const EditProfilePage()),
        );
      },
      child: Image.asset(
        'assets/${widget.userMode}_icon.png', 
        height: 45,
        errorBuilder: (context, error, stackTrace) => const CircleAvatar(child: Icon(Icons.person)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A0505),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, 
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset('assets/logo.png', height: 40), 
            _getModeButton(), 
          ],
        ),
      ),
      // Εναλλαγή μεταξύ των 3 καταστάσεων: Loading, Success, ή Upload
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Colors.blue)) 
        : (_isSubmitted ? _buildThankYouView() : _buildUploadView()),
    );
  }

  Widget _buildUploadView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          const Text("Verify your Professional Status", 
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const Text("Within 3 days you will receive an email confirmation.", 
              style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 50),
          
          _buildStepRow("Step 1:", "Upload your ID or Passport", () => _showPickerOptions(true), _idImage != null),
          const SizedBox(height: 40),
          _buildStepRow("Step 2:", "Upload a pdf of your certifications", () => _showPickerOptions(false), _certImage != null),
          
          const Spacer(),
          Center(
            child: ElevatedButton(
              onPressed: () async {
                // Έλεγχος αν λείπουν αρχεία
                if (_idImage == null || _certImage == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please upload both documents!"),
                      backgroundColor: Colors.red,
                    ),
                  );
                } else {
                  // Προσομοίωση φόρτωσης
                  setState(() => _isLoading = true);
                  await Future.delayed(const Duration(seconds: 2));
                  setState(() {
                    _isLoading = false;
                    _isSubmitted = true;
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Submit", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
                  SizedBox(width: 15),
                  Icon(Icons.check, color: Colors.white),
                ],
              ),
            ),
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _buildThankYouView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(child: Image.asset('assets/verify_completed.png', height: 100, 
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.check_circle, color: Colors.blue, size: 100))),
          const SizedBox(height: 20),
          const Text("THANK YOU!!!", 
              style: TextStyle(color: Colors.white, fontFamily: 'Jura', fontSize: 38, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          const Text(
            "Within 3 days you will receive an\nemail confirmation.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontFamily: 'Jura', fontSize: 16, fontWeight: FontWeight.bold ),
          ),
          const SizedBox(height: 40),
          Container(
            width: 320,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: const Color.fromARGB(255, 239, 225, 225), borderRadius: BorderRadius.circular(20)),
            child: const Column(
              children: [
                _StatusItem(icon: Icons.image, text: "Choose from Gallery"),
                _StatusItem(icon: Icons.camera_alt, text: "Take a Picture"),
                _StatusItem(icon: Icons.file_copy, text: "Certifications Uploaded"),
              ],
            ),
          ),
          const SizedBox(height: 40),
          // Νέο κουμπί επιστροφής
          ElevatedButton(
            onPressed: () {
              // Μεταφορά στην Edit Profile Page και καθαρισμός του ιστορικού πλοήγησης
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const EditProfilePage()),
                (route) => false, // Αυτό αφαιρεί όλες τις προηγούμενες σελίδες από το stack
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red, width: 2),
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
            ),
            child: const Text(
              "Return to main", 
              style: TextStyle(fontWeight: FontWeight.bold)
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepRow(String step, String label, VoidCallback onTap, bool isDone) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(step, style: const TextStyle(color: Colors.white, fontSize: 18)),
        const SizedBox(height: 10),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(color: const Color(0xFFD9D9D9), borderRadius: BorderRadius.circular(30)),
            child: Row(
              children: [
                Icon(Icons.camera_alt, color: isDone ? Colors.green : Colors.red),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(isDone ? "File Uploaded Successfully!" : label, 
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500)),
                ),
                if (isDone) const Icon(Icons.check_circle, color: Colors.green),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusItem extends StatelessWidget {
  final IconData icon;
  final String text;
  const _StatusItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.red, size: 22),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(color: Colors.black, fontSize: 15))),
          const Icon(Icons.check_circle, color: Colors.green, size: 22),
        ],
      ),
    );
  }
}
