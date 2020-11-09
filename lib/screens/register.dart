import 'dart:developer';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:projetofinal/components/login_button.dart';

class RegisterScreen extends StatelessWidget {
  TextEditingController _nickController = new TextEditingController();
  TextEditingController _emailController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();



  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.black,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        child: Scaffold(
          body: SafeArea(
              top: false,
              child: Container(
                padding: EdgeInsets.only(
                    top: 60,
                    right: 40,
                    left: 40
                ),
                color: Colors.white,
                child: ListView(
                  children: <Widget>[
                    SizedBox(
                        height: 80
                    ),
                    TextFormField(
                      controller: _nickController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                          labelText: "Nick",
                          labelStyle: TextStyle(
                              color: Colors.deepOrange,
                              fontWeight: FontWeight.w400,
                              fontSize: 16
                          )
                      ),
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      autocorrect: false,
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                          labelText: "E-mail",
                          labelStyle: TextStyle(
                              color: Colors.deepOrange,
                              fontWeight: FontWeight.w400,
                              fontSize: 16
                          )
                      ),
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: _passwordController,
                      keyboardType: TextInputType.text,
                      obscureText: true,
                      decoration: InputDecoration(
                          labelText: "Senha",
                          labelStyle: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w400,
                              fontSize: 16
                          )
                      ),
                    ),
                    SizedBox(height: 60),
                    new LoginButton("Finalizar", null, ()=> _register(context, _nickController.text, _emailController.text.trim(), _passwordController.text.trim())),
                  ],
                ),
              )
          ),
        )
    );
  }
}


_register(context, nick, email, password) async {
  try{
    await Firebase.initializeApp();

    UserCredential user = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,

    );

    var hp = Random().nextInt(58)+40;
    var strength = Random().nextInt(58)+40;
    var defense = Random().nextInt(58)+40;
    var avg = ((hp+strength+defense)/3).round();

    var userAdditionalInfo = {
      "nick":nick,
      "email":email,
      "matches": 0,
      "wins": 0,
      "defeats":0,
      "hp": hp,
      "strength": strength,
      "defence": defense,
      "avg": avg,
      "pic": "https://vignette.wikia.nocookie.net/tudosobrehoradeaventura/images/e/e4/Finn-and-jake-the-eyes.png/revision/latest/scale-to-width-down/340?cb=20130728103621&path-prefix=pt-br"
    };

    DocumentReference newUser = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.user.uid);

    newUser.set(userAdditionalInfo);
    DocumentReference initialFriend = await newUser.collection("friends").add({});
    newUser.collection("friends").doc(initialFriend.id).delete();

    Navigator.pop(context);
  }
  catch(e){
    print("[login][_login]: "+e.toString());
  }
}


