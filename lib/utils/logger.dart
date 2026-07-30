import 'package:flutter/foundation.dart';

/// Καταγραφή διαγνωστικών μηνυμάτων μόνο σε debug builds.
///
/// Το `debugPrint` της Flutter ΔΕΝ αφαιρείται από τα release builds - απλώς
/// περιορίζει τον ρυθμό εξόδου και στη συνέχεια καλεί `print`. Ο έλεγχος
/// [kDebugMode] είναι αυτός που κρατάει τα logs εκτός της έκδοσης που φτάνει
/// στους χρήστες.
///
/// Μην περνάτε προσωπικά δεδομένα (email, ονόματα, λίστες από likes). Τα logs
/// καταλήγουν στο logcat και στα bug reports, και τα SDK καταγραφής crash
/// (Crashlytics, Sentry) συχνά τα επισυνάπτουν στις αναφορές που στέλνουν.
void logDebug(String message) {
  if (kDebugMode) {
    debugPrint(message);
  }
}