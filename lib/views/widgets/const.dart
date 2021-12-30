import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:titikkita/views/widgets/generalInputText.dart';



class WidgetStyle {
  static InputDecoration inputDecoration({hintText}) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      hintText: hintText,
      hintStyle: TextStyle(
        color: Colors.grey,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(10.0),
        ),
        borderSide: BorderSide.none,
      ),
    );
  }
}

const ktextTitleBlue = TextStyle(
    color: Color(0xff084A9A),
    fontSize: 11,
    fontStyle: FontStyle.normal,
    fontWeight: FontWeight.bold,
    decoration: TextDecoration.none);

const kTextValueBlack = TextStyle(
    color: Colors.black54,
    fontSize: 11,
    fontStyle: FontStyle.normal,
    fontWeight: FontWeight.bold,
    decoration: TextDecoration.none);

const kListTileTextStyle = TextStyle(color: Colors.black87, fontSize: 11.0);

const kListTileTextStyleSmaller = TextStyle(color: Colors.black54, fontSize: 11.0);

const kMapWMS = 'http://103.233.103.22:8090/geoserver/smartvillage/wms?';

const kMapLayers =  [
  // 'ortofoto',
  'foto_udara_taraju',
  'labelpadasuka',

];

const kMapRotation = InteractiveFlag.pinchZoom | InteractiveFlag.drag ;

const kIconCloseAppBar = Icon(
  Icons.highlight_off,
  color: Colors.redAccent,
  size: 30,
);

const kAppBarTextTitleStyle = TextStyle(
color: Colors.white,
fontFamily: "roboto",
fontSize: 13,
fontWeight: FontWeight.bold);


