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
  
  // Λίστα που περιέχει και Matches και Groups
  List<Map<String, dynamic>> _displayItems = []; 
  // Λίστα για το Dialog επιλογής μελών
  List<Tester> _availableMatches = [];

  bool _isLoading = true;
  Tester? _currentUser; 
  bool _isDeleting = false; // Για το mode διαγραφής

  @override
  void initState() {
    super.initState();
    _theme = ModeTheme(widget.mode);
    _loadData();
  }

  // Νέα λογική φόρτωσης (Matches + Groups)
  Future<void> _loadData() async {
    try {
      final testerBox = await Hive.openBox<Tester>('testers_v2');
      final groupBox = await Hive.openBox('groups'); // Νέο box
      
      final currentUser = testerBox.values.firstWhere(
        (u) => u.email.toLowerCase() == widget.currentUserEmail.toLowerCase(),
        orElse: () => Tester(name: 'User', email: widget.currentUserEmail, passwordHash: '', country: '', interests: '', age: 0, level: '', gender: ''),
      );
      _currentUser = currentUser;

      //  MATCHES 
      final myLikedByMap = currentUser.likedBy ?? {};
      final peopleWhoLikedMe = myLikedByMap[widget.mode] ?? [];
      final foundMatches = <Tester>[];

      for (var otherEmail in peopleWhoLikedMe) {
        try {
          final otherUser = testerBox.values.firstWhere((u) => u.email.toLowerCase() == otherEmail.toLowerCase());
          final othersLikedByMap = otherUser.likedBy ?? {};
          final peopleOtherUserLiked = othersLikedByMap[widget.mode] ?? [];

          if (peopleOtherUserLiked.contains(widget.currentUserEmail.toLowerCase())) {
            foundMatches.add(otherUser);
          }
        } catch (e) {
          debugPrint("Match check failed for: $otherEmail");
        }
      }
      _availableMatches = foundMatches;

      // GROUPS
      final myGroups = groupBox.values.where((g) {
        final group = g as Map;
        final members = List<String>.from(group['members'] ?? []);
        return group['mode'] == widget.mode && members.contains(widget.currentUserEmail);
      });

      // COMBINE & SORT 
      List<Map<String, dynamic>> tempList = [];

      for (var match in foundMatches) {
        tempList.add({'type': 'match', 'data': match, 'timestamp': DateTime.fromMillisecondsSinceEpoch(0)});
      }

      for (var group in myGroups) {
        final gMap = group as Map;
        DateTime time = gMap['created_at'] != null ? DateTime.parse(gMap['created_at']) : DateTime.now();
        tempList.add({'type': 'group', 'data': gMap, 'timestamp': time});
      }

      // Ταξινόμηση: Νεότερα πρώτα
      tempList.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));

      if (mounted) {
        setState(() {
          _displayItems = tempList;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading data: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  //  Δημιουργία Group
  Future<void> _createGroup(String groupName, Set<String> memberEmails) async {
    final groupBox = await Hive.openBox('groups');
    memberEmails.add(widget.currentUserEmail); 

    final newGroup = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'name': groupName,
      'mode': widget.mode,
      'members': memberEmails.toList(),
      'created_at': DateTime.now().toIso8601String(),
    };

    await groupBox.add(newGroup);
    await _loadData(); 
  }

  //  Διαγραφή
  // --- ΔΙΑΓΡΑΦΗ (UNMATCH ΜΟΝΟ) ---
  Future<void> _deleteItem(Map<String, dynamic> itemWrapper) async {
    final type = itemWrapper['type'];
    final data = itemWrapper['data'];

    if (type == 'match') {
      // --- MATCH: Διαγραφή και από τους δύο (Κανονική λειτουργία) ---
      final matchToDelete = data as Tester;
      final box = await Hive.openBox<Tester>('testers_v2');

      final myKey = box.keys.firstWhere((k) {
        final u = box.get(k);
        return u != null && u.email.toLowerCase() == widget.currentUserEmail.toLowerCase();
      }, orElse: () => null);

      final otherKey = box.keys.firstWhere((k) {
        final u = box.get(k);
        return u != null && u.email.toLowerCase() == matchToDelete.email.toLowerCase();
      }, orElse: () => null);

      // Αφαίρεση από εμένα
      if (myKey != null) {
        final me = box.get(myKey)!;
        final myLikes = Map<String, List<String>>.from(me.likedBy ?? {});
        final myModeLikes = List<String>.from(myLikes[widget.mode] ?? []);
        myModeLikes.remove(matchToDelete.email.toLowerCase());
        myLikes[widget.mode] = myModeLikes;
        
        await box.put(myKey, Tester(
          name: me.name, email: me.email, passwordHash: me.passwordHash, country: me.country,
          interests: me.interests, age: me.age, level: me.level, gender: me.gender,
          profilePicture: me.profilePicture, likedBy: myLikes,
        ));
      }

      // Αφαίρεση από τον άλλον
      if (otherKey != null) {
        final other = box.get(otherKey)!;
        final otherLikes = Map<String, List<String>>.from(other.likedBy ?? {});
        final otherModeLikes = List<String>.from(otherLikes[widget.mode] ?? []);
        otherModeLikes.remove(widget.currentUserEmail.toLowerCase());
        otherLikes[widget.mode] = otherModeLikes;

        await box.put(otherKey, Tester(
          name: other.name, email: other.email, passwordHash: other.passwordHash, country: other.country,
          interests: other.interests, age: other.age, level: other.level, gender: other.gender,
          profilePicture: other.profilePicture, likedBy: otherLikes,
        ));
      }

      setState(() => _displayItems.remove(itemWrapper));
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Chat deleted for both users.')));

    } else if (type == 'group') {
      // --- GROUP: Απαγόρευση διαγραφής από εδώ ---
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please go to Chat Settings to leave or delete this group.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  // Dialog για Group
  void _showCreateGroupDialog() {
    final selectedUsers = <String>{}; 
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          backgroundColor: Colors.white,
          title: const Text("New Group", style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Group Name',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Align(alignment: Alignment.centerLeft, child: Text("Select Members:", style: TextStyle(fontWeight: FontWeight.bold))),
                  const SizedBox(height: 8),
                  if (_availableMatches.isEmpty)
                    const Padding(padding: EdgeInsets.all(8.0), child: Text("No matches available yet."))
                  else
                    ..._availableMatches.map((user) {
                      final isSelected = selectedUsers.contains(user.email);
                      return CheckboxListTile(
                        activeColor: _theme.primaryColor,
                        contentPadding: EdgeInsets.zero,
                        title: Text(user.name, style: const TextStyle(fontFamily: 'Inter')),
                        value: isSelected,
                        onChanged: (val) => setStateDialog(() => val == true ? selectedUsers.add(user.email) : selectedUsers.remove(user.email)),
                        secondary: CircleAvatar(
                          backgroundImage: user.profilePicture != null ? FileImage(File(user.profilePicture!)) : null,
                          child: user.profilePicture == null ? const Icon(Icons.person) : null,
                        ),
                      );
                    }),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel", style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: _theme.primaryColor),
              onPressed: () {
                if (nameController.text.trim().isEmpty || selectedUsers.isEmpty) return;
                _createGroup(nameController.text.trim(), selectedUsers);
                Navigator.pop(ctx);
              },
              child: const Text("Create", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
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
                    // Αλλαγή 7: Header με Edit Button
                    Padding(
                      padding: const EdgeInsets.only(left: 20, top: 20, bottom: 10, right: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Matches",
                            style: TextStyle(fontFamily: 'Inter', fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.edit_square, size: 20, color: Colors.black54),
                            onSelected: (value) {
                              if (value == 'group') {
                                _showCreateGroupDialog();
                              } else if (value == 'delete'){ setState(() => _isDeleting = !_isDeleting);}
                            },
                            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                              const PopupMenuItem<String>(value: 'group', child: Row(children: [Icon(Icons.group_add, color: Colors.black54), SizedBox(width: 8), Text('Create Group')])),
                              PopupMenuItem<String>(value: 'delete', child: Row(children: [Icon(_isDeleting ? Icons.check : Icons.delete_outline, color: _isDeleting ? Colors.green : Colors.red), SizedBox(width: 8), Text(_isDeleting ? 'Done Editing' : 'Delete Chats')])),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Divider(thickness: 1, color: Colors.grey),
                    Expanded(
                      child: _isLoading 
                        ? Center(child: CircularProgressIndicator(color: _theme.primaryColor))
                        : _displayItems.isEmpty 
                            ? _buildEmptyState()
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                itemCount: _displayItems.length, // Χρησιμοποιούμε τη νέα λίστα
                                itemBuilder: (context, index) {
                                  final item = _displayItems[index];
                                  return _buildGenericChatItem(item); // Νέα συνάρτηση
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
        width: 80, height: 80,
        child: FloatingActionButton(
          backgroundColor: _theme.primaryColor,
          shape: const CircleBorder(),
          onPressed: () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => SwipePage(mode: widget.mode, currentUserEmail: widget.currentUserEmail)));
          },
          child: const Text("SWIPE", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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
                Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfilePage(tester: _currentUser!))).then((_) => _loadData());
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
          Text("No matches yet in ${widget.mode} mode.", style: TextStyle(color: Colors.grey[600], fontSize: 16)),
        ],
      ),
    );
  }

  // Γενική μέθοδος εμφάνισης (User ή Group)
  Widget _buildGenericChatItem(Map<String, dynamic> itemWrapper) {
    final type = itemWrapper['type'];
    final data = itemWrapper['data'];
    
    String name = '';
    String subtitle = '';
    String time = 'Now';
    ImageProvider? image;
    bool isGroup = false;

    // Προετοιμασία δεδομένων για εμφάνιση στη λίστα
    if (type == 'match') {
      final user = data as Tester;
      name = user.name;
      subtitle = "It's a match! Say hello.";
      if (user.profilePicture != null && user.profilePicture!.isNotEmpty) {
        image = FileImage(File(user.profilePicture!));
      }
    } else if (type == 'group') {
      final group = data as Map;
      isGroup = true; // Το χρησιμοποιούμε για το εικονίδιο τοπικά
      name = group['name'] ?? 'Group';
      subtitle = "${(group['members'] as List).length} members";
    }

    return GestureDetector(
      onTap: () {
        if (_isDeleting) return; // Αν διαγράφουμε, δεν ανοίγουμε chat

        // ΑΛΛΑΓΗ ΣΤΟ NAVIGATION 
        if (type == 'match') {
          // Περίπτωση 1: ΑΠΛΟ CHAT (MATCH)
          // Στέλνουμε: isGroup = false, και το αντικείμενο του χρήστη (otherUser)
          final user = data as Tester;
          
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage(
                currentUser: _currentUser!,
                userMode: widget.mode,
                
                // ΔΕΔΟΜΕΝΑ ΓΙΑ CHAT PAGE:
                isGroup: false,        // Δεν είναι ομάδα
                otherUser: user,       // Στέλνουμε τον χρήστη
                groupData: null,       // Δεν στέλνουμε δεδομένα ομάδας
              ),
            ),
          ).then((_) => _loadData());

        } else if (type == 'group') {
          // Περίπτωση 2: ΟΜΑΔΙΚΗ (GROUP)
          // Στέλνουμε: isGroup = true, και τα δεδομένα της ομάδας (groupData)
          final group = data as Map<String, dynamic>; // Καστάρουμε ως Map

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage(
                currentUser: _currentUser!,
                userMode: widget.mode,
                
                // ΔΕΔΟΜΕΝΑ ΓΙΑ ΤΟΝ ΑΛΛΟ DEVELOPER:
                isGroup: true,         // Είναι ομάδα!
                groupData: group,      // Στέλνουμε το Map με τα μέλη, όνομα, id
                otherUser: null,       // Δεν υπάρχει "άλλος χρήστης" (είναι πολλοί)
              ),
            ),
          ).then((_) => _loadData());
        }
      },
      child: Container(
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
              backgroundImage: image,
              child: image == null 
                ? Icon(isGroup ? Icons.groups : Icons.person, color: Colors.white, size: 30) 
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
                      Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Inter')),
                      if (_isDeleting)
                        GestureDetector(
                          onTap: () => _deleteItem(itemWrapper),
                          child: const Icon(Icons.remove_circle, color: Colors.red),
                        )
                      else
                        Text(time, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey[800], fontSize: 14, fontFamily: 'Inter')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
