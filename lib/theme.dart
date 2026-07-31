import 'package:flutter/material.dart';

/// Το ενιαίο theme της εφαρμογής.
///
/// Ζει σε ξεχωριστό αρχείο ώστε να το χρησιμοποιούν και το `main.dart` και τα
/// widget tests - αλλιώς τα tests θα έτρεχαν με άλλο styling από την
/// πραγματική εφαρμογή και δεν θα απέδειχναν τίποτα.
///
/// ΣΗΜΑΝΤΙΚΟ: το [InputDecorationTheme] ΔΕΝ ορίζει σταθερό ύψος. Τα πεδία
/// παίρνουν ύψος από το περιεχόμενό τους, ώστε να μεγαλώνουν όταν ο χρήστης
/// έχει αυξημένο μέγεθος γραμματοσειράς. Μην τυλίγετε TextField σε
/// `SizedBox(height: ...)`.
ThemeData buildFitlinkrTheme() {
  return ThemeData(
    fontFamily: 'IstokWeb',
    scaffoldBackgroundColor: const Color(0xFF1A0505),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFD9D9D9),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
    ),
  );
}