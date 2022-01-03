import 'package:flutter/material.dart';
import 'package:titikkita/controller/cmdbuild_controller.dart';
import 'package:titikkita/util/getFamilyOnPrincipal.dart';
import 'package:titikkita/views/widgets/appBar.dart';
import 'package:titikkita/views/widgets/const.dart';
import 'package:titikkita/views/widgets/containerBuilder.dart';
import 'package:titikkita/views/widgets/loadingIndicator.dart';

class FamilyListView extends StatefulWidget {
  FamilyListView({this.data});
  final List data;

  @override
  _FamilyListViewState createState() => _FamilyListViewState();
}

class _FamilyListViewState extends State<FamilyListView> {
  List familyList = [];
  List familyListFilter = [];
  bool _isLoading = false;
  List<String> positionKeyList = [];
  List<String> itemList = [
    'Cari berdasarkan: ',
    'NKK',
    'Nama keluarga',
  ];
  String searchKey = 'kategori pencarian';
  String searchValue;
  bool isFoundData = true;
  String isNotFoundDataError;
  List foundData = [];
  bool isShowFilterResult = false;
  TextEditingController textFieldController = TextEditingController();
  int total=0;

  @override
  void initState() {
    getDefaultData();
    super.initState();
  }

  void getDefaultData() async {
    setState(() {
      _isLoading = true;
    });
    if(widget.data == null){
      var family = await getFamilyListForPrincipal(context);
      setState(() {
        familyList = family;
      });
    }else{
      setState(() {
        familyList = widget.data;
      });

    }
    setState(() {
      total = familyList.length;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarCustom.buildAppBarCustom(
          context: context, title: 'Daftar Nama Keluarga'),
      body: _isLoading
          ? Center(child: LoadingIndicator.containerSquareLoadingIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
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
                                color: Colors.black54),
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
                          child: TextField(
                            keyboardType: searchKey == 'Nama keluarga'
                                ? TextInputType.text
                                : TextInputType.number,
                            controller: textFieldController,
                            obscureText: false,
                            decoration: InputDecoration(
                                suffixIcon: Icon(Icons.search, size: 20),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.blue, width: 2.0)),
                                hintText: 'Masukkan $searchKey',
                                hintStyle: TextStyle(fontSize: 11.0, height: 4),
                                // errorText: isValidate ? validation : validationException,
                                errorStyle: TextStyle(fontSize: 11),
                                fillColor: Colors.red,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(4),
                                    borderSide:
                                        BorderSide(color: Colors.white))),
                            onSubmitted: (val) async {
                              if(val == ''){
                                setState(() {
                                  isShowFilterResult = false;
                                });
                              }else{
                                if (searchKey == itemList[0] ||
                                    searchKey == 'kategori pencarian') {
                                  setState(() {
                                    isFoundData = false;
                                    isNotFoundDataError =
                                    'Silahkan pilih kategori pencarian terlebih dahulu.';
                                  });
                                } else {
                                  var key = searchKey == 'Nama keluarga'
                                      ? 'Description'
                                      : 'Code';
                                  await CmdbuildController.findCardWith2Filter(
                                      context: context,
                                      cardName: 'app_family',
                                      filter: 'contain',
                                      key: ['_tenant',key],
                                      value: [familyList[0]['_tenant'],val]).then((value){

                                    if(value['data'].length == 0){
                                      setState(() {
                                        isFoundData = false;
                                        isNotFoundDataError =
                                        'Data tidak ditemukan.';
                                      });
                                    }else {
                                      setState(() {
                                        familyListFilter = value['data'];
                                        total = familyListFilter.length;
                                        isShowFilterResult = true;
                                        isFoundData = true;
                                        isNotFoundDataError = '';
                                      });
                                    }
                                  });
                                }
                              }
                            },
                            onChanged: (val) async {
                              setState(() {
                                isShowFilterResult = false;
                                searchValue = val;
                                if(val == ''){

                                    isShowFilterResult = false;

                                }
                              });
                            },
                            style: TextStyle(
                                fontFamily: 'roboto',
                                fontSize: 15,
                                color: Colors.black54),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top: 10, left: 10),
                  child: Text(
                    'Total Keluarga : $total',
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
                    : Expanded(
                        child: ListView.builder(
                          itemBuilder: (context, index) {
                            return ContainerBuilder.buildContainerListFamily(
                              data: isShowFilterResult
                                  ? familyListFilter[index]
                                  : familyList[index],
                              context: context,
                            );
                          },
                          itemCount: isShowFilterResult
                              ? familyListFilter.length
                              : familyList.length,
                        ),
                      ),
                !isFoundData && searchValue.length == 0 ?
                Expanded(
                  child: ListView.builder(
                    itemBuilder: (context, index) {
                      return ContainerBuilder.buildContainerListFamily(
                        data: isShowFilterResult
                            ? familyListFilter[index]
                            : familyList[index],
                        context: context,
                      );
                    },
                    itemCount: isShowFilterResult
                        ? familyListFilter.length
                        : familyList.length,
                  ),
                ) : Container()
              ],
            ),
    );
  }
}
