import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String id;
  final String name;
  final String age;
  final String number;

  AppUser({
    required this.id,
    required this.name,
    required this.age,
    required this.number,
  });

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    return AppUser(
      id: doc.id,
      name: doc.get("NAME") as String,
      age: doc.get("AGE") as String,
      number: doc.get("NUMBER") as String,
    );
  }
}
