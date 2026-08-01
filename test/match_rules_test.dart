import 'package:flutter_test/flutter_test.dart';

import 'package:fitlinkr/models/tester.dart';
import 'package:fitlinkr/utils/match_rules.dart';
import 'package:fitlinkr/utils/validators.dart';

Tester user(
  String name, {
  Map<String, List<String>>? likedBy,
  String? profilePicture,
  bool verified = false,
}) {
  return Tester(
    name: name,
    email: '$name@example.com',
    passwordHash: 'hash',
    country: 'Greece',
    interests: 'Gym',
    age: 25,
    level: 'Expert',
    gender: 'Other',
    profilePicture: profilePicture,
    likedBy: likedBy,
    isProfessionalVerified: verified,
  );
}

void main() {
  group('counterpartMode', () {
    test('Learner and Professional are each other\'s counterpart', () {
      expect(counterpartMode('Learner'), 'Professional');
      expect(counterpartMode('Professional'), 'Learner');
    });

    test('Friend and Swole-mate are their own counterpart', () {
      expect(counterpartMode('Friend'), 'Friend');
      expect(counterpartMode('Swole-mate'), 'Swole-mate');
    });

    test('is case-insensitive on input', () {
      expect(counterpartMode('learner'), 'Professional');
      expect(counterpartMode('PROFESSIONAL'), 'Learner');
    });
  });

  group('isMutualMatch', () {
    test('true when each has liked the other in the paired modes', () {
      // Bob liked me while browsing as a Professional...
      final me = user('alice', likedBy: {
        'Professional': ['bob@example.com'],
      });
      // ...and I liked Bob while browsing as a Learner.
      final bob = user('bob', likedBy: {
        'Learner': ['alice@example.com'],
      });

      expect(isMutualMatch(me: me, other: bob, mode: 'Learner'), isTrue);
    });

    test('false when only one side has liked', () {
      final me = user('alice', likedBy: {
        'Professional': ['bob@example.com'],
      });
      final bob = user('bob');

      expect(isMutualMatch(me: me, other: bob, mode: 'Learner'), isFalse);
    });

    test('false when the likes are in unrelated modes', () {
      final me = user('alice', likedBy: {
        'Friend': ['bob@example.com'],
      });
      final bob = user('bob', likedBy: {
        'Friend': ['alice@example.com'],
      });

      // Matched as Friends, so not a match in Learner mode.
      expect(isMutualMatch(me: me, other: bob, mode: 'Learner'), isFalse);
      expect(isMutualMatch(me: me, other: bob, mode: 'Friend'), isTrue);
    });

    test('compares emails case-insensitively', () {
      // Likes are stored lowercased; profiles keep registration casing.
      final me = Tester(
        name: 'Alice',
        email: 'Alice@Example.com',
        passwordHash: 'h',
        country: 'Greece',
        interests: 'Gym',
        age: 25,
        level: 'Expert',
        gender: 'Other',
        likedBy: {
          'Friend': ['bob@example.com'],
        },
      );
      final bob = Tester(
        name: 'Bob',
        email: 'BOB@example.com',
        passwordHash: 'h',
        country: 'Greece',
        interests: 'Gym',
        age: 25,
        level: 'Expert',
        gender: 'Other',
        likedBy: {
          'Friend': ['alice@example.com'],
        },
      );

      expect(isMutualMatch(me: me, other: bob, mode: 'Friend'), isTrue);
    });
  });

  group('chat thread ids', () {
    test('both participants of a cross-mode pair get the same id', () {
      final fromLearner = directChatThreadId(
        myEmail: 'alice@example.com',
        otherEmail: 'bob@example.com',
        mode: 'Learner',
      );
      final fromProfessional = directChatThreadId(
        myEmail: 'bob@example.com',
        otherEmail: 'alice@example.com',
        mode: 'Professional',
      );

      expect(fromLearner, fromProfessional);
    });

    test('id does not depend on argument order or casing', () {
      final a = directChatThreadId(
        myEmail: 'Alice@Example.com',
        otherEmail: 'bob@example.com',
        mode: 'Friend',
      );
      final b = directChatThreadId(
        myEmail: 'bob@EXAMPLE.com',
        otherEmail: 'alice@example.com',
        mode: 'Friend',
      );

      expect(a, b);
    });

    test('different modes give different threads', () {
      final friend = directChatThreadId(
        myEmail: 'alice@example.com',
        otherEmail: 'bob@example.com',
        mode: 'Friend',
      );
      final swole = directChatThreadId(
        myEmail: 'alice@example.com',
        otherEmail: 'bob@example.com',
        mode: 'Swole-mate',
      );

      expect(friend, isNot(swole));
    });

    test('group ids are stable', () {
      expect(groupChatThreadId('123'), groupChatThreadId('123'));
      expect(groupChatThreadId('123'), isNot(groupChatThreadId('456')));
    });
  });

  group('validateAge', () {
    test('accepts an adult age', () {
      expect(validateAge('18'), isNull);
      expect(validateAge('45'), isNull);
      expect(validateAge(' 30 '), isNull);
    });

    test('rejects under 18 - the gate must hold on the edit form too', () {
      expect(validateAge('17'), isNotNull);
      expect(validateAge('5'), isNotNull);
      expect(validateAge('-3'), isNotNull);
    });

    test('rejects implausible and non-numeric values', () {
      expect(validateAge('500'), isNotNull);
      expect(validateAge('abc'), isNotNull);
      expect(validateAge(''), isNotNull);
      expect(validateAge(null), isNotNull);
    });
  });

  group('Tester.copyWith', () {
    test('carries over every field that is not named', () {
      final original = user(
        'alice',
        verified: true,
        profilePicture: '/tmp/a.png',
        likedBy: {
          'Friend': ['bob@example.com'],
        },
      );

      final renamed = original.copyWith(name: 'Alicia');

      expect(renamed.name, 'Alicia');
      // These are the fields that used to get silently reset when callers
      // rebuilt Tester by hand.
      expect(renamed.isProfessionalVerified, isTrue);
      expect(renamed.likedBy, original.likedBy);
      expect(renamed.passwordHash, original.passwordHash);
      expect(renamed.profilePicture, '/tmp/a.png');
    });

    test('can clear the profile picture explicitly', () {
      final withPhoto = user('alice', profilePicture: '/tmp/a.png');

      expect(withPhoto.copyWith(profilePicture: null).profilePicture, isNull);
    });

    test('omitting profilePicture keeps the existing one', () {
      final withPhoto = user('alice', profilePicture: '/tmp/a.png');

      expect(withPhoto.copyWith(name: 'x').profilePicture, '/tmp/a.png');
    });
  });
}