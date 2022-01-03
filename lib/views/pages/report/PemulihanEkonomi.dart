import 'package:flutter/material.dart';
import 'package:titikkita/controller/cmdbuild_controller.dart';
import 'package:titikkita/state/indivivual_provider.dart';
import 'package:titikkita/state/local_provider.dart';
import 'package:titikkita/util/getFamilyData.dart';
import 'package:titikkita/views/widgets/appBar.dart';
import 'package:titikkita/views/widgets/bottomNavigation.dart';
import 'package:titikkita/views/widgets/const.dart';
import 'package:titikkita/views/widgets/loadingIndicator.dart';
import 'package:provider/provider.dart' as provider;
import 'package:titikkita/views/widgets/popupNotif.dart';

class PemulihanEkonomi extends StatefulWidget {
  const PemulihanEkonomi();

  @override
  _PemulihanEkonomiState createState() => _PemulihanEkonomiState();
}

class _PemulihanEkonomiState extends State<PemulihanEkonomi> {
  bool _isLoading = false;
  bool isChecked = false;
  List familyMembers = [];
  List economyIssuesLookup = [];
  Map <String, dynamic> familyMembersChecked = {};
  List <dynamic> issueMembersList =[];

  void initState() {
    getLookup();
    defaultData();
    super.initState();
  }

  void defaultData() {
      fetchFamilyMember();
  }

  void fetchFamilyMember() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await fetchingDataFamilyMembers(context).then((value) {
        setState(() {
          familyMembers =
          provider.Provider.of<LocalProvider>(context, listen: false)
              .members['familyMembers'];
          for(var i=0; i<familyMembers.length;i++){
            familyMembersChecked["${familyMembers[i]['_id']}"]= {
              'isEconomyIssue': false,
              'type':{}
            };
            for(var j=0; j<economyIssuesLookup.length;j++){
              familyMembersChecked["${familyMembers[i]['_id']}"]['type']["${economyIssuesLookup[j]['_id']}"] = false;
            }

          }
          _isLoading = false;
        });
        print(familyMembersChecked);
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Erroer: $e');
      ShowPopupNotification.errorNotification(
          context: context,
          content: 'Terjadi error. Coba lagi nanti!',
          action: () {
            Navigator.of(context, rootNavigator: true).pop();
          });
    }

  }

  void getLookup()async{
    await CmdbuildController.getOneLookup('IsuPemulihanEkonomi', context).then((value){
      setState(() {
        economyIssuesLookup = value['data'];
      });
    });
  }

  void onSubmit(){
    familyMembersChecked.forEach((key, value) {
      if(value['isEconomyIssue']){
        value['type'].forEach((key2,value){
          if(value){
            issueMembersList.add({'memberId':key, 'lookupId':key2});
          }
        });

      }
    });
    issueMembersList.forEach((el) async{
      var dataToAdd = {
        'IsuPemulihanEkonomi': el['lookupId']
      };
      var cardId = el['memberId'];
      await CmdbuildController.commitEditCardById(cardId, dataToAdd, 'app_citizen', context).then((value){
        ScaffoldMessenger.of(context).showSnackBar(
            ShowPopupNotification.showSnackBar(content: 'Laporan terkirim'));
        Navigator.pop(context);
      }).catchError((e){
        print('Erroer: $e');
        ShowPopupNotification.errorNotification(
            context: context,
            content: 'Terjadi error. Coba lagi nanti!',
            action: () {
              Navigator.of(context, rootNavigator: true).pop();
            });
      });
    });

  }

  @override
  Widget build(BuildContext context) {

    final individualProvider =
        provider.Provider.of<IndividualProvider>(context, listen: false);
    final constraintData =
        provider.Provider.of<LocalProvider>(context, listen: false)
            .principalConstraint['data'][0];
    final localProvider =
        provider.Provider.of<LocalProvider>(context, listen: false);

    return Scaffold(
        appBar: AppBarCustom.buildAppBarCustom(
            title: 'Pemulihan Ekonomi', context: context),
        body: _isLoading == true
            ? Center(
                child: LoadingIndicator.containerSquareLoadingIndicator(),
              )
            : Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.0),
          child: Container(
              child: !individualProvider.isIndividualLogin
                  ? ListView(
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Anggota keluarga yang terdampak isu ekonomi:',
                    style: ktextTitleBlue,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Column(
                    children: familyMembers.map((e) {
                      return Column(
                        children: [
                          ListTile(
                            title: Text('${e['Description']}'),
                            dense: true,
                            trailing: Checkbox(
                              checkColor: Colors.white,
                              value: familyMembersChecked["${e['_id']}"]['isEconomyIssue'],
                              onChanged: (value) {
                                setState(() {
                                  familyMembersChecked["${e['_id']}"]['isEconomyIssue'] = value;
                                });
                              },
                            ),
                          ),
                          familyMembersChecked["${e['_id']}"]['isEconomyIssue'] ?
                          Column(
                            children:economyIssuesLookup.map((el){
                              return  ListTile(
                                title: Text('${el['description']}'),
                                dense: true,
                                leading: Checkbox(
                                  checkColor: Colors.white,
                                  value:familyMembersChecked["${e['_id']}"]['type']["${el['_id']}"],
                                  onChanged: (value) {
                                    setState(() {
                                      familyMembersChecked["${e['_id']}"]['type']["${el['_id']}"] = value;
                                    });
                                  },
                                ),
                              );
                            }).toList() ,
                          ) : Container()
                        ],
                      );
                    }).toList(),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 80),
                    color: Colors.blue[900],
                    child: TextButton(
                      style: TextButton.styleFrom(
                        primary: Colors.white,
                        textStyle: const TextStyle(
                            fontSize: 15, color: Colors.white),
                      ),
                      onPressed: onSubmit,
                      child: const Text('Simpan'),
                    ),
                  ),
                ],
              )
                  : Container(
                child: ListView(
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      'Anggota keluarga yang terdampak isu ekonomi: ',
                      style: ktextTitleBlue,
                    ),
                    ListTile(
                      title:
                      Text('${constraintData['Description']}'),
                      dense: true,
                      trailing: Checkbox(
                        checkColor: Colors.white,
                        value: isChecked,
                        onChanged: (value) {
                          setState(() {
                            isChecked = value;
                          });
                        },
                      ),
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 80),
                      color: Colors.blue[900],
                      child: TextButton(
                        style: TextButton.styleFrom(
                          primary: Colors.white,
                          textStyle: const TextStyle(
                              fontSize: 15, color: Colors.white),
                        ),
                        onPressed: onSubmit,
                        child: const Text('Simpan'),
                      ),
                    ),
                  ],
                ),
              )),
        ));
  }
}
