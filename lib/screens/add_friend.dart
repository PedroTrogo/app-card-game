import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projetofinal/components/search_bar.dart';
import 'package:projetofinal/screens/lobby.dart';

class AddFriend extends StatefulWidget {
  @override
  _AddFriendState createState() => _AddFriendState();
}

class _AddFriendState extends State<AddFriend> {
  TextEditingController _searchController = new TextEditingController();
  Future resultsLoaded;
  QuerySnapshot userFriends;
  List _allResults = [];
  List _resultsList = [];
  User user = null;

  getAllUsers() async {
    user = await FirebaseAuth.instance.currentUser;

    var data = await FirebaseFirestore.instance
        .collection("users")
        .get();

    userFriends = await FirebaseFirestore.instance
        .collection("users").doc(user.uid).collection("friends").get();

    print("friends: "+userFriends.size.toString());
    setState(() {
      _allResults = data.docs;
    });
    return "done";
  }


  @override
  void didChangeDependencies(){
    super.didChangeDependencies();
    resultsLoaded = getAllUsers();
  }

  @override
  void initState(){
    super.initState();
    _searchController.addListener(_onSearchChange);
  }

  @override
  void dispose(){
    _searchController.removeListener(_onSearchChange);
    _searchController.dispose();
    super.dispose();
  }

  _onSearchChange(){
    searchResultsList();
  }

  searchResultsList(){
    var showResults = [];

    if(_searchController.text != ""){
      for(var e in _allResults){
        bool match = e.get("nick").toString().startsWith(new RegExp(_searchController.text, caseSensitive: false));
        if(match && e.id != user.uid){
          showResults.add(e);
        }
      }
    }
    else{
      showResults = [];
    }

    setState(() {
      _resultsList = showResults;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: <Widget>[
              Container(
                margin: const EdgeInsets.only(top: 20),
                child: SearchBar('Encontrar um Amigo...', _searchController),
              ),
              _searchController.text == "" ?
              Expanded(
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: Icon(
                        Icons.search,
                        size: 200,
                        color: Color.fromRGBO(0, 0, 0, .03),
                      ),
                    ),
                    Divider(thickness: 1),
                    ConstrainedBox(
                      constraints: new BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height * .05,
                        minWidth: MediaQuery.of(context).size.width,
                        maxHeight: MediaQuery.of(context).size.height/3,
                        maxWidth: MediaQuery.of(context).size.width,
                      ),
                      child: user != null ? Container(
                          width: MediaQuery.of(context).size.width,
                          child: StreamBuilder(
                            stream: FirebaseFirestore.instance.collection("users").doc(user.uid).collection("friendRequests").snapshots(),
                              builder: (context, snapshot){
                                if(!snapshot.hasData)
                                  return Text("Sem Informações");

                                switch(snapshot.connectionState){
                                  case ConnectionState.none:
                                  case ConnectionState.waiting:
                                    return Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  default: {
                                    return ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: snapshot.data.documents.length,
                                        itemBuilder:(BuildContext context, int index) =>
                                          FriendRequestItem(snapshot.data.documents[index], _allResults)
                                    );//
                                  }
                                }
                            }
                          ),
                        ):
                      Container()
                    )
                  ],
                )
              ) :
              Container(),
              _searchController.text != "" ?
              Expanded(
                child: ListView.builder(
                  itemCount: _resultsList.length,
                  itemBuilder:(BuildContext context, int index) =>
                    FriendListItem(_resultsList[index], user.uid, userFriends)
                  )
              ):
              Container(),
            ],
          ),
        ),
      ),
    );
  }
}


class FriendListItem extends StatefulWidget{
  var _data;
  String userID;
  QuerySnapshot userFriends;
  bool alreadyFriend;

  FriendListItem(_data, userID, userFriends){
    this._data = _data;
    this.userID = userID;
    this.userFriends = userFriends;
    bool temp = false;
    this.userFriends.docs.forEach((element) {
      if(element.id == _data.id)
        temp = true;
    });

    this.alreadyFriend = temp;
  }

  @override
  _FriendListItemState createState() => _FriendListItemState();
}

class _FriendListItemState extends State<FriendListItem> {
  var requestAlreadySent = false;

  void getFriendRequests()async{
    QuerySnapshot temp = await FirebaseFirestore.instance
        .collection("users")
        .doc(widget._data.id)
        .collection("friendRequests")
        .get();

    temp.docs.forEach((element) {
      if(element.id == widget.userID && mounted){
        setState(() {
          requestAlreadySent = true;
        });
      }
    });
  }

  void sendRequest()async{
    FirebaseFirestore.instance
        .collection("users")
        .doc(widget._data.id)
        .collection("friendRequests")
        .doc(widget.userID)
        .set({});

    FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser.uid)
        .collection("requestsSent")
        .doc(widget._data.id)
        .set({});

    if(!mounted)
      return;

    setState(() {
      requestAlreadySent = true;
    });
  }

  @override
  Widget build(BuildContext context){
    getFriendRequests();
    print("areadyFriend "+widget.alreadyFriend.toString());
    return Column(
      children: <Widget>[
        Container(
          height: MediaQuery.of(context).size.height * .15,
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                child: CircleAvatar(
                    radius: 25,
                    backgroundImage: NetworkImage(widget._data.get("pic"))
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(widget._data.get("nick"), style: TextStyle(fontSize: 18)),
                  Text(widget._data.get("email"), style: TextStyle(fontSize: 13)),
                ],
              ),
              Container(
                child: FlatButton(
                  child: Text(widget.alreadyFriend ? "" : (requestAlreadySent ? "Pending":"Add"), style: TextStyle(color: requestAlreadySent ? Colors.orange : Colors.green, fontSize: 16)),
                  onPressed: (requestAlreadySent || widget.alreadyFriend) ? null : () => sendRequest(),
                ),
              )
            ],
          ),
        ),
        Divider(height: 1,)
      ],
    );
  }
}


class FriendRequestItem extends StatelessWidget{
  final QueryDocumentSnapshot _data;
  final _allUsers;

  FriendRequestItem(this._data, this._allUsers);

  void acceptRequest(){
    rejectRequest();

    FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser.uid)
        .collection("friends")
        .doc(_data.id)
        .set({});

    FirebaseFirestore.instance
        .collection("users")
        .doc(_data.id)
        .collection("friends")
        .doc(FirebaseAuth.instance.currentUser.uid)
        .set({});
  }

  void rejectRequest(){
    FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser.uid)
        .collection("friendRequests")
        .doc(_data.id)
        .delete();

    FirebaseFirestore.instance
        .collection("users")
        .doc(_data.id)
        .collection("requestsSent")
        .doc(FirebaseAuth.instance.currentUser.uid)
        .delete();
  }

  QueryDocumentSnapshot find(e){
    for(int i =0; i < _allUsers.length; i++){
      if(_allUsers[i].id == _data.id)
        return _allUsers[i];
    }

    return null;
  }

  @override
  Widget build(BuildContext context){
    var user = find(_data.id);

    return Column(
      children: <Widget>[
        Container(
          height: MediaQuery.of(context).size.height * .15,
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                child:
                CircleAvatar(
                    radius: 25,
                    backgroundImage: NetworkImage(user?.get("pic") ?? "https://www.bsn.eu/wp-content/uploads/2016/12/user-icon-image-placeholder.jpg")
                )
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(user?.get("nick") ?? "not found", style: TextStyle(fontSize: 18)),
                  Text(user?.get("email") ?? "not found", style: TextStyle(fontSize: 13)),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    height: MediaQuery.of(context).size.height * .06,
                    child: FlatButton(
                      child: Text("Accept", style: TextStyle(color: Colors.green, fontSize: 16)),
                      onPressed: () => acceptRequest(),
                    ),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height * .06,
                    child: FlatButton(
                      child: Text("Reject", style: TextStyle(color: Colors.orange, fontSize: 16)),
                      onPressed: () => rejectRequest(),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
        Divider(height: 1,)
      ],
    );
  }
}