import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:fitlinkr/data/user_repository.dart';
import 'package:fitlinkr/models/tester.dart';

/// Τα ζεύγη mode που πρέπει να ταιριάζουν μεταξύ τους.
///
/// Ο Learner ταιριάζει με Professional και αντίστροφα. Τα Friend και
/// Swole-mate ταιριάζουν με τον εαυτό τους. Αυτός ο πίνακας είναι το σημείο
/// που έσπασε επανειλημμένα, γι' αυτό δοκιμάζεται εξαντλητικά.
const modePairs = <(String, String)>[
  ('Friend', 'Friend'),
  ('Swole-mate', 'Swole-mate'),
  ('Learner', 'Professional'),
  ('Professional', 'Learner'),
];

const alice = 'alice@example.com';
const bob = 'bob@example.com';

Tester makeUser(String name, {bool verified = false}) => Tester(
      name: name,
      email: '${name.toLowerCase()}@example.com',
      passwordHash: 'hash',
      country: 'Greece',
      interests: 'Gym',
      age: 25,
      level: 'Expert',
      gender: 'Other',
      isProfessionalVerified: verified,
    );

void main() {
  late Directory tempDir;
  late UserRepository users;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('fitlinkr_test_');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(TesterAdapter());
    }
    users = UserRepository();
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    await Hive.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('accounts', () {
    test('findByEmail is case-insensitive and returns null when absent',
        () async {
      await users.create(makeUser('Alice'));

      expect((await users.findByEmail('ALICE@example.com'))?.name, 'Alice');
      expect(await users.findByEmail('nobody@example.com'), isNull);
    });

    test('emailExists ignores casing', () async {
      await users.create(makeUser('Alice'));

      expect(await users.emailExists('Alice@Example.com'), isTrue);
      expect(await users.emailExists('bob@example.com'), isFalse);
    });

    test('updateProfile keeps likes received since the object was read',
        () async {
      await users.create(makeUser('Alice'));
      await users.create(makeUser('Bob'));

      // Bob likes Alice, then Alice edits her profile.
      await users.like(fromEmail: bob, toEmail: alice, mode: 'Friend');

      await users.updateProfile(
        email: alice,
        name: 'Alicia',
        country: 'Greece',
        interests: 'Yoga',
        age: 26,
        level: 'Expert',
        gender: 'Other',
        profilePicture: null,
        isProfessionalVerified: false,
      );

      final updated = await users.findByEmail(alice);
      expect(updated?.name, 'Alicia');
      // This is the data-loss bug: the like must survive the edit.
      expect(updated?.likedBy?['Friend'], contains(bob));
    });

    test('setProfessionalVerified only flips the flag', () async {
      await users.create(makeUser('Alice'));
      await users.like(fromEmail: alice, toEmail: alice, mode: 'Friend');

      await users.setProfessionalVerified(alice);

      final updated = await users.findByEmail(alice);
      expect(updated?.isProfessionalVerified, isTrue);
      expect(updated?.name, 'Alice');
    });
  });

  group('mutual matching across every mode pair', () {
    for (final (myMode, theirMode) in modePairs) {
      test('$myMode + $theirMode match and both see each other', () async {
        await users.create(makeUser('Alice', verified: true));
        await users.create(makeUser('Bob', verified: true));

        final firstLike =
            await users.like(fromEmail: alice, toEmail: bob, mode: myMode);
        expect(firstLike, isFalse, reason: 'one-sided like is not a match');

        final secondLike =
            await users.like(fromEmail: bob, toEmail: alice, mode: theirMode);
        expect(secondLike, isTrue, reason: 'second like completes the match');

        final aliceMatches =
            await users.fetchMatches(email: alice, mode: myMode);
        expect(
          aliceMatches.map((t) => t.email),
          contains(bob),
          reason: 'Alice must see Bob in her $myMode matches',
        );

        final bobMatches =
            await users.fetchMatches(email: bob, mode: theirMode);
        expect(
          bobMatches.map((t) => t.email),
          contains(alice),
          reason: 'Bob must see Alice in his $theirMode matches',
        );
      });

      test('$myMode + $theirMode unmatch clears it for both', () async {
        await users.create(makeUser('Alice', verified: true));
        await users.create(makeUser('Bob', verified: true));

        await users.like(fromEmail: alice, toEmail: bob, mode: myMode);
        await users.like(fromEmail: bob, toEmail: alice, mode: theirMode);

        await users.unmatch(email: alice, otherEmail: bob, mode: myMode);

        expect(await users.fetchMatches(email: alice, mode: myMode), isEmpty);
        expect(await users.fetchMatches(email: bob, mode: theirMode), isEmpty);
      });
    }

    test('a one-sided like produces no match for either side', () async {
      await users.create(makeUser('Alice'));
      await users.create(makeUser('Bob'));

      await users.like(fromEmail: alice, toEmail: bob, mode: 'Friend');

      expect(await users.fetchMatches(email: alice, mode: 'Friend'), isEmpty);
      expect(await users.fetchMatches(email: bob, mode: 'Friend'), isEmpty);
    });

    test('liking in one mode does not create a match in another', () async {
      await users.create(makeUser('Alice'));
      await users.create(makeUser('Bob'));

      await users.like(fromEmail: alice, toEmail: bob, mode: 'Friend');
      await users.like(fromEmail: bob, toEmail: alice, mode: 'Friend');

      expect(
        await users.fetchMatches(email: alice, mode: 'Swole-mate'),
        isEmpty,
      );
    });
  });

  group('swipe candidates', () {
    test('never includes yourself', () async {
      await users.create(makeUser('Alice'));
      await users.create(makeUser('Bob'));

      final candidates = await users.fetchSwipeCandidates(
        viewerEmail: alice,
        mode: 'Friend',
      );

      expect(candidates.map((t) => t.email), isNot(contains(alice)));
      expect(candidates.map((t) => t.email), contains(bob));
    });

    test('excludes people already judged in that mode', () async {
      await users.create(makeUser('Alice'));
      await users.create(makeUser('Bob'));

      await users.recordInteraction(
        viewerEmail: alice,
        mode: 'Friend',
        targetEmail: bob,
      );

      final friends = await users.fetchSwipeCandidates(
        viewerEmail: alice,
        mode: 'Friend',
      );
      expect(friends, isEmpty);

      // ...but a different mode is a fresh deck.
      final swole = await users.fetchSwipeCandidates(
        viewerEmail: alice,
        mode: 'Swole-mate',
      );
      expect(swole.map((t) => t.email), contains(bob));
    });

    test('Learner mode only shows verified professionals', () async {
      await users.create(makeUser('Alice'));
      await users.create(makeUser('Bob', verified: true));
      await users.create(makeUser('Carol'));

      final candidates = await users.fetchSwipeCandidates(
        viewerEmail: alice,
        mode: 'Learner',
      );

      expect(candidates.map((t) => t.email), contains(bob));
      expect(
        candidates.map((t) => t.email),
        isNot(contains('carol@example.com')),
      );
    });

    test('people who already liked you come first', () async {
      await users.create(makeUser('Alice'));
      await users.create(makeUser('Bob'));
      await users.create(makeUser('Carol'));

      // Carol liked Alice; Bob did not.
      await users.like(
        fromEmail: 'carol@example.com',
        toEmail: alice,
        mode: 'Friend',
      );

      final candidates = await users.fetchSwipeCandidates(
        viewerEmail: alice,
        mode: 'Friend',
      );

      expect(candidates.first.email, 'carol@example.com');
    });

    test('respects the limit', () async {
      for (final name in ['Bob', 'Carol', 'Dave']) {
        await users.create(makeUser(name));
      }
      await users.create(makeUser('Alice'));

      final candidates = await users.fetchSwipeCandidates(
        viewerEmail: alice,
        mode: 'Friend',
        limit: 2,
      );

      expect(candidates, hasLength(2));
    });
  });

  group('account deletion', () {
    test('removes the account and its likes on other people', () async {
      await users.create(makeUser('Alice'));
      await users.create(makeUser('Bob'));

      await users.like(fromEmail: alice, toEmail: bob, mode: 'Friend');
      await users.like(fromEmail: bob, toEmail: alice, mode: 'Friend');

      expect(await users.deleteAccount(alice), isTrue);

      expect(await users.findByEmail(alice), isNull);

      final remainingBob = await users.findByEmail(bob);
      expect(remainingBob?.likedBy?['Friend'] ?? [], isNot(contains(alice)));
      expect(await users.fetchMatches(email: bob, mode: 'Friend'), isEmpty);
    });

    test('returns false for an account that does not exist', () async {
      expect(await users.deleteAccount('ghost@example.com'), isFalse);
    });
  });
}