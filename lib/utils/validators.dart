/// Ο ελάχιστος επιτρεπτός ηλικιακός περιορισμός για χρήση της εφαρμογής.
const int minimumAge = 18;

/// Άνω όριο, ώστε να απορρίπτονται προφανώς λανθασμένες τιμές.
const int maximumAge = 120;

/// Επιστρέφει μήνυμα σφάλματος για το [value], ή null αν η ηλικία είναι δεκτή.
///
/// Χρησιμοποιείται και από τη φόρμα εγγραφής και από τη φόρμα επεξεργασίας
/// προφίλ, ώστε το όριο ηλικίας να μην μπορεί να παρακαμφθεί αλλάζοντας το
/// προφίλ μετά την εγγραφή.
String? validateAge(String? value) {
  final trimmed = value?.trim() ?? '';
  if (trimmed.isEmpty) return 'Enter your age';

  final age = int.tryParse(trimmed);
  if (age == null) return 'Enter a valid number';
  if (age < minimumAge) return 'You must be at least $minimumAge';
  if (age > maximumAge) return 'Enter a valid age';

  return null;
}