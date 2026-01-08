import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

import '../models/tester.dart';
import 'login.dart';
import 'swipe.dart';
import 'verification_page.dart';

class EditProfilePage extends StatefulWidget {
  final Tester tester;
  const EditProfilePage({super.key, required this.tester});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final ImagePicker _picker = ImagePicker();

  String _name = '';
  String _country = '';
  String _interests = '';
  String _age = '';
  String _level = '';
  String _gender = 'Prefer not to say';
  String? _avatarPath;
  String _currentMode = 'friend';
  Image _modeIcon(String mode) {
    switch (mode) {
      case 'professional':
        return Image.asset('assets/professional_icon.png', height: 60);
      case 'learner':
        return Image.asset('assets/learner_icon.png', height: 60);
      case 'swolemate':
        return Image.asset('assets/swolemate_icon.png', height: 60);
      default:
        return Image.asset('assets/friend_icon.png', height: 60);
    }
  }

  @override
  void initState() {
    super.initState();

    _name = widget.tester.name;
    _country = widget.tester.country;
    _interests = widget.tester.interests;
    _age = widget.tester.age.toString();
    _level = widget.tester.level;
    _gender = widget.tester.gender;
    _loadAvatar();
  }

  Future<void> _loadAvatar() async {
    final box = await Hive.openBox<String>('avatars');
    final path = box.get(widget.tester.email);
    if (mounted) {
      setState(() {
        _avatarPath = path;
      });
    }
  }

  Future<void> _setAvatarPath(String? path) async {
    final box = await Hive.openBox<String>('avatars');
    if (path == null) {
      await box.delete(widget.tester.email);
    } else {
      await box.put(widget.tester.email, path);
    }
    if (mounted) {
      setState(() {
        _avatarPath = path;
      });
    }
  }

  Future<String> _saveImageToAppDir(XFile picked) async {
    // Use an already open Hive box to get the storage directory
    final box = await Hive.openBox<String>('avatars');
    final boxPath = box.path;
    if (boxPath == null) {
      throw Exception('Could not determine storage path');
    }

    final hiveDir = Directory(boxPath).parent;
    final avatarsDir = Directory(p.join(hiveDir.path, 'avatar_images'));
    if (!await avatarsDir.exists()) {
      await avatarsDir.create(recursive: true);
    }

    final ext = p.extension(picked.path);
    final safeEmail = widget.tester.email.replaceAll(
      RegExp(r'[^a-zA-Z0-9]'),
      '_',
    );
    final fileName =
        '${safeEmail}_${DateTime.now().millisecondsSinceEpoch}$ext';
    final destPath = p.join(avatarsDir.path, fileName);

    // Copy file to app dir
    final destFile = await File(picked.path).copy(destPath);

    // Clean up previous avatar file if present
    if (_avatarPath != null) {
      try {
        final oldFile = File(_avatarPath!);
        if (await oldFile.exists()) {
          await oldFile.delete();
        }
      } catch (_) {}
    }

    return destFile.path;
  }

  Future<void> _saveProfile({
    required String name,
    required String country,
    required String interests,
    required String age,
    required String level,
    required String gender,
  }) async {
    final box = await Hive.openBox<Tester>('testers_v2');
    final key = box.keys.cast<dynamic>().firstWhere((k) {
      final t = box.get(k);
      return t != null &&
          t.email.toLowerCase() == widget.tester.email.toLowerCase();
    }, orElse: () => null);

    final updated = Tester(
      name: name,
      email: widget.tester.email,
      passwordHash: widget.tester.passwordHash,
      country: country,
      interests: interests,
      age: int.tryParse(age) ?? widget.tester.age,
      level: level,
      gender: gender,
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
      _gender = gender;
    });

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile saved')));
    }
  }

  // ignore: unused_element
  Future<void> _showTestersDialog() async {
    final box = await Hive.openBox<Tester>('testers');
    final testers = box.values.toList();

    //xrhsh showDialog gia na emfanistei sthn mesi ths othonhs to edit profile
    showDialog(
      // ignore: use_build_context_synchronously
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A0505),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: testers.length,
            itemBuilder: (context, index) {
              final t = testers[index];
              return ListTile(
                title: Text(
                  t.name,
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  '${t.email} • ${t.country} • ${t.interests} • ${t.age} • ${t.level}',
                  style: const TextStyle(color: Colors.white70),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CLOSE', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  //pop up gia edit profile
  void _openEditModal() {
    // ignore: no_leading_underscores_for_local_identifiers
    final _formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: _name);
    final List<String> countries = [
      'United States',
      'United Kingdom',
      'Canada',
      'Australia',
      'Germany',
      'France',
      'Spain',
      'Italy',
      'Greece',
      'Netherlands',
      'Belgium',
      'Switzerland',
      'Austria',
      'Portugal',
      'Sweden',
      'Norway',
      'Denmark',
      'Finland',
      'Poland',
      'Ireland',
      'Japan',
      'South Korea',
      'China',
      'India',
      'Brazil',
      'Mexico',
      'Argentina',
      'Chile',
      'New Zealand',
      'South Africa',
    ];
    String selectedCountry = countries.contains(_country) ? _country : (countries.isNotEmpty ? countries.first : '');
    final List<String> interestOptions = [
      'Gym',
      'Yoga',
      'Running',
      'Cycling',
      'Swimming',
      'Hiking',
      'Water Polo',
      'Boxing',
      'Football',
      'Basketball',
    ];
    Set<String> selectedInterests = _interests
        .split(RegExp(r'[;,\n]'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty && interestOptions.contains(e))
        .toSet();
    if (selectedInterests.length > 3) {
      selectedInterests = selectedInterests.take(3).toSet();
    }
    final ageCtrl = TextEditingController(text: _age);
    final List<String> levels = ['Beginner', 'Intermediate', 'Expert'];
    String selectedLevel = levels.contains(_level) ? _level : 'Beginner';
    final List<String> genders = ['Male', 'Female', 'Prefer not to say'];
    String selectedGender = genders.contains(_gender) ? _gender : 'Prefer not to say';
    ImageProvider? avatarImage = _avatarPath != null
        ? FileImage(File(_avatarPath!))
        : null;

    // gia tis parametrous pou allazoun
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF1A0505),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: StatefulBuilder(
            builder: (context, setModalState) => SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    const Center(
                      child: Text(
                        'Account Settings',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontFamily: 'Inter', fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: SizedBox(
                        width: 120,
                        height: 120,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircleAvatar(
                              radius: 55,
                              backgroundColor: Colors.white70,
                              backgroundImage: avatarImage,
                              child: avatarImage == null
                                  ? Icon(
                                      Icons.person,
                                      size: 42,
                                      color: Colors.grey[700],
                                    )
                                  : null,
                            ),
                            Positioned(
                              bottom: 4,
                              child: PopupMenuButton<String>(
                                onSelected: (value) async {
                                  try {
                                    if (value == 'take' || value == 'upload') {
                                      final src = value == 'take'
                                          ? ImageSource.camera
                                          : ImageSource.gallery;
                                      final picked = await _picker.pickImage(
                                        source: src,
                                      );
                                      if (picked != null) {
                                        final savedPath =
                                            await _saveImageToAppDir(picked);
                                        await _setAvatarPath(savedPath);
                                        setModalState(() {
                                          avatarImage = FileImage(
                                            File(savedPath),
                                          );
                                        });
                                      }
                                    } else if (value == 'remove') {
                                      await _setAvatarPath(null);
                                      setModalState(() {
                                        avatarImage = null;
                                      });
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Error: ${e.toString()}',
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                },
                                color: const Color(0xFF2A0A0A),
                                itemBuilder: (context) => const [
                                  PopupMenuItem(
                                    value: 'take',
                                    child: Text('Take a picture'),
                                  ),
                                  PopupMenuItem(
                                    value: 'upload',
                                    child: Text('Upload a picture'),
                                  ),
                                  PopupMenuItem(
                                    value: 'remove',
                                    child: Text('Remove photo'),
                                  ),
                                ],
                                child: CircleAvatar(
                                  radius: 20,
                                  backgroundColor: Colors.black54,
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Name', style: TextStyle(color: Colors.white, fontFamily: 'Inter', fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: nameCtrl,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFD9D9D9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (v) =>
                          (v?.trim().isEmpty ?? true) ? 'Enter a name' : null,
                    ),

                    const SizedBox(height: 12),
                    const Text(
                      'Country',
                      style: TextStyle(color: Colors.white, fontFamily: 'Inter', fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      // ignore: deprecated_member_use
                      value: selectedCountry,
                      items: countries
                          .map(
                            (c) => DropdownMenuItem(
                              value: c,
                              child: Text(c),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setModalState(() {
                            selectedCountry = v;
                          });
                        }
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFD9D9D9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),
                    const Text(
                      'Interests',
                      style: TextStyle(color: Colors.white, fontFamily: 'Inter', fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: interestOptions.map((opt) {
                        final isSelected = selectedInterests.contains(opt);
                        return FilterChip(
                          label: Text(opt),
                          selected: isSelected,
                          selectedColor: Colors.redAccent,
                          checkmarkColor: Colors.white,
                          onSelected: (val) {
                            setModalState(() {
                              if (val) {
                                if (selectedInterests.length < 3) {
                                  selectedInterests.add(opt);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Select up to 3 interests'),
                                    ),
                                  );
                                }
                              } else {
                                selectedInterests.remove(opt);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Choose up to 3 interests',
                      style: TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'Inter', fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 12),
                    const Text('Age', style: TextStyle(color: Colors.white, fontFamily: 'Inter', fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: ageCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFD9D9D9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Enter your age';
                        }
                        if (int.tryParse(v.trim()) == null) {
                          return 'Enter a valid number';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 12),
                    const Text('Level', style: TextStyle(color: Colors.white, fontFamily: 'Inter', fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      // ignore: deprecated_member_use
                      value: selectedLevel,
                      items: levels
                          .map(
                            (l) => DropdownMenuItem(
                              value: l,
                              child: Text(l[0].toUpperCase() + l.substring(1)),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setModalState(() {
                            selectedLevel = v;
                          });
                        }
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFD9D9D9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),
                    const Text('Gender', style: TextStyle(color: Colors.white, fontFamily: 'Inter', fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      // ignore: deprecated_member_use
                      value: selectedGender,
                      items: genders
                          .map(
                            (g) => DropdownMenuItem(
                              value: g,
                              child: Text(g),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setModalState(() {
                            selectedGender = v;
                          });
                        }
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFD9D9D9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState?.validate() ?? false) {
                              final interestsClean = selectedInterests
                                  .take(3)
                                  .join(', ');
                              await _saveProfile(
                                name: nameCtrl.text.trim(),
                                country: selectedCountry,
                                interests: interestsClean,
                                age: ageCtrl.text.trim(),
                                level: selectedLevel,
                                gender: selectedGender,
                              );
                              // ignore: use_build_context_synchronously
                              Navigator.of(context).pop();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.red,
                            shape: const StadiumBorder(),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 14,
                            ),
                          ),
                          child: const Text(
                            'SAVE',
                            style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Inter'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white),
                            shape: const StadiumBorder(),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 14,
                            ),
                          ),
                          child: const Text(
                            'CANCEL',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Inter',
                            ),
                          ),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A0505),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => _buildLayout(context),
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
              const Divider(color: Colors.red, thickness: 2),
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
          _modeIcon(_currentMode),
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
              CircleAvatar(
                radius: 40,
                foregroundImage: _avatarPath != null
                    ? FileImage(File(_avatarPath!))
                    : null,
                child: _avatarPath == null
                    ? Icon(Icons.person, color: Colors.grey[700], size: 50)
                    : null,
              ),

              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    minimumSize: const Size(0, 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                  },
                  child: const Text(
                    'SIGN OUT',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
                  ),
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
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'Inter',
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Country: $_country',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'Inter',
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Interests: $_interests',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'Inter',
                            ),
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
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'Inter',
                            ),
                          ),

                          const SizedBox(height: 8),
                          Text(
                            'Level: $_level',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'Inter',
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 5),
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
                              child: const Text('Edit Profile', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold)),
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
              fontFamily: 'Inter',
            ),
          ),
        ),
        const SizedBox(height: 16),

        _modeTile(
          'Professional',
          Image.asset(
            'assets/professional_icon.png',
            width: 40,
            height: 40,
            fit: BoxFit.cover,
          ),
          Colors.blue,
          onRight: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (ctx) =>
                    VerificationProcessPage(
                      userMode: 'professional',
                      tester: widget.tester,
                    ),
              ),
            );
          },
          onTap: () {
            setState(() {
              _currentMode = 'professional';
            });
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (ctx) => const SwipePage(mode: 'Professional'),
              ),
            );
          },
        ),
        _modeTile(
          'Learner',
          Image.asset(
            'assets/learner_icon.png',
            width: 40,
            height: 40,
            fit: BoxFit.cover,
          ),
          Colors.green,
          onTap: () {
            setState(() {
              _currentMode = 'learner';
            });
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (ctx) => const SwipePage(mode: 'Learner'),
              ),
            );
          },
        ),
        _modeTile(
          'Friend',
          Image.asset(
            'assets/friend_icon.png',
            width: 40,
            height: 40,
            fit: BoxFit.cover,
          ),
          Colors.red,
          onTap: () {
            setState(() {
              _currentMode = 'friend';
            });
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (ctx) => const SwipePage(mode: 'Friend'),
              ),
            );
          },
        ),
        _modeTile(
          'Swole-mate',
          Image.asset(
            'assets/swolemate_icon.png',
            width: 40,
            height: 40,
            fit: BoxFit.cover,
          ),
          Colors.purple,
          onTap: () {
            setState(() {
              _currentMode = 'swolemate';
            });
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (ctx) => const SwipePage(mode: 'Swole-mate'),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _modeTile(
    String title,
    Image icon,
    Color color, {
    VoidCallback? onRight,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2A0A0A),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            SizedBox(width: 40, height: 40, child: ClipOval(child: icon)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontFamily: 'Inter', fontWeight: FontWeight.bold),
              ),
            ),
            if (onRight != null)
              Padding(
                padding: const EdgeInsets.only(left: 12.0),
                child: OutlinedButton(
                  onPressed: onRight,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF1E88E5)),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: Colors.blue[600],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text('VERIFY', style: TextStyle(color: Colors.white, fontFamily: 'Inter', fontWeight: FontWeight.bold)),
                      SizedBox(width: 8),
                      Icon(Icons.check, color: Colors.white, size: 18),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
