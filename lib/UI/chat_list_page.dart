import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/tester.dart';
import 'swipe.dart'; 
import 'edit_profile.dart'; 
import 'chat_page.dart';

class ChatListPage extends StatefulWidget {
  final String currentUserEmail; 
  final String mode;

  const ChatListPage({
    super.key, 
    required this.currentUserEmail, 
    required this.mode
  });

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  late ModeTheme _theme;
  List<Tester> _matches = []; 
  bool _isLoading = true;
  Tester? _currentUser; 

  @override
  void initState() {
    super.initState();
    _theme = ModeTheme(widget.mode);
    _loadData();
  }

  // Φόρτωση των Matches από το Hive
  Future<void> _loadData() async {
    try {
      final box = await Hive.openBox<Tester>('testers_v2');
      
      // 1. Εύρεση του τρέχοντος χρήστη
      final currentUser = box.values.firstWhere(
        (u) => u.email.toLowerCase() == widget.currentUserEmail.toLowerCase(),
        orElse: () => Tester(name: 'User', email: widget.currentUserEmail, passwordHash: '', country: '', interests: '', age: 0, level: '', gender: ''),
      );

      _currentUser = currentUser;

      // 2. Εύρεση των ατόμων που έκαναν like σε αυτό το mode
      final myLikedByMap = currentUser.likedBy ?? {};
      final peopleWhoLikedMe = myLikedByMap[widget.mode] ?? [];

      final foundMatches = <Tester>[];

      // 3. Έλεγχος αμοιβαιότητας (Mutual Like)
      for (var otherEmail in peopleWhoLikedMe) {
        try {
          final otherUser = box.values.firstWhere(
            (u) => u.email.toLowerCase() == otherEmail.toLowerCase(),
          );

          final othersLikedByMap = otherUser.likedBy ?? {};
          final peopleOtherUserLiked = othersLikedByMap[widget.mode] ?? [];

          // Αν ο άλλος έχει κάνει like σε εμάς ΚΑΙ εμείς σε αυτόν -> Match
          if (peopleOtherUserLiked.contains(widget.currentUserEmail.toLowerCase())) {
            foundMatches.add(otherUser);
          }
          
        } catch (e) {
          debugPrint("Match check failed for: $otherEmail");
        }
      }

      if (mounted) {
        setState(() {
          _matches = foundMatches;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading data: $e");
      if (mounted) setState(() => _isLoading = false);
    }
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
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 20, top: 20, bottom: 10),
                      child: Text(
                        "Matches",
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 24, 
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const Divider(thickness: 1, color: Colors.grey),
                    Expanded(
                      child: _isLoading 
                        ? Center(child: CircularProgressIndicator(color: _theme.primaryColor))
                        : _matches.isEmpty 
                            ? _buildEmptyState()
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                itemCount: _matches.length,
                                itemBuilder: (context, index) {
                                  final match = _matches[index];
                                  return GestureDetector(
                                    onTap: () {
                                      if (_currentUser != null) {
                                        // Πλοήγηση στο Chat και ανανέωση κατά την επιστροφή
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ChatPage(
                                              userMode: widget.mode,
                                              currentUser: _currentUser!,
                                              otherUser: match,
                                            ),
                                          ),
                                        ).then((_) => _loadData()); 
                                      }
                                    },
                                    child: _buildChatItem(
                                      match: match, 
                                      message: "It's a match! Say hello.",
                                      time: "New",
                                    ),
                                  );
                                },
                              ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: SizedBox(
        width: 80, 
        height: 80,
        child: FloatingActionButton(
          backgroundColor: _theme.primaryColor,
          shape: const CircleBorder(),
          onPressed: () {
            Navigator.pushReplacement(
              context, 
              MaterialPageRoute(
                builder: (_) => SwipePage(
                  mode: widget.mode, 
                  currentUserEmail: widget.currentUserEmail, 
                ),
              ),
            );
          },
          child: const Text(
            "SWIPE", 
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
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
            onTap: () {
              if (_currentUser != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditProfilePage(tester: _currentUser!)),
                ).then((_) => _loadData());
              }
            },
            child: _theme.icon,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 60, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            "No matches yet in ${widget.mode} mode.",
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildChatItem({required Tester match, required String message, required String time}) {
    ImageProvider? avatarImage;
    if (match.profilePicture != null && match.profilePicture!.isNotEmpty) {
      avatarImage = FileImage(File(match.profilePicture!));
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _theme.backgroundColor, 
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.grey[400],
            backgroundImage: avatarImage,
            child: avatarImage == null 
              ? const Icon(Icons.person, color: Colors.white, size: 30) 
              : null,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      match.name, 
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      time,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  message,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[800], fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
