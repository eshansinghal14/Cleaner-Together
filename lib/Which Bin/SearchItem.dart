import 'dart:io';
import 'dart:convert';
import 'package:cleaner_together/Custom%20Widgets.dart';
import 'package:http/http.dart' as http;
import 'package:cleaner_together/Auth/SignUp.dart';
import 'package:cleaner_together/Which%20Bin/ItemInfo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cleaner_together/Data Structures.dart';
import 'package:cleaner_together/Utilities.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:camera/camera.dart';
import 'package:cleaner_together/Which Bin/PickRecyclingFacility.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cleaner_together/Notifications.dart';

class SearchItem extends StatefulWidget {
  @override
  SearchItemState createState() => SearchItemState();
}

class SearchItemState extends State<SearchItem> {
  var items = [];
  var index = -1;
  bool head = false;
  var itemsLoaded = false;

  var searchTerm = '';
  var searchResults = [];

  final itemNameController = TextEditingController();
  FocusNode itemNameNode = new FocusNode();
  var itemName = '';

  CameraController controller;
  List<CameraDescription> cameras;

  double slidingTop = 200;

  @override
  void initState() {
    super.initState();
    setupCamera();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   // App state changed before we got the chance to initialize.
  //   if (controller == null || !controller.value.isInitialized) {
  //     return;
  //   }
  //   if (state == AppLifecycleState.inactive) {
  //     controller?.dispose();
  //   } else if (state == AppLifecycleState.resumed) {
  //     if (controller != null) {
  //       setupCamera();
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: SideMenu(),
      body: FutureBuilder(
          future: getItems(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              print('Error: ${snapshot.error.toString()}');
            } else if (itemsLoaded) {
              return Container(
                height: 700,
                child: FloatingSearchBar(
                  automaticallyImplyDrawerHamburger: false,
                  leadingActions: [
                    FloatingSearchBarAction(
                      showIfClosed: true,
                      child: Container(
                        padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                        child: Image.asset('assets/Transparent Logo.png')
                      ),
                    ),
                  ],
                  body: Stack(
                    alignment: Alignment.topCenter,
                    children: <Widget>[
                      SlidingUpPanel(
                        minHeight: 200,
                        maxHeight: MediaQuery.of(context).size.height - 100,
                        // snapPoint: 0.4,
                        onPanelSlide: (double pos) => setState(() {
                          slidingTop = pos *
                                  (MediaQuery.of(context).size.height - 300) + 30;
                          print(slidingTop);
                        }),
                        panel: Container(
                          decoration: BoxDecoration(
                            // color: Colors.grey[300],
                            borderRadius: BorderRadius.all(Radius.circular(50))
                          ),
                          padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                          child: Column(
                            children: <Widget>[
                              Container(
                                height: 4,
                                width: 50,
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5)),
                                  color: Colors.grey,
                                ),
                              ),
                              Expanded(
                                child: ListView.builder(
                                  itemCount: items.length + 26,
                                  scrollDirection: Axis.vertical,
                                  addRepaintBoundaries: false,
                                  itemBuilder: (context, i) {
                                    if (i == 0) {
                                      head = true;
                                      return makeHeader('A');
                                    } else if (head ||
                                        (items[index].name.substring(0, 1) ==
                                            items[index + 1]
                                                .name
                                                .substring(0, 1))) {
                                      index += 1;
                                      head = false;
                                      return makeItem(items[index], context);
                                    }
                                    head = true;
                                    return makeHeader(items[index + 1]
                                        .name
                                        .substring(0, 1));
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        body: Container(
                          child: Stack(
                            children: <Widget>[
                              CameraPreview(controller),
                              Container(
                                margin: EdgeInsets.fromLTRB(0, MediaQuery.of(context).size.height - slidingTop - 200, 0, slidingTop + 20),
                                // color: Colors.red,
                                child: Container(
                                  alignment: Alignment.bottomCenter,
                                  margin: EdgeInsets.fromLTRB(10, 0, 10, 10),
                                  child: Row(
                                    children: <Widget>[
                                      Align(
                                        alignment: Alignment.bottomLeft,
                                        child: TextButton(
                                          child: Text(
                                            'Cleaner Together',
                                            style: TextStyle(
                                                fontSize: 20.0,
                                                color: Colors.white
                                              // foreground: Paint()
                                              //   ..style = PaintingStyle.stroke
                                              //   ..strokeWidth = 1
                                              //   ..color = Colors.black,
                                            ),
                                          ),
                                          onPressed: () async {
                                            if (await canLaunch(
                                                'https://cleanertogether.com/'))
                                              await launch(
                                                  'https://cleanertogether.com/');
                                          },
                                        ),
                                      ),
                                      Spacer(),
                                      Column(
                                        children: <Widget>[
                                          FloatingActionButton(
                                            heroTag: 1,
                                            backgroundColor: Colors.white,
                                            child: Icon(
                                              Icons.location_on,
                                              color: Theme.of(context).primaryColor,
                                            ),
                                            onPressed: () async {
                                              recyclingCenterPressed();
                                            },
                                          ),
                                          SizedBox(height: 10,),
                                          FloatingActionButton(
                                            backgroundColor: Theme.of(context).primaryColor,
                                            heroTag: 2,
                                            child: Icon(
                                              Icons.add,
                                              color: Colors.white,
                                            ),
                                            onPressed: () {
                                              addItemAlertDialog();
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.fromLTRB(0, 0, 0, 100),
                                child: Align(
                                  alignment: Alignment.bottomCenter,
                                  child: FloatingActionButton(
                                    heroTag: 4,
                                    child: Icon(Icons.camera),
                                    onPressed: () async {
                                      if (FirebaseAuth.instance.currentUser ==
                                          null)
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    SignUp()));
                                      else {
                                        final photoItem =
                                            await controller.takePicture();
                                        submitItemRequestDialog(photoItem);
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  transition: ExpandingFloatingSearchBarTransition(),
                  title: Text(
                    'Search for an item',
                    style: TextStyle(fontSize: 18.0),
                  ),
                  hint: 'Search for an item',
                  actions: [
                    FloatingSearchBarAction(
                      showIfClosed: true,
                      child: IconButton(
                        icon: Icon(
                          Icons.notifications_active,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => Notifications()));
                        },
                      ),
                    ),
                    FloatingSearchBarAction(
                      child: IconButton(
                        icon: Icon(
                          Icons.menu,
                          color: Colors.grey
                        ),
                        onPressed: () {
                          Scaffold.of(context).openEndDrawer();
                        },
                      ),
                    ),
                  ],
                  onQueryChanged: (query) {
                    setState(() {
                      searchTerm = query;
                      searchResults = [];
                      for (int i = 0; i < items.length; i++) {
                        if ((items[i].name.toLowerCase() +
                                items[i].alternateNames.toLowerCase())
                            .contains(query.toLowerCase()))
                          searchResults.add(items[i]);
                      }
                    });
                  },
                  builder: (context, transition) {
                    return ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      child: Container(
                        height: 200,
                        child: ListView.builder(
                          itemCount: searchResults.length,
                          scrollDirection: Axis.vertical,
                          itemBuilder: (context, i) {
                            print(searchResults);
                            return makeItem(searchResults[i], context);
                          },
                        ),
                      ),
                    );
                  }
                ),
              );
            }
            return Center(child: CircularProgressIndicator());
          }),
    );
  }

  setupCamera() async {
    cameras = await availableCameras();
    controller = CameraController(cameras[0], ResolutionPreset.high);
    print(controller);
    await controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  submitItemRequestDialog(XFile image) {
    var alertDialog = AlertDialog(
      title: RichText(
        text: TextSpan(
          children: <TextSpan>[
            TextSpan(
                text: 'Submit Item Request\n',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                    color: Colors.black)),
            TextSpan(
                text:
                    'The image below will be sent to our team to determine if it is recyclable and we will send an answer as soon as possible.',
                style: TextStyle(fontSize: 16.0, color: Colors.black))
          ],
        ),
      ),
      content: Image.file(File(image.path)),
      actions: <Widget>[
        ElevatedButton(
          child: Text(
            'Send',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
                backgroundColor: Colors.transparent),
          ),
          style: ElevatedButton.styleFrom(
            primary: Colors.white,
            elevation: 0,
          ),
          onPressed: () async {
            final autoID = FirebaseFirestore.instance
                .collection('requestedItems')
                .doc()
                .id;
            TaskSnapshot snapshot;
            String downloadUrl;
            snapshot = await FirebaseStorage.instance
                .ref()
                .child("RequestedItems/$autoID.jpg")
                .putFile(File(image.path));
            downloadUrl = await snapshot.ref.getDownloadURL();
            await FirebaseFirestore.instance
                .collection("requestedItems")
                .doc(autoID)
                .set({
              'user': await Utilities.read('user'),
              'imageURL': downloadUrl,
              'message': '',
            });
            Navigator.pop(context);
          },
        ),
      ],
    );

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alertDialog;
        });
  }

  addItemAlertDialog() {
    var alertDialog = AlertDialog(
      title: Text('Add an Item'),
      content: Text(
          'If you cannot find the object you are looking for, please enter it below to help expand our database of items!'),
      actions: <Widget>[
        TextField(
          keyboardType: TextInputType.multiline,
          maxLines: null,
          obscureText: false,
          controller: itemNameController,
          focusNode: itemNameNode,
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: Theme.of(context).primaryColor, width: 3),
            ),
            labelText: 'Item Name',
            labelStyle: TextStyle(
              color: itemNameNode.hasFocus
                  ? Theme.of(context).primaryColor
                  : Colors.grey,
            ),
            suffix: ButtonTheme(
              buttonColor: Colors.transparent,
              child: ElevatedButton(
                child: Text(
                  'Add',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                      backgroundColor: Colors.transparent),
                ),
                style: ElevatedButton.styleFrom(
                  primary: Colors.white,
                  elevation: 0,
                ),
                onPressed: () async {
                  if (FirebaseAuth.instance.currentUser == null)
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => SignUp()));
                  else {
                    Navigator.of(context, rootNavigator: true).pop('dialog');
                    await FirebaseFirestore.instance
                        .collection("other")
                        .doc()
                        .set({
                      'name': itemName,
                      'username': await Utilities.read('user'),
                      'approved': false,
                    });
                  }
                },
              ),
            ),
          ),
          onTap: () {
            setState(() {
              FocusScope.of(context).requestFocus(itemNameNode);
            });
          },
          onChanged: (String val) async {
            itemName = val;
          },
        ),
      ],
    );

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alertDialog;
        });
  }

  recyclingCenterPressed() async {
    if (await Utilities.read('recyclingCenter') == '')
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => PickRecyclingFacility()));
    else {
      final centerId = await Utilities.read('recyclingCenter');
      final facilityIn =
          'http://api.earth911.com/earth911.getProgramDetails?api_key=783aa93e81e2003e&program_id=$centerId';
      final facilityInfo =
          json.decode((await http.get(Uri.parse(facilityIn))).body);
      var alertDialog = AlertDialog(
        title: RichText(
          textAlign: TextAlign.left,
          text: TextSpan(
            children: <TextSpan>[
              TextSpan(
                  text: facilityInfo['result'][centerId]['description'] + '\n',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                      color: Colors.black)),
              TextSpan(
                  text: facilityInfo['result'][centerId]['phone'] + '\n',
                  style: TextStyle(fontSize: 16.0, color: Colors.black)),
              TextSpan(
                  text: facilityInfo['result'][centerId]['notes_public'],
                  style: TextStyle(fontSize: 16.0, color: Colors.black)),
            ],
          ),
        ),
        content: TextButton(
          child: Align(
            child: Text(
              facilityInfo['result'][centerId]['url'],
              textAlign: TextAlign.left,
              style: TextStyle(
                color: Colors.blue,
              ),
            ),
          ),
          onPressed: () async {
            if (await canLaunch(facilityInfo['result'][centerId]['url']))
              await launch(facilityInfo['result'][centerId]['url']);
          },
        ),
        actions: <Widget>[
          ElevatedButton(
            child: Align(
              child: Text(
                'Change Recycling Facility',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                    backgroundColor: Colors.transparent),
              ),
            ),
            style: ElevatedButton.styleFrom(
              primary: Colors.white,
              elevation: 0,
            ),
            onPressed: () async {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PickRecyclingFacility()));
            },
          ),
        ],
      );

      showDialog(
          context: context,
          builder: (BuildContext context) {
            return alertDialog;
          });
    }
  }

  getItems() async {
    String userCenter = await Utilities.read('recyclingCenter');
    if (!itemsLoaded) {
      await FirebaseFirestore.instance.collection('items').where('approved', isEqualTo: true).get().then((qs) {
        qs.docs.forEach((element) async {
          var data = element.data();
          String id = element.id;
          final eid = data['id'] ?? '';
          final user = data['username'] ?? '';
          final name = data['name'] ?? '';
          final alternateNames = data['alternateNames'] ?? '';
          final material = data['material'] ?? '';
          final whichBin = data['whichBin'] ?? '';
          final image = data['image'] ?? '';
          final info = data['info'] ?? '';
          final links = data['links'] ?? '';
          final item = Item(id, eid.toString(), user, name, alternateNames,
              material, whichBin, image, info, 'items', links);
          if (data['image'] != null && data['material'] != null && !data.containsValue(item)) {
            items.add(item);
          }
        });
      });
    }
    print(items.length);
    items.sort((a, b) => a.name.compareTo(b.name));
    if (userCenter != '') {
      for (int i = 0; i < items.length; i++) {
        if (items[i].eid != '') {
          items[i].whichBin = 'Trash';
        }
      }
      print(userCenter);
      final locationUrl =
          'http://api.earth911.com/earth911.getProgramDetails?api_key=783aa93e81e2003e&program_id=$userCenter';
      final locationInfo =
          json.decode((await http.get(Uri.parse(locationUrl))).body);
      print(locationInfo);
      for (int i = 0;
          i < locationInfo['result'][userCenter]['materials'].length;
          i++) {
        int index = items.indexWhere((item) =>
            item.eid ==
            locationInfo['result'][userCenter]['materials'][i]['material_id']);
        print(index);
        if (index != -1) {
          items[index].whichBin = 'Accepted by ${locationInfo['result']} ';
          if (locationInfo['result'][userCenter]['materials'][i]['pickup'])
            items[index].whichBin += '(Curbside) ';
          if (locationInfo['result'][userCenter]['materials'][i]['dropoff'])
            items[index].whichBin += '(Dropoff)';
          if (locationInfo['result'][userCenter]['materials'][i]['notes'] != '')
            items[i].info +=
                '\n*${locationInfo['result'][userCenter]['materials'][i]['notes']}';
        }
      }
    }
    itemsLoaded = true;
    // searchResults = items;
  }

  Text makeHeader(String letter) {
    return Text(
      letter,
      style: TextStyle(fontSize: 36.0),
    );
  }

  Card makeItem(Item item, BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(
          item.name,
        ),
        subtitle: Text(item.whichBin),
        leading: Image.network(item.image),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => ItemInfo(item),));
        },
      ),
    );
  }
}
