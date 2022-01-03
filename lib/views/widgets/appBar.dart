import 'package:flutter/material.dart';
import 'package:titikkita/views/widgets/const.dart';

class AppBarCustom {
  static buildAppBarCustom({title, context, iconAction, action, icon}) {
    return AppBar(
        centerTitle: false,
        backgroundColor: Color(0xff084A9A),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "$title",
          style: kAppBarTextTitleStyle
        ),
        actions: iconAction == true ? <Widget>[icon] : <Widget>[]);
  }

  static buildAppBarNoNavigation({title, context, iconAction, action, icon}) {
    return AppBar(
        centerTitle: true,
        backgroundColor: Color(0xff084A9A),
        leading: Container(),
        title: Text(
          "$title",
          style: TextStyle(
              color: Colors.white,
              fontFamily: "roboto",
              fontSize: 14,
              fontWeight: FontWeight.bold),
        ),
        actions: iconAction == true ? <Widget>[icon] : <Widget>[]);
  }
}
