import 'package:flutter/material.dart';
import 'package:titikkita/controller/cmdbuild_controller.dart';
import 'package:titikkita/state/local_provider.dart';
import 'package:titikkita/state/principal_provider.dart';
import 'package:titikkita/util/navigation.dart';
import 'package:titikkita/views/pages/family_member/MemberDetails.dart';
import 'package:titikkita/views/widgets/appBar.dart';
import 'package:provider/provider.dart' as provider;
import 'package:titikkita/views/widgets/const.dart';
import 'package:titikkita/views/widgets/containerBuilder.dart';
import 'package:titikkita/views/widgets/loadingIndicator.dart';

class CitizenListView extends StatefulWidget {
  CitizenListView({this.data});

  final List data;

  @override
  _CitizenListViewState createState() => _CitizenListViewState();
}

class _CitizenListViewState extends State<CitizenListView> {
  bool _isLoading = false;
  List<dynamic> foundData = [];
  List<dynamic> displayData = [];
  List<String> itemList = [
    'Cari berdasarkan: ',
    'NKK',
    'NIK',
    'Nama lengkap',
  ];
  String searchKey = 'kategori pencarian';
  String searchValue;
  TextEditingController textFieldController = TextEditingController();
  bool isFoundData = true;
  String isNotFoundDataError = '';
  dynamic userData;
  List<dynamic> familyName = [];
  List<dynamic> familyNameToDisplay = [];
  String key;

  @override
  void initState() {
    getDefaultData();
    super.initState();
  }

  void getDefaultData() async {
    print("=====");
    print(widget.data );
    setState(() {
      _isLoading = true;
    });
    userData = provider.Provider.of<LocalProvider>(context, listen: false)
        .principalConstraint['data'][0];
    var principalState =
        provider.Provider.of<PrincipalProvider>(context, listen: false);
    var result;
    // if(principalState.allCitizen.length == 0){
    //   if (userData['_Jabatan_code'] == 'Ketua RT') {
    //     key = 'RT';
    //     await CmdbuildController.findCardWithSomeFilter(
    //         context: context,
    //         cardName: 'app_citizen',
    //         filter: 'equal',
    //         key: ['RT', 'RW', '_tenant'],
    //         value: [userData['RT'], userData['RW'], userData['Desa']])
    //         .then((value) {
    //           result = value;
    //     });
    //   }
    //   if (userData['_Jabatan_code'] == 'Ketua RW') {
    //     key = 'RW';
    //     await CmdbuildController.findCardWith2Filter(
    //         context: context,
    //         cardName: 'app_citizen',
    //         key: ['RW', '_tenant'],
    //         value: [userData['RW'], userData['Desa']]).then((value) {
    //       result = value;
    //
    //     });
    //   }
    //   if (userData['_Jabatan_code'] == 'Kepala Desa') {
    //     key = '_tenant';
    //     await CmdbuildController.findCardWithFilter(
    //         context: context,
    //         cardName: 'app_citizen',
    //         key: '_tenant',
    //         filter: 'equal',
    //         value: userData['Desa']).then((value) {
    //       result = value;
    //     });
    //   }
    //   if (userData['_Jabatan_code'] == 'Ketua Dusun') {
    //     key = 'Dusun';
    //     await CmdbuildController.findCardWithFilter(
    //         context: context,
    //         cardName: 'app_citizen',
    //         key: 'Dusun',
    //         filter: 'equal',
    //         value: userData['Dusun']).then((value) {
    //       result = value;
    //     });
    //   }
    //
    //   provider.Provider.of<PrincipalProvider>(context,listen: false).updateAllCitizen(result['data']);
    //   var local = [];
    //   var nonLocal = [];
    //   result['data'].forEach((e){
    //     if(e['_type'] == 'app_localcitizen'){
    //       local.add(e);
    //     }else{
    //       nonLocal.add(e);
    //     }
    //   });
    //
    //   provider.Provider.of<PrincipalProvider>(context,listen: false).updateCitizen(local);
    //   provider.Provider.of<PrincipalProvider>(context,listen: false).updateNonCitizen(nonLocal);
    //   setState(() {
    //     foundData = result['data'];
    //     displayData = result['data'];
    //   });
    // }else{
    //   setState(() {
    //     foundData = principalState.allCitizen;
    //     displayData =  principalState.allCitizen;
    //   });
    // }
    if(widget.data == null){
      await CmdbuildController
          .findCardWith2Filter(
          context: context,
          cardName: 'app_citizen',
          filter: 'equal',
          key: [
            'RW',
            'RT'
          ],
          value: [
            userData['RW'],
            userData['RT']
          ]).then((value) {
            setState(() {
              foundData = value['data'];
              displayData = value['data'];
            });
      });
    }else{
      setState(() {
        foundData = widget.data;
        displayData = widget.data;
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  void getAllFamilyList() async {
    var key = searchKey == 'Nama lengkap'
        ? 'Description'
        : searchKey == 'NIK'
            ? 'Code'
            : 'Code';

    if (searchKey == 'NIK') {
      var data = displayData.where((element) {
        return element[key].toLowerCase().contains(searchValue.toLowerCase()) &&
            element['_type'] == 'app_nonlocalcitizen';
      }).toList();
      setState(() {
        foundData = data;
        isFoundData = true;
      });
    } else if (searchKey == 'NKK') {
      var data = displayData.where((element) {
        return element[key].toLowerCase().contains(searchValue.toLowerCase()) &&
            element['_type'] == 'app_localcitizen';
      }).toList();
      setState(() {
        foundData = data;
        isFoundData = true;
      });
    } else {
      var data = displayData.where((element) {
        return element[key].toLowerCase().contains(searchValue.toLowerCase());
      }).toList();
      setState(() {
        foundData = data;
        isFoundData = true;
      });
    }

    if (foundData.length == 0) {
      setState(() {
        isFoundData = false;
        isNotFoundDataError = 'Data tidak ditemukan.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBarCustom.buildAppBarCustom(
            title: 'Pencarian Nama Warga', context: context),
        body: _isLoading
            ? Center(child: LoadingIndicator.containerSquareLoadingIndicator())
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 5.0),
                          width: MediaQuery.of(context).size.width / 3.1,
                          height: 40,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.black38)),
                          child: Padding(
                            padding: EdgeInsets.only(left: 8.0),
                            child: DropdownButtonFormField<String>(
                              decoration: InputDecoration.collapsed(
                                  hintText: '',
                                  hintStyle:
                                      TextStyle(fontSize: 11.0, height: 2)),
                              value: itemList[0],
                              isExpanded: true,
                              style: TextStyle(
                                fontFamily: 'roboto',
                                fontSize: 11,
                                color: Colors.black54,
                              ),
                              items: itemList != null
                                  ? itemList
                                      .map<DropdownMenuItem<String>>((value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Center(
                                          child: Text(
                                            value,
                                          ),
                                        ),
                                      );
                                    }).toList()
                                  : null,
                              onChanged: (val) {
                                setState(() {
                                  foundData = [];
                                  textFieldController.text = '';
                                  if (val != 'Cari berdasarkan: ') {
                                    searchKey = val;
                                  } else {
                                    searchKey = 'kategori pencarian.';
                                  }
                                  searchValue = '';
                                });
                                // actionDropdown(key, val);
                              },
                            ),
                          ),
                        ),
                        SizedBox(width: 5.0),
                        Expanded(
                          child: Container(
                            height: 40.0,
                            margin: EdgeInsets.only(top: 5.0),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: TextField(
                                keyboardType: searchKey == 'Nama lengkap'
                                    ? TextInputType.text
                                    : TextInputType.number,
                                controller: textFieldController,
                                obscureText: false,
                                decoration: InputDecoration(
                                    prefixIcon: Icon(
                                      Icons.search,
                                      size: 20,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.blue, width: 2.0)),
                                    hintText: 'Masukkan $searchKey',
                                    hintStyle:
                                        TextStyle(fontSize: 11.0, height: 4),
                                    // errorText: isValidate ? validation : validationException,
                                    errorStyle: TextStyle(fontSize: 11),
                                    fillColor: Colors.red,
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(4),
                                        borderSide:
                                            BorderSide(color: Colors.white))),
                                onSubmitted: (val) async {
                                  if(val != ''){
                                    if (searchKey == itemList[0] ||
                                        searchKey == 'kategori pencarian') {
                                      setState(() {
                                        isFoundData = false;
                                        isNotFoundDataError =
                                        'Silahkan pilih kategori pencarian terlebih dahulu.';
                                      });
                                    } else {
                                      var key = searchKey == 'Nama lengkap'
                                          ? 'Description'
                                          : searchKey == 'NIK'
                                          ? 'Code'
                                          : 'Keluarga';

                                      if (searchKey == 'NKK') {
                                        await CmdbuildController
                                            .findCardWithFilter(
                                            context: context,
                                            cardName: 'app_family',
                                            filter: 'contain',
                                            key: 'Code',
                                            value: val)
                                            .then((data) async{
                                          await CmdbuildController
                                              .findCardWith2Filter(
                                              context: context,
                                              cardName: 'app_citizen',
                                              filter: 'equal',
                                              key: [
                                                '_tenant',
                                                'Keluarga'
                                              ],
                                              value: [
                                                displayData[0]['_tenant'],
                                                data['data'][0]['_id']
                                              ]).then((value) {

                                            if (value['data'].length == 0) {
                                              setState(() {
                                                isFoundData = false;
                                                isNotFoundDataError =
                                                'Data tidak ditemukan.';
                                              });
                                            } else {
                                              setState(() {
                                                foundData = value['data'];
                                                isFoundData = true;
                                              });
                                            }
                                          });
                                        });
                                      }else{
                                        await CmdbuildController
                                            .findCardWith2Filter(
                                            context: context,
                                            cardName: 'app_citizen',
                                            filter: 'contain',
                                            key: [
                                              '_tenant',
                                              key
                                            ],
                                            value: [
                                              displayData[0]['_tenant'],
                                              val
                                            ]).then((value) {
                                          if (value['data'].length == 0) {
                                            setState(() {
                                              isFoundData = false;
                                              isNotFoundDataError =
                                              'Data tidak ditemukan.';
                                            });
                                          } else {
                                            setState(() {
                                              foundData = value['data'];
                                              isFoundData = true;
                                            });
                                          }
                                        });
                                      }
                                    }
                                  }else{
                                    setState(() {
                                      foundData = displayData;
                                    });
                                  }
                                },
                                onChanged: (val) async {
                                  setState(() {
                                    searchValue = val;
                                    if(val == ''){
                                      foundData = displayData;
                                    }
                                  });
                                },
                                style: TextStyle(
                                    fontFamily: 'roboto',
                                    fontSize: 11,
                                    color: Colors.black54),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 20),
                      child: Text(
                        'Total Penduduk : ${foundData.length}',
                        style: kTextValueBlack,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    !isFoundData && searchValue.length != 0
                        ? Center(
                            child: Text(
                              '$isNotFoundDataError',
                              style: kTextValueBlack,
                            ),
                          )
                        : SingleChildScrollView(
                            child: Container(
                              height: MediaQuery.of(context).size.height / 1.4,
                              child: ListView.builder(
                                controller: ScrollController(),
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  return ContainerBuilder
                                      .buildContainerPersonDetail(
                                    context: context,
                                    fullName: foundData[index]['Description'],
                                    gender: foundData[index]
                                        ['_JenisKelamin_code'],
                                    personalId: foundData[index]['Code'],
                                    placeOfBirth: foundData[index]
                                        ['TempatLahir'],
                                    action: () {
                                      goToPage(
                                          context,
                                          PersonDetailsView(
                                            dataPerson: foundData[index],
                                            memberIndex: index,
                                            cardName: foundData[index]['_type'],
                                            isPrincipal: true,
                                            isFromSearch: true,
                                          ));
                                    },
                                  );
                                },
                                itemCount: foundData.length,
                              ),
                            ),
                          ),
                    !isFoundData && searchValue.length == 0 ?
                    SingleChildScrollView(
                      child: Container(
                        height: MediaQuery.of(context).size.height / 1.4,
                        child: ListView.builder(
                          controller: ScrollController(),
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return ContainerBuilder
                                .buildContainerPersonDetail(
                              context: context,
                              fullName: displayData[index]['Description'],
                              gender: displayData[index]
                              ['_JenisKelamin_code'],
                              personalId: displayData[index]['Code'],
                              placeOfBirth: displayData[index]
                              ['TempatLahir'],
                              action: () {
                                goToPage(
                                    context,
                                    PersonDetailsView(
                                      dataPerson: displayData[index],
                                      memberIndex: index,
                                      cardName: displayData[index]['_type'],
                                      isPrincipal: true,
                                      isFromSearch: true,
                                    ));
                              },
                            );
                          },
                          itemCount: displayData.length,
                        ),
                      ),
                    ) :
                    Container(
                    )
                  ],
                ),
              ));
  }
}
