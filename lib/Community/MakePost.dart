import 'dart:io';
import 'package:cleaner_together/Utilities.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:image_cropper/image_cropper.dart';

class MakePost extends StatefulWidget {
  @override
  MakePostState createState() => MakePostState();
}

class MakePostState extends State<MakePost> {
  var descrip = '';
  File image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Make Post'),
        centerTitle: true,
        automaticallyImplyLeading: true,
        actions: [
          IconButton(
            icon: Text('Post'),
            onPressed: () {
              post();
            },
          )
        ],
      ),
      body: Container(
        margin: EdgeInsets.fromLTRB(10, 20, 10, 20),
        child: Column(
          children: <Widget>[
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'What are you up to?'
              ),
              onChanged: (String val) async {
                descrip = val;
              },
            ),
            ButtonTheme(
              child: ElevatedButton(
                child: Text(
                  'Pick Image',
                  style: TextStyle(fontSize: 30.0, backgroundColor: Colors.blue),
                ),
                onPressed: () {
                  getImage();
                },
              ),
            ),
            if (image != null) Image.file(image),
          ],
        ),
      ),
    );
  }

  post() async {
    final autoID = FirebaseFirestore.instance.collection('feed').doc().id;
    TaskSnapshot snapshot;
    String downloadUrl;
    if (image != null) {
      snapshot = await FirebaseStorage.instance.ref().child("Feed/$autoID.jpg").putFile(image);
      downloadUrl = await snapshot.ref.getDownloadURL();
    }
    final formatter = new DateFormat('yyyy-MM-dd');
    await FirebaseFirestore.instance.collection("feed").doc(autoID).set({
      'user': await Utilities.read('user'),
      'description': descrip,
      'datePost': formatter.format(DateTime.now()),
      'likes': [],
      'imageURL': image == null ? '' : downloadUrl,
    });
    Navigator.pop(context);
  }

  Future getImage() async {
    final i = await ImagePicker().getImage(source: ImageSource.gallery);
    setState(() async {
      image = await ImageCropper.cropImage(
        sourcePath: i.path,
        aspectRatioPresets: [CropAspectRatioPreset.square],
        androidUiSettings: AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false
        ),
        iosUiSettings: IOSUiSettings(
          title: 'Crop Image',
        )
      );
      print(image);
    });
  }
}