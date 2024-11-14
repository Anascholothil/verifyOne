import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  String id;
  String name;
  String age;
  String number;

  AppUser({
    required this.id,
    required this.name,
    required this.age,
    required this.number,
  });

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    return AppUser(
      id: doc.id,
      name: doc.get("NAME").toString(),
      age: doc.get("AGE").toString(),
      number: doc.get("NUMBER").toString(),
    );
  }
}
