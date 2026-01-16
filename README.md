# FitLinkr 

**FitLinkr** είναι μια καινοτόμος εφαρμογή γνωριμιών που συνδυάζει την αγάπη για τη φυσική δραστηριότητα με τη δημιουργία νέων κοινωνικών σχέσεων. Η εφαρμογή προσφέρει πολλαπλές λειτουργίες swipe για διαφορετικούς σκοπούς: από φιλικές σχέσεις έως επαγγελματική καθοδήγηση και ρομαντικές γνωριμίες μεταξύ ατόμων με κοινά fitness ενδιαφέροντα.

---

## Πίνακας Περιεχομένων

- [α. Οδηγίες Εγκατάστασης & Χρήσης](#α-οδηγίες-εγκατάστασης--χρήσης)
- [β. Τεχνικές Προδιαγραφές](#β-τεχνικές-προδιαγραφές)
- [γ. Σύγκριση με Πρωτότυπο](#γ-σύγκριση-με-πρωτότυπο)
- [δ. Βίντεο Παρουσίασης](#δ-βίντεο-παρουσίασης)
- [Χαρακτηριστικά Εφαρμογής](#-χαρακτηριστικά-εφαρμογής)
- [Επαλήθευση Λειτουργικότητας](#-επαλήθευση-λειτουργικότητας)

---

## α. Οδηγίες Εγκατάστασης & Χρήσης

### Εγκατάσταση

Η εφαρμογή FitLinkr είναι σχεδιασμένη για **απλή και γρήγορη εγκατάσταση** χωρίς περίπλοκα βήματα.

#### **Μέθοδος 1: Εγκατάσταση APK (Συνιστάται)**

1. **Κατεβάστε το APK** από τον παρακάτω σύνδεσμο:
   - **[Λήψη APK FitLinkr](#)** *(συμπληρώστε με το link σας)*

2. **Ενεργοποιήστε την εγκατάσταση από άγνωστες πηγές:**
   - Πηγαίνετε στις **Ρυθμίσεις** → **Ασφάλεια** → Ενεργοποιήστε **"Εγκατάσταση από άγνωστες πηγές"**
   - (Για Android 8.0+): Ρυθμίσεις → Εφαρμογές → Πρόσβαση ειδικών εφαρμογών → Εγκατάσταση άγνωστων εφαρμογών → Επιλέξτε το πρόγραμμα περιήγησης/διαχειριστή αρχείων → Επιτρέψτε

3. **Εγκαταστήστε το APK:**
   - Ανοίξτε το κατεβασμένο αρχείο `.apk`
   - Πατήστε **"Εγκατάσταση"**
   - Περιμένετε να ολοκληρωθεί η εγκατάσταση

4. **Ανοίξτε την εφαρμογή** και ξεκινήστε!

#### **Μέθοδος 2: Εκτέλεση από Κώδικα (Για Developers)**

```bash
# 1. Clone το repository
git clone [URL_REPOSITORY]
cd fitlinkr

# 2. Εγκατάσταση dependencies
flutter pub get

# 3. Σύνδεση Android device ή εκκίνηση emulator
flutter devices

# 4. Εκτέλεση της εφαρμογής
flutter run
```

---

### Προδημιουργημένοι Λογαριασμοί Δοκιμής

Για να δείτε **όλες τις δυνατότητες** της εφαρμογής αμέσως, χρησιμοποιήστε τους παρακάτω λογαριασμούς:

| Email | Password | Όνομα | Χαρακτηριστικά |
|---------|------------|---------|-----------------|
| `popi@example.com` | `popi123` | Popi | Επαληθευμένη Professional, 29 ετών, Expert |
| `kiki@example.com` | `kiki123` | Kiki | 29 ετών, Expert, Female |
| `petros@example.com` | `petros123` | Petros | 29 ετών, Expert, Male |
| `nikos@example.com` | `password123` | Nikos | 29 ετών, Expert, Male |
| `sara@example.com` | `saraPass!` | Sara | 25 ετών, Beginner, Yoga |
| `amir@example.com` | `amir$ecure` | Amir | 31 ετών, Intermediate, Running |

💡 **Συμβουλή:** Συνδεθείτε με διαφορετικούς λογαριασμούς για να δείτε τις αλληλεπιδράσεις (matches, chat, likes).

---

### Οδηγίες Χρήσης

#### **1. Εγγραφή Νέου Χρήστη**

1. Πατήστε **"Sign Up"** από την αρχική οθόνη
2. Συμπληρώστε τα στοιχεία σας:
   - Όνομα, Email, Κωδικός Πρόσβασης
   - Χώρα, Ηλικία (18-120 ετών)
   - Φύλο (Male/Female/Other)
   - Ενδιαφέροντα (Gym, Yoga, Running, κλπ.)
   - Επίπεδο (Beginner/Intermediate/Expert)
3. Πατήστε **"Register"**

#### **2. Σύνδεση**

1. Εισάγετε το **Email** και **Password** σας
2. Πατήστε **"Login"**
3. (Προαιρετικό) Χρησιμοποιήστε **"Forgot Password?"** για ανάκτηση κωδικού

#### **3. Επεξεργασία Προφίλ**

1. Μετά τη σύνδεση, θα μεταφερθείτε στη σελίδα **Edit Profile**
2. **Προσθήκη φωτογραφίας:**
   - Πατήστε **"Edit Details"** κουμπί
   - Πατήστε το avatar (εικονίδιο κάμερας) → Επιλέξτε **"Take photo"**, **"Choose from Gallery"** ή **"Remove Photo"**
3. **Ενημέρωση στοιχείων:**
   - Πατήστε **"Edit Details"** → Τροποποιήστε όνομα, χώρα, ενδιαφέροντα, ηλικία, επίπεδο, φύλο → **"SAVE"**

#### **4. Επιλογή Λειτουργίας (Mode)**

Η FitLinkr προσφέρει **4 διαφορετικές λειτουργίες**:

| Mode | Περιγραφή | Σκοπός |
|---------|-------------|-----------|
|🟥**Friend** | Φιλική γνωριμία | Βρείτε φίλους για κοινές προπονήσεις |
|🟩**Learner** | Μαθητής | Βρείτε επαληθευμένους επαγγελματίες για καθοδήγηση |
|🟦**Professional** | Επαγγελματίας | Προσφέρετε υπηρεσίες προπονητή (απαιτείται επαλήθευση) |
|💕🟪 **Swole-Mate** | Ρομαντική γνωριμία | Βρείτε το ταίρι σας στο γυμναστήριο! |

**Για να ξεκινήσετε σε ένα mode:**
- Στη σελίδα **Edit Profile**, κάντε scroll κάτω στο **"Mode Selection"**
- Πατήστε στο mode που θέλετε (π.χ. Learner, Professional, Friend, Swole-mate)
- Θα μεταφερθείτε αυτόματα στην οθόνη swipe για αυτό το mode
- **Σημείωση:** Το Professional mode είναι κλειδωμένο μέχρι να επαληθευτείτε

#### **5. Swipe & Match**

1. Επιλέξτε ένα mode από τη σελίδα **Edit Profile** (βλ. παραπάνω)
2. Θα δείτε προφίλ άλλων χρηστών σε κάρτες
3. **Swipe Right (→)** ή πατήστε το **❤️** κουμπί για Like
4. **Swipe Left (←)** ή πατήστε το **❌** κουμπί για Pass  
5. Αν υπάρχει **αμοιβαίο like → MATCH!** 🎉
6. Το match εμφανίζεται αυτόματα στη λίστα των chats σας
7. **Φίλτρα:** Πατήστε το **⚙️ εικονίδιο** (κάτω δεξιά) για να φιλτράρετε κατά επίπεδο, χώρα, φύλο, ενδιαφέροντα

#### **6. Chat & Messaging**

1. Από το Swipe screen, πατήστε το κουμπί **"CHAT"** (κάτω αριστερά)
2. Δείτε όλα τα matches σας για το τρέχον mode
3. **Πατήστε σε ένα chat** για να ανοίξετε τη συνομιλία
4. **Αποστολή μηνύματος:**
   - Πληκτρολογήστε το μήνυμα στο κάτω πεδίο
   - Πατήστε το **▶️ εικονίδιο Send**
5. **Αποστολή εικόνας:**
   - Πατήστε το **📷 εικονίδιο** (αριστερά από το πεδίο μηνύματος)
   - Επιλέξτε εικόνα από τη συλλογή σας
6. **Δημιουργία Group Chat:**
   - Από τη λίστα chats, πατήστε **"+"** (πάνω δεξιά)
   - Επιλέξτε μέλη από τα matches σας → Δώστε όνομα ομάδας → **"CREATE"**
7. **Επιστροφή στο Swipe:** Πατήστε το mode icon (πάνω δεξιά στη chat list)

#### **7. Επαλήθευση ως Professional**

1. Στη σελίδα **Edit Profile**, κάντε scroll κάτω στο **"Mode Selection"**
2. Βρείτε το **"Professional"** mode και πατήστε το κουμπί **"VERIFY"**
3. Ανεβάστε:
   - **📄 ID/Ταυτότητα** (πατήστε "Choose ID Image" → επιλέξτε από Gallery ή Camera)
   - **🎓 Πιστοποιητικό** (πατήστε "Choose Certificate Image" → επιλέξτε από Gallery ή Camera)
4. Πατήστε **"Submit for Review"**
5. Θα δείτε επιβεβαίωση επιτυχίας με πράσινο checkmark
6. ✅ Το κουμπί αλλάζει σε **"VERIFIED"** (πράσινο)
7. Μπορείτε τώρα να χρησιμοποιήσετε το Professional mode

#### **8. Ρυθμίσεις Λογαριασμού**

1. Από το **Edit Profile** → Πατήστε το εικονίδιο **⚙️ Settings** (δίπλα από το "Edit Details")
2. **Αλλαγή κωδικού:**
   - Πατήστε **"Change Password"**
   - Εισάγετε τον **τρέχοντα κωδικό**
   - Εισάγετε τον **νέο κωδικό** (τουλάχιστον 6 χαρακτήρες)
   - Πατήστε **"CHANGE PASSWORD"**
3. **Διαγραφή λογαριασμού:**
   - Πατήστε **"Delete Account"** (κόκκινο κουμπί)
   - Εισάγετε τον **κωδικό** σας
   - Πληκτρολογήστε **"DELETE"** για επιβεβαίωση
   - Πατήστε **"DELETE ACCOUNT"**
   - ⚠️ **Μη αναστρέψιμη ενέργεια!** Διαγράφονται: προφίλ, φωτογραφίες, matches, chats, likes

---

## β. Τεχνικές Προδιαγραφές

### 📱 Απαιτήσεις Συστήματος

| Πεδίο | Απαίτηση |
|-------|----------|
| **Πλατφόρμα** | Android |
| **Minimum SDK** | API Level 21 (Android 5.0 Lollipop) |
| **Target SDK** | API Level 35 (Android 15) |
| **Compile SDK** | API Level 35 |
| **System Image** | Με ή χωρίς Google Play Services (η εφαρμογή χρησιμοποιεί τοπική βάση Hive) |
| **Αρχιτεκτονική** | ARM64-v8a, ARMv7, x86, x86_64 |

### 🛠️ Τεχνολογίες & Dependencies

#### **Core Framework**
- **Flutter SDK:** 3.10.3+
- **Dart SDK:** 3.10.3+

#### **Βάση Δεδομένων**
- **Hive:** 2.2.3 (NoSQL τοπική βάση)
- **Hive Flutter:** 1.1.0
- **Path Provider:** 2.1.3

#### **Ασφάλεια**
- **BCrypt:** 1.2.0 (Κρυπτογράφηση passwords)

#### **UI/UX**
- **Material Design 3**
- Custom Fonts: Jura, IstokWeb, Inter

#### **Λειτουργίες**
- **Image Picker:** 1.0.7 (Φωτογραφίες προφίλ & chat)
- **Shared Preferences:** 2.1.1 (Τοπική αποθήκευση)
- **Intl:** 0.20.2 (Μορφοποίηση ημερομηνίας/ώρας)

#### **Navigation**
- **Go Router:** 14.2.7 (Routing & Deep Linking)

### 🔗 Σύνδεσμοι

- **📦 APK Download:** [Σύνδεσμος APK](#) *(συμπληρώστε)*
- **💻 Code Repository:** https://github.com/panayotis3/Fitlinkr.git
- **📄 Documentation:** Αυτό το README.md

### ⚙️ Build Configuration

```yaml
# pubspec.yaml
name: fitlinkr
version: 0.1.0
environment:
  sdk: ^3.10.3
```

```kotlin
// android/app/build.gradle.kts
android {
    compileSdk = 35
    minSdk = 21
    targetSdk = 35
}
```

---

## γ. Σύγκριση με Πρωτότυπο

### 🎨 Υλοποιημένα Χαρακτηριστικά από το Prototype (Phase 2)

Η τελική εφαρμογή **ακολουθεί πιστά** το αρχικό prototype με τις εξής βελτιώσεις:

#### ✅ **Πλήρως Υλοποιημένα**

1. **Σύστημα Εγγραφής/Σύνδεσης:**
   - Email/Password authentication
   - Password hashing με BCrypt
   - Validation πεδίων
   - Forgot Password functionality

2. **4 Διαφορετικά Modes:**
   - Friend, Learner, Professional, Swole-Mate
   - Μοναδικά χρώματα & εικονίδια ανά mode
   - Ανεξάρτητα swipe stacks για κάθε mode

3. **Swipe System:**
   - Like/Dislike με animation
   - Match detection σε πραγματικό χρόνο
   - Αυτόματη δημιουργία chat μετά από match

4. **Chat Functionality:**
   - 1-on-1 messaging
   - Group chats
   - Αποστολή εικόνων
   - Message status (sent/seen)
   - Timestamped messages

5. **Profile Management:**
   - Avatar upload
   - Επεξεργασία στοιχείων
   - Professional verification
   - Account settings

#### 🆕 **Επιπλέον Χαρακτηριστικά (πέραν του Prototype)**

- **Enhanced Security:**
  - Password confirmation dialog για critical actions
  - Secure account deletion
  
- **Improved UX:**
  - Custom splash screen
  - Adaptive icons
  - Error handling με user-friendly messages
  
- **Data Persistence:**
  - Πλήρης αποθήκευση όλων των δεδομένων στο Hive
  - Διατήρηση chat history
  - Profile picture storage στο file system

#### ⚠️ **Διαφορές από το Prototype**


## 🎯 Χαρακτηριστικά Εφαρμογής

### ✨ Core Features

1. **Multi-Mode Dating System**
   - 4 διαφορετικοί σκοποί χρήσης
   - Ανεξάρτητα swipe stacks
   - Mode-specific theming

2. **Swipe Matching**
   - Tinder-like interface
   - Real-time match detection
   - Αμοιβαίο like system

3. **Real-Time Chat**
   - 1-on-1 conversations
   - Group messaging
   - Image sharing
   - Message status tracking

4. **Profile Customization**
   - Profile Picture
   - Editable information
   - Professional verification badge

5. **Security & Privacy**
   - Bcrypt password hashing
   - Secure account deletion
   - Data persistence με Hive

### 📊 Δομή Δεδομένων

#### **User Model (Tester)**
```dart
{
  name: String,
  email: String (unique),
  passwordHash: String (bcrypt),
  country: String,
  interests: String,
  age: int (18-120),
  level: String (Beginner/Intermediate/Expert),
  gender: String (Male/Female/Other),
  profilePicture: String? (file path),
  likedBy: Map<String, List<String>> (mode -> emails),
  isProfessionalVerified: bool
}
```

#### **Chat Messages**
```dart
{
  senderEmail: String,
  message: String,
  timestamp: DateTime,
  status: String (sent/seen),
  imagePath: String? (optional)
}
```

#### **Group Chat**
```dart
{
  id: String,
  name: String,
  members: List<String> (emails),
  admin: String (email)
}
```

---

## 🔒 Επαλήθευση Λειτουργικότητας

### ✅ Διασφάλιση Λειτουργικότητας έως 7 Φεβρουαρίου 2025

Η εφαρμογή FitLinkr **λειτουργεί πλήρως αυτόνομα** χωρίς εξάρτηση από εξωτερικές υπηρεσίες:

#### **1. Τοπική Βάση Δεδομένων (Hive)**
- **Δεν απαιτείται internet connection**
- Όλα τα δεδομένα αποθηκεύονται στη συσκευή
- Δεν υπάρχουν εξωτερικοί servers που μπορεί να πέσουν
- Άμεση προσβασιμότητα 24/7

#### **2. Data Persistence - Αποδείξεις Λειτουργικότητας**

**Α. Δεδομένα που Αποθηκεύονται:**
- 👤 Προφίλ χρηστών (6 προδημιουργημένοι + νέες εγγραφές)
- 📸 Φωτογραφίες προφίλ (τοπικά αρχεία)
- ❤️ Likes & Matches (ανά mode)
- 💬 Chat history (μηνύματα + εικόνες)
- 👥 Group chats (μέλη + admin)
- ⚙️ Settings (preferences)

**Β. Τροποποίηση Δεδομένων Μεταξύ Layouts:**

| Ενέργεια | Layout A | Layout B | Αποτέλεσμα |
|----------|----------|----------|------------|
| Edit Name | Edit Profile | Swipe Screen | Το όνομα ενημερώνεται παντού |
| Upload Avatar | Edit Profile | Chat List | Το avatar εμφανίζεται στα chats |
| Send Message | Chat Page | Chat List | Τελευταίο μήνυμα + unread count |
| Like User | Swipe Screen | Chat List | Match → εμφανίζεται στη λίστα |
| Change Password | Settings | Login | Νέος κωδικός απαιτείται για login |
| Verify Professional | Verification Page | Edit Profile | Badge εμφανίζεται στο προφίλ |

**Γ. Δοκιμαστικό Σενάριο (Proof of Persistence):**

1. **Login** με `popi@example.com`
2. **Edit Profile** → Αλλάξτε το όνομα σε "Popi Updated"
3. **Upload** μια φωτογραφία προφίλ
4. **Start Swiping** → Κάντε like στον "Nikos"
5. **Check Chat List** → Το match με Nikos εμφανίζεται
6. **Send Message** → "Hello Nikos!"
7. **Logout** και κάντε **Login ξανά**
8. ✅ **Όλα τα δεδομένα παραμένουν:** όνομα, φωτογραφία, matches, μηνύματα

#### **3. Όχι "Απλή Εναλλαγή Οθονών"**

Η εφαρμογή **αποδεδειγμένα** δεν είναι static:

- **Dynamic User List:** Νέες εγγραφές εμφανίζονται αμέσως στο swipe
- **Real-Time Matching:** Αμοιβαία likes → αυτόματη δημιουργία chat
- **Live Chat Updates:** Μηνύματα αποθηκεύονται με timestamp
- **Profile Changes Propagate:** Τροποποιήσεις φαίνονται σε όλα τα screens
- **Group Chat Sync:** Μέλη βλέπουν τα ίδια μηνύματα
- **Verification Status:** Το badge ενημερώνεται μετά την επαλήθευση

---

## 🛠️ Development Info

### Δομή Project

```
lib/
├── main.dart              # Entry point & Hive initialization
├── app.dart               # MaterialApp configuration
├── models/
│   └── tester.dart        # User model + HiveAdapter
└── UI/
    ├── login.dart         # Login screen
    ├── register.dart      # Registration screen
    ├── forgot_password.dart
    ├── edit_profile.dart  # Profile management
    ├── swipe.dart         # Swipe matching
    ├── chat_list_page.dart
    ├── chat_page.dart     # 1-on-1 & group chats
    ├── verification_page.dart
    └── account_settings.dart
```

### Hive Boxes

| Box Name | Type | Περιγραφή |
|----------|------|-----------|
| `testers_v2` | `Box<Tester>` | User profiles |
| `chat_[mode]_[emails]` | `Box` | 1-on-1 chats |
| `chat_group_[id]` | `Box` | Group chats |
| `avatars` | `Box<String>` | Avatar paths |

### Build Commands

```bash
# Debug build
flutter run

# Release APK
flutter build apk --release

# Release Bundle (για Play Store)
flutter build appbundle --release

# Install on device
flutter install
```
---

## 📜 License & Credits

- **Developed by:** Καββαδά Ευδοκία(03122832), Κιωκάκη Καλλιόπη(03122629), Ματσούκας Παναγιώτης(03122206)  
- **University Project:** ΕΜΠ/ΗΜΜΥ
- **Date:** Ιανουάριος 2026
- **Framework:** Flutter 3.10.3
- **Database:** Hive (NoSQL)

---

## 🎓 Ακαδημαϊκές Πληροφορίες

Αυτή η εφαρμογή αναπτύχθηκε ως μέρος του μαθήματος **Αλληλεπίδραση Ανθρώπου Υπολογιστή** για το ακαδημαϊκό έτος 2024-2025.

**Φάση 3: Τελική Παράδοση**
- Λειτουργική εφαρμογή με data persistence
- Πλήρης τεκμηρίωση
- Προδημιουργημένοι χρήστες για testing
- Χωρίς εξαρτήσεις από εξωτερικές υπηρεσίες

---

**FitLinkr** - *Where fitness meets connection!* 💪❤️
