import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../pages/main_page.dart';

class User {
  String favoriteFood;
  String name;
  String ownGender;
  String wantedGender;
  String picURL;
  String uid;
  List<dynamic> matches = List();

  String documentId;

  User(this.name);

  String toString() {
    return 'Hi, my name is ${name}.  I am a ${ownGender}, '
        'and I am looking for ${wantedGender}.  My favorite food is ${favoriteFood}';
  }

  Map<String, dynamic> toJson() => {
    "favoriteFood": favoriteFood,
    "name": name,
    "ownGender": ownGender,
    "wantedGender": wantedGender,
    "picURL": picURL,
    "uid": uid,
    "matches": matches,
  };

  User.fromSnapshot(DocumentSnapshot snapshot) :
        favoriteFood = snapshot.data()['favoriteFood'],
        documentId = snapshot.id;
}