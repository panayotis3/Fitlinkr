import 'package:hive/hive.dart';



class Tester {
  final String name;
  final String email;
  final String passwordHash;
  final String country;
  final String interests;
  final int age;
  final String level;
  final String gender;
  final String? profilePicture;
  final Map<String, List<String>>? likedBy; // mode -> list of emails who liked in that mode

  Tester({
    required this.name,
    required this.email,
    required this.passwordHash,
    required this.country,
    required this.interests,
    required this.age,
    required this.level,
    required this.gender,
    this.profilePicture,
    this.likedBy,
  });

  @override
  String toString() {
    return 'Tester(name: $name, email: $email, country: $country, interests: $interests, age: $age, level: $level, gender: $gender)';
  }
}


class TesterAdapter extends TypeAdapter<Tester> {
  @override
  final int typeId = 2;

  @override
  Tester read(BinaryReader reader) {
    final name = reader.readString();
    final email = reader.readString();
    final passwordHash = reader.readString();
    final country = reader.readString();
    final interests = reader.readString();
    final age = reader.readInt();
    final level = reader.readString();
    final gender = reader.readString();
    
    // Read profilePicture if available
    String? profilePicture;
    try {
      if (reader.availableBytes > 0) {
        final hasPicture = reader.readBool();
        if (hasPicture) {
          profilePicture = reader.readString();
        }
      }
    } catch (e) {
      profilePicture = null;
    }
    
    // Try to read likedBy - new format is Map<String, List<String>>
    Map<String, List<String>>? likedBy;
    try {
      if (reader.availableBytes >= 4) {
        final mapLength = reader.readInt();
        if (mapLength > 0 && reader.availableBytes > 0) {
          likedBy = {};
          for (int i = 0; i < mapLength; i++) {
            final mode = reader.readString();
            final emailsLength = reader.readInt();
            final emails = List<String>.generate(emailsLength, (_) => reader.readString());
            likedBy[mode] = emails;
          }
        }
      }
    } catch (e) {
      // Old format or corrupt data - just use null
      print('Could not read likedBy (old format or corrupt): $e');
      likedBy = null;
    }
    
    return Tester(name: name, email: email, passwordHash: passwordHash, country: country, interests: interests, age: age, level: level, gender: gender, profilePicture: profilePicture, likedBy: likedBy,);
  }

  @override
  void write(BinaryWriter writer, Tester obj) {
    writer.writeString(obj.name);
    writer.writeString(obj.email);
    writer.writeString(obj.passwordHash);
    writer.writeString(obj.country);
    writer.writeString(obj.interests);
    writer.writeInt(obj.age);
    writer.writeString(obj.level);
    writer.writeString(obj.gender);
    
    // Write profilePicture
    final hasPicture = obj.profilePicture != null;
    writer.writeBool(hasPicture);
    if (hasPicture) {
      writer.writeString(obj.profilePicture!);
    }
    
    final likedByMap = obj.likedBy ?? {};
    writer.writeInt(likedByMap.length);
    likedByMap.forEach((mode, emails) {
      writer.writeString(mode);
      writer.writeInt(emails.length);
      for (final email in emails) {
        writer.writeString(email);
      }
    });
  }
}