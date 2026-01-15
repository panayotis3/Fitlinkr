import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/tester.dart';
import 'chat_list_page.dart';


class ModeTheme {
  final String mode;

  ModeTheme(this.mode);

  Image get icon {
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

  Color get backgroundColor {
    switch (mode.toLowerCase()) {
      case 'professional':
        return const Color(0xFFD8EEFF);
      case 'learner':
        return const Color(0xFFEDFDEC);
      case 'swole-mate':
        return const Color(0xFFD946EF);
      default:
        return const Color(0xFFFEF4EB);
    }
  }

  BoxDecoration get backgroundDecoration {
    if (mode.toLowerCase() == 'swole-mate') {
      return const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/Heart_Background.png'),
          fit: BoxFit.cover,
        ),
      );
    }
    return BoxDecoration(color: backgroundColor);
  }

  Color get primaryColor {
    switch (mode.toLowerCase()) {
      case 'professional':
        return const Color(0xFF007AFD);
      case 'learner':
        return const Color(0xFF0FC080);
      case 'swole-mate':
        return const Color(0xFF9926EB);
      default:
        return const Color(0xFFEE1026);
    }
  }

  Color get cardBackgroundColor {
    return mode.toLowerCase() == 'swole-mate' 
        ? const Color(0xFFC5289E) 
        : Colors.white;
  }

  Color get interestTagColor {
    return mode.toLowerCase() == 'swole-mate'
        ? const Color(0xFFE9D6F6)
        : backgroundColor;
  }

  Color get dislikeIconColor {
    switch (mode.toLowerCase()) {
      case 'professional':
        return const Color(0xFF091F72);
      case 'learner':
        return const Color(0xFF00571F);
      case 'swole-mate':
        return const Color(0xFF760A6D);
      default:
        return const Color(0xFF72090F);
    }
  }

  Color get dislikeBackgroundColor {
    switch (mode.toLowerCase()) {
      case 'professional':
        return const Color(0xFF7DB2DA);
      case 'learner':
        return const Color(0xFF7BD976);
      case 'swole-mate':
        return const Color(0xFFFF95E4);
      default:
        return const Color(0xFFFDC9BC);
    }
  }

  Color get chatButtonColor {
    return mode.toLowerCase() == 'swole-mate'
        ? const Color(0xFFC5289E)
        : primaryColor;
  }

  Color get chatButtonTextColor {
    return mode.toLowerCase() == 'swole-mate'
        ? Colors.white
        : primaryColor;
  }

  Color get chatButtonBackgroundColor {
    return mode.toLowerCase() == 'swole-mate'
        ? const Color(0xFFC5289E)
        : Colors.white;
  }

  Color get filterTitleColor {
    return mode.toLowerCase() == 'swole-mate'
        ? const Color(0xFFFF95E4)
        : primaryColor;
  }

  Color get filterHeaderColor {
    return mode.toLowerCase() == 'swole-mate'
        ? const Color(0xFFC5289E)
        : primaryColor;
  }

  BoxDecoration get filterModalDecoration {
    if (mode.toLowerCase() == 'swole-mate') {
      return const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/Heart_Background.png'),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      );
    }
    return BoxDecoration(
      color: backgroundColor,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
    );
  }
}

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
  late ModeTheme _theme;
  bool _isLoading = true;

  // filtra
  String _fitnessLevel = 'Any';
  String _country = 'Any';
  String _gender = 'Any';
  Set<String> _selectedInterests = {};

  // travame ta acc apo hive
  List<Map<String, String>> _accounts = [];
  List<Map<String, String>> _allAccounts = [];

  @override
  void initState() {
    super.initState();
    _theme = ModeTheme(widget.mode);
    _loadUsers();
  }

  void _applyFilters() {
    List<Map<String, String>> filtered = List.from(_allAccounts);

    if (_fitnessLevel != 'Any') {
      filtered = filtered.where((account) => 
        account['level']?.toLowerCase() == _fitnessLevel.toLowerCase()
      ).toList();
    }

    if (_country != 'Any') {
      filtered = filtered.where((account) => 
        account['country'] == _country
      ).toList();
    }

    if (_gender != 'Any') {
      filtered = filtered.where((account) => 
        account['gender'] == _gender
      ).toList();
    }

    if (_selectedInterests.isNotEmpty) {
      filtered = filtered.where((account) {
        final userInterests = account['interests']?.split(', ') ?? [];
        return _selectedInterests.any((interest) => userInterests.contains(interest));
      }).toList();
    }

    setState(() {
      _accounts = filtered;
      _currentIndex = 0;
    });
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    
    try {
      final box = await Hive.openBox<Tester>('testers_v2');
      final interactionsBox = await Hive.openBox('user_interactions');
      debugPrint('Total users in box: ${box.length}');
      
      // Get list of users I've already interacted with in this mode
      final myInteractionKey = '${widget.currentUserEmail.toLowerCase()}_${widget.mode.toLowerCase()}';
      final myInteractions = interactionsBox.get(myInteractionKey, defaultValue: <String>[]) as List;
      final interactedEmails = myInteractions.cast<String>().toSet();
      debugPrint('Already interacted with ${interactedEmails.length} users in ${widget.mode} mode');
      
      var allUsers = box.values.where((user) => 
        user.email.toLowerCase() != widget.currentUserEmail.toLowerCase() &&
        !interactedEmails.contains(user.email.toLowerCase())
      ).toList();
      
      debugPrint('Users after filtering current user and interactions: ${allUsers.length}');
      
      // If in Learner mode, only show verified professionals
      if (widget.mode.toLowerCase() == 'learner') {
        allUsers = allUsers.where((user) => user.isProfessionalVerified).toList();
        debugPrint('Learner mode: Filtered to verified professionals only: ${allUsers.length}');
      }

      final currentUser = box.values.firstWhere(
        (u) => u.email.toLowerCase() == widget.currentUserEmail.toLowerCase(),
        orElse: () => Tester(name: '', email: '', passwordHash: '', country: '', interests: '', age: 0, level: '', gender: ''),
      );
      
      // Determine which mode to check for likes based on current mode
      // Learners see Professionals who liked them, and vice versa
      String modeToCheck;
      if (widget.mode.toLowerCase() == 'learner') {
        modeToCheck = 'Professional';
      } else if (widget.mode.toLowerCase() == 'professional') {
        modeToCheck = 'Learner';
      } else {
        modeToCheck = widget.mode;
      }
      
      final likedByMap = currentUser.likedBy ?? {};
      final whoLikedMe = likedByMap[modeToCheck] ?? [];
      debugPrint('Current user (${widget.currentUserEmail}) in ${widget.mode} mode checking likes from $modeToCheck mode: $whoLikedMe');

      // Separate users who liked you and others
      final usersWhoLikedYou = <Tester>[];
      final otherUsers = <Tester>[];

      for (final user in allUsers) {
        try {
          if (whoLikedMe.contains(user.email.toLowerCase())) {
            debugPrint('${user.email} liked me - adding to priority list');
            usersWhoLikedYou.add(user);
          } else {
            otherUsers.add(user);
          }
        } catch (e) {
          debugPrint('Error processing user ${user.email}: $e');
          otherUsers.add(user);
        }
      }
      
      debugPrint('Users who liked you: ${usersWhoLikedYou.length}');
      debugPrint('Other users: ${otherUsers.length}');

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
        _isLoading = false;
      });
      
      debugPrint('Final accounts to show: ${_accounts.length}');
    } catch (e, stackTrace) {
      debugPrint('Error loading users: $e');
      debugPrint('Stack trace: $stackTrace');
      
      setState(() => _isLoading = false);
      
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

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: _theme.filterModalDecoration,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _theme.filterHeaderColor,
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
                      _buildFilterSection(
                        'Fitness Level',
                        DropdownButtonFormField<String>(
                          initialValue: _fitnessLevel,
                          dropdownColor: const Color(0xFFD9D9D9),
                          decoration: _filterInputDecoration(),
                          style: _filterTextStyle(),
                          items: ['Any', 'Beginner', 'Intermediate', 'Expert']
                              .map((level) => DropdownMenuItem(
                                    value: level,
                                    child: Text(level, style: _filterTextStyle()),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setModalState(() => _fitnessLevel = value);
                            }
                          },
                        ),
                      ),
                      _buildFilterSection(
                        'Country',
                        DropdownButtonFormField<String>(
                          initialValue: _country,
                          dropdownColor: const Color(0xFFD9D9D9),
                          decoration: _filterInputDecoration(),
                          style: _filterTextStyle(),
                          items: ['Any', 'United States', 'United Kingdom', 'Canada', 'Australia', 'Germany', 'France', 'Spain', 'Italy', 'Greece']
                              .map((country) => DropdownMenuItem(
                                    value: country,
                                    child: Text(country, style: _filterTextStyle()),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setModalState(() => _country = value);
                            }
                          },
                        ),
                      ),
                      _buildFilterSection(
                        'Gender',
                        DropdownButtonFormField<String>(
                          initialValue: _gender,
                          dropdownColor: const Color(0xFFD9D9D9),
                          decoration: _filterInputDecoration(),
                          style: _filterTextStyle(),
                          items: ['Any', 'Male', 'Female', 'Other']
                              .map((gender) => DropdownMenuItem(
                                    value: gender,
                                    child: Text(gender, style: _filterTextStyle()),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setModalState(() => _gender = value);
                            }
                          },
                        ),
                      ),
                      Text(
                        'Interests',
                        style: TextStyle(
                          color: _theme.filterTitleColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: ['Gym', 'Yoga', 'Running', 'Cycling', 'Swimming', 'Hiking', 'Boxing', 'Football']
                            .map((interest) => _buildInterestChip(interest, setModalState))
                            .toList(),
                      ),
                      const SizedBox(height: 32),
                      _buildFilterButtons(setModalState),
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

  Widget _buildFilterSection(String title, Widget dropdown) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: _theme.filterTitleColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 8),
        dropdown,
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildInterestChip(String interest, StateSetter setModalState) {
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? _theme.primaryColor : const Color(0xFFD9D9D9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? _theme.primaryColor : const Color(0xFFD9D9D9),
            width: 2,
          ),
        ),
        child: Text(
          interest,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontSize: 14,
            fontFamily: 'Inter',
          ),
        ),
      ),
    );
  }

  Widget _buildFilterButtons(StateSetter setModalState) {
    return Row(
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
              backgroundColor: _theme.filterHeaderColor,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
    );
  }

  InputDecoration _filterInputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFFD9D9D9),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  TextStyle _filterTextStyle() {
    return const TextStyle(
      color: Colors.black,
      fontSize: 14,
      fontWeight: FontWeight.bold,
      fontFamily: 'Inter',
    );
  }

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta;
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (_dragOffset.dx.abs() > 100) {
      final direction = _dragOffset.dx > 0 ? 'right' : 'left';
      _animateCardOffScreen(direction);
    } else {
      setState(() {
        _dragOffset = Offset.zero;
      });
    }
  }

  void _animateCardOffScreen(String direction) async {
    bool isMatch = false;
    String? matchedUserName;
    
    if (_currentIndex < _accounts.length) {
      final targetEmail = _accounts[_currentIndex]['email']!;
      
      if (direction == 'right') {
        matchedUserName = _accounts[_currentIndex]['name'];
        isMatch = await _saveLike(targetEmail);
      }
      
      // Save interaction (like or pass) so user doesn't appear again
      await _saveInteraction(targetEmail);
    }
    
    setState(() {
      _currentIndex++;
      _dragOffset = Offset.zero;
    });
    
    if (isMatch && matchedUserName != null) {
      _showMatchDialog(matchedUserName);
    } else if (!isMatch && direction == 'right') {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Liked!'),
          duration: Duration(milliseconds: 500),
        ),
      );
    } else if (direction == 'left') {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passed'),
          duration: Duration(milliseconds: 500),
        ),
      );
    }
  }

  void _showMatchDialog(String matchedUserName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: _theme.cardBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.favorite, color: _theme.primaryColor, size: 80),
            const SizedBox(height: 16),
            const Text(
              "It's a Match!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
            ),
            const SizedBox(height: 8),
            Text(
              'You and $matchedUserName liked each other!',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontFamily: 'Inter'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep Swiping'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatListPage(
                    currentUserEmail: widget.currentUserEmail,
                    mode: widget.mode,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _theme.primaryColor,
            ),
            child: const Text('Send Message', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _saveInteraction(String userEmail) async {
    try {
      final interactionsBox = await Hive.openBox('user_interactions');
      final myInteractionKey = '${widget.currentUserEmail.toLowerCase()}_${widget.mode.toLowerCase()}';
      
      final currentInteractions = interactionsBox.get(myInteractionKey, defaultValue: <String>[]) as List;
      final interactionsList = currentInteractions.cast<String>().toList();
      
      if (!interactionsList.contains(userEmail.toLowerCase())) {
        interactionsList.add(userEmail.toLowerCase());
        await interactionsBox.put(myInteractionKey, interactionsList);
        debugPrint('Saved interaction with $userEmail in ${widget.mode} mode');
      }
    } catch (e) {
      debugPrint('Error saving interaction: $e');
    }
  }

  Future<bool> _saveLike(String likedUserEmail) async {
    try {
      final box = await Hive.openBox<Tester>('testers_v2');
      
      final userKey = box.keys.firstWhere((key) {
        final user = box.get(key);
        return user != null && user.email.toLowerCase() == likedUserEmail.toLowerCase();
      }, orElse: () => null);

      if (userKey != null) {
        final likedUser = box.get(userKey);
        if (likedUser != null) {
          final currentLikedByMap = Map<String, List<String>>.from(likedUser.likedBy ?? {});
          final modeList = List<String>.from(currentLikedByMap[widget.mode] ?? []);
          if (!modeList.contains(widget.currentUserEmail.toLowerCase())) {
            modeList.add(widget.currentUserEmail.toLowerCase());
          }
          currentLikedByMap[widget.mode] = modeList;

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
            isProfessionalVerified: likedUser.isProfessionalVerified,
          );

          await box.put(userKey, updatedUser);
          
          // Check if it's a mutual match
          // Get the current user
          final currentUserKey = box.keys.firstWhere((key) {
            final user = box.get(key);
            return user != null && user.email.toLowerCase() == widget.currentUserEmail.toLowerCase();
          }, orElse: () => null);
          
          if (currentUserKey != null) {
            final currentUser = box.get(currentUserKey);
            if (currentUser != null) {
              final myLikedByMap = currentUser.likedBy ?? {};
              final peopleWhoLikedMe = myLikedByMap[widget.mode] ?? [];
              
              // If the person I just liked has also liked me, it's a match!
              if (peopleWhoLikedMe.contains(likedUserEmail.toLowerCase())) {
                return true; // It's a match!
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error saving like: $e');
    }
    return false; // Not a match
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A0505),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const Divider(color: Colors.red, thickness: 2, height: 2),
            Expanded(
              child: Container(
                decoration: _theme.backgroundDecoration,
                child: Column(
                  children: [
                    Expanded(child: _buildCardStack()),
                    _buildFooter(),
                  ],
                ),
              ),
            ),
          ],
        ),
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
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: _theme.icon,
          ),
        ],
      ),
    );
  }

  Widget _buildCardStack() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: _theme.primaryColor),
      );
    }
    
    if (_currentIndex >= _accounts.length) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 80, color: _theme.primaryColor),
            const SizedBox(height: 16),
            const Text(
              'No more profiles',
              style: TextStyle(fontSize: 24, fontFamily: 'Inter', color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'Check back later for more matches!',
              style: TextStyle(fontSize: 16, fontFamily: 'Inter', color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
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
                child: _buildProfileCard(),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildSwipeButtons(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    final account = _accounts[_currentIndex];
    return Container(
      width: 350,
      height: 500,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: _theme.cardBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black,
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
            _buildProfileImage(account),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                '${account['name']}, ${account['age']}',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter',
                ),
              ),
            ),
            const SizedBox(height: 25),
            _buildInterestTags(account),
            const SizedBox(height: 10),
            _buildFitnessLevelTag(account),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage(Map<String, String> account) {
    return Container(
      height: 260,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(16),
      ),
      child: account['profilePicture']!.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(
                File(account['profilePicture']!),
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Center(
                  child: Icon(Icons.person, size: 80, color: Colors.grey[600]),
                ),
              ),
            )
          : Center(child: Icon(Icons.person, size: 80, color: Colors.grey[600])),
    );
  }

  Widget _buildInterestTags(Map<String, String> account) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.start,
      children: account['interests']!.split(', ').map((interest) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: _theme.interestTagColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            interest,
            style: const TextStyle(fontSize: 14, fontFamily: 'Inter', color: Colors.black),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFitnessLevelTag(Map<String, String> account) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _theme.interestTagColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        account['level'] ?? 'Beginner',
        style: const TextStyle(fontSize: 14, fontFamily: 'Inter'),
      ),
    );
  }

  Widget _buildSwipeButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => _animateCardOffScreen('left'),
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: _theme.dislikeBackgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.close_rounded,
              color: _theme.dislikeIconColor,
              size: 50,
            ),
          ),
        ),
        const SizedBox(width: 30),
        GestureDetector(
          onTap: () => _animateCardOffScreen('right'),
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: _theme.primaryColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.favorite, color: Colors.white, size: 40),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () { //allagh
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatListPage(
                      currentUserEmail: widget.currentUserEmail, // Στέλνουμε το email
                      mode: widget.mode,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _theme.chatButtonBackgroundColor,
                side: BorderSide(color: _theme.chatButtonColor, width: 2),
                padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              ),
              child: Text(
                'CHAT',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter',
                  color: _theme.chatButtonTextColor,
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: _showFilterModal,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _theme.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.tune, color: Colors.black, size: 30),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

