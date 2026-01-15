import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../models/tester.dart';


class ChatPage extends StatefulWidget {
  final String userMode;
  final Tester currentUser;
  final Tester otherUser;

  const ChatPage({
    super.key,
    required this.userMode,
    required this.currentUser,
    required this.otherUser,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  Box? _chatBox;
  bool _isBoxReady = false;

  @override
  void initState() {
    super.initState();
    _openChatBox();
  }

  Future<void> _openChatBox() async {
    List<String> emails = [widget.currentUser.email, widget.otherUser.email];
    emails.sort();
    
    String emailsPart = emails.join('_').replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
    String modePart = widget.userMode.toLowerCase().replaceAll('-', '');
    String chatId = 'chat_${modePart}_$emailsPart';

    _chatBox = await Hive.openBox(chatId);
    _markMessagesAsSeen();
    if (mounted) {
      setState(() => _isBoxReady = true);
    }
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

  // ΛΕΙΤΟΥΡΓΙΑ 1: ΑΠΛΗ ΔΙΑΓΡΑΦΗ ΜΗΝΥΜΑΤΩΝ (ΚΡΑΤΑΕΙ ΤΟ MATCH)
  Future<void> _clearOnlyMessages() async {
    await _chatBox?.clear();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conversation history cleared')),
      );
      setState(() {}); 
    }
  }

  // ΛΕΙΤΟΥΡΓΙΑ 2: BLOCK & UNMATCH (ΔΙΑΓΡΑΦΕΙ ΤΟ MATCH)
  Future<void> _blockAndDeleteEverything() async {
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

        modeLikes.removeWhere((email) => email.toLowerCase() == widget.otherUser.email.toLowerCase());
        updatedLikedBy[widget.userMode] = modeLikes;
        
        final updatedUser = Tester(
          name: myUser.name,
          email: myUser.email,
          passwordHash: myUser.passwordHash,
          country: myUser.country,
          interests: myUser.interests,
          age: myUser.age,
          level: myUser.level,
          gender: myUser.gender,
          profilePicture: myUser.profilePicture,
          likedBy: updatedLikedBy,
          isProfessionalVerified: myUser.isProfessionalVerified,
        );

        await userBox.putAt(currentUserIndex, updatedUser);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User blocked and unmatched')));
        Navigator.pop(context); // Επιστροφή στη λίστα (ο χρήστης θα εξαφανιστεί)
      }
    } catch (e) {
      debugPrint("Block error: $e");
    }
  }

  void _showOtherUserProfile() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A0505),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              CircleAvatar(
                radius: 60,
                backgroundImage: (widget.otherUser.profilePicture != null && widget.otherUser.profilePicture!.isNotEmpty)
                    ? FileImage(File(widget.otherUser.profilePicture!)) : null,
                child: (widget.otherUser.profilePicture == null) ? const Icon(Icons.person, size: 60) : null,
              ),
              const SizedBox(height: 15),
              Text(widget.otherUser.name, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              const Divider(color: Colors.white24, height: 30),
              _infoRow(Icons.location_on, "Country: ${widget.otherUser.country}"),
              _infoRow(Icons.fitness_center, "Level: ${widget.otherUser.level}"),
              const SizedBox(height: 30),
              GestureDetector(
                onTap: () { Navigator.pop(context); _blockAndDeleteEverything(); },
                child: const Text("Block & Delete Conversation", 
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, decoration: TextDecoration.underline, fontSize: 16)),
              ),
              const SizedBox(height: 20),
            ],
          ),
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

  void _sendMessage({String? text, String? imagePath}) {
    if (_chatBox == null) return;
    if ((text != null && text.trim().isNotEmpty) || imagePath != null) {
      _chatBox!.add({
        'senderEmail': widget.currentUser.email,
        'text': text,
        'imagePath': imagePath,
        'timestamp': DateTime.now(),
        'status': 'sent',
      });
      _messageController.clear();
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) _sendMessage(imagePath: image.path);
    } catch (e) { debugPrint("Error: $e"); }
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
        elevation: 0,
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
          _buildUserInfoHeader(lightColor),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: _chatBox!.listenable(),
              builder: (context, Box box, _) {
                final messages = box.values.toList().reversed.toList();
                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(15),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index] as Map;
                    bool isMe = msg['senderEmail'] == widget.currentUser.email;
                    
                    bool showDate = false;
                    DateTime date = msg['timestamp'] as DateTime;
                    if (index == messages.length - 1) {
                      showDate = true;
                    } else {
                      final prevMsg = messages[index + 1] as Map;
                      DateTime prevDate = prevMsg['timestamp'] as DateTime;
                      if (date.day != prevDate.day) showDate = true;
                    }

                    return Column(
                      children: [
                        if (showDate) _buildDateHeader(date),
                        _buildChatBubble(msg, themeColor, isMe),
                      ],
                    );
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

  Widget _buildUserInfoHeader(Color lightBgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      color: lightBgColor,
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFF1A0505),
            backgroundImage: (widget.otherUser.profilePicture != null) ? FileImage(File(widget.otherUser.profilePicture!)) : null,
            child: (widget.otherUser.profilePicture == null) ? const Icon(Icons.person, color: Colors.white) : null,
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(widget.otherUser.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.black))),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onSelected: (val) {
              if (val == 'view') _showOtherUserProfile();
              if (val == 'del') _clearOnlyMessages();
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(value: 'view', child: Text("View Profile")),
              const PopupMenuItem(value: 'del', child: Text("Delete Conversation", style: TextStyle(color: Colors.red))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateHeader(DateTime date) {
    String day = (date.day == DateTime.now().day && date.month == DateTime.now().month) 
        ? "Today" 
        : DateFormat('d MMMM yyyy').format(date);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Center(child: Text(day, style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.bold))),
    );
  }

  Widget _buildChatBubble(Map msg, Color color, bool isMe) {
    String time = DateFormat('HH:mm').format(msg['timestamp'] as DateTime);
    bool isSeen = msg['status'] == 'seen';

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            margin: const EdgeInsets.symmetric(vertical: 4),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            decoration: BoxDecoration(
              color: isMe ? color : Colors.grey[200],
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: isMe ? const Radius.circular(20) : Radius.zero,
                bottomRight: isMe ? Radius.zero : const Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (msg['imagePath'] != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.file(File(msg['imagePath']))),
                  ),
                if (msg['text'] != null && msg['text'].toString().isNotEmpty)
                  Text(msg['text'], style: TextStyle(color: isMe ? Colors.white : Colors.black87, fontSize: 16)),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(time, style: const TextStyle(fontSize: 10, color: Colors.grey)),
              if (isMe) ...[
                const SizedBox(width: 4),
                Icon(Icons.done_all, size: 14, color: isSeen ? Colors.blue : Colors.grey),
              ]
            ],
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildInputBar(Color themeColor) {
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 25, top: 10),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.camera_alt, color: themeColor),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (ctx) => SafeArea(
                  child: Wrap(children: [
                    ListTile(leading: const Icon(Icons.camera), title: const Text('Camera'), onTap: () { _pickImage(ImageSource.camera); Navigator.pop(ctx); }),
                    ListTile(leading: const Icon(Icons.image), title: const Text('Gallery'), onTap: () { _pickImage(ImageSource.gallery); Navigator.pop(ctx); }),
                  ]),
                ),
              );
            },
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: "Message...",
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: themeColor,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: () => _sendMessage(text: _messageController.text),
            ),
          ),
        ],
      ),
    );
  }
}