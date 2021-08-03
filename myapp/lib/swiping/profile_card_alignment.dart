import 'dart:math';
import 'package:myapp/services/provider_widget.dart';

import '../models/User.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProfileCardAlignment extends StatelessWidget {
  final int cardNum;
  ProfileCardAlignment(this.cardNum);
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  User user = User("");

  @override
  Widget build(BuildContext context) {
    _getProfileData(context);
    return Card(
      child: Stack(
        children: <Widget>[
          SizedBox.expand(
            child: Material(
              borderRadius: BorderRadius.circular(12.0),
              child: (user.picURL != null) ? Image.network(user.picURL, fit: BoxFit.cover): Image.asset('res/noPic.png', fit: BoxFit.cover),
            ),
          ),
          SizedBox.expand(
            child: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Colors.transparent, Colors.black54],
                      begin: Alignment.center,
                      end: Alignment.bottomCenter)),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
                padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Card number $cardNum',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                            fontWeight: FontWeight.w700)),
                    Padding(padding: EdgeInsets.only(bottom: 8.0)),
                    Text('Hi, my name is ${user.name}.  I am a ${user.ownGender}, '
                        'and I am looking for ${user.wantedGender}.  My favorite food is ${user.favoriteFood}',
                        textAlign: TextAlign.start,
                        style: TextStyle(color: Colors.white)),
                  ],
                )),
          )
        ],
      ),
    );
  }

  _getProfileData(BuildContext context) async {
    final uid = await getRandomData();
    DocumentSnapshot results = await users.doc(uid.id).get();
    user.favoriteFood = results.data()['favoriteFood'];
    user.name = results.data()['name'];
    user.ownGender = results.data()['ownGender'];
    user.wantedGender = results.data()['wantedGender'];
    user.uid = results.data()['uid'];
    user.picURL = results.data()['picURL'];
    user.matches = results.data()['matches'];
  }

  Future<DocumentReference> getRandomData() async {
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    final autoId = _getAutoId();

    final query = users
        .where("uid", isGreaterThanOrEqualTo: autoId)
        .orderBy("uid")
        .limit(1);
    QuerySnapshot response = await query.get();
    if (response.docs == null || response.docs.length == 0) {
      final anotherQuery = users
          .where('uid', isLessThan: autoId)
          .orderBy('uid')
          .limit(1);
      response = await anotherQuery.get();
    }
    var answer = response.docs[0].reference;
    return answer;
  }

  _getAutoId() {
    const AUTO_ID_ALPHABET = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    const AUTO_ID_LENGTH = 28;
    final buffer = StringBuffer();
    final random = Random.secure();

    final maxRandom = AUTO_ID_ALPHABET.length;

    for (int i = 0; i < AUTO_ID_LENGTH; i++) {
      buffer.write(AUTO_ID_ALPHABET[random.nextInt(maxRandom)]);
    }
    print(buffer.toString());
    return buffer.toString();
  }

}