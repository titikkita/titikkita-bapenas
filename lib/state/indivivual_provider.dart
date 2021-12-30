import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class IndividualProvider extends ChangeNotifier {
  dynamic individualData;
  bool isIndividualLogin = false;
  dynamic individualLocation;
  List polygonPoints=[];
  Map<String,List> attachments = {};

  void updateIsIndividualLogin() {
    isIndividualLogin = true;
    notifyListeners();
  }

  void updateIndividualData(data) {
    individualData = data;
    notifyListeners();
  }

  void updateIndividualLocation(data){
    individualLocation = data;
    notifyListeners();
  }
  void updatePolygonPoints(data) {
    polygonPoints.add(data);
    notifyListeners();
  }
  void updateAttachment(key,value){
    attachments[key] = value;
    notifyListeners();
  }

}
