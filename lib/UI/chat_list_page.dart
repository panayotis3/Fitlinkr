import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/tester.dart';
import 'swipe.dart'; 
import 'edit_profile.dart'; 

class ChatListPage extends StatefulWidget {
  final String currentUserEmail; // Παίρνουμε το email από το Swipe
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

  //  ΣΥΝΑΡΤΗΣΗ ΓΙΑ ΤΑ MATCHES 
  Future<void> _loadData() async {
    try {
      final box = await Hive.openBox<Tester>('testers_v2');
      
      // 1. Βρίσκουμε τον εαυτό μας (Current User)
      final currentUser = box.values.firstWhere(
        (u) => u.email.toLowerCase() == widget.currentUserEmail.toLowerCase(),
        orElse: () => Tester(name: 'User', email: widget.currentUserEmail, passwordHash: '', country: '', interests: '', age: 0, level: '', gender: ''),
      );

      _currentUser = currentUser;

      // 2. Παίρνουμε τη λίστα με αυτούς που ΜΑΣ έκαναν like (Incoming Likes)
      final myLikedByMap = currentUser.likedBy ?? {};
      final peopleWhoLikedMe = myLikedByMap[widget.mode] ?? [];

      final foundMatches = <Tester>[];

      // 3. Ελέγχουμε για Αμοιβαιότητα (Mutual Like / Match)
      for (var otherEmail in peopleWhoLikedMe) {
        try {
          // Βρίσκουμε τον χρήστη που μας έκανε like (τον "Άλλον")
          final otherUser = box.values.firstWhere(
            (u) => u.email.toLowerCase() == otherEmail.toLowerCase(),
          );

          // --- Ο ΕΛΕΓΧΟΣ ΓΙΑ ΤΟ MATCH ---
          // Για να είναι Match, πρέπει να έχουμε κάνει κι εμείς Like σε αυτόν.
          // Αυτό σημαίνει ότι το ΔΙΚΟ ΜΑΣ email πρέπει να είναι στη ΔΙΚΗ ΤΟΥ λίστα likedBy.
          
          final othersLikedByMap = otherUser.likedBy ?? {};
          final peopleOtherUserLiked = othersLikedByMap[widget.mode] ?? [];

          // Αν το email μας είναι στη λίστα του άλλου -> MATCH!
          if (peopleOtherUserLiked.contains(widget.currentUserEmail.toLowerCase())) {
            foundMatches.add(otherUser);
          }
          
        } catch (e) {
          print("User match check failed for: $otherEmail");
        }
      }

      if (mounted) {
        setState(() {
          _matches = foundMatches;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading data: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A0505),
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset('assets/logo.png', height: 40),
            
            // Κουμπί Profile
            GestureDetector(
              onTap: () {
                if (_currentUser != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProfilePage(tester: _currentUser!),
                    ),
                  ).then((_) => _loadData()); 
                }
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _theme.primaryColor, 
                ),
                child: SizedBox(
                  height: 30, 
                  width: 30, 
                  child: _theme.icon,
                ),
              ),
            ),
          ],
        ),
      ),
      
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 20, top: 20, bottom: 10),
            child: Text(
              "Matches", // Το άλλαξα σε Matches
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
                        return _buildChatItem(
                          match: match, 
                          message: "It's a match! Say hello.",
                          time: "New",
                        );
                      },
                    ),
          ),
        ],
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
            style: TextStyle(
              fontFamily: 'Inter', 
              fontWeight: FontWeight.bold, 
              color: Colors.white
            )
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
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
            style: TextStyle(color: Colors.grey[600], fontSize: 16, fontFamily: 'Inter'),
          ),
          const SizedBox(height: 8),
           Text(
            "Keep swiping to find a match!",
            style: TextStyle(color: Colors.grey[500], fontSize: 14, fontFamily: 'Inter'),
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
        borderRadius: BorderRadius.circular(0),
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
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        fontFamily: 'Inter',
                      ),
                    ),
                    Text(
                      time,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 14,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
