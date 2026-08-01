import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../utils/logger.dart';

/// Αποθήκευση των εικόνων προφίλ στον χώρο της εφαρμογής.
///
/// Ο image_picker επιστρέφει διαδρομή σε προσωρινό φάκελο που το λειτουργικό
/// καθαρίζει, οπότε το αρχείο πρέπει να αντιγραφεί κάπου μόνιμα.
///
/// ΜΕ FIREBASE: αντικαθίσταται από Cloud Storage - το [saveAvatar] ανεβάζει
/// και επιστρέφει URL αντί για τοπική διαδρομή. Ο υπόλοιπος κώδικας κρατάει
/// ένα String, οπότε δεν αλλάζει.
class AvatarStorage {
  static const String _folder = 'avatar_images';

  Future<Directory> _directory() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(base.path, _folder));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Αντιγράφει την [picked] στον χώρο της εφαρμογής και επιστρέφει τη νέα
  /// διαδρομή. Αν δοθεί [previousPath], το παλιό αρχείο διαγράφεται.
  Future<String> saveAvatar(
    XFile picked, {
    required String ownerEmail,
    String? previousPath,
  }) async {
    final dir = await _directory();

    final safeEmail = ownerEmail.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
    final fileName =
        '${safeEmail}_${DateTime.now().millisecondsSinceEpoch}${p.extension(picked.path)}';

    final saved = await File(picked.path).copy(p.join(dir.path, fileName));

    if (previousPath != null) {
      await deleteAvatar(previousPath);
    }

    return saved.path;
  }

  /// Διαγράφει ένα αποθηκευμένο avatar, αγνοώντας σφάλματα.
  Future<void> deleteAvatar(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) await file.delete();
    } catch (e) {
      logDebug('Could not delete avatar file: $e');
    }
  }
}