import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myapp/services/provider_widget.dart';
import '../models/User.dart';

class ViewMatchesPage extends StatefulWidget {
  @override
  _ViewMatchesPageState createState() => _ViewMatchesPageState();
}

class _ViewMatchesPageState extends State<ViewMatchesPage> {
  User user = User("");
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  List<User> matches = List();
  List<User> rights = List();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: new Text('These are your matches!'),
        ),
      body: _showProfileList(),
    );
  }

  _showProfileList() {

    return new FutureBuilder(
      future: _getMatchData(),
       builder: (context, snapshot) {
         if (snapshot.connectionState == ConnectionState.done) {
           print("loading");
         }
         _createChildren();
         return Container();
       }
    );

    return new Container(
      padding: EdgeInsets.all(15),
      child: new ListView(
        children: _createChildren(),
      ),
    );
  }

  _getMatchData() async {
    await _getProfileData();
    List<User> profilesToCheck = List();
    for (String uid in user.matches) {
      print(uid);
      profilesToCheck.add(await _getOthersData(uid));
    }
    rights = profilesToCheck;
    List<User> profilesToView = List();
    for (User otherUser in profilesToCheck) {
      if (otherUser.matches.contains(user.uid)) {
        profilesToView.add(otherUser);
      }
    }
    matches = profilesToView;
  }

  List<Widget> _createChildren() {
    print(matches);
    print("");
    print(rights);
    return new List<Widget>.generate(matches.length, (int index) {
      return Text(matches[index].toString());
    });
  }

  _getProfileData() async {
    final uid = await Provider.of(context).auth.getCurrentUID();
    DocumentSnapshot results = await users.doc(uid).get();
    user.favoriteFood = results.data()['favoriteFood'];
    user.name = results.data()['name'];
    user.ownGender = results.data()['ownGender'];
    user.wantedGender = results.data()['wantedGender'];
    user.uid = results.data()['uid'];
    user.picURL = results.data()['picURL'];
    user.matches = List.castFrom<dynamic, String>(results.data()['matches']);
  }

  _getOthersData(String uid) async {
    User user1;
    DocumentSnapshot results = await users.doc(uid).get();
    user1.favoriteFood = results.data()['favoriteFood'];
    user1.name = results.data()['name'];
    user1.ownGender = results.data()['ownGender'];
    user1.wantedGender = results.data()['wantedGender'];
    user1.uid = results.data()['uid'];
    user1.picURL = results.data()['picURL'];
    user1.matches = results.data()['matches'];
    return user1;
  }
}