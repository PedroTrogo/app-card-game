import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchBar extends StatelessWidget {
  String _placeholder = "";
  TextEditingController _controller;
  SearchBar(this._placeholder, this._controller);

  @override
  Widget build(BuildContext context) {

    return Container(
        height: 50,
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.symmetric(horizontal: 5),
        alignment: Alignment(0.0, 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(
              Radius.circular(50.0)
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(.5),
              spreadRadius: 1,
              blurRadius: 3,
              offset: Offset(-2, 2), // changes position of shadow
            ),
          ],
        ),
        child: TextField(
          controller: _controller,
          textAlignVertical: TextAlignVertical.center,
          decoration: InputDecoration(
              hintStyle: TextStyle(height: 0),
              border: InputBorder.none,
              hintText: _placeholder,
              prefixIcon: Icon(Icons.search),
              suffixIcon: IconButton(
                onPressed: () => _controller.clear(),
                icon: Icon(Icons.clear),
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                iconSize: 20,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius:BorderRadius.circular(50),
                borderSide: BorderSide(color: Colors.white, width: 3.0))
        ),
      )
    );
  }
}
