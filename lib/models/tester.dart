import 'package:hive/hive.dart';



class Tester {
  final String name;
  final String email;
  final String passwordHash;
  final String country;
  final String interests;
  final int age;
  final String level;

  Tester({
    required this.name,
    required this.email,
    required this.passwordHash,
    required this.country,
    required this.interests,
    required this.age,
    required this.level,
  });

  @override
  String toString() {
    return 'Tester(name: $name, email: $email, country: $country, interests: $interests, age: $age, level: $level)';
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
    return Tester(name: name, email: email, passwordHash: passwordHash, country: country, interests: interests, age: age, level: level);
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
  }
}
