import 'package:hive_flutter/hive_flutter.dart';

import '../utils/logger.dart';
import '../utils/match_rules.dart';

/// Το μοναδικό σημείο πρόσβασης σε συνομιλίες και ομάδες.
///
/// Τα κλειδιά των συνομιλιών χτίζονται ΜΟΝΟ εδώ (μέσω [directChatThreadId] /
/// [groupChatThreadId]). Όταν το ίδιο κλειδί χτιζόταν σε δύο αρχεία, τα δύο
/// αντίγραφα διαφώνησαν και τα μηνύματα κατέληγαν σε διαφορετικά boxes.
class ChatRepository {
  static const String _groupsBox = 'groups';

  /// Το box μιας προσωπικής συνομιλίας.
  ///
  /// ΣΗΜΕΙΩΣΗ: επιστρέφει Hive [Box] ώστε το UI να μπορεί να ακούει με
  /// `listenable()`. Είναι το τελευταίο σημείο όπου διαρρέει ο τύπος του Hive
  /// έξω από το data layer - με Firestore αντικαθίσταται από `Stream`.
  Future<Box> openDirectThread({
    required String myEmail,
    required String otherEmail,
    required String mode,
  }) {
    return Hive.openBox(
      directChatThreadId(myEmail: myEmail, otherEmail: otherEmail, mode: mode),
    );
  }

  /// Το box μιας ομαδικής συνομιλίας.
  Future<Box> openGroupThread(String groupId) =>
      Hive.openBox(groupChatThreadId(groupId));

  /// Προσθέτει μήνυμα στη συνομιλία.
  Future<void> sendMessage(
    Box thread, {
    required String senderEmail,
    required String senderName,
    String? text,
    String? imagePath,
    bool isSystem = false,
  }) {
    return thread.add({
      'senderEmail': isSystem ? 'system' : senderEmail,
      'senderName': senderName,
      'text': text,
      'imagePath': imagePath,
      'timestamp': DateTime.now(),
      'status': 'sent',
      'isSystem': isSystem,
    });
  }

  /// Σημειώνει ως διαβασμένα όσα μηνύματα δεν έστειλε ο [myEmail].
  Future<void> markSeen(Box thread, String myEmail) async {
    for (int i = 0; i < thread.length; i++) {
      final msg = thread.getAt(i);
      if (msg is Map && msg['senderEmail'] != myEmail) {
        msg['status'] = 'seen';
        await thread.putAt(i, msg);
      }
    }
  }

  /// Το τελευταίο μήνυμα μιας συνομιλίας, για την προεπισκόπηση στη λίστα.
  ///
  /// ΜΕ FIRESTORE: μην κάνετε ξεχωριστό ερώτημα ανά συνομιλία. Αποθηκεύστε
  /// `lastMessage` / `lastMessageAt` πάνω στο έγγραφο του match, ώστε η λίστα
  /// να κοστίζει ένα read ανά γραμμή αντί για ένα ερώτημα ανά γραμμή.
  Future<({String? text, String? imagePath, DateTime? at})> lastMessage(
    Box thread,
  ) async {
    if (thread.isEmpty) return (text: null, imagePath: null, at: null);

    final msg = thread.getAt(thread.length - 1);
    if (msg is! Map) return (text: null, imagePath: null, at: null);

    final rawTime = msg['timestamp'];
    return (
      text: msg['text'] as String?,
      imagePath: msg['imagePath'] as String?,
      at: rawTime is DateTime ? rawTime : null,
    );
  }

  // ---------------------------------------------------------------------
  // Ομάδες
  // ---------------------------------------------------------------------

  /// Οι ομάδες στις οποίες συμμετέχει ο [email] για το [mode].
  Future<List<Map>> groupsFor({
    required String email,
    required String mode,
  }) async {
    final box = await Hive.openBox(_groupsBox);
    return box.values.whereType<Map>().where((group) {
      final members = List<String>.from(group['members'] ?? const <String>[]);
      return group['mode'] == mode && members.contains(email);
    }).toList();
  }

  /// Δημιουργεί ομάδα και επιστρέφει τα δεδομένα της.
  Future<Map<String, dynamic>> createGroup({
    required String name,
    required String mode,
    required String adminEmail,
    required Set<String> memberEmails,
  }) async {
    final box = await Hive.openBox(_groupsBox);
    final members = {...memberEmails, adminEmail}.toList();

    final group = <String, dynamic>{
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'name': name,
      'mode': mode,
      'members': members,
      'admin': adminEmail,
      'created_at': DateTime.now().toIso8601String(),
    };

    await box.add(group);
    return group;
  }

  /// Ενημερώνει όνομα, μέλη και admin μιας υπάρχουσας ομάδας.
  Future<void> updateGroup({
    required String groupId,
    required String name,
    required List<String> members,
    required String adminEmail,
  }) async {
    final box = await Hive.openBox(_groupsBox);
    final key = box.keys.firstWhere(
      (k) => (box.get(k) as Map?)?['id'] == groupId,
      orElse: () => null,
    );

    if (key == null) {
      logDebug('updateGroup: group not found');
      return;
    }

    final updated = Map<String, dynamic>.from(box.get(key) as Map);
    updated['name'] = name;
    updated['members'] = members;
    updated['admin'] = adminEmail;
    await box.put(key, updated);
  }
}