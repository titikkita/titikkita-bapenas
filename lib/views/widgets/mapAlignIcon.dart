import 'package:flutter/material.dart';

class MapAlignIcon {
  static Align mapAlignIcon({top, left, right, color, icon, action}) {
    return Align(
      alignment: Alignment.topLeft,
      child: GestureDetector(
        onTap: (){
          action();
        },
        child: Container(
          // color: Colors.white,
          margin: EdgeInsets.only(top: top, left: left, right: right),
          padding: EdgeInsets.all(3),
          decoration: BoxDecoration(
              color: Colors.white70,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(width: 1)),
          child: icon,
        ),
      ),
    );
  }
}
