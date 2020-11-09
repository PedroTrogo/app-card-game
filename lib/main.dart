import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:projetofinal/screens/match.dart';
import 'package:projetofinal/screens/register.dart';

import 'screens/login.dart';
import 'screens/home.dart';
import 'screens/profile.dart';
import 'screens/deck.dart';
import 'screens/lobby.dart';
import 'screens/add_friend.dart';

void main() async  {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        backgroundColor: Colors.white
      ),
      home: LoginScreen(),
      routes: <String, WidgetBuilder>{
        "/login": (BuildContext context) => LoginScreen(),
        "/register": (BuildContext context) => RegisterScreen(),
        "/home": (BuildContext context) => Home(),
        "/profile": (BuildContext context) => Profile(),
        "/deck": (BuildContext context) => Deck(),
        "/lobby": (BuildContext context) => Lobby(),
        "/add_friend": (BuildContext context) => AddFriend(),
        "/match": (BuildContext context) => Match(),
      },
    );
  }
}