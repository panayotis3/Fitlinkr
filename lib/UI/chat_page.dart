import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../models/tester.dart';

class ChatPage extends StatefulWidget {
  final Tester currentUser;
  final String userMode;
  final bool isGroup;
  final Tester? otherUser; 
  final Map<String, dynamic>? groupData; 

  const ChatPage({
    super.key,
    required this.currentUser,
    required this.userMode,
    required this.isGroup,
    this.otherUser,
    this.groupData,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  Box? _chatBox;
  bool _isBoxReady = false;
  
  late List<String> _groupMembers;
  late String _groupName;
  late String _adminEmail;

  @override
  void initState() {
    super.initState();
    if (widget.isGroup) {
      _groupMembers = List<String>.from(widget.groupData!['members'] ?? []);
      _groupName = widget.groupData!['name'] ?? 'Group';
      _adminEmail = widget.groupData!['admin'] ?? (_groupMembers.isNotEmpty ? _groupMembers.first : ""); 
    }
    _openChatBox();
  }

  Future<void> _openChatBox() async {
    String chatId;
    if (widget.isGroup) {
      chatId = 'chat_group_${widget.groupData!['id']}';
    } else {
      List<String> emails = [widget.currentUser.email, widget.otherUser!.email];
      emails.sort();
      String emailsPart = emails.join('_').replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
      chatId = 'chat_${widget.userMode.toLowerCase().replaceAll('-', '')}_$emailsPart';
    }

    _chatBox = await Hive.openBox(chatId);
    _markMessagesAsSeen();
    if (mounted) setState(() => _isBoxReady = true);
  }

  void _markMessagesAsSeen() {
    if (_chatBox == null) return;
    for (int i = 0; i < _chatBox!.length; i++) {
      var msg = _chatBox!.getAt(i);
      if (msg is Map && msg['senderEmail'] != widget.currentUser.email) {
        msg['status'] = 'seen';
        _chatBox!.putAt(i, msg);
      }
    }
  }

  // --- ΛΕΙΤΟΥΡΓΙΕΣ ΔΙΑΓΡΑΦΗΣ (ΑΠΟ ΤΟ ΠΑΛΙΟ ΣΟΥ ΚΩΔΙΚΑ) ---
  Future<void> _clearOnlyMessages() async {
    await _chatBox?.clear();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Conversation history cleared')));
      setState(() {}); 
    }
  }

  Future<void> _blockAndDeleteEverything() async {
    if (widget.isGroup) return; // Δεν ισχύει για groups
    try {
      await _chatBox?.clear();
      final userBox = Hive.box<Tester>('testers_v2');
      final currentUserIndex = userBox.values.toList().indexWhere(
        (u) => u.email.toLowerCase() == widget.currentUser.email.toLowerCase()
      );

      if (currentUserIndex != -1) {
        Tester myUser = userBox.getAt(currentUserIndex)!;
        Map<String, List<String>> updatedLikedBy = Map.from(myUser.likedBy ?? {});
        List<String> modeLikes = List.from(updatedLikedBy[widget.userMode] ?? []);

        modeLikes.removeWhere((email) => email.toLowerCase() == widget.otherUser!.email.toLowerCase());
        updatedLikedBy[widget.userMode] = modeLikes;
        
        final updatedUser = Tester(
          name: myUser.name, email: myUser.email, passwordHash: myUser.passwordHash,
          country: myUser.country, interests: myUser.interests, age: myUser.age,
          level: myUser.level, gender: myUser.gender, profilePicture: myUser.profilePicture,
          likedBy: updatedLikedBy,
        );

        await userBox.putAt(currentUserIndex, updatedUser);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User blocked and unmatched')));
        Navigator.pop(context); // Κλείνει το Modal
        Navigator.pop(context); // Επιστροφή στη ChatListPage
      }
    } catch (e) { debugPrint("Block error: $e"); }
  }

  // --- VIEW PROFILE MODAL (ΤΟ ΠΑΛΙΟ ΣΟΥ DESIGN) ---
  // --- VIEW PROFILE MODAL (ΕΝΗΜΕΡΩΜΕΝΟ ΜΕ INTERESTS) ---
  void _showOtherUserProfile() {
    if (widget.isGroup || widget.otherUser == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A0505),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: (widget.otherUser!.profilePicture != null && widget.otherUser!.profilePicture!.isNotEmpty)
                        ? FileImage(File(widget.otherUser!.profilePicture!)) : null,
                    child: (widget.otherUser!.profilePicture == null) ? const Icon(Icons.person, size: 60) : null,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    widget.otherUser!.name, 
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)
                  ),
                  Text(
                    "${widget.otherUser!.age} years old", 
                    style: const TextStyle(color: Colors.grey, fontSize: 16)
                  ),
                  const Divider(color: Colors.white24, height: 40),
                  
                  _infoRow(Icons.location_on, "Country: ${widget.otherUser!.country}"),
                  _infoRow(Icons.fitness_center, "Level: ${widget.otherUser!.level}"),
                  
                  // ΠΡΟΣΘΗΚΗ INTERESTS
                  _infoRow(Icons.favorite, "Interests: ${widget.otherUser!.interests}"),
                  
                  
                  const SizedBox(height: 30),
                  GestureDetector(
                    onTap: () { Navigator.pop(context); _blockAndDeleteEverything(); },
                    child: const Text(
                      "Block & Delete Conversation", 
                      style: TextStyle(
                        color: Colors.red, 
                        fontWeight: FontWeight.bold, 
                        decoration: TextDecoration.underline, 
                        fontSize: 16
                      )
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [Icon(icon, color: Colors.white70), const SizedBox(width: 15), Text(text, style: const TextStyle(color: Colors.white70, fontSize: 16))]),
    );
  }
  // --- VIEW PROFILE MODAL ---
  void _showUserProfile(Tester user, {bool showBlockOption = false}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A0505),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: (user.profilePicture != null && user.profilePicture!.isNotEmpty)
                        ? FileImage(File(user.profilePicture!)) : null,
                    child: (user.profilePicture == null) ? const Icon(Icons.person, size: 60) : null,
                  ),
                  const SizedBox(height: 15),
                  Text(user.name, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  Text("${user.age} years old", style: const TextStyle(color: Colors.grey, fontSize: 16)),
                  const Divider(color: Colors.white24, height: 40),
                  _infoRow(Icons.location_on, "Country: ${user.country}"),
                  _infoRow(Icons.fitness_center, "Level: ${user.level}"),
                  _infoRow(Icons.favorite, "Interests: ${user.interests}"),
                  
                  if (showBlockOption) ...[
                    const SizedBox(height: 30),
                    GestureDetector(
                      onTap: () { Navigator.pop(context); _blockAndDeleteEverything(); },
                      child: const Text("Block & Delete Conversation", 
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, decoration: TextDecoration.underline, fontSize: 16)),
                    ),
                  ],
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // --- GROUP MODAL ---
  // --- GROUP LOGIC & MODALS ---
  void _showGroupDetails() {
    final testerBox = Hive.box<Tester>('testers_v2');
    TextEditingController nameEdit = TextEditingController(text: _groupName);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A0505),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Group Details", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.person_add, color: Colors.green),
              title: const Text("Add Member from Matches", style: TextStyle(color: Colors.white)),
              onTap: () { Navigator.pop(context); _showAddMembersDialog(); },
            ),
            TextField(
              controller: nameEdit,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: "Change chat name:", labelStyle: TextStyle(color: Colors.grey)),
              onSubmitted: (val) { _groupName = val; _updateGroupInHive(); },
            ),
            const SizedBox(height: 20),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: _groupMembers.map((email) {
                  final member = testerBox.values.firstWhere((u) => u.email == email, orElse: () => widget.currentUser);
                  return ListTile(
                    onTap: () {
                      // Όταν πατάμε ένα μέλος, ανοίγει το προφίλ ΧΩΡΙΣ block option
                      if (member.email != widget.currentUser.email) {
                        _showUserProfile(member, showBlockOption: false);
                      }
                    },
                    leading: CircleAvatar(backgroundImage: member.profilePicture != null ? FileImage(File(member.profilePicture!)) : null),
                    title: Row(children: [
                      Text(member.name, style: const TextStyle(color: Colors.white)),
                      if (email == _adminEmail) const Padding(padding: EdgeInsets.only(left: 8), child: Icon(Icons.workspace_premium, color: Colors.amber, size: 18)),
                    ]),
                    trailing: (_adminEmail == widget.currentUser.email && email != _adminEmail)
                        ? IconButton(icon: const Icon(Icons.remove_circle, color: Colors.red), onPressed: () => _removeUser(email, member.name))
                        : null,
                  );
                }).toList(),
              ),
            ),
            TextButton(onPressed: _leaveGroup, child: const Text("DELETE AND LEAVE", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- ΜΕΘΟΔΟΙ ΥΠΟΣΤΗΡΙΞΗΣ (SEND, PICK IMAGE, κλπ) ---
  void _sendMessage({String? text, String? imagePath, String? systemMessage}) {
  if (_chatBox == null) return;

  final hasSystem = systemMessage != null && systemMessage.trim().isNotEmpty;
  final hasText = text != null && text.trim().isNotEmpty;
  final hasImage = imagePath != null;

  // Guard: μην στέλνεις κενά
  if (!hasSystem && !hasText && !hasImage) return;

  _chatBox!.add({
    'senderEmail': hasSystem ? 'system' : widget.currentUser.email,
    'senderName': widget.currentUser.name,
    'text': hasSystem ? systemMessage.trim() : text?.trim(),
    'imagePath': imagePath,
    'timestamp': DateTime.now(),
    'status': 'sent',
    'isSystem': hasSystem,
  });

  _messageController.clear();
}


  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source, imageQuality: 70);
      if (image != null) _sendMessage(imagePath: image.path);
    } catch (e) { debugPrint("Error: $e"); }
  }

  void _removeUser(String email, String name) async {
    _groupMembers.remove(email);
    await _updateGroupInHive();
    _sendMessage(systemMessage: "Admin removed $name");
    // ignore: use_build_context_synchronously
    Navigator.pop(context);
    _showGroupDetails();
  }

  void _leaveGroup() async {
    _sendMessage(systemMessage: "${widget.currentUser.name} left the chat");
    _groupMembers.remove(widget.currentUser.email);
    if (_adminEmail == widget.currentUser.email && _groupMembers.isNotEmpty) _adminEmail = _groupMembers.first;
    await _updateGroupInHive();
    // ignore: use_build_context_synchronously
    Navigator.pop(context); 
    // ignore: use_build_context_synchronously
    Navigator.pop(context); 
  }

  Future<void> _updateGroupInHive() async {
    final groupBox = await Hive.openBox('groups');
    final key = groupBox.keys.firstWhere((k) => groupBox.get(k)['id'] == widget.groupData!['id'], orElse: () => null);
    if (key != null) {
      final updatedData = Map<String, dynamic>.from(widget.groupData!);
      updatedData['name'] = _groupName;
      updatedData['members'] = _groupMembers;
      updatedData['admin'] = _adminEmail;
      await groupBox.put(key, updatedData);
    }
    setState(() {});
  }

  void _showAddMembersDialog() {
    final testerBox = Hive.box<Tester>('testers_v2');
    final availableMatches = testerBox.values.where((user) {
      final myLikes = widget.currentUser.likedBy?[widget.userMode] ?? [];
      final userLikes = user.likedBy?[widget.userMode] ?? [];
      bool isMatch = myLikes.contains(user.email) && userLikes.contains(widget.currentUser.email);
      return isMatch && !_groupMembers.contains(user.email);
    }).toList();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text("Add Member"),
        content: SizedBox(
          width: double.maxFinite,
          child: availableMatches.isEmpty ? const Text("No matches to add.") : ListView.builder(
            shrinkWrap: true,
            itemCount: availableMatches.length,
            itemBuilder: (c, i) => ListTile(
              leading: CircleAvatar(backgroundImage: availableMatches[i].profilePicture != null ? FileImage(File(availableMatches[i].profilePicture!)) : null),
              title: Text(availableMatches[i].name),
              onTap: () {
                setState(() => _groupMembers.add(availableMatches[i].email));
                _updateGroupInHive();
                _sendMessage(systemMessage: "${availableMatches[i].name} added");
                Navigator.pop(ctx);
              },
            ),
          ),
        ),
      ),
    );
  }

  // --- UI COLORS & BUILD ---
  Color _getModeColor() {
    String m = widget.userMode.toLowerCase().replaceAll('-', '');
    if (m == 'professional') return const Color(0xFF2196F3);
    if (m == 'learner') return const Color(0xFF4CAF50);
    if (m == 'friend') return const Color(0xFFE53935);
    if (m == 'swolemate') return const Color(0xFF9C27B0);
    return const Color(0xFF2196F3);
  }

  Color _getLightModeColor() {
    String m = widget.userMode.toLowerCase().replaceAll('-', '');
    if (m == 'professional') return const Color(0xFFDBEBFD);
    if (m == 'learner') return const Color(0xFFD4F6EA);
    if (m == 'friend') return const Color(0xFFFFE0E0);
    if (m == 'swolemate') return const Color(0xFFF0E0FF);
    return const Color(0xFFDBEBFD);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isBoxReady) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final themeColor = _getModeColor();
    final lightColor = _getLightModeColor();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A0505),
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset('assets/logo.png', height: 40),
            Image.asset('assets/${widget.userMode.toLowerCase().replaceAll('-', '')}_icon.png', height: 45),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildHeader(lightColor),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: _chatBox!.listenable(),
              builder: (context, Box box, _) {
                final messages = box.values.where((m) => m is Map && m.containsKey('timestamp')).toList().reversed.toList();
                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(15),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index] as Map;
                    bool showDate = false;
                    DateTime date = msg['timestamp'] as DateTime;
                    if (index == messages.length - 1) { showDate = true; } 
                    else {
                      final prevMsg = messages[index + 1] as Map;
                      DateTime prevDate = prevMsg['timestamp'] as DateTime;
                      if (date.day != prevDate.day) showDate = true;
                    }
                    if (msg['isSystem'] == true) return _buildSystemMessage(msg['text']);
                    return Column(children: [
                      if (showDate) _buildDateHeader(date),
                      _buildChatBubble(msg, themeColor, msg['senderEmail'] == widget.currentUser.email),
                    ]);
                  },
                );
              },
            ),
          ),
          _buildInputBar(themeColor),
        ],
      ),
    );
  }

  Widget _buildHeader(Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
      color: bgColor,
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFF1A0505),
            backgroundImage: (!widget.isGroup && widget.otherUser?.profilePicture != null) 
                ? FileImage(File(widget.otherUser!.profilePicture!)) : null,
            child: (widget.isGroup) ? const Icon(Icons.groups, color: Colors.white) : 
                   (widget.otherUser?.profilePicture == null ? const Icon(Icons.person, color: Colors.white) : null),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(widget.isGroup ? _groupName : (widget.otherUser?.name ?? ""), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black))),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onSelected: (val) {
              if (val == 'details') _showGroupDetails();
              if (val == 'profile') _showOtherUserProfile();
              if (val == 'del') _clearOnlyMessages();
            },
            itemBuilder: (ctx) => [
              if (widget.isGroup) const PopupMenuItem(value: 'details', child: Text("Group Details"))
              else ...[
                const PopupMenuItem(value: 'profile', child: Text("View Profile")),
                const PopupMenuItem(value: 'del', child: Text("Delete Conversation", style: TextStyle(color: Colors.red))),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateHeader(DateTime date) {
    String day = (date.day == DateTime.now().day) ? "Today" : DateFormat('d MMMM yyyy').format(date);
    return Padding(padding: const EdgeInsets.symmetric(vertical: 15), child: Center(child: Text(day, style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.bold))));
  }

  Widget _buildSystemMessage(String text) {
    return Center(child: Padding(padding: const EdgeInsets.all(12), child: Text(text, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic, fontSize: 13))));
  }

  Widget _buildChatBubble(Map msg, Color color, bool isMe) {
    String time = DateFormat('HH:mm').format(msg['timestamp'] as DateTime);
    bool isSeen = msg['status'] == 'seen';
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (widget.isGroup && !isMe) Padding(padding: const EdgeInsets.only(left: 8, bottom: 2), child: Text(msg['senderName'] ?? "", style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            margin: const EdgeInsets.symmetric(vertical: 4),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            decoration: BoxDecoration(
              color: isMe ? color : Colors.grey[200],
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20), topRight: const Radius.circular(20),
                bottomLeft: isMe ? const Radius.circular(20) : Radius.zero,
                bottomRight: isMe ? Radius.zero : const Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (msg['imagePath'] != null) Padding(padding: const EdgeInsets.only(bottom: 5), child: ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.file(File(msg['imagePath'])))),
                if (msg['text'] != null) Text(msg['text'], style: TextStyle(color: isMe ? Colors.white : Colors.black87, fontSize: 16)),
              ],
            ),
          ),
          Row(mainAxisSize: MainAxisSize.min, children: [
            Text(time, style: const TextStyle(fontSize: 10, color: Colors.grey)),
            if (isMe) ...[const SizedBox(width: 4), Icon(Icons.done_all, size: 14, color: isSeen ? Colors.blue : Colors.grey)],
          ]),
        ],
      ),
    );
  }

  Widget _buildInputBar(Color themeColor) {
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 25, top: 10),
      child: Row(children: [
        IconButton(icon: Icon(Icons.camera_alt, color: themeColor), onPressed: () => showModalBottomSheet(
          context: context, builder: (ctx) => SafeArea(child: Wrap(children: [
            ListTile(leading: const Icon(Icons.camera), title: const Text('Camera'), onTap: () { Navigator.pop(ctx); _pickImage(ImageSource.camera); }),
            ListTile(leading: const Icon(Icons.image), title: const Text('Gallery'), onTap: () { Navigator.pop(ctx); _pickImage(ImageSource.gallery); }),
          ])))),
        Expanded(child: TextField(controller: _messageController, decoration: InputDecoration(hintText: "Message...", filled: true, fillColor: Colors.grey[100], border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none)))),
        const SizedBox(width: 8),
        CircleAvatar(backgroundColor: themeColor, child: IconButton(icon: const Icon(Icons.send, color: Colors.white), onPressed: () => _sendMessage(text: _messageController.text))),
      ]),
    );
  }
}
