import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gradient_bottom_navigation_bar/gradient_bottom_navigation_bar.dart';
import 'package:flutter_icons/flutter_icons.dart';

import 'lobby.dart';
import 'profile.dart';
import 'add_friend.dart';
import 'deck.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  int _currentIndex = 2;

  final _tabs = [
    Profile(),
    Deck(),
    Lobby(),
    AddFriend(),
  ];
  final _barTitle = [
    "Profile",
    "Deck",
    "Lobby",
    "+Friend",
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text(_barTitle[_currentIndex]),
        leading: null,
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    Colors.orangeAccent,
                    Colors.red,
                  ])
          ),
        ),
      ),
      body: _tabs[_currentIndex],
      bottomNavigationBar: GradientBottomNavigationBar(
        backgroundColorStart: Colors.orangeAccent,
        backgroundColorEnd: Colors.red,
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.shifting,
        items: [
          BottomNavigationBarItem(
            icon: Icon(AntDesign.user, size: 25),
            title: Text(""),
          ),
          BottomNavigationBarItem(
            icon: Icon(MaterialCommunityIcons.cards_outline, size: 25,),
            title: Text(""),
          ),
          BottomNavigationBarItem(
              icon: Icon(MaterialCommunityIcons.sword, size: 25),
              title: Text(""),
          ),
          BottomNavigationBarItem(
              icon: Icon(AntDesign.adduser, size: 25),
              title: Text(""),
          )
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
