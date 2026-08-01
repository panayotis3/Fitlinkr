import 'dart:io';

import 'package:hive_flutter/hive_flutter.dart';

import '../models/tester.dart';
import '../utils/logger.dart';
import '../utils/match_rules.dart';

/// Το μοναδικό σημείο πρόσβασης στα δεδομένα χρηστών.
///
/// Καμία οθόνη δεν ανοίγει Hive box απευθείας. Έτσι η μετάβαση σε Firestore
/// αγγίζει μόνο αυτό το αρχείο αντί για εννιά αρχεία UI.
///
/// ΣΧΕΔΙΑΣΜΟΣ: οι υπογραφές είναι φτιαγμένες όπως ρωτάει κανείς έναν server -
/// τα φίλτρα και το [limit] περνούν ΜΕΣΑ στο ερώτημα. Σήμερα, με Hive, η
/// υλοποίηση σαρώνει ούτως ή άλλως τα πάντα τοπικά (δωρεάν). Με Firestore
/// όμως το φιλτράρισμα πρέπει να γίνει στον server: αν κατεβάζαμε όλους τους
/// χρήστες και φιλτράραμε στη συσκευή, θα πληρώναμε ένα read ανά χρήστη ανά
/// άνοιγμα οθόνης - και θα χρειαζόμασταν δικαίωμα ανάγνωσης σε ΟΛΟΥΣ τους
/// χρήστες, που είναι και κενό ασφαλείας.
class UserRepository {
  static const String _usersBox = 'testers_v2';
  static const String _interactionsBox = 'user_interactions';

  Future<Box<Tester>> _open() => Hive.openBox<Tester>(_usersBox);

  /// Το κλειδί Hive της εγγραφής με το δοσμένο email, ή null.
  dynamic _keyForEmail(Box<Tester> box, String email) {
    final target = email.toLowerCase();
    return box.keys.cast<dynamic>().firstWhere(
      (k) => box.get(k)?.email.toLowerCase() == target,
      orElse: () => null,
    );
  }

  /// Η εγγραφή με το δοσμένο email, ή null αν δεν υπάρχει.
  Future<Tester?> findByEmail(String email) async {
    final box = await _open();
    final key = _keyForEmail(box, email);
    return key == null ? null : box.get(key);
  }

  /// Οι εγγραφές για τα δοσμένα emails, με κλειδί το email σε πεζά.
  ///
  /// ΜΕ FIRESTORE: ένα ερώτημα `whereIn` (σε ομάδες των 30) αντί για ένα
  /// ερώτημα ανά χρήστη.
  Future<Map<String, Tester>> findByEmails(Iterable<String> emails) async {
    final box = await _open();
    final wanted = emails.map((e) => e.toLowerCase()).toSet();

    return {
      for (final user in box.values)
        if (wanted.contains(user.email.toLowerCase()))
          user.email.toLowerCase(): user,
    };
  }

  /// Αν υπάρχει ήδη λογαριασμός με αυτό το email (case-insensitive).
  ///
  /// Με Firebase Auth αυτό φεύγει εντελώς - ο έλεγχος μοναδικότητας γίνεται
  /// server-side κατά την εγγραφή.
  Future<bool> emailExists(String email) async =>
      await findByEmail(email) != null;

  /// Δημιουργία νέου λογαριασμού.
  Future<void> create(Tester tester) async {
    final box = await _open();
    await box.add(tester);
  }

  /// Ενημέρωση των πεδίων που ελέγχει η φόρμα προφίλ.
  ///
  /// Διαβάζει την τρέχουσα εγγραφή αμέσως πριν το write, ώστε αλλαγές που
  /// έγιναν στο μεταξύ (π.χ. likes που δεχτήκαμε) να μη χάνονται.
  Future<void> updateProfile({
    required String email,
    required String name,
    required String country,
    required String interests,
    required int age,
    required String level,
    required String gender,
    required String? profilePicture,
    required bool isProfessionalVerified,
  }) async {
    final box = await _open();
    final key = _keyForEmail(box, email);
    final current = key == null ? null : box.get(key);
    if (current == null) {
      logDebug('updateProfile: no record found for the given account');
      return;
    }

    final updated = current.copyWith(
      name: name,
      country: country,
      interests: interests,
      age: age,
      level: level,
      gender: gender,
      profilePicture: profilePicture,
      isProfessionalVerified: isProfessionalVerified,
    );

    await box.put(key, updated);
    await box.flush();
  }

  /// Σήμανση του λογαριασμού ως επαληθευμένου επαγγελματία.
  ///
  /// ΠΡΟΣΟΧΗ: σήμερα το γράφει ο ίδιος ο client. Σε πραγματική εφαρμογή αυτό
  /// πρέπει να το ορίζει ΜΟΝΟ ο server μετά από ανθρώπινο έλεγχο.
  Future<void> setProfessionalVerified(String email) async {
    final box = await _open();
    final key = _keyForEmail(box, email);
    final current = key == null ? null : box.get(key);
    if (current == null) return;
    await box.put(key, current.copyWith(isProfessionalVerified: true));
  }

  /// Οριστική διαγραφή λογαριασμού: φωτογραφία, likes άλλων χρηστών προς
  /// αυτόν, και η ίδια η εγγραφή.
  Future<bool> deleteAccount(String email) async {
    final box = await _open();
    final key = _keyForEmail(box, email);
    if (key == null) return false;

    final user = box.get(key);

    if (user?.profilePicture != null) {
      try {
        final file = File(user!.profilePicture!);
        if (await file.exists()) await file.delete();
      } catch (e) {
        logDebug('Could not delete profile picture: $e');
      }
    }

    await _removeFromEveryonesLikes(box, email);
    await box.delete(key);
    return true;
  }

  // ---------------------------------------------------------------------
  // Swipe
  // ---------------------------------------------------------------------

  /// Οι υποψήφιοι που πρέπει να δει ο [viewerEmail] στο [mode].
  ///
  /// Εξαιρούνται: ο ίδιος, όσοι έχουν ήδη κριθεί (like ή pass) σε αυτό το
  /// mode, και - στο Learner mode - όσοι δεν είναι επαληθευμένοι
  /// επαγγελματίες. Όσοι μας έχουν ήδη κάνει like έρχονται πρώτοι.
  ///
  /// ΜΕ FIRESTORE: όλα τα παραπάνω πρέπει να γίνουν server-side ερώτημα με
  /// `.where(...).limit(limit)`. Το να κατέβουν όλοι οι χρήστες και να
  /// φιλτραριστούν εδώ θα κόστιζε ένα read ανά χρήστη ανά άνοιγμα οθόνης.
  Future<List<Tester>> fetchSwipeCandidates({
    required String viewerEmail,
    required String mode,
    int limit = 50,
  }) async {
    final box = await _open();
    final viewer = viewerEmail.toLowerCase();

    final judged = await _interactionsFor(viewerEmail, mode);

    var candidates = box.values.where((user) {
      final email = user.email.toLowerCase();
      if (email == viewer) return false;
      if (judged.contains(email)) return false;

      // Οι Learners βλέπουν μόνο επαληθευμένους επαγγελματίες.
      if (mode.toLowerCase() == 'learner' && !user.isProfessionalVerified) {
        return false;
      }

      // Όποιον έχουμε ήδη κάνει like δεν τον ξαναδείχνουμε.
      final likesOnThem = user.likedBy?[mode] ?? const <String>[];
      return !likesOnThem.contains(viewer);
    }).toList();

    // Όσοι μας έκαναν like πρώτοι.
    final me = await findByEmail(viewerEmail);
    final whoLikedMe = me?.likedBy?[counterpartMode(mode)] ?? const <String>[];

    candidates.sort((a, b) {
      final aLiked = whoLikedMe.contains(a.email.toLowerCase()) ? 0 : 1;
      final bLiked = whoLikedMe.contains(b.email.toLowerCase()) ? 0 : 1;
      return aLiked.compareTo(bLiked);
    });

    return candidates.take(limit).toList();
  }

  /// Τα emails που ο [email] έχει ήδη κρίνει (like ή pass) στο [mode].
  Future<Set<String>> _interactionsFor(String email, String mode) async {
    final box = await Hive.openBox(_interactionsBox);
    final key = '${email.toLowerCase()}_${mode.toLowerCase()}';
    final stored = box.get(key, defaultValue: <String>[]) as List;
    return stored.cast<String>().toSet();
  }

  /// Καταγράφει ότι ο [viewerEmail] έκρινε τον [targetEmail] (like ή pass),
  /// ώστε να μην ξαναεμφανιστεί.
  Future<void> recordInteraction({
    required String viewerEmail,
    required String mode,
    required String targetEmail,
  }) async {
    final box = await Hive.openBox(_interactionsBox);
    final key = '${viewerEmail.toLowerCase()}_${mode.toLowerCase()}';
    final current = (box.get(key, defaultValue: <String>[]) as List)
        .cast<String>()
        .toList();

    if (current.contains(targetEmail.toLowerCase())) return;
    current.add(targetEmail.toLowerCase());
    await box.put(key, current);
  }

  /// Καταγράφει ένα like και επιστρέφει true αν προέκυψε αμοιβαίο match.
  ///
  /// Το like αποθηκεύεται πάνω στον ΧΡΗΣΤΗ ΠΟΥ ΔΕΧΤΗΚΕ το like, με κλειδί το
  /// mode στο οποίο έκανε swipe αυτός που το έδωσε - δείτε [counterpartMode].
  Future<bool> like({
    required String fromEmail,
    required String toEmail,
    required String mode,
  }) async {
    final box = await _open();
    final targetKey = _keyForEmail(box, toEmail);
    final target = targetKey == null ? null : box.get(targetKey);
    if (target == null) return false;

    final likedBy = Map<String, List<String>>.from(target.likedBy ?? {});
    final forMode = List<String>.from(likedBy[mode] ?? const <String>[]);
    if (!forMode.contains(fromEmail.toLowerCase())) {
      forMode.add(fromEmail.toLowerCase());
    }
    likedBy[mode] = forMode;

    await box.put(targetKey, target.copyWith(likedBy: likedBy));

    // Match αν αυτός που μόλις κάναμε like μας είχε ήδη κάνει like από το
    // αντίστοιχο mode.
    final me = await findByEmail(fromEmail);
    final theyLikedMe =
        me?.likedBy?[counterpartMode(mode)] ?? const <String>[];
    return theyLikedMe.contains(toEmail.toLowerCase());
  }

  // ---------------------------------------------------------------------
  // Matches
  // ---------------------------------------------------------------------

  /// Όσοι έχουν αμοιβαίο like με τον [email] στο [mode].
  Future<List<Tester>> fetchMatches({
    required String email,
    required String mode,
  }) async {
    final me = await findByEmail(email);
    if (me == null) return const [];

    // Τα likes προς εμένα είναι αποθηκευμένα με το mode του άλλου.
    final whoLikedMe = me.likedBy?[counterpartMode(mode)] ?? const <String>[];
    if (whoLikedMe.isEmpty) return const [];

    final box = await _open();
    final matches = <Tester>[];

    for (final otherEmail in whoLikedMe) {
      final key = _keyForEmail(box, otherEmail);
      final other = key == null ? null : box.get(key);
      if (other == null) continue;

      if (isMutualMatch(me: me, other: other, mode: mode)) {
        matches.add(other);
      }
    }

    return matches;
  }

  /// Καταργεί το match ανάμεσα στους δύο χρήστες και για τις δύο πλευρές.
  Future<void> unmatch({
    required String email,
    required String otherEmail,
    required String mode,
  }) async {
    final box = await _open();

    // Το like ΤΟΥΣ προς εμένα ζει κάτω από το δικό τους mode...
    await _removeLike(
      box,
      ownerEmail: email,
      likerEmail: otherEmail,
      mode: counterpartMode(mode),
    );

    // ...και το δικό ΜΟΥ like προς αυτούς κάτω από το δικό μου.
    await _removeLike(
      box,
      ownerEmail: otherEmail,
      likerEmail: email,
      mode: mode,
    );
  }

  /// Αφαιρεί το [likerEmail] από το `likedBy[mode]` του [ownerEmail].
  Future<void> _removeLike(
    Box<Tester> box, {
    required String ownerEmail,
    required String likerEmail,
    required String mode,
  }) async {
    final key = _keyForEmail(box, ownerEmail);
    final owner = key == null ? null : box.get(key);
    if (owner == null) return;

    final likedBy = Map<String, List<String>>.from(owner.likedBy ?? {});
    final forMode = List<String>.from(likedBy[mode] ?? const <String>[]);
    if (!forMode.remove(likerEmail.toLowerCase())) return;

    likedBy[mode] = forMode;
    await box.put(key, owner.copyWith(likedBy: likedBy));
  }

  /// Αφαιρεί το [email] από τις λίστες likedBy όλων των υπόλοιπων χρηστών.
  Future<void> _removeFromEveryonesLikes(Box<Tester> box, String email) async {
    final target = email.toLowerCase();

    for (final key in box.keys) {
      final user = box.get(key);
      if (user == null || user.email.toLowerCase() == target) continue;

      final likedByMap = Map<String, List<String>>.from(user.likedBy ?? {});
      var changed = false;

      for (final mode in likedByMap.keys) {
        final emails = List<String>.from(likedByMap[mode]!);
        if (emails.remove(target)) {
          likedByMap[mode] = emails;
          changed = true;
        }
      }

      if (changed) {
        await box.put(key, user.copyWith(likedBy: likedByMap));
      }
    }
  }
}