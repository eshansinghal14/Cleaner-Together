import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cleaner_together/Utilities.dart';
import 'package:cleaner_together/Admin/Admin.dart';

class SideMenu extends StatelessWidget {

  String username;
  String email;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getUserName(),
      builder: (context, snapshot) {
        if (username != null) {
          return Drawer(
            child: Container(
              padding: EdgeInsets.fromLTRB(10, 50, 10, 10),
              color: Colors.blue,
              child: Material(
                color: Colors.transparent,
                child: Column(
                  children: <Widget>[
                    RichText(
                      text: TextSpan(
                        children: <TextSpan>[
                          TextSpan(text: username != null ? username + '\n' : '', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0, color: Colors.white)),
                          TextSpan(text: email != null ? email : '', style: TextStyle(fontSize: 16.0, color: Colors.white))
                        ],
                      ),
                    ),
                    Container(
                      height: 350,
                      child: Expanded(
                        child: ListView(
                          children: buildPagesMenu(context),
                        ),
                      ),
                    ),
                    Spacer(),
                    Wrap(
                      spacing: -5,
                      children: buildWebPages(),
                    ),
                    Divider(
                      color: Colors.grey[100],
                      height: 10,
                      thickness: 1,
                      endIndent: 30,
                    ),
                    Container(
                      height: 30,
                      child: Wrap(
                        alignment: WrapAlignment.start,
                        spacing: 0,
                        children: buildSocialButtons(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }

  getUserName() async {
    username = await Utilities.read('user');
    email = FirebaseAuth.instance.currentUser.email;
  }
  List<Widget> buildPagesMenu(BuildContext context) {
    final pageNames = ['Home', 'Discover', 'Which Bin?', 'Community'];
    final pageIcons = [Icons.home, Icons.book, Icons.home, Icons.people, Icons.admin_panel_settings];
    if (FirebaseAuth.instance.currentUser != null && ['eshsinghal@yahoo.com', 'anita_singhal_25@yahoo.com'].contains(FirebaseAuth.instance.currentUser.email))
      pageNames.add('Admin');
    List<Widget> pages = [];

    for (int i = 0; i < pageNames.length; i++) {
      pages.add(
        ListTile(
          leading: Icon(pageIcons[i], color: Colors.white,),
          title: Text(pageNames[i], style: TextStyle(color: Colors.white),),
          onTap: () {
            if (pageNames[i] == 'Home')
              DefaultTabController.of(context).animateTo(0);
            if (pageNames[i] == 'Discover')
              DefaultTabController.of(context).animateTo(1);
            else if (pageNames[i] == 'Which Bin?')
              DefaultTabController.of(context).animateTo(2);
            else if (pageNames[i] == 'Community')
              DefaultTabController.of(context).animateTo(3);
            else
              Navigator.push(context, MaterialPageRoute(builder: (context) => Admin()));
          },
        )
      );
    }
    return pages;
  }

  List<Widget> buildWebPages() {
    final pageNames = ['About Us', 'Initiatives', 'Contact Us'];
    final pageUrls = ['https://cleanertogether.com/about-us/', 'https://cleanertogether.com/projects/', 'https://cleanertogether.com/find-us/'];
    List<Widget> webPages = [];

    for (int i = 0; i < pageNames.length; i++) {
      webPages.add(
        TextButton(
          child: Text(
            pageNames[i],
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: Colors.grey[100],
                backgroundColor: Colors.transparent
            ),
          ),
          onPressed: () async {
            if (await canLaunch(pageUrls[i]))
              await launch(pageUrls[i]);
          }
        )
      );

      if (i + 1 != pageNames.length) {
        webPages.add(
          Text(
            '\n·',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[100],
            ),
          ),
        );
      }
    }
    return webPages;
  }

  List<Widget> buildSocialButtons() {
    final platformIcons = ['assets/Facebook Logo.png', 'assets/Instagram Logo.png', 'assets/YouTube Logo.png'];
    final platformUrls = ['https://www.facebook.com/cleanertogether', 'https://www.instagram.com/cleanertogether/', 'https://www.youtube.com/channel/UCivoKr4QvWz_nbb8Mru_sxw'];
    List<Widget> socialButtons = [];

    for (int i = 0; i < platformIcons.length; i++) {
      socialButtons.add(
        IconButton(
          icon: Image.asset(platformIcons[i]),
          onPressed: () async {
            if (await canLaunch(platformUrls[i]))
              await launch(platformUrls[i]);
          },
        )
      );
    }
    return socialButtons;
  }
}