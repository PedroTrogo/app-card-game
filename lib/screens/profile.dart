import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  User  user = FirebaseAuth.instance.currentUser;
  QuerySnapshot friendsRef;
  bool loading = true;

  Profile(){
    getUserInfo();
  }

  void getUserInfo()async{
    friendsRef = await FirebaseFirestore.instance.collection("users").doc(user.uid).collection("friends").get();
    loading = false;
  }

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  _logOut(){
    Navigator.pushReplacementNamed(context, "/login");
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
          stream: FirebaseFirestore.instance.collection("users").doc(widget.user.uid).snapshots(),
          builder: (context, snapshot){

            if(snapshot.connectionState == ConnectionState.waiting || widget.loading){
              return Container(
                alignment: Alignment.center,
                child: CircularProgressIndicator(),
              );
            }

            if(snapshot.hasError || !snapshot.hasData) {
              return Text("Erro ao carregar o usuário");
            }

            var userInfo =  snapshot.data;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              child: Container(
                alignment: AlignmentDirectional.center,
                child: Column(
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(userInfo.get("pic")),
                        radius: 40,
                      ),
                    ),
                    Text(
                      userInfo.get("nick"),
                      style: TextStyle(fontSize: 20),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 20, bottom: 20),
                      child: Divider(
                        height: 1.0,
                      ),
                    ),
                    Column(
                      children: <Widget>[
                        StreamBuilder(
                          stream: snapshot.data.reference.collection("friends").snapshots(),
                          builder: (context, snapshot){
                            if(snapshot.connectionState == ConnectionState.waiting || widget.loading){
                              return Container(
                                width: 0.0,
                                height: 0.0,
                                alignment: Alignment.center,
                                child: CircularProgressIndicator(),
                              );
                            }

                            if(snapshot.hasError || !snapshot.hasData) {
                              PerfilRow("Amigos", "...");
                            }

                            return PerfilRow("Amigos", snapshot.data.size ?? "0");
                          }
                        ),
                        PerfilRow("Partidas Jogadas", userInfo.get("matches")),
                        PerfilRow("Vitórias", userInfo.get("wins")),
                        PerfilRow("Derrotas", userInfo.get("defeats"))
                      ],
                    ),
                    Container(
                        margin: const EdgeInsets.only(top: 30),
                        alignment: Alignment.center,
                        child: FlatButton(
                          onPressed: _logOut,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Icon(Icons.exit_to_app, color: Colors.black54),
                              Container(
                                margin: const EdgeInsets.only(left: 5),
                                child: Text("Sair", style: TextStyle(fontSize: 18, color: Colors.black54),),
                              )
                            ],
                          ),
                        )
                    )
                  ],
                ),
              )
            );
          },
        );
  }
}

class PerfilRow extends StatelessWidget {
  var _title;
  var _value;

  PerfilRow(this._title, this._value);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text("${_title}", style: TextStyle(fontSize: 18, color: Colors.black38)),
              Container(
                child: Text("${_value}", style: TextStyle(fontSize: 18, color: Colors.deepOrange)),
              )
            ],
          ),
          Divider(
            height: 1.0,
          ),
        ],
      )
    );
  }
}
