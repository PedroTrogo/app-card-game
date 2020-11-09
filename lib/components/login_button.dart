import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoginButton extends StatelessWidget {
  var _title;
  IconData _icon;
  Function _onPress;

  LoginButton(title, IconData icon, Function onPress){
    this._title = title;
    this._icon = icon;
    this._onPress = onPress;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      alignment: Alignment.center,
      decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [.3, 1],
            colors: [
              Colors.orangeAccent,
              Colors.red,
            ],
          ),
          borderRadius: BorderRadius.all(
              Radius.circular(10)
          )
      ),
      child: SizedBox.expand(
        child: FlatButton(
          onPressed: this._onPress,
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  _title,
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                Icon(
                  this._icon,
                  color: Colors.white,
                )
              ]
          ),
        ),
      ),
    );
  }
}
