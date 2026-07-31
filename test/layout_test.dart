
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fitlinkr/UI/forgot_password.dart';
import 'package:fitlinkr/UI/login.dart';
import 'package:fitlinkr/UI/register.dart';
import 'package:fitlinkr/theme.dart';

/// Η μικρότερη οθόνη που θέλουμε να υποστηρίζουμε (iPhone SE 1ης γενιάς,
/// καθώς και πολλά φθηνά Android).
const Size kSmallPhone = Size(320, 568);

/// Τυπικό μέγεθος Android.
const Size kTypicalPhone = Size(360, 640);

/// Εμφανίζει τη [page] στο δοσμένο μέγεθος και μεγέθυνση κειμένου και
/// αποτυγχάνει αν η Flutter αναφέρει overflow.
///
/// Το overflow δεν είναι σιωπηλό στα tests: το RenderFlex πετάει σφάλμα, το
/// οποίο μαζεύουμε με το [WidgetTester.takeException].
Future<void> expectNoOverflow(
  WidgetTester tester,
  Widget page, {
  required Size surface,
  double textScale = 1.0,
}) async {
  tester.view.physicalSize = surface;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      // Ίδιο theme με την εφαρμογή, αλλιώς το test δεν δοκιμάζει το πραγματικό
      // styling (π.χ. το contentPadding των πεδίων).
      theme: buildFitlinkrTheme(),
      home: Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: page,
        ),
      ),
    ),
  );

  expect(tester.takeException(), isNull);
}

void main() {
  group('LoginPage', () {
    testWidgets('fits a 320pt screen', (tester) async {
      await expectNoOverflow(tester, const LoginPage(), surface: kSmallPhone);
    });

    testWidgets('fits a 320pt screen at 2x text', (tester) async {
      await expectNoOverflow(
        tester,
        const LoginPage(),
        surface: kSmallPhone,
        textScale: 2.0,
      );
    });
  });

  group('ForgotPasswordPage', () {
    testWidgets('fits a 320pt screen', (tester) async {
      await expectNoOverflow(
        tester,
        const ForgotPasswordPage(),
        surface: kSmallPhone,
      );
    });

    testWidgets('fits a 320pt screen at 2x text', (tester) async {
      await expectNoOverflow(
        tester,
        const ForgotPasswordPage(),
        surface: kSmallPhone,
        textScale: 2.0,
      );
    });
  });

  group('RegisterPage', () {
    testWidgets('fits a 320pt screen', (tester) async {
      await expectNoOverflow(
        tester,
        const RegisterPage(),
        surface: kSmallPhone,
      );
    });

    testWidgets('fits a typical 360pt screen', (tester) async {
      await expectNoOverflow(
        tester,
        const RegisterPage(),
        surface: kTypicalPhone,
      );
    });

    testWidgets('fits a typical screen at 1.5x text', (tester) async {
      await expectNoOverflow(
        tester,
        const RegisterPage(),
        surface: kTypicalPhone,
        textScale: 1.5,
      );
    });

    testWidgets('fits a typical screen at 2x text', (tester) async {
      await expectNoOverflow(
        tester,
        const RegisterPage(),
        surface: kTypicalPhone,
        textScale: 2.0,
      );
    });

    testWidgets('fits the smallest screen at 2x text', (tester) async {
      await expectNoOverflow(
        tester,
        const RegisterPage(),
        surface: kSmallPhone,
        textScale: 2.0,
      );
    });
  });

  group('page content respects narrow screens', () {
    // Τα πεδία ΔΕΝ πρέπει να έχουν σταθερό ύψος: αν το ύψος τους δεν αυξάνεται
    // μαζί με το μέγεθος γραμματοσειράς, το κείμενο κόβεται σιωπηλά (δεν
    // πετάει overflow, οπότε κανένα άλλο test δεν θα το πιάσει).
    testWidgets('register fields grow with text scale', (tester) async {
      Future<double> measure(double scale) async {
        tester.view.physicalSize = kTypicalPhone;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          MaterialApp(
            theme: buildFitlinkrTheme(),
            home: Builder(
              builder: (context) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(scale)),
                child: const RegisterPage(),
              ),
            ),
          ),
        );

        return tester.getSize(find.byType(TextField).first).height;
      }

      final normal = await measure(1.0);
      final scaled = await measure(2.0);

      expect(
        scaled,
        greaterThan(normal),
        reason: 'text fields must grow when the user enlarges system text; '
            'a fixed SizedBox(height:) would keep this constant and clip',
      );
    });
  });
}