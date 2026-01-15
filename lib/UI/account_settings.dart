import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:bcrypt/bcrypt.dart';

import '../models/tester.dart';
import 'login.dart';

class AccountSettingsPage extends StatefulWidget {
  final Tester tester;
  const AccountSettingsPage({super.key, required this.tester});

  @override
  State<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  bool _isDeleting = false;

  Future<void> _showDeleteAccountDialog() async {
    final passwordController = TextEditingController();
    final confirmController = TextEditingController();
    bool passwordVisible = false;

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF2A0A0A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Colors.red, width: 2),
          ),
          title: Row(
            children: const [
              Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
              SizedBox(width: 12),
              Text(
                'Delete Account',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'This action cannot be undone!',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'The following data will be permanently deleted:',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 8),
                _buildDeleteItem('• Your profile information'),
                _buildDeleteItem('• Profile picture'),
                _buildDeleteItem('• Match history'),
                _buildDeleteItem('• All likes and connections'),
                _buildDeleteItem('• Account credentials'),
                const SizedBox(height: 20),
                const Text(
                  'To confirm, please enter your password:',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passwordController,
                  obscureText: !passwordVisible,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Enter password',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    filled: true,
                    fillColor: const Color(0xFF1A0505),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.red),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[700]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.red, width: 2),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        passwordVisible ? Icons.visibility : Icons.visibility_off,
                        color: Colors.grey[400],
                      ),
                      onPressed: () {
                        setDialogState(() {
                          passwordVisible = !passwordVisible;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Type DELETE to confirm:',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: confirmController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Type DELETE',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    filled: true,
                    fillColor: const Color(0xFF1A0505),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.red),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[700]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.red, width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                passwordController.dispose();
                confirmController.dispose();
                Navigator.of(context).pop();
              },
              child: const Text(
                'CANCEL',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                final password = passwordController.text;
                final confirmation = confirmController.text;

                // Validate password
                if (password.isEmpty) {
                  _showErrorSnackBar('Please enter your password');
                  return;
                }

                if (!BCrypt.checkpw(password, widget.tester.passwordHash)) {
                  _showErrorSnackBar('Incorrect password');
                  return;
                }

                // Validate confirmation text
                if (confirmation != 'DELETE') {
                  _showErrorSnackBar('Please type DELETE to confirm');
                  return;
                }

                passwordController.dispose();
                confirmController.dispose();
                Navigator.of(context).pop();
                await _deleteAccount();
              },
              child: const Text(
                'DELETE ACCOUNT',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeleteItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.grey[400],
          fontSize: 13,
          fontFamily: 'Inter',
        ),
      ),
    );
  }

  Future<void> _deleteAccount() async {
    setState(() {
      _isDeleting = true;
    });

    try {
      final box = await Hive.openBox<Tester>('testers_v2');

      // Find the user's key
      final key = box.keys.cast<dynamic>().firstWhere((k) {
        final t = box.get(k);
        return t != null &&
            t.email.toLowerCase() == widget.tester.email.toLowerCase();
      }, orElse: () => null);

      if (key != null) {
        // Delete profile picture if exists
        if (widget.tester.profilePicture != null) {
          try {
            final file = File(widget.tester.profilePicture!);
            if (await file.exists()) {
              await file.delete();
            }
          } catch (e) {
            print('Error deleting profile picture: $e');
          }
        }

        // Remove user from other users' likedBy lists
        await _removeFromOtherUsersLikes(box);

        // Delete the user account
        await box.delete(key);

        // Success - navigate to login
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false,
          );

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account deleted successfully'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        _showErrorSnackBar('Account not found');
      }
    } catch (e) {
      _showErrorSnackBar('Error deleting account: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  Future<void> _removeFromOtherUsersLikes(Box<Tester> box) async {
    final userEmail = widget.tester.email.toLowerCase();

    for (final key in box.keys) {
      final user = box.get(key);
      if (user != null && user.email.toLowerCase() != userEmail) {
        bool needsUpdate = false;
        final likedByMap = Map<String, List<String>>.from(user.likedBy ?? {});

        // Remove this user from all mode lists
        for (final mode in likedByMap.keys) {
          final emailList = likedByMap[mode]!;
          if (emailList.contains(userEmail)) {
            emailList.remove(userEmail);
            needsUpdate = true;
          }
        }

        if (needsUpdate) {
          final updatedUser = Tester(
            name: user.name,
            email: user.email,
            passwordHash: user.passwordHash,
            country: user.country,
            interests: user.interests,
            age: user.age,
            level: user.level,
            gender: user.gender,
            profilePicture: user.profilePicture,
            likedBy: likedByMap,
            isProfessionalVerified: user.isProfessionalVerified,
          );
          await box.put(key, updatedUser);
        }
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
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
        title: const Text(
          'Account Settings',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isDeleting
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    'Deleting account...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Account Management',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Manage your account settings and data',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A0A0A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[800]!, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.person, color: Colors.white, size: 24),
                            SizedBox(width: 12),
                            Text(
                              'Account Information',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow('Email', widget.tester.email),
                        const SizedBox(height: 8),
                        _buildInfoRow('Name', widget.tester.name),
                        const SizedBox(height: 8),
                        _buildInfoRow('Member Since', _getMemberSinceDate()),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Divider(color: Colors.grey, thickness: 1),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A0A0A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red, width: 2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.warning_amber_rounded,
                                color: Colors.red, size: 24),
                            SizedBox(width: 12),
                            Text(
                              'Danger Zone',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Once you delete your account, there is no going back. Please be certain.',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                            fontFamily: 'Inter',
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.delete_forever),
                            label: const Text(
                              'DELETE ACCOUNT',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Inter',
                                fontSize: 16,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: _showDeleteAccountDialog,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            '$label:',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
              fontFamily: 'Inter',
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  String _getMemberSinceDate() {
    // Since we don't track creation date, return a default message
    return 'Beta Tester';
  }
}
