// THIS PAGE HAS BEEN REDACTED - IS NOT USED

import 'package:flutter/material.dart';
import '../services/authentication.dart';
import 'dart:async';
import '../services/provider_widget.dart';
import '../models/User.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class View_Profile_Page extends StatefulWidget {

  View_Profile_Page({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _createViewProfilePageState();
}


class _createViewProfilePageState extends State<View_Profile_Page> {

  User user = User("");
  final dbRef = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Profile Creation'),
        ),
        body: _profileViewingPage(context)
    );
  }

  Widget _profileViewingPage(BuildContext context) {
    return new SingleChildScrollView(
      padding: EdgeInsets.all(15),
      child: new Column(
        children: <Widget>[
          FutureBuilder(
              future: _getProfileData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  //do nothing, just wait;
                }
                return new Column(
                    children: <Widget>[
                      Text(("Name: ${user.name}"), style: TextStyle(fontSize: 20), textAlign: TextAlign.start),
                      Text(("I am: ${user.ownGender}"), style: TextStyle(fontSize: 20), textAlign: TextAlign.start),
                      Text(("I am looking for: ${user.wantedGender}"), style: TextStyle(fontSize: 20), textAlign: TextAlign.start),
                    ],
                );
              }
          ),
        ],
      ),
    );
  }

  _getProfileData() async {
    final uid = await Provider
        .of(context)
        .auth
        .getCurrentUID();
    await Provider
        .of(context)
        .db
        .collection('users')
        .document(uid)
        .get().then((result) {
      user.name = result.data['name'];
      user.ownGender = result.data['ownGender'];
      user.wantedGender = result.data['wantedGender'];
    });
  }
}