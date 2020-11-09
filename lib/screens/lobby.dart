import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:projetofinal/screens/match.dart';
import 'package:random_color/random_color.dart';

final user = FirebaseAuth.instance.currentUser;

class Lobby extends StatelessWidget {
  createTable() async {
    var data = {
      "number": "0",
      "mode": "Normal",
      "currentRoundPlayer": "undefined",
      "round": 1
    };

    DocumentReference tableRef =
        await FirebaseFirestore.instance.collection("matches").add(data);

    print("Match created with id: " + tableRef.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder(
            stream:
                FirebaseFirestore.instance.collection("matches").snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Text("Sem Informações");
              }

              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                default:
                  if (snapshot.data.documents.length == 0) return Container();

                  return Container(
                      color: Colors.white,
                      child: GridView.builder(
                          padding: EdgeInsets.all(20),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 20,
                                  mainAxisSpacing: 20),
                          itemCount: snapshot.data.docs.length,
                          itemBuilder: (context, index) {
                            List tables = snapshot.data.docs.toList();
                            QueryDocumentSnapshot docRef =
                                snapshot.data.docs[index];
                            CollectionReference playersColl =
                                docRef.reference.collection("players");

                            return Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(.5),
                                      spreadRadius: 1,
                                      blurRadius: 3,
                                      offset: Offset(
                                          -2, 2), // changes position of shadow
                                    ),
                                  ]),
                              child: FlatButton(
                                child:
                                    _lobbyPreview(tables[index], playersColl),
                                splashColor: RandomColor().randomColor(),
                                onPressed: () {
                                  Navigator.pushNamed(context, "/match",
                                      arguments: tables[index].id);
                                },
                              ),
                            );
                          }));
              }
            }),
        floatingActionButton: Draggable(
          feedback: FloatingActionButton(
              child: Icon(MaterialCommunityIcons.plus),
              onPressed: () {},
              backgroundColor: RandomColor()
                  .randomColor(colorBrightness: ColorBrightness.dark)),
          child: FloatingActionButton(
              child: Icon(MaterialCommunityIcons.plus),
              onPressed: () {
                createTable();
              },
              backgroundColor: RandomColor()
                  .randomColor(colorBrightness: ColorBrightness.dark)),
          childWhenDragging: Container(),
        ));
  }
}

Widget _lobbyPreview(
    QueryDocumentSnapshot data, CollectionReference playersConnected) {
  Size screen(context) {
    return MediaQuery.of(context).size;
  }

  return StreamBuilder(
      stream: playersConnected.snapshots(),
      builder: (context, players) {
        switch (players.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Center(child: CircularProgressIndicator());
          default:
            if (players.hasError) return Container();

            return Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: Column(
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.only(bottom: 5, top: 5),
                    child: Icon(MaterialCommunityIcons.sword,
                        size: screen(context).width * .15,
                        color: RandomColor().randomColor()),
                  ),
                  TableInfoItem("Modo", "Normal", context),
                  TableInfoItem(
                      "Players", "(${players.data.docs.length} - 2)", context),
                  Container(
                    margin: const EdgeInsets.only(top: 5),
                    child: Row(
                      children: <Widget>[
                        Text("#",
                            textAlign: TextAlign.left,
                            style: TextStyle(color: Colors.black45)),
                        Text("${data.get('number')}"),
                      ],
                    ),
                  )
                ],
              ),
            );
        }
      });
}

Widget TableInfoItem(String title, var value, context) {
  Size screen(context) {
    return MediaQuery.of(context).size;
  }

  return Container(
      margin: const EdgeInsets.only(top: 3),
      child: Row(
        children: <Widget>[
          Container(
              width: screen(context).width * .15,
              alignment: Alignment.centerLeft,
              child: FittedBox(
                fit: BoxFit.fitWidth,
                child: Text(
                  "${title}",
                  textAlign: TextAlign.left,
                  style: TextStyle(color: Colors.black45),
                ),
              )),
          Container(
            width: screen(context).width * .15,
            alignment: Alignment.centerLeft,
            child: FittedBox(
                fit: BoxFit.fitWidth,
                child: Text("${value}", textAlign: TextAlign.left)),
          )
        ],
      ));
}
