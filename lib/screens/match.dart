import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:projetofinal/components/card_detail.dart';
import 'package:projetofinal/screens/home.dart';
import 'package:projetofinal/screens/lobby.dart';
import 'dart:async';

import 'package:random_color/random_color.dart';

DocumentReference _currentTable;
QuerySnapshot _allCards;
var attackingCardData;
var appBarHeight;
String matchID;
List<String> alreadyAttackInThisRound = [];
int currentRound;

class Match extends StatelessWidget {
  static List<QueryDocumentSnapshot> playersInMatch = [];

  @override
  Widget build(BuildContext context) {
    matchID = ModalRoute.of(context).settings.arguments;
    _currentTable = FirebaseFirestore.instance.collection("matches").doc(matchID);

    void exitGame() async {
//      QuerySnapshot playersCount = await _currentTable.collection("players").get();

      QuerySnapshot cardsInField = await _currentTable
          .collection("players")
          .doc(FirebaseAuth.instance.currentUser.uid)
          .collection("cardsInField")
          .get();
      QuerySnapshot cardsInHand = await _currentTable
          .collection("players")
          .doc(FirebaseAuth.instance.currentUser.uid)
          .collection("cardsInHand")
          .get();
      DocumentSnapshot player = await _currentTable
          .collection("players")
          .doc(FirebaseAuth.instance.currentUser.uid)
          .get();
      WriteBatch batch = FirebaseFirestore.instance.batch();

      cardsInField.docs.forEach((element) {
        batch.delete(element.reference);
      });
      cardsInHand.docs.forEach((element) {
        batch.delete(element.reference);
      });

      batch.delete(player.reference);

      batch.commit();

      Navigator.pushReplacementNamed(context, "/home");
    }

    Future<bool> _onBackPressed() {
      return showDialog(
            context: context,
            builder: (context) => new AlertDialog(
              shape: RoundedRectangleBorder(),
              actionsPadding: const EdgeInsets.symmetric(horizontal: 20),
              title: new Text('Are you sure?'),
              content: new Text('Do you want to quit current game'),
              actions: <Widget>[
                new GestureDetector(
                  onTap: () => Navigator.of(context).pop(false),
                  child: Text("NO"),
                ),
                SizedBox(height: 46),
                new GestureDetector(
                  onTap: () => exitGame(),
                  child: Text("YES"),
                ),
              ],
            ),
          ) ??
          false;
    }

    AppBar appBar = AppBar(
      centerTitle: true,
      title: Text(matchID),
      leading: new IconButton(
        icon: new Icon(Icons.arrow_back),
        onPressed: () {
          _onBackPressed();
        },
      ),
      flexibleSpace: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
              Colors.orangeAccent,
              Colors.red,
            ])),
      ),
    );

    appBarHeight = appBar.preferredSize.height;

    return WillPopScope(
        onWillPop: _onBackPressed,
        child: Scaffold(
          appBar: appBar,
          body: Container(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              OpponentField(),
              Divider(
                height: 2,
                thickness: 2,
              ),
              MyField()
            ],
          )),
        ));
  }
}

class MyField extends StatefulWidget {
  @override
  _MyFieldState createState() => _MyFieldState();
}

class _MyFieldState extends State<MyField> {
  bool standBy = true;
  var roundManager = {
    "discardsFromHand": 1,
    "discardsFromField": 1,
    "sets": 1,
    "draws": 1,
  };
  bool loading = true;
  List<String> _myDeck = [];
  String _userId = FirebaseAuth.instance.currentUser.uid;

  _MyFieldState() {
    matchSetup();
  }

  //configura as dependencias da partida
  void matchSetup() async {
    _allCards = await FirebaseFirestore.instance.collection("users").get(); //recebe todos os usuarios como cartas
    DocumentSnapshot user = await FirebaseFirestore.instance.collection("users").doc(_userId).get(); //uma referencia ao usuario atual
    QuerySnapshot friendsTemp = await user.reference.collection("friends").get(); //armazena o id das cartas possuidas pelo usuario atual
    List<String> handCountTemp = []; //as cartas na mao do player

    friendsTemp.docs.forEach((element) {
      _myDeck.add(element.id);
    });

    await _currentTable.collection("players").doc(_userId).set({
      "hp": 100,
      "nick": user.get("nick")
    }); //recebe a referencia do player correspondente ao usuario. Caso ainda nao exista, ele é criado

    DocumentReference docRef = _currentTable.collection("players").doc(_userId);

    QuerySnapshot cardsPreviewslyInHand = await docRef.collection("cardsInHand").get();

    if(cardsPreviewslyInHand.docs.length == 0){
      for (var i = 0; i < 3 && i < _myDeck.length; i++) {
        var index = Random().nextInt(_myDeck.length); //pega uma carta aleatoria do baralho
        handCountTemp.add(_myDeck[index]); //adiciona a carta a mao
        _myDeck.removeAt(index); //remove essa carta do baralho
      }
    }

    WriteBatch batch = FirebaseFirestore.instance.batch();

    handCountTemp.forEach((e) {
      batch.set(docRef.collection("cardsInHand").doc(e), {});
    }); //cria um doc para cada carta na mao no collection cardsInHand

    batch.commit();

    setState(() {
      loading = false;
    });
  }

  //adiciona uma carta na mao
  void drawCard() async {
    if (roundManager["draws"] == 0)
      return;

    QuerySnapshot cardsInHand = await _currentTable
        .collection("players")
        .doc(_userId)
        .collection("cardsInHand")
        .get();

    print("comprando " + cardsInHand.docs.length.toString());

    if (cardsInHand.docs.length > 3)
      return;

    String handTemp = _myDeck.removeAt(Random().nextInt(_myDeck.length));

    _currentTable
        .collection("players")
        .doc(_userId)
        .collection("cardsInHand")
        .doc(handTemp)
        .set({});

    roundManager["draws"] = 0;
  }

  //coloca uma carta no campo
  void setCardOnField(QueryDocumentSnapshot data) async {
    try {
      if (roundManager["sets"] == 0) return;

      QuerySnapshot cardsInField = await _currentTable
          .collection("players")
          .doc(_userId)
          .collection("cardsInField")
          .get();

      if (cardsInField.docs.length >= 3) {
        return;
      }

      discardCard(data, "hand");

      roundManager["sets"] = 0;

      CollectionReference fieldRef = _currentTable
          .collection("players")
          .doc(_userId)
          .collection("cardsInField");

      fieldRef.doc(data.id).set({"hp": data.get("hp")});
    } catch (e) {
      print("erro: " + e.toString());
    }
  }

  //remove uma carta da mao
  void discardCard(QueryDocumentSnapshot data, fromWhere) async {
    CardDetail.dismissCardDetail(context);

    if (fromWhere == "hand") {
      roundManager["discardsFromHand"] = 0;
      await _currentTable
          .collection("players")
          .doc(_userId)
          .collection("cardsInHand")
          .doc(data.id)
          .delete();
    }
    else {
      roundManager["discardsFromField"] = 0;
      await _currentTable
          .collection("players")
          .doc(_userId)
          .collection("cardsInField")
          .doc(data.id)
          .delete();
    }
  }

  void showCardDetails(QueryDocumentSnapshot data, actionButtons) {
    CardDetail.showCardDetail(context, data, true, actionButtons);
  }

  void attack(QueryDocumentSnapshot data) {
    if(alreadyAttackInThisRound.firstWhere((element) => element == data.id, orElse: () => "true") != "true")
      return;

    CardDetail.dismissCardDetail(context);

    attackingCardData = {
      "id": data.id,
      "strength": data.get("strength"),
    };
  }

  void cardActions(action, data) {
    if (standBy) return;

    switch (action) {
      case 'Set':
        setCardOnField(data);
        break;
      case 'Discard from Field':
        if (roundManager["discardsFromField"] == 0) return;
        discardCard(data, "field");
        break;
      case 'Discard from Hand':
        if (roundManager["discardsFromHand"] == 0) return;
        discardCard(data, "hand");
        break;
      case 'Attack':
        attack(data);
        break;
      default:
        print(action.toString());
        break;
    }
  }

  void startRound() {
    print("Round just started");
    standBy = false;
    alreadyAttackInThisRound = [];
    roundManager = {
      "discardsFromHand": 1,
      "discardsFromField": 1,
      "sets": 1,
      "draws": 1
    };
    print(roundManager["sets"]);
    drawCard();
  }

  void endMyTurn() async {
    standBy = true;
    QuerySnapshot players = await _currentTable.collection("players").get();

    if (players.docs.length < 2)
      return;

    String opponentID = players.docs.firstWhere((element) => element.id != _userId,  orElse: () => null).id;

    DocumentSnapshot table =  await _currentTable.get();
    int roundCount = table.get("round");

    _currentTable.update({"currentRoundPlayer": opponentID, "round": roundCount+1});
    currentRound++;

    print("turn end");
  }

  Size screen(context) {
    return MediaQuery.of(context).size;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: loading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Expanded(
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.only(top: 10),
                child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  StreamBuilder(
                      stream: _currentTable.snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Container(
                            alignment: Alignment.center,
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (snapshot.hasError || !snapshot.hasData) {
                          return Text("Sem informação do servidor");
                        }

                        currentRound = snapshot.data.get("round");
                        if (snapshot.data.get("currentRoundPlayer") == _userId)
                          startRound();

                        return Container(
                          height: (screen(context).height - appBarHeight) * .05,
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              Text(
                                  "ROUND   "+snapshot.data.get("round")?.toString() ?? "1"
                              ),
                              Container(
                                  width: screen(context).width * .2,
                                  height: (screen(context).height - appBarHeight) * .05,
                                  margin: const EdgeInsets.only(right: 20),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      border: new Border.all(width: 1, color: Colors.black),
                                      borderRadius: new BorderRadius.all(Radius.circular(5))),
                                      child: FlatButton(
                                        onPressed: () => endMyTurn(),
                                        child: FittedBox(
                                            fit: BoxFit.fitWidth,
                                            child: Text(
                                                snapshot.data.get("currentRoundPlayer") == "undefined" ||
                                                    snapshot.data.get("currentRoundPlayer") != _userId ||
                                                    standBy ? "Waiting..." : "End My Turn")
                                        ),
                                      )
                              ),
                              StreamBuilder(
                                stream: _currentTable.collection("players").doc(_userId).snapshots(),
                                builder: (context, snapshot){
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                  return Container(
                                  alignment: Alignment.center,
                                  child: CircularProgressIndicator(),
                                  );
                                  }
                                  if (snapshot.hasError || !snapshot.hasData) {
                                  return Text("Sem informação do servidor");
                                  }

                                  Future<bool> endDialog() {
                                    return showDialog(
                                      context: context,
                                      builder: (context) => new AlertDialog(
                                        shape: RoundedRectangleBorder(),
                                        actionsPadding: const EdgeInsets.symmetric(
                                            horizontal: 20),
                                        title: new Text('Oh no!!'),
                                        content: new Text(
                                            'You lose the match'),
                                        actions: <Widget>[
                                          new GestureDetector(
                                            onTap: () => Navigator.pushReplacementNamed(context, "/home"),
                                            child: Text("Leave match"),
                                          ),
                                          SizedBox(height: 46),
                                        ],
                                      ),
                                    ) ??
                                        false;
                                  }

                                  if(snapshot.data.get("hp") <= 0){
                                    endDialog();
                                  }

                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      FittedBox(
                                        fit: BoxFit.fitWidth,
                                        child:Text("HP")
                                      ),
                                      Container(width: 10,),
                                      FittedBox(
                                        fit: BoxFit.fitWidth,
                                        child:Text(snapshot.data.get("hp").toString(), style: TextStyle(color: Colors.green),)
                                      ),
                                    ],
                                  );
                                },
                              )
                            ],
                          ),
                        );
                      }),
                    Container(
                      width: screen(context).width,
                      height: (screen(context).height - appBarHeight) * .4,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                         StreamBuilder(
                            stream: _currentTable.collection("players").doc(_userId).collection("cardsInField").snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Container(
                                  alignment: Alignment.center,
                                  child: CircularProgressIndicator(),
                                );
                              }

                              if (snapshot.hasError || !snapshot.hasData) {
                                return Text("Sem informação do servidor");
                              }

                              List<Widget> getCardInField() {
                                List<Widget> list = List();

                                for (int i = 0; i < 3; i++) {
                                  if (i < snapshot.data.documents.length) {
                                    var e = snapshot.data.documents[i];
                                    var cardData = _allCards.docs.firstWhere((item) => item.id == e.id, orElse: () => null);
                                    list.add(_CardSlot(
                                        onPress: (cardData) =>
                                            showCardDetails(cardData, [
                                              {
                                                "actionButton":
                                                    cardActions,
                                                "title": "Attack"
                                              },
                                              {
                                                "actionButton":
                                                    cardActions,
                                                "title":
                                                    "Discard from Field"
                                              }
                                            ]),
                                        cardData: cardData,
                                        hp: e.get("hp")));
                                  } else {
                                    list.add(_CardSlot(onPress: null));
                                  }
                                }

                                return list;
                              }

                              return Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: getCardInField(),
                              );
                            }
                          ),
                          StreamBuilder(
                            stream: _currentTable.collection("players").doc(_userId).collection("cardsInHand").snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Container(
                                  alignment: Alignment.center,
                                  child: CircularProgressIndicator(),
                                );
                              }

                              if (snapshot.hasError || !snapshot.hasData) {
                                return Text("Sem informação do servidor");
                              }

                              List<Widget> getCardInHand() {
                                List<Widget> list = List();

                                for (int i = 0; i < 4; i++) {
                                  if (i < snapshot.data.documents.length) {
                                    var e = snapshot.data.documents[i];
                                    var cardData = _allCards.docs.firstWhere((item) => item.id == e.id, orElse: () => null);

                                    print(cardData);

                                    if(cardData == null)
                                      list.add(_CardSlot(onPress: null));
                                    else{
                                      list.add(_CardSlot(
                                        onPress: (cardData) =>
                                            showCardDetails(cardData, [
                                              {
                                                "actionButton": cardActions,
                                                "title": "Set"
                                              },
                                              {
                                                "actionButton": cardActions,
                                                "title": "Discard from Hand"
                                              }
                                            ]),
                                        cardData: cardData,
                                        hp: cardData.get("avg"),
                                        isCardInHand: true,
                                      ));
                                    }

                                  }
                                  else {
                                    list.add(_CardSlot(onPress: null));
                                  }
                                }

                                return list;
                              }

                              return Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: getCardInHand(),
                              );
                            }
                          )
                        ],
                      )
                    )
                  ],
                ),
              )
            ),
        )
    );
  }
}

class OpponentField extends StatefulWidget {
  @override
  _OpponentField createState() => _OpponentField();
}

class _OpponentField extends State<OpponentField> {
  CollectionReference players = FirebaseFirestore.instance.collection("matches").doc(_currentTable.id).collection("players");

  int currentHP = 100;

  Size screen(context) {
    return MediaQuery.of(context).size;
  }

  void selectFirstToGo(id1, id2)async{
    DocumentSnapshot currentRoundPlayer = await _currentTable.get();

    if(currentRoundPlayer.get("currentRoundPlayer") != "undefined")
      return;

    String firstToGo = Random().nextInt(2) == 0 ? id1 : id2;

    _currentTable.update({"currentRoundPlayer": firstToGo});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Expanded(
        child: Container(
            child: StreamBuilder(
                stream: players.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (snapshot.hasError || !snapshot.hasData) {
                    return Text("Sem informação do servidor");
                  }

                  if (snapshot.data.documents.length == 1)
                    return Center(child: Text("Waiting for other player"));

                  String opponentID = snapshot.data.documents.firstWhere((element) => element.id != FirebaseAuth.instance.currentUser.uid, orElse: () => null)?.id;
                  
                  if(opponentID == null)
                    return Container();

                  selectFirstToGo(opponentID, user.uid);

                  return StreamBuilder(
                      stream: players.doc(opponentID).collection("cardsInField").snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Container(
                            alignment: Alignment.center,
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (snapshot.hasError || !snapshot.hasData) {
                          return Text("Sem informação do servidor");
                        }

                        void calcDamage(QueryDocumentSnapshot data) {
                          int def = data.get("defence");
                          int atk = attackingCardData["strength"];

                          int damage = (atk * (def / 100)).round();

                          QueryDocumentSnapshot cardRef;

                          for (int i = 0; i < snapshot.data.documents.length; i++) {
                            if (snapshot.data.documents[i].id == data.id) {
                              cardRef = snapshot.data.documents[i];
                              break;
                            }
                          }

                          int hp = cardRef.get("hp");
                          int newHP = hp - damage;
                          alreadyAttackInThisRound.add(attackingCardData["id"]);
                          attackingCardData = null;

                          if (newHP <= 0) {
                            cardRef.reference.delete();
                          } else {
                            cardRef.reference
                                .update({"hp": newHP < 0 ? 0 : newHP});
                          }
                        }

                        Future<bool> confirmSelection(QueryDocumentSnapshot data) {
                          return showDialog(
                                context: context,
                                builder: (context) => new AlertDialog(
                                  shape: RoundedRectangleBorder(),
                                  actionsPadding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  title: new Text('Are you sure?'),
                                  content: new Text(
                                      'Do you want to attack this card?'),
                                  actions: <Widget>[
                                    new GestureDetector(
                                      onTap: () =>
                                          Navigator.of(context).pop(false),
                                      child: Text("No"),
                                    ),
                                    SizedBox(height: 46),
                                    new GestureDetector(
                                      onTap: () => {
                                        calcDamage(data),
                                        Navigator.of(context).pop(false)
                                      },
                                      child: Text("Yes"),
                                    ),
                                    new GestureDetector(
                                      onTap: () => {
                                        attackingCardData = null,
                                        Navigator.of(context).pop(false)
                                      },
                                      child: Text("Cancel"),
                                    ),
                                  ],
                                ),
                              ) ??
                              false;
                        }

                        Future<bool> endDialog() {
                          return showDialog(
                            context: context,
                            builder: (context) => new AlertDialog(
                              shape: RoundedRectangleBorder(),
                              actionsPadding: const EdgeInsets.symmetric(
                                  horizontal: 20),
                              title: new Text('Congratulations!!'),
                              content: new Text(
                                  'You won the match'),
                              actions: <Widget>[
                                new GestureDetector(
                                  onTap: () => Navigator.pushReplacementNamed(context, "/home"),
                                  child: Text("Yeah!"),
                                ),
                                SizedBox(height: 46),
                              ],
                            ),
                          ) ??
                              false;
                        }

                        Future<bool> firstRoundDirectAttackDialog() {
                          return showDialog(
                            context: context,
                            builder: (context) => new AlertDialog(
                              shape: RoundedRectangleBorder(),
                              actionsPadding: const EdgeInsets.symmetric(
                                  horizontal: 20),
                              title: new Text('Warning!!'),
                              content: new Text(
                                  'You can not attack in the first round'),
                              actions: <Widget>[
                                new GestureDetector(
                                  onTap: () =>  Navigator.of(context).pop(false),
                                  child: Text("Ok"),
                                ),
                                SizedBox(height: 46),
                              ],
                            ),
                          ) ??
                              false;
                        }

                        void directAttack()async{
                          if(currentRound == null || currentRound == 1){
                            firstRoundDirectAttackDialog();
                            return;
                          }


                            if(attackingCardData == null || snapshot.data.documents.length > 0)
                              return;

                            DocumentSnapshot opponent = await players.doc(opponentID).get();

                            int hp = opponent.get("hp");
                            int atk = attackingCardData["strength"];
                            int newHP = hp - atk;

                            alreadyAttackInThisRound.add(attackingCardData["id"]);
                            attackingCardData = null;

                            if (newHP <= 0) {
                              opponent.reference.delete();
                              endDialog();
                            } else {
                              opponent.reference.update({"hp": newHP});
                              if(mounted)
                                setState(() {
                                  currentHP = newHP;
                                });
                            }
                        }

                        void showCardDetails(QueryDocumentSnapshot data) {
                          if (attackingCardData == null)
                            CardDetail.showCardDetail(context, data, false, null);
                          else {
                            confirmSelection(data);
                          }
                        }

                        List<Widget> getCardInField() {
                          List<Widget> list = List();

                          for (int i = 0; i < 3; i++) {
                            if (i < snapshot.data.documents.length) {
                              var e = snapshot.data.documents[i];
                              var cardData = _allCards.docs.firstWhere((item) => item.id == e.id, orElse: () => null);
                              list.add(_CardSlot(onPress: (cardData) => showCardDetails(cardData), cardData: cardData, hp: e.get("hp")));
                            } else {
                              list.add(_CardSlot(onPress: () => directAttack()));
                            }
                          }
                          return list;
                        }

                        return Container(
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              Container(
                                child: StreamBuilder(
                                    stream: players.doc(opponentID).collection("cardsInHand").snapshots(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return Container(
                                          alignment: Alignment.center,
                                          child: CircularProgressIndicator(),
                                        );
                                      }

                                      if (snapshot.hasError || !snapshot.hasData) {
                                        return Text(
                                            "Sem informação do servidor");
                                      }

                                      List<Widget> getCardInHand() {
                                        List<Widget> list = List();

                                        for (int i = 0;
                                            i < snapshot.data.documents.length;
                                            i++) list.add(_CardSlot());

                                        return list;
                                      }

                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: getCardInHand(),
                                      );
                                  }
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: getCardInField(),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  FittedBox(
                                      fit: BoxFit.fitWidth,
                                      child:Text("HP")
                                  ),
                                  Container(width: 10,),
                                  FittedBox(
                                      fit: BoxFit.fitWidth,
                                      child:Text(currentHP.toString(), style: TextStyle(color: Colors.red),)
                                  ),
                                ],
                              )
                            ],
                          ),
                        );
                    });
                }
            )
          )
        )
    );
  }
}


class _CardSlot extends StatelessWidget {
  var onPress;
  var hp;
  DocumentSnapshot cardData;
  bool isCardInHand;

  _CardSlot({this.onPress, this.cardData, this.hp, this.isCardInHand});

  Size screen(context) {
    return MediaQuery.of(context).size;
  }

  @override
  Widget build(BuildContext context) {
    return (Container(
      width: screen(context).width * .20,
      height: (screen(context).height - appBarHeight) * .15,
      decoration: BoxDecoration(
          border: new Border.all(
              width: 1,
              color: cardData == null ? Colors.black26 : Colors.black),
          borderRadius: new BorderRadius.all(Radius.circular(5))),
          child: cardData == null
          ? FlatButton(
              onPressed: onPress != null ? () => onPress() : () => {},
              child: Container()
          )
          : FlatButton(
              onPressed: () => onPress(this.cardData),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  CircleAvatar(
                      radius: (screen(context).height - appBarHeight) * .025,
                      backgroundImage: NetworkImage(cardData.data()["pic"])),
                  Container(
                    child: CircleAvatar(
                      radius: (screen(context).height - appBarHeight) * .025,
                      backgroundColor:
                          isCardInHand != null ? Colors.orange : Colors.green,
                      child: FittedBox(
                          fit: BoxFit.fitWidth,
                          child: Text(
                            hp.toString(),
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          )),
                    ),
                  )
                ],
              )),
    ));
  }
}
