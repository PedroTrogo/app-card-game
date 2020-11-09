import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:random_color/random_color.dart';

class CardDetail {
  static showCardDetail(context, QueryDocumentSnapshot data, showActionButtons, actionButtons) {
    showDialog(
        context: context,
        builder: (context) {
          return CardDetails(data, showActionButtons, actionButtons);
        });
  }

  static dismissCardDetail(context){
    Navigator.pop(context);
  }
}

class CardDetails extends StatelessWidget {
  final QueryDocumentSnapshot data;
  final bool showActionButtons;
  final List actionButtons;

  CardDetails(this.data, this.showActionButtons, this.actionButtons);

  screen(context) {
    return MediaQuery.of(context).size;
  }


  List<Widget> getActionButtons(context){
    List<Widget> list = [];

    if(actionButtons == null)
        return list;

    String formatTitle(String str){
      var arr = str.split(" ");

      return arr[0];
    }
    
    for(int i = 0; i< actionButtons.length; i++){
      list.add(
        Container(
          width: screen(context).width * .22,
          height: screen(context).height * .1,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(10))
          ),
          child: FlatButton(
              onPressed: () => actionButtons[i]["actionButton"] != null ? actionButtons[i]["actionButton"](actionButtons[i]["title"], this.data) : null,
              child: FittedBox(fit:BoxFit.fitWidth, child: Text(formatTitle(actionButtons[i]["title"]))),
          ),
        )
      );
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {

    return Dialog(
      elevation: 0,
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(),
        child: Container(
          height: screen(context).height * .8,
          child: Column(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  color: RandomColor()
                      .randomColor(colorBrightness: ColorBrightness.light),
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: ClipPath(
                      clipper: _BorderClipper(),
                      child: Container(
                        color: Colors.white,
                        height: screen(context).height * .6,
                        width: screen(context).width * .7,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Container(
                              child: CircleAvatar(
                                  radius: screen(context).height * .1,
                                  backgroundImage: NetworkImage(data.get("pic"))),
                            ),
                            Container(
                              child: Text(
                                data.get("nick"),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black),
                              ),
                            ),
                            Container(
                              height: screen(context).height * .15,
                              margin: const EdgeInsets.only(top: 10),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Divider(height: 1),
                                  ProfileRow("HP", data.get("hp")),
                                  ProfileRow("FORÇA", data.get("strength")),
                                  ProfileRow("DEFESA", data.get("defence")),
                                ],
                              ),
                            ),
                            Container(
                                child: CircleAvatar(
                                  radius: screen(context).height * .05,
                                  backgroundColor: RandomColor().randomColor(
                                      colorBrightness: ColorBrightness.dark),
                                  child: Text(
                                    "${data.get("avg")}",
                                    style: TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ))
                          ],
                        ),
                      ),
                    )),
              ),
              Container(
                height: screen(context).height * .1,
                margin: const EdgeInsets.only(top: 10),
                padding: const EdgeInsets.symmetric(horizontal: 60),
                child: !showActionButtons ? Container() :
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: getActionButtons(context)
                ),
              )
            ],
          )
        ));
  }
}

class ProfileRow extends StatelessWidget {
  var _title;
  var _value;
  ProfileRow(this._title, this._value);

  @override
  Widget build(BuildContext context) {
    return Container(
//        margin: const EdgeInsets.only(top: 20),
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text("${_title}",
                    style: TextStyle(fontSize: 16, color: Colors.black38)),
                Container(
                    child: Text("${_value}",
                        style: TextStyle(
                            fontSize: 16,
                            color: this._value <= 64
                                ? Colors.orange
                                : (_value <= 89
                                    ? Colors.blueAccent
                                    : Colors.deepPurple)))),
              ],
            ),
            Divider(
              height: 1.0,
            ),
          ],
        ));
  }
}

class _BorderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    var widthStart = .1;
    var widthEnd = .9;
    var heigthStart = .05;
    var heigthEnd = .95;

    //top
    path.lineTo(0, size.height * heigthStart);
    path.lineTo(size.width * widthStart, 0);
    path.lineTo(size.width * widthEnd, 0);
    path.lineTo(size.width * widthEnd, 0);
    path.lineTo(size.width, size.height * heigthStart);

    //rigth
    path.lineTo(size.width, size.height * .40);
    path.lineTo(size.width * .95, size.height * .45);

    //bottom
    path.lineTo(size.width, size.height * heigthEnd);
    path.lineTo(size.width * widthEnd, size.height);
    path.lineTo(size.width * widthStart, size.height);
    path.lineTo(0, size.height * heigthEnd);

    //left
    path.lineTo(size.width * .05, size.height * .45);
    path.lineTo(0, size.height * .40);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
