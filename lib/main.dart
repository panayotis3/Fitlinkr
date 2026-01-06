import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:bcrypt/bcrypt.dart';

import 'models/tester.dart';
import 'app.dart'; // This links to your other file

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive and open the testers box (versioned)
  await Hive.initFlutter();
  Hive.registerAdapter(TesterAdapter());
  final box = await Hive.openBox<Tester>('testers_v2');

  // Seed hard-coded dummy testers if box is empty
  if (box.isEmpty) {
    final testers = [
      Tester(
        name: 'Nikos',
        email: 'nikos@example.com',
        passwordHash: BCrypt.hashpw('password123', BCrypt.gensalt()),
        country: 'Greece',
        interests: 'Gym',
        age: 29,
        level: 'Expert',
      ),
      Tester(
        name: 'Sara',
        email: 'sara@example.com',
        passwordHash: BCrypt.hashpw('saraPass!', BCrypt.gensalt()),
        country: 'Sweden',
        interests: 'Yoga',
        age: 25,
        level: 'Beginner',
      ),
      Tester(
        name: 'Amir',
        email: 'amir@example.com',
        passwordHash: BCrypt.hashpw('amir\$ecure', BCrypt.gensalt()),
        country: 'Lebanon',
        interests: 'Running',
        age: 31,
        level: 'Intermediate',
      ),
    ];
    for (final t in testers) {
      await box.add(t);
    }
  }

  runApp(const FitLinkrApp());
}