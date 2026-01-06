import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../models/tester.dart';
import 'login.dart';
import 'verification_page.dart';

class EditProfilePage extends StatefulWidget {
  final Tester tester; // required - page only loads for full accounts
  const EditProfilePage({super.key, required this.tester});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  


  String _name = '';
  String _country = '';
  String _interests = '';
  String _age = '';
  String _level = '';

  @override
  void initState() {
    super.initState();

    
    _name = widget.tester.name;
    _country = widget.tester.country;
    _interests = widget.tester.interests;
    _age = widget.tester.age.toString();
    _level = widget.tester.level;
  }

  Future<void> _saveProfile({required String name, required String country, required String interests, required String age, required String level}) async {
    final box = await Hive.openBox<Tester>('testers_v2');
    final key = box.keys.cast<dynamic>().firstWhere((k) {
      final t = box.get(k);
      return t != null && t.email.toLowerCase() == widget.tester.email.toLowerCase();
    }, orElse: () => null);

    final updated = Tester(
      name: name,
      email: widget.tester.email,
      passwordHash: widget.tester.passwordHash,
      country: country,
      interests: interests,
      age: int.tryParse(age) ?? widget.tester.age,
      level: level,
    );

    if (key != null) {
      await box.put(key, updated);
    } else {
      await box.add(updated);
    }

    setState(() {
      _name = name;
      _country = country;
      _interests = interests;
      _age = age;
      _level = level;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile saved')));
    }
  }

  // ignore: unused_element
  Future<void> _showTestersDialog() async {
    final box = await Hive.openBox<Tester>('testers');
    final testers = box.values.toList();

    showDialog(
      // ignore: use_build_context_synchronously
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A0505),
        title: const Text('Dummy Testers', style: TextStyle(color: Colors.white)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: testers.length,
            itemBuilder: (context, index) {
              final t = testers[index];
              return ListTile(
                title: Text(t.name, style: const TextStyle(color: Colors.white)),
                subtitle: Text('${t.email} • ${t.country} • ${t.interests} • ${t.age} • ${t.level}', style: const TextStyle(color: Colors.white70)),
              );
            },

          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('CLOSE', style: TextStyle(color: Colors.white))),
        ],
      ),
    );
  }

  void _openEditModal() {
    // ignore: no_leading_underscores_for_local_identifiers
    final _formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: _name);
    final countryCtrl = TextEditingController(text: _country);
    final interestsCtrl = TextEditingController(text: _interests);
    final ageCtrl = TextEditingController(text: _age);
    final levelCtrl = TextEditingController(text: _level);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Color(0xFF1A0505),
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  const Center(child: Text('Edit Profile', style: TextStyle(color: Colors.white, fontSize: 18))),
                  const SizedBox(height: 16),

                  const Text('Name', style: TextStyle(color: Colors.white)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: nameCtrl,
                    decoration: InputDecoration(filled: true, fillColor: const Color(0xFFD9D9D9), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none)),
                    validator: (v) => (v?.trim().isEmpty ?? true) ? 'Enter a name' : null,
                  ),

                  const SizedBox(height: 12),
                  const Text('Country', style: TextStyle(color: Colors.white)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: countryCtrl,
                    decoration: InputDecoration(filled: true, fillColor: const Color(0xFFD9D9D9), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none)),
                  ),

                  const SizedBox(height: 12),
                  const Text('Interests', style: TextStyle(color: Colors.white)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: interestsCtrl,
                    decoration: InputDecoration(filled: true, fillColor: const Color(0xFFD9D9D9), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none)),
                  ),

                  const SizedBox(height: 12),
                  const Text('Age', style: TextStyle(color: Colors.white)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: ageCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(filled: true, fillColor: const Color(0xFFD9D9D9), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none)),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Enter your age';
                      if (int.tryParse(v.trim()) == null) return 'Enter a valid number';
                      return null;
                    },
                  ),

                  const SizedBox(height: 12),
                  const Text('Level', style: TextStyle(color: Colors.white)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: levelCtrl,
                    decoration: InputDecoration(filled: true, fillColor: const Color(0xFFD9D9D9), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none)),
                  ),

                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState?.validate() ?? false) {
                            await _saveProfile(
                              name: nameCtrl.text.trim(),
                              country: countryCtrl.text.trim(),
                              interests: interestsCtrl.text.trim(),
                              age: ageCtrl.text.trim(),
                              level: levelCtrl.text.trim(),
                            );
                            // ignore: use_build_context_synchronously
                            Navigator.of(context).pop();
                          }
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.red, shape: const StadiumBorder(), padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14)),
                        child: const Text('SAVE', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white), shape: const StadiumBorder(), padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14)),
                        child: const Text('CANCEL', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A0505),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) =>_buildLayout(context),
        ),
      ),
    );
  }

  Widget _buildLayout(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Column(
            children: [
              _buildHeader(),
              const Divider(
                color: Colors.red,
                thickness: 2,
              ),
            ],
          ),
          _buildProfileCard(context),
          const SizedBox(height: 24),
          _buildModeSelection(),
        ],
      ),
    );
  }

 

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset('assets/logo.png', height: 60),
          const CircleAvatar(
            backgroundColor: Colors.transparent,
            child: Icon(Icons.favorite, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A0A0A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              const CircleAvatar(
                radius: 40,
                backgroundImage: AssetImage('assets/profile.jpg'),
              ),

              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                    );
                  },
                  child: const Text('Logout'),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Name: $_name',
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Country: $_country',
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Interests: $_interests',
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Age: $_age',
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                          ),

                          const SizedBox(height: 8),
                          Text(
                            'Level: $_level',
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _openEditModal,
                  child: const Text('Edit Profile'),
                ),
                          ),
                           ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeSelection() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          color: Colors.red,
          child: const Text(
            'Mode Selection',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),

        _modeTile(
          'Professional',
          Image.asset('assets/professional_icon.png', width:40, height:40, fit: BoxFit.cover),
          Colors.blue,
          onRight: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const VerificationProcessPage(userMode: 'professional')));
          },
        ),
        _modeTile('Learner', Image.asset('assets/learner_icon.png', width:40, height:40, fit: BoxFit.cover), Colors.green),
        _modeTile('Friend', Image.asset('assets/friend_icon.png', width:40, height:40, fit: BoxFit.cover), Colors.red),
        _modeTile('Swole-mate', Image.asset('assets/swolemate_icon.png', width:40, height:40, fit: BoxFit.cover), Colors.purple),
      ],
    );
  }

  Widget _modeTile(String title, Image icon, Color color, {VoidCallback? onRight}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A0A0A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: ClipOval(
              child: icon,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
          if (onRight != null)
            Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: OutlinedButton(
                onPressed: onRight,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF1E88E5)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  backgroundColor: Colors.blue[600],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text('VERIFY', style: TextStyle(color: Colors.white)),
                    SizedBox(width: 8),
                    Icon(Icons.check, color: Colors.white, size: 18),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
