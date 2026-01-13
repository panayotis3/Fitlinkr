import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/tester.dart';

class SwipePage extends StatefulWidget {
  final String mode;
  final String currentUserEmail;
  const SwipePage({super.key, required this.mode, required this.currentUserEmail});

  @override
  State<SwipePage> createState() => _SwipePageState();
}

class _SwipePageState extends State<SwipePage> {
  Offset _dragOffset = Offset.zero;
  int _currentIndex = 0;

  // Filter state
  String _fitnessLevel = 'Any';
  String _country = 'Any';
  String _gender = 'Any';
  Set<String> _selectedInterests = {};

  // User accounts from Hive
  List<Map<String, String>> _accounts = [];
  List<Map<String, String>> _allAccounts = []; // Store unfiltered accounts

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  void _applyFilters() {
    List<Map<String, String>> filtered = List.from(_allAccounts);

    // Filter by fitness level
    if (_fitnessLevel != 'Any') {
      filtered = filtered.where((account) => 
        account['level']?.toLowerCase() == _fitnessLevel.toLowerCase()
      ).toList();
    }

    // Filter by country
    if (_country != 'Any') {
      filtered = filtered.where((account) => 
        account['country'] == _country
      ).toList();
    }

    // Filter by gender
    if (_gender != 'Any') {
      filtered = filtered.where((account) => 
        account['gender'] == _gender
      ).toList();
    }

    // Filter by interests (user must have at least one selected interest)
    if (_selectedInterests.isNotEmpty) {
      filtered = filtered.where((account) {
        final userInterests = account['interests']?.split(', ') ?? [];
        return _selectedInterests.any((interest) => userInterests.contains(interest));
      }).toList();
    }

    setState(() {
      _accounts = filtered;
      _currentIndex = 0; // Reset to first card
    });
  }

  Future<void> _loadUsers() async {
    try {
      final box = await Hive.openBox<Tester>('testers_v2');
      print('Total users in box: ${box.length}');
      
      final allUsers = box.values.where((user) => 
        user.email.toLowerCase() != widget.currentUserEmail.toLowerCase()
      ).toList();
      
      print('Users after filtering current user: ${allUsers.length}');

      // Get current user's likedBy list for THIS mode (who liked me in this mode)
      final currentUser = box.values.firstWhere(
        (u) => u.email.toLowerCase() == widget.currentUserEmail.toLowerCase(),
        orElse: () => Tester(name: '', email: '', passwordHash: '', country: '', interests: '', age: 0, level: '', gender: ''),
      );
      final likedByMap = currentUser.likedBy ?? {};
      final whoLikedMe = likedByMap[widget.mode] ?? [];
      print('Current user (${widget.currentUserEmail}) was liked by in ${widget.mode} mode: $whoLikedMe');

      // Separate users who liked you and others
      final usersWhoLikedYou = <Tester>[];
      final otherUsers = <Tester>[];

      for (final user in allUsers) {
        try {
          // Check if this user's email is in MY likedBy list
          if (whoLikedMe.contains(user.email.toLowerCase())) {
            print('${user.email} liked me - adding to priority list');
            usersWhoLikedYou.add(user);
          } else {
            otherUsers.add(user);
          }
        } catch (e) {
          print('Error processing user ${user.email}: $e');
          otherUsers.add(user);
        }
      }
      
      print('Users who liked you: ${usersWhoLikedYou.length}');
      print('Other users: ${otherUsers.length}');

      // Prioritize users who liked you
      final prioritizedUsers = [...usersWhoLikedYou, ...otherUsers];

      setState(() {
        _allAccounts = prioritizedUsers.map((user) => {
          'email': user.email,
          'name': user.name,
          'age': user.age.toString(),
          'interests': user.interests,
          'level': user.level,
          'country': user.country,
          'gender': user.gender,
          'profilePicture': user.profilePicture ?? '',
        }).toList();
        
        _accounts = List.from(_allAccounts);
        _applyFilters();
      });
      
      print('Final accounts to show: ${_accounts.length}');
    } catch (e, stackTrace) {
      print('Error loading users: $e');
      print('Stack trace: $stackTrace');
      
      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading users: ${e.toString()}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
  
  Image _modeIcon(String mode) {
    switch (mode.toLowerCase()) {
      case 'professional':
        return Image.asset('assets/professional_icon.png', height: 60);
      case 'learner':
        return Image.asset('assets/learner_icon.png', height: 60);
      case 'swole-mate':
        return Image.asset('assets/swolemate_icon.png', height: 60);
      default:
        return Image.asset('assets/friend_icon.png', height: 60);
    }
  }

  Color _getModeColor(String mode) {
    switch (mode.toLowerCase()) {
      case 'professional':
        return const Color(0xFFD8EEFF);
      case 'learner':
        return const Color(0xFFEDFDEC);
      case 'swole-mate':
        return const Color(0xFF801992);
      default: // friend
        return const Color(0xFFFEF4EB);
    }
  }

  Color _getDislikeIconColor(String mode) {
    switch (mode.toLowerCase()) {
      case 'professional':
        return const Color(0xFF091F72);
      case 'learner':
        return const Color(0xFF00571F);
      case 'swole-mate':
        return const Color(0xFF760A6D);
      default: // friend
        return const Color(0xFF72090F);
    }
  }

  Color _getDislikeBackgroundColor(String mode) {
    switch (mode.toLowerCase()) {
      case 'professional':
        return const Color(0xFF7DB2DA);
      case 'learner':
        return const Color(0xFF7BD976);
      case 'swole-mate':
        return const Color(0xFFFF95E4);
      default: // friend
        return const Color(0xFFFDC9BC);
    }
  }

  Color _getLikeButtonColor(String mode) {
    switch (mode.toLowerCase()) {
      case 'professional':
        return const Color(0xFF007AFD);
      case 'learner':
        return const Color(0xFF0FC080);
      case 'swole-mate':
        return const Color(0xFF9926EB);
      default: // friend
        return const Color(0xFFEE1026);
    }
  }

  Color _getChatButtonColor(String mode) {
    switch (mode.toLowerCase()) {
      case 'professional':
        return const Color(0xFF007AFD);
      case 'learner':
        return const Color(0xFF0FC080);
      case 'swole-mate':
        return const Color(0xFFD946EF);
      default: // friend
        return const Color(0xFFEE1026);
    }
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: BoxDecoration(
            color: _getModeColor(widget.mode),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _getChatButtonColor(widget.mode),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Filters',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Inter',
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fitness Level',
                        style: TextStyle(
                          color: _getChatButtonColor(widget.mode),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: _fitnessLevel,
                        dropdownColor: const Color(0xFFD9D9D9),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Color(0xFFD9D9D9),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter',
                        ),
                        items: ['Any', 'Beginner', 'Intermediate', 'Expert']
                            .map((level) => DropdownMenuItem(
                                  value: level,
                                  child: Text(level, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontFamily: 'Inter')),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setModalState(() {
                              _fitnessLevel = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Country',
                        style: TextStyle(
                          color: _getChatButtonColor(widget.mode),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: _country,
                        dropdownColor: const Color(0xFFD9D9D9),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Color(0xFFD9D9D9),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.bold
                        ),
                        items: ['Any', 'United States', 'United Kingdom', 'Canada', 'Australia', 'Germany', 'France', 'Spain', 'Italy', 'Greece']
                            .map((country) => DropdownMenuItem(
                                  value: country,
                                  child: Text(country, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontFamily: 'Inter')),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setModalState(() {
                              _country = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Gender',
                        style: TextStyle(
                          color: _getChatButtonColor(widget.mode),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: _gender,
                        dropdownColor: const Color(0xFFD9D9D9),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Color(0xFFD9D9D9),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.bold
                        ),
                        items: ['Any', 'Male', 'Female', 'Other']
                            .map((gender) => DropdownMenuItem(
                                  value: gender,
                                  child: Text(gender, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontFamily: 'Inter')),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setModalState(() {
                              _gender = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Interests',
                        style: TextStyle(
                          color: _getChatButtonColor(widget.mode),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: ['Gym', 'Yoga', 'Running', 'Cycling', 'Swimming', 'Hiking', 'Boxing', 'Football'].map((interest) {
                          final isSelected = _selectedInterests.contains(interest);
                          return GestureDetector(
                            onTap: () {
                              setModalState(() {
                                if (isSelected) {
                                  _selectedInterests.remove(interest);
                                } else {
                                  _selectedInterests.add(interest);
                                }
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? _getChatButtonColor(widget.mode)
                                    : Color(0xFFD9D9D9),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? _getChatButtonColor(widget.mode)
                                      : Color(0xFFD9D9D9),
                                  width: 2,
                                ),
                              ),
                              child: Text(
                                interest,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.black,
                                  fontSize: 14,
                                  fontFamily: 'Inter'
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setModalState(() {
                                  _fitnessLevel = 'Any';
                                  _country = 'Any';
                                  _gender = 'Any';
                                  _selectedInterests.clear();
                                });
                                _applyFilters();
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.white),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Reset',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                                 onPressed: () {
                                _applyFilters();
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _getChatButtonColor(widget.mode),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Apply Filters',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta;
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (_dragOffset.dx.abs() > 100) {
      // Swiped far enough
      final direction = _dragOffset.dx > 0 ? 'right' : 'left';
      _animateCardOffScreen(direction);
    } else {
      // Return to center
      setState(() {
        _dragOffset = Offset.zero;
      });
    }
  }

  void _animateCardOffScreen(String direction) async {
    if (direction == 'right' && _currentIndex < _accounts.length) {
      // Save the like
      await _saveLike(_accounts[_currentIndex]['email']!);
    }
    
    setState(() {
      _currentIndex++;
      _dragOffset = Offset.zero;
    });
    
    // Show a message
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(direction == 'right' ? 'Liked!' : 'Passed'),
        duration: const Duration(milliseconds: 500),
      ),
    );
  }

  Future<void> _saveLike(String likedUserEmail) async {
    try {
      final box = await Hive.openBox<Tester>('testers_v2');
      
      // Find the user being liked
      final userKey = box.keys.firstWhere((key) {
        final user = box.get(key);
        return user != null && user.email.toLowerCase() == likedUserEmail.toLowerCase();
      }, orElse: () => null);

      if (userKey != null) {
        final likedUser = box.get(userKey);
        if (likedUser != null) {
          // Add current user's email to their likedBy map for this mode
          final currentLikedByMap = Map<String, List<String>>.from(likedUser.likedBy ?? {});
          final modeList = List<String>.from(currentLikedByMap[widget.mode] ?? []);
          if (!modeList.contains(widget.currentUserEmail.toLowerCase())) {
            modeList.add(widget.currentUserEmail.toLowerCase());
          }
          currentLikedByMap[widget.mode] = modeList;

          // Create updated user object
          final updatedUser = Tester(
            name: likedUser.name,
            email: likedUser.email,
            passwordHash: likedUser.passwordHash,
            country: likedUser.country,
            interests: likedUser.interests,
            age: likedUser.age,
            level: likedUser.level,
            gender: likedUser.gender,
            likedBy: currentLikedByMap,
          );

          // Save back to Hive
          await box.put(userKey, updatedUser);
        }
      }
    } catch (e) {
      print('Error saving like: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A0505),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset('assets/logo.png', height: 60),
                      const SizedBox(width: 12),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: _modeIcon(widget.mode),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.red, thickness: 2, height: 2),
            Expanded(
              child: Container(
                color: _getModeColor(widget.mode),
                child: _currentIndex < _accounts.length
                    ? SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 20),
                            GestureDetector(
                              onPanUpdate: _onDragUpdate,
                              onPanEnd: _onDragEnd,
                              child: Transform.translate(
                                offset: _dragOffset,
                                child: Transform.rotate(
                                  angle: _dragOffset.dx / 1000,
                                  child: Container(
                                    width: 350,
                                    height: 500,
                                    margin: const EdgeInsets.symmetric(horizontal: 20),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          // ignore: deprecated_member_use
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 10,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            height: 260,
                                            decoration: BoxDecoration(
                                              color: Colors.grey[300],
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                            child: _accounts[_currentIndex]['profilePicture']!.isNotEmpty
                                                ? ClipRRect(
                                                    borderRadius: BorderRadius.circular(16),
                                                    child: Image.file(
                                                      File(_accounts[_currentIndex]['profilePicture']!),
                                                      width: double.infinity,
                                                      height: double.infinity,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context, error, stackTrace) {
                                                        return Center(
                                                          child: Icon(
                                                            Icons.person,
                                                            size: 80,
                                                            color: Colors.grey[600],
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  )
                                                : Center(
                                                    child: Icon(
                                                      Icons.person,
                                                      size: 80,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                          ),
                                          const SizedBox(height: 16),
                                          Padding(
                                            padding: const EdgeInsets.only(left: 10),
                                            child: Text(
                                              '${_accounts[_currentIndex]['name']}, ${_accounts[_currentIndex]['age']}',
                                              style: const TextStyle(
                                                fontSize: 26,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Inter',
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 25),
                                          Wrap(
                                            spacing: 8,
                                            runSpacing: 8,
                                            alignment: WrapAlignment.start,
                                            children: _accounts[_currentIndex]['interests']!
                                                .split(', ')
                                                .map((interest) => Container(
                                                      padding: const EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                        vertical: 8,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: _getModeColor(widget.mode),
                                                        borderRadius: BorderRadius.circular(20),
                                                      ),
                                                      child: Text(
                                                        interest,
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          fontFamily: 'Inter',
                                                        ),
                                                      ),
                                                    ))
                                                .toList(),
                                          ),
                                          const SizedBox(height: 10),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _getModeColor(widget.mode),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              _accounts[_currentIndex]['level'] ?? 'Beginner',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontFamily: 'Inter',
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    _animateCardOffScreen('left');
                                  },
                                  child: Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: _getDislikeBackgroundColor(widget.mode),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.close_rounded,
                                      color: _getDislikeIconColor(widget.mode),
                                      size: 50,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 30),
                                GestureDetector(
                                  onTap: () {
                                    _animateCardOffScreen('right');
                                  },
                                  child: Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: _getLikeButtonColor(widget.mode),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.favorite,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      )
                    : Center(
                        child: Text(
                          'No more accounts',
                          style: const TextStyle(
                            fontSize: 24,
                            fontFamily: 'Inter',
                            color: Colors.grey,
                          ),
                        ),
                      ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: Color(_getModeColor(widget.mode).value),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        print("Chat button pressed");
                      },
                      style: ElevatedButton.styleFrom(
                        side: BorderSide(color: _getChatButtonColor(widget.mode), width: 2),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 60,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: Text(
                        'CHAT',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter',
                          color: _getChatButtonColor(widget.mode),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                     GestureDetector(
                        onTap: _showFilterModal,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _getChatButtonColor(widget.mode),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.tune,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
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

