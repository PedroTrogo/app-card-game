import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:projetofinal/components/card_detail.dart';
import 'package:random_color/random_color.dart';

class CardListItem extends StatelessWidget {
  final QueryDocumentSnapshot data;

  CardListItem(this.data);

  @override
  Widget build(BuildContext context) {

    return Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:BorderRadius.all(
                    Radius.circular(10)
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(.5),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: Offset(-2, 2), // changes position of shadow
                  ),
                ]
            ),
          child: FlatButton(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Container(
                  child: CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(data.get("pic"))
                  ),
                ),
                Text(
                  data.get("nick"),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.black),
                ),
                Container(
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: RandomColor().randomColor(colorBrightness: ColorBrightness.dark),
                      child: Text(
                        "${data.get("avg")}",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    )
                )
              ],
            ),
            splashColor: RandomColor().randomColor(),
            onPressed: () => {
              CardDetail.showCardDetail(context, data, false, null)
          },
        )
      );
  }
}