import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class LocalProvider extends ChangeNotifier {
  dynamic familyData;
  dynamic address;
  Map <String, List> members={};
  List <String> familyList = [];
  List <DropdownMenuItem> familyListDropdown = [];
  Map<String, List> report={};
  Map<String, List> information={};
  Map <String, List> lookupData={};
  Map <String, dynamic> lookupDataDetail={};
  Map <String, List<DropdownMenuItem>> lookupDataDropdown={};
  List<dynamic> neighborData = [];
  List<dynamic> otherAreaList = [];
  List<dynamic> comodityPoints = [];
  List <dynamic> faqList = [];
  dynamic infoLocationPoint;
  String infoLocationAddress;
  Map<String,List> attachments = {};
  String token;
  Map<String, List> principalInformationData={};
  List <dynamic> familyListDetails = [];
 dynamic principalConstraint = {};
Map <String,List> multiSelectItem= {};
  Map<String, List<DropdownMenuItem>> lookupPerson = {};
  Map<String, List<DropdownMenuItem>> lookupFamily = {};

  Future<void> updateFamilyData(data) async {
    familyData = data;
    notifyListeners();
  }

  void updateAddressData(data) {
    address = data;
    notifyListeners();
  }

  void updateMembers(member,nonMember) {
    members['familyMembers']= member['data'];
    members['familyNonMembers']= nonMember['data'];
    notifyListeners();
  }


  Future <void> updateLocalMemberData(data, index) {
    members['familyMembers'][index]= data;
    notifyListeners();
  }

  void addNewMemberInLocalState(data) {
    members['familyMembers'].add(data);
    notifyListeners();
  }

  void updatePrincipalConstraint(data){
    principalConstraint = data;
    notifyListeners();
  }

  Future<void> updateReportList(data, cardName) async {
    report['$cardName']= data['data'];
    notifyListeners();
  }

  void addReportListInLocal(data, cardName) {
    if(report[cardName]== null){
      report['$cardName'] = [];
    }
    report['$cardName'].insert(0, data);
    notifyListeners();
  }

  Future<void> updatePublicInformationData(data) async {
    information['publicInformationList'] = data['data'];
    notifyListeners();
  }


  Future<void> updatePersonalInformationData(data) async {
    information['privateInformationList'] = data['data'];
    notifyListeners();
  }

  void updateLookupPerson(data){
    lookupPerson = data;
    notifyListeners();
  }

  void updateLookupFamily(data){
    lookupFamily = data;
    notifyListeners();
  }

  void updateLookupData(data,lookupType) {
    switch(lookupType){
      case "memberLookup":
        lookupDataDetail['citizenLookupData'] = data;
        break;
      case "comodityLookup":
        lookupDataDetail['comodityLookupData'] = data;
        break;
      case "addressLookup":
        lookupDataDetail['addressLookupData'] = data;
        break;
      case "orientationLookup":
        lookupDataDetail['orientationLookupData'] = data;
        break;
    }

    data.forEach((key,value){
      lookupData['$key'] = [];
      value['data'].forEach((x) {
        lookupData['$key'].add(x['code']);
      });
      // lookupData['$key'].insert(0, 'Pilih salah satu');
    });
    notifyListeners();
  }
  void updateLookupDataLocal(key,value){
    lookupData[key]=[];
    lookupData[key]=value;
    notifyListeners();
  }

  void updateNeighborLocation(data) {
    neighborData.add(data);
    notifyListeners();
  }

  void updateInfoLocationPoint(data) {
    infoLocationPoint = data;
    notifyListeners();
  }

  void updateInfoLocationAddress(data) {
    infoLocationAddress = data;
    notifyListeners();
  }

  void updateOneReporList(index, data, cardName) {
    report['$cardName'][index] = data;
    notifyListeners();
  }

  void emptyNeighborLocation() {
    neighborData = [];
    notifyListeners();
  }

  void updateOtherAreaList(data) {
    otherAreaList.add(data);
    notifyListeners();
  }

  void updateComodityPoints(data) {
    comodityPoints.add(data);
    notifyListeners();
  }

  void emptyComodityPoints() {
    comodityPoints = [];
    notifyListeners();
  }

  void emptyOtherAreaList() {
    otherAreaList = [];
    notifyListeners();
  }

  void updateFamilyList(dynamic data) {
    // for (var i in value.keys) {
    //   lookupData['$i'] = [];
    //   for (var j = 0; j < value['$i']['data'].length; j++) {
    //     lookupData['$i'].add(DropdownMenuItem(
    //       child: Text('${value[i]['data'][j]['description']}'),
    //       value: value[i]['data'][j],
    //     ));
    //   }
    // }
    data['data'].forEach((e){
      print(e);
      familyListDropdown.add(DropdownMenuItem(
        child: Text('${e['Description']}, ${e['_RT_description']}-${e['_RW_description']}'),
        value: e,
      ));
    });
    notifyListeners();
  }

  void updateFamilyListDetails(dynamic data) {
      familyListDetails = data['data'];
    notifyListeners();
  }

  void updateFAQ(List <String> data) {
    familyList = data;
    notifyListeners();
  }

  void updateAttachment(key,value){
    attachments[key] = value;
    notifyListeners();
  }

  void deleteMember(key,index){
    members['$key'].removeAt(index);
    notifyListeners();
  }

  Future <void> updateAdminToken(value)async{
    token= value;
    notifyListeners();
  }

  void updatePrincipalInformationData(key,data){
    principalInformationData[key] = data;
    notifyListeners();
  }
}
