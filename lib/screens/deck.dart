import 'dart:developer';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:projetofinal/components/card_list_item.dart';
import 'package:projetofinal/components/search_bar.dart';
import 'package:random_color/random_color.dart';

class Deck extends StatefulWidget {
  @override
  _DeckState createState() => _DeckState();
}

class _DeckState extends State<Deck> {
  TextEditingController _searchController;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Column(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
            ),
           padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 20),
           child: SearchBar("Pesquisar Carta", _searchController),
          ),
          Expanded(
            child: StreamBuilder(
                stream: FirebaseFirestore.instance.collection("users").snapshots(),
                builder: (context, snapshot) {
                  if(!snapshot.hasData)
                    return Text("Sem Informações");

                  switch(snapshot.connectionState){
                    case ConnectionState.none:
                    case ConnectionState.waiting:
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    default:
                      return Container(
                        color: Colors.white,
                        child: GridView.builder(
                          padding: EdgeInsets.all(20),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 20,
                              mainAxisSpacing: 20
                          ),
                          itemCount: snapshot.data.documents.length,
                          itemBuilder: (context, index) {

                            return CardListItem(snapshot.data.documents[index]);
                          }
                      ));
                    }
                }
            ),
          )
        ],
      ),
    );
  }
}

