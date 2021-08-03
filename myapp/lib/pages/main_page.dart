import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myapp/pages/view_matches_page.dart';
import '../services/authentication.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';
import './home_page.dart';
import 'package:myapp/models/User.dart';
import '../services/provider_widget.dart';
import './View_Profile_Page.dart';
import '../services/Pic_Upload.dart';
import './swipe_feed_page.dart';

class MainPage extends StatefulWidget {
  MainPage({Key key, this.auth, this.userId, this.onSignedOut})
      : super(key: key);

  // added these to be able to pass to the account settings page if needed
  final BaseAuth auth;
  final VoidCallback onSignedOut;
  final String userId;

  @override
  State<StatefulWidget> createState() => new _MainPageState();
}

// Just your different authentication statuses
enum AuthStatus {
  NOT_DETERMINED,
  NOT_LOGGED_IN,
  LOGGED_IN,
}

class _MainPageState extends State<MainPage> {

  AuthStatus authStatus = AuthStatus.NOT_DETERMINED;
  String _userId = "";

  //I think I needed a constructor so it just prints hi to the console
  _MainPageState() {
    print("hi?");
  }

  // if you hit the logout button
  _signOut() async {
    try {
      await widget.auth.signOut();
      widget.onSignedOut();
    } catch (e) {
      print(e);
    }
  }

  //Main home page
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('flyt main login page'),
        actions: <Widget>[
          new FlatButton(
              child: new Text('Logout',
                  style: new TextStyle(fontSize: 17.0, color: Colors.white)),
              onPressed: _signOut)
        ],
      ),
      body: _showButtonList(),
    );
  }

  //Header method that contains the two (currently) buttons
  Widget _showButtonList() {
    return new Container(
      padding: EdgeInsets.all(15),
      child: new ListView(
        children: <Widget>[
          _createProfileContainer(),
          new SizedBox(
            height: 20.0,
          ),
          _acctSettingsContainer(),
          new SizedBox(
            height: 20.0,
          ),
          _startContainer(),
          new SizedBox(
            height: 20.0,
          ),
          _viewContainer(),
        ],
      ),
    );
  }

/*
// This container has been removed after figuring out how to access data quickly from the database

  _viewProfileContainer() {
    return new MaterialButton(
      shape:
      RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => View_Profile_Page()),
        );
      },
      minWidth: MediaQuery.of(context).size.width,
      padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
      color: Colors.white,
      textColor: Colors.black,
      child: Text(
        "View Your Current Profile",
        textAlign: TextAlign.center,
      ),
    );
  }
*/

  _viewContainer() {
    return new MaterialButton(
      shape:
      RoundedRectangleBorder(borderRadius: new BorderRadius.circular(800.0)),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => goToViewer()),
        );
      },
      minWidth: MediaQuery.of(context).size.width,
      padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
      color: Colors.deepOrange,
      textColor: Colors.white,
      child: Text(
        "View Your Matches!",
        textAlign: TextAlign.center,
      ),
    );
  }

  _startContainer() {
    return new MaterialButton(
      shape:
      RoundedRectangleBorder(borderRadius: new BorderRadius.circular(800.0)),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => goToSwiper()),
        );
      },
      minWidth: MediaQuery.of(context).size.width,
      padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
      color: Colors.lightBlueAccent,
      textColor: Colors.white,
      child: Text(
        "Start Swiping!",
        textAlign: TextAlign.center,
      ),
    );
  }

// returns the button to move to the profile creation screen
  _createProfileContainer() {
    return new MaterialButton(
      shape:
      RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => createProfilePage()),
        );
      },
      minWidth: MediaQuery.of(context).size.width,
      padding: EdgeInsets.fromLTRB(40.0, 50.0, 40.0, 50.0),
      color: Colors.green,
      textColor: Colors.white,
      child: Text(
        "Create/Edit Profile",
        textAlign: TextAlign.center,
      ),
    );
  }

  // returns the button to move to the account settings container
  _acctSettingsContainer() {
    return new MaterialButton(
      shape:
      RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => goToSettings(auth: widget.auth, onSignedOut: _onSignedOut, userId: _userId)),
        );
      },
      minWidth: MediaQuery.of(context).size.width,
      padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
      color: Colors.grey,
      textColor: Colors.white,
      child: Text(
        "Account Settings",
        textAlign: TextAlign.center,
      ),
    );
  }

  // Home page refers to the account settings page (called this because haven't changed from original
  HomePage goToHome(BaseAuth auth, VoidCallback onSignedOut, String userId) {
    return new HomePage(
      userId: _userId,
      auth: widget.auth,
      onSignedOut: _onSignedOut,
    );
  }

  //changes the authentication status when you hit the logout button
  void _onSignedOut() {
    setState(() {
      authStatus = AuthStatus.NOT_LOGGED_IN;
      _userId = "";
    });
  }
}

// takes you to the account setting page with help fro other method
class goToSettings extends StatelessWidget{

  @override
  goToSettings({Key key, this.auth, this.userId, this.onSignedOut})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback onSignedOut;
  final String userId;

  @override
  Widget build(BuildContext context) {
    return new HomePage(
      userId: userId,
      auth: auth,
      onSignedOut: onSignedOut,
    );
  }
}

class goToUploader extends StatelessWidget{

  goToUploader({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new ImageCapture();
  }
}

class goToSwiper extends StatelessWidget {

  goToSwiper({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new SwipeFeedPage();
  }
}

class goToViewer extends StatelessWidget {

  goToViewer({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new ViewMatchesPage();
  }
}

//----------------------------------------------------------------------------------

// The different genders people have to choose from
enum Genders {Female, Male }

class createProfilePage extends StatefulWidget {

  @override
  _createProfilePageState createState() => _createProfilePageState();
}

class _createProfilePageState extends State<createProfilePage> {
  User user = User("");
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  TextEditingController _userFoodController = TextEditingController();
  TextEditingController _userNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
          title: Text('Profile Creation'),
        ),
        body: _profileCreationPage(context)
    );
  }

  //The whole profile creation page
  Widget _profileCreationPage(BuildContext context) {
    _getProfileData();
    return new SingleChildScrollView(
      padding: EdgeInsets.all(15),
      child: new Column(
        children: <Widget>[
          _showNameContainer(),
          _saveNameContainer(),
          new SizedBox(
            height: 20.0,
          ),
          Text(
            'How do you most identify?',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          new MyGenderSelection(question: 0),

          new Text(
            'What gender are you currently looking for?',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          new MyGenderSelection(question: 1),

          _viewFoodsContainer(),

          _addPhotosContainer(),

          _addFoodsContainer(context),
        ],
      ),
    );
  }

  // This methods gets all the data from the firestore cloud and saves it to the current user, another global variable
  _getProfileData() async {
    final uid = await Provider.of(context).auth.getCurrentUID();
    DocumentSnapshot results = await users.doc(uid).get();
          user.favoriteFood = results.data()['favoriteFood'];
          user.name = results.data()['name'];
          user.ownGender = results.data()['ownGender'];
          user.wantedGender = results.data()['wantedGender'];
          user.uid = results.data()['uid'];
          user.picURL = results.data()['picURL'];
          user.matches = results.data()['matches'];

  }

  // creates the save name button
  Widget _saveNameContainer() {
    return new RaisedButton(
      child: Text('Save Name'),
      color: Colors.green,
      textColor: Colors.white,
      onPressed: () async {
        user.name = _userNameController.text;
        setState(() {
          _userNameController.text = user.name;
        });
        final uid = await Provider.of(context).auth.getCurrentUID();
        user.uid = uid;
        await Provider.of(context)
            .db
            .collection('users')
            .document(uid)
            .setData(user.toJson());
      },
    );
  }

  // creates the textbox where you can edit and see your name
  Widget _showNameContainer() {
    return new FutureBuilder(
        future: _getProfileData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            _userNameController.text = user.name;
          }
          return Container(
            decoration: BoxDecoration(
              borderRadius: new BorderRadius.circular(30.0),
            ),
            padding: EdgeInsets.fromLTRB(10, 20, 10, 20),
            child: Column(
              children: <Widget>[
                new TextFormField(
                  controller: _userNameController,
                  decoration: new InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                    hintText: user.name ?? "Enter Your Name (first)",
                    border:
                    OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22.0)),
                  ),
                ),
              ],
            ),
          );
        });
  }

  // the button where you can add photos
  // TO-DO: DOES NOT WORK YET
  Widget _addPhotosContainer() {
    return Container(
      child: ElevatedButton(
          child: Text('Add Photos Here!', style: TextStyle(color: Colors.white)),
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Colors.orangeAccent),
          ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => goToUploader()),
          );
        },
      ),
    );
  }

  // the text widget where it shows your favorite food
  Widget _viewFoodsContainer() {
    return new FutureBuilder(
      future: _getProfileData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          _userFoodController.text = user.favoriteFood;
        }
        return Text(
            "Favorite Food: ${user.favoriteFood}",
            style: TextStyle(color: Colors.black, fontSize: 20.5),
        );
      }
    );
  }

  // returns the widget for the add favorite food button
  Widget _addFoodsContainer(BuildContext context) {
    return Container(
      child: ElevatedButton(
          child: Text('Add Your favorite food here', style: TextStyle(color: Colors.white)),
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Colors.black45),
          ),
          onPressed: () {
            _userEditBottomSheet(context);
          },
      ),
    );
  }

  // the pop up for what happens when you try to edit the food
  _userEditBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Container(
          height: MediaQuery.of(context).size.height * .60,
          child: Padding(
            padding: const EdgeInsets.only(left: 15.0, top: 15.0),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text("Update Profile"),
                    Spacer(),
                    IconButton(
                      icon: Icon(Icons.cancel),
                      color: Colors.red,
                      iconSize: 25,
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 15.0),
                        child: TextField(
                          controller: _userFoodController,
                          decoration: InputDecoration(
                            helperText: "Favorite Food",
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    RaisedButton(
                      child: Text('Save'),
                      color: Colors.green,
                      textColor: Colors.white,
                      onPressed: () async {
                        user.favoriteFood = _userFoodController.text;
                        setState(() {
                          _userFoodController.text = user.favoriteFood;
                        });
                        final uid = await Provider.of(context).auth.getCurrentUID();
                        await Provider.of(context)
                            .db
                            .collection('users')
                            .document(uid)
                            .setData(user.toJson());
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// This class is how the buttons work; used in the gender selection
// for the parameter question 0 will stand for the first one about your own gender
// and 1 will mean the second question about what gender you are looking for
class MyGenderSelection extends StatefulWidget {
  final int question;
  MyGenderSelection({Key key, this.question}) : super(key: key);


  @override
  _MyGenderSelectionState createState() => _MyGenderSelectionState();
}

class _MyGenderSelectionState extends State<MyGenderSelection> {

  User user = User("");
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  Genders currGender = Genders.Female;

  Widget build(BuildContext context) {
    _getProfileData();
    return Column(
      children: <Widget>[
        ListTile(
          title: const Text('Female'),
          leading: Radio(
            value: Genders.Female,
            groupValue: currGender,
            onChanged: (Genders value) {
              setState(() {
                currGender = value;
              });
            },
          ),
        ),
        ListTile(
          title: const Text('Male'),
          leading: Radio(
            value: Genders.Male,
            groupValue: currGender,
            onChanged: (Genders value) {
              setState(() {
                currGender = value;
              });
            },
          ),
        ),
        TextButton(
          child: Text('Save'),
          onPressed: () {
            _saveGenderChange(widget.question);
          }
        ),
      ],
    );
  }

  _saveGenderChange(int question) async {
    if (question == 0) {
      user.ownGender = currGender.toString().substring(currGender.toString().indexOf('.') + 1);
    } else {
      user.wantedGender = currGender.toString().substring(currGender.toString().indexOf('.') + 1);
    }
      final uid = await Provider.of(context).auth.getCurrentUID();
      await Provider.of(context)
          .db
          .collection('users')
          .document(uid)
          .setData(user.toJson());
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

  }
}
