import '../models/tester.dart';

/// Swipe modes come in pairs. Someone browsing in Learner mode is shown (and
/// liked by) people browsing in Professional mode, and vice versa. Friend and
/// Swole-mate are matched against themselves.
///
/// Likes are stored on the *liked* user as `likedBy[mode]`, where `mode` is the
/// mode the *liker* was browsing in. So while I browse in [mode]:
///   - who liked me  -> my `likedBy[counterpartMode(mode)]`
///   - did I like them -> their `likedBy[mode]`
String counterpartMode(String mode) {
  switch (mode.toLowerCase()) {
    case 'learner':
      return 'Professional';
    case 'professional':
      return 'Learner';
    default:
      return mode;
  }
}

/// Whether [me] and [other] have liked each other in [mode].
///
/// Emails are lowercased when a like is stored, but profiles keep whatever
/// casing the user registered with, so every comparison here is
/// case-insensitive.
bool isMutualMatch({
  required Tester me,
  required Tester other,
  required String mode,
}) {
  bool contains(List<String>? emails, String email) =>
      emails != null &&
      emails.any((e) => e.toLowerCase() == email.toLowerCase());

  final theyLikedMe = contains(me.likedBy?[counterpartMode(mode)], other.email);
  final iLikedThem = contains(other.likedBy?[mode], me.email);

  return theyLikedMe && iLikedThem;
}

/// The mode key both sides of a conversation agree on.
///
/// A Professional and a Learner are two ends of one pairing, so they must
/// resolve to the same key — otherwise each writes into a thread the other
/// never reads. Taking the alphabetically first of the pair is arbitrary but
/// stable from either side.
String _canonicalMode(String mode) {
  final pair = [mode, counterpartMode(mode)]..sort();
  return pair.first;
}

/// Storage key for a one-to-one conversation.
///
/// Must produce the same value no matter which participant is asking, so both
/// the emails and the mode are canonicalised before joining.
String directChatThreadId({
  required String myEmail,
  required String otherEmail,
  required String mode,
}) {
  final emails = [myEmail.toLowerCase(), otherEmail.toLowerCase()]..sort();
  final emailsPart = emails.join('_').replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
  final modePart = _canonicalMode(mode).toLowerCase().replaceAll('-', '');
  return 'chat_${modePart}_$emailsPart';
}

/// Storage key for a group conversation.
String groupChatThreadId(String groupId) => 'chat_group_$groupId';