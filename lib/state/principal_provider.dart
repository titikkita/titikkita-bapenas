import 'package:flutter/material.dart';

class PrincipalProvider extends ChangeNotifier{
  Map <String, List> members = {};
  List citizen = [];
  List nonCitizen = [];
  List family = [];
  List allCitizen= [];
  void updateMembers(key,data){
    members[key] = data;
    notifyListeners();
  }
  void updateCitizen(data){
    citizen = data;
    notifyListeners();
  }
  void updateNonCitizen(data){
    nonCitizen = data;
    notifyListeners();
  }
  void updateFamily(data){
    family = data;
    notifyListeners();
  }

  void updateAllCitizen(data){
    allCitizen = data;
    notifyListeners();
  }
}