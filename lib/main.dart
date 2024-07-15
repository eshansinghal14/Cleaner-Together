import 'package:cleaner_together/Admin/Admin.dart';
import 'package:cleaner_together/Auth/Login.dart';
import 'package:cleaner_together/Auth/SignUp.dart';
import 'package:cleaner_together/Community/Feed.dart';
import 'package:cleaner_together/Home.dart';
import 'package:cleaner_together/Which%20Bin/SearchItem.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'Discover.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(CleanerTogether());
}

class CleanerTogether extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      theme: ThemeData(
        // Define the default brightness and colors.
        brightness: Brightness.light,
        primaryColor: Color(0xFFEDD098), //Green
        accentColor: Color(0xFF97BFD8), // Blue
        shadowColor: Color(0xFF8CC090), //Brown

        // Define the default font family.
        fontFamily: 'Raleway',

        // Define the default TextTheme. Use this to specify the default
        // text styling for headlines, titles, bodies of text, and more.
        textTheme: TextTheme(
          headline1: TextStyle(fontSize: 72.0),
          headline6: TextStyle(fontSize: 36.0),
          bodyText2: TextStyle(fontSize: 14.0),
        ),
      ),
      home: DefaultTabController(
        length: 3,
        initialIndex: 0,
        child: Scaffold(
          backgroundColor: Colors.white,
          bottomNavigationBar: Container(
            margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
            decoration: BoxDecoration(
              // borderRadius: BorderRadius.circular(10),
              gradient: LinearGradient(
                colors: [Color(0xFFEDD098), Color(0xFF97BFD8)],
              ),
            ),
            child: TabBar(
              labelColor: Colors.white,
              tabs: [
                // Tab(
                //   text: 'Home',
                //   icon: Icon(Icons.home),
                // ),
                Tab(
                  text: 'Discover',
                  icon: Icon(Icons.book),
                ),
                Tab(
                  text: 'Home',
                  icon: Icon(Icons.home),
                ),
                Tab(
                  text: 'Community',
                  icon: Icon(Icons.people),
                ),
              ],
            ),
          ),
          body: TabBarView(
            children: <Widget>[
              // Home(),
              Discover(),
              SearchItem(),
              Feed(),
            ],
          ),
        ),
      ),
    );
  }
}