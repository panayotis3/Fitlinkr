import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:bcrypt/bcrypt.dart';

import 'models/tester.dart';
import 'ui/login_page.dart'; 
import 'app.dart'; 

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // dinoume access sthn Hive kai arxikopoioume to box
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
        gender: 'Male'
      ),
      Tester(
        name: 'Sara',
        email: 'sara@example.com',
        passwordHash: BCrypt.hashpw('saraPass!', BCrypt.gensalt()),
        country: 'Sweden',
        interests: 'Yoga',
        age: 25,
        level: 'Beginner',
        gender: 'Female'
      ),
      Tester(
        name: 'Amir',
        email: 'amir@example.com',
        passwordHash: BCrypt.hashpw('amir\$ecure', BCrypt.gensalt()),
        country: 'Lebanon',
        interests: 'Running',
        age: 31,
        level: 'Intermediate',
        gender: 'Other'
      ),
    ];
    for (final t in testers) {
      await box.add(t);
    }
  }

  runApp(const FitLinkrApp());
}
class FitLinkrApp extends StatelessWidget {
  const FitLinkrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FitLinkr',
      theme: ThemeData(
        fontFamily: 'IstokWeb', 
        scaffoldBackgroundColor: const Color(0xFF1A0505), 
      ),
      home: const LoginPage(),
    );
  }
}
