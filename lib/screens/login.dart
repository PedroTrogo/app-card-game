import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:projetofinal/components/login_button.dart';
import 'package:projetofinal/screens/home.dart';

class LoginScreen extends StatelessWidget {
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
                  width: 128,
                  height: 128,
                  child: Image.asset("assets/logo.png"),
                ),
                SizedBox(
                  height: 80
                ),
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
                new LoginButton("Login", null, ()=> _login(context, _emailController.text.trim(), _passwordController.text.trim())),
                SizedBox(height: 20),
                new LoginButton("Register", null,  ()=> _register(context))
              ],
            ),
          )
        ),
      )
    );
  }
}

_verificarLogin(context)async{
  await Firebase.initializeApp();
  var user = await FirebaseAuth.instance.currentUser;

  if(user != null)
    Navigator.pushReplacementNamed(context, "/home");
}


_register(context){
  Navigator.pushNamed(context, "/register");
}

_login(context, email, password) async {

  try{
    await Firebase.initializeApp();
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    Navigator.pushReplacementNamed(context, "/home");
  }
  catch(e){
    print("[login][_login]: "+e.toString());
    Dialog();
  }
}


