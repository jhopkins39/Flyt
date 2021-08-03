import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart'; // For File Upload To Firestore
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_cropper/image_cropper.dart';
import './provider_widget.dart';
import '../models/User.dart';
//import 'package:path/path.dart' as Path;

class Uploader extends StatefulWidget {
  final File file;

  Uploader({Key key, this.file}) : super(key: key);
  createState() => _UploaderState();
}

class _UploaderState extends State<Uploader> {

  CollectionReference users = FirebaseFirestore.instance.collection('users');
  final FirebaseStorage _storage = FirebaseStorage(storageBucket: 'gs://flyt-15b2c.appspot.com');
  StorageUploadTask _uploadTask;
  User user = User("");

  //This will now upload the file with the url as the uid
  Future<String> _startUpload(File file) async{
    final uid = await Provider.of(context).auth.getCurrentUID();
    DocumentSnapshot results = await users.doc(uid).get();
      user.favoriteFood = results.data()['favoriteFood'];
      user.name = results.data()['name'];
      user.ownGender = results.data()['ownGender'];
      user.wantedGender = results.data()['wantedGender'];
      user.picURL = results.data()['picURL'];
      user.uid = results.data()['uid'];
    //String filePath = 'images/${DateTime.now()}.png';
    var storageRef = _storage.ref().child("images/${uid}.png");
    _uploadTask = storageRef.putFile(file);
    var completedTask = await _uploadTask.onComplete;
    String downloadUrl = await completedTask.ref.getDownloadURL();
    user.picURL = downloadUrl;
    await Provider.of(context)
        .db
        .collection('users')
        .document(uid)
        .setData(user.toJson());
    return downloadUrl;
  }

  Future<String> getUserProfileImage(String uid) async {
    return await _storage.ref().child("images/$uid.png").getDownloadURL();
  }

  @override
  Widget build(BuildContext context) {
    if (_uploadTask != null) {
      return StreamBuilder<StorageTaskEvent>(
          stream: _uploadTask.events,
          builder: (context, snapshot) {
            var event = snapshot?.data?.snapshot;

            double progressPercent = event != null
                ? event.bytesTransferred / event.totalByteCount
                : 0;

            return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (_uploadTask.isComplete)
                    Text('🎉🎉🎉',
                        style: TextStyle(
                            color: Colors.greenAccent,
                            height: 2,
                            fontSize: 30)),
                  if (_uploadTask.isPaused)
                    FlatButton(
                      child: Icon(Icons.play_arrow, size: 50),
                      onPressed: _uploadTask.resume,
                    ),
                  if (_uploadTask.isInProgress)
                    FlatButton(
                      child: Icon(Icons.pause, size: 50),
                      onPressed: _uploadTask.pause,
                    ),


                  LinearProgressIndicator(value: progressPercent),
                  Text(
                    '${(progressPercent * 100).toStringAsFixed(2)} % ',
                    style: TextStyle(fontSize: 50),
                  ),
                ]);
          });
    } else {
      return FlatButton.icon(
          color: Colors.blue,
          label: Text('Upload to Firebase'),
          icon: Icon(Icons.cloud_upload),
          onPressed: () => _startUpload(widget.file));
    }
  }
}

//--------------------------------------------------------------------------------

class ImageCapture extends StatefulWidget {
  createState() => _ImageCaptureState();
}

class _ImageCaptureState extends State<ImageCapture> {
  /// Active image file
  final FirebaseStorage _storage = FirebaseStorage(storageBucket: 'gs://flyt-15b2c.appspot.com');
  File _imageFile;
  final picker = ImagePicker();
  String uid;
  CollectionReference users = FirebaseFirestore.instance.collection('users');

  /// Cropper plugin

  Future<void> _cropImage() async {
    File cropped = await ImageCropper.cropImage(
        sourcePath: _imageFile.path,
        // ratioX: 1.0,
        // ratioY: 1.0,
        // maxWidth: 512,
        // maxHeight: 512,
        );

    setState(() {
      _imageFile = cropped ?? _imageFile;
    });
  }

  _getProfileData() async {
    uid = await Provider.of(context).auth.getCurrentUID();
  }


  /// Select an image via gallery or camera
  Future<void> getImage(ImageSource source) async {
    final pickedFile = await picker.getImage(source: source);

    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  /// Remove image
  void _clear() {
    setState(() => _imageFile = null);
  }

  @override
  Widget build(BuildContext context) {
    _getProfileData();
    return Scaffold(
      appBar: new AppBar(
        title: new Text('Image Uploader!'),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            IconButton(
              icon: Icon(
                Icons.photo_camera,
                size: 30,
              ),
              onPressed: () => getImage(ImageSource.camera),
              color: Colors.blue,
            ),
            IconButton(
              icon: Icon(
                Icons.photo_library,
                size: 30,
              ),
              onPressed: () => getImage(ImageSource.gallery),
              color: Colors.pink,
            ),
          ],
        ),
      ),
      body: ListView(
        children: <Widget>[
          if (_imageFile != null) ...[
            Container(
                padding: EdgeInsets.all(32), child: Image.file(_imageFile)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                FlatButton(
                  //color: Colors.black,
                  child: Icon(Icons.crop),
                  onPressed: _cropImage,
                ),
                FlatButton(
                  //color: Colors.black,
                  child: Icon(Icons.refresh),
                  onPressed: _clear,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(32),
              child: Uploader(
                file: _imageFile,
              ),
            )
          ]
          else ... [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: 300.0),
                  ElevatedButton(
                    child: Text('Uploaded Photo will appear here!', style: TextStyle(color: Colors.white)),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.black),
                    ),
                  )
                ]
              )
            ]
        ]
      ),
    );
  }

  checkForPic() async {
    final uid = await Provider.of(context).auth.getCurrentUID();
    DocumentSnapshot results = await users.doc(uid).get();
    return results.data()['picURL'];
  }
}