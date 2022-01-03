import 'package:flutter/material.dart';
import 'package:titikkita/util/getComodityData.dart';
import 'package:titikkita/views/pages/family_data/Comodity.dart';
import 'package:titikkita/views/widgets/appBar.dart';
import 'package:titikkita/views/widgets/bottomNavigation.dart';
import 'package:titikkita/views/widgets/generalInputText.dart';
import 'package:titikkita/views/widgets/loadingIndicator.dart';
import 'package:titikkita/views/widgets/popupNotif.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:provider/provider.dart' as provider;
import 'package:titikkita/state/local_provider.dart';
import 'package:intl/intl.dart';
import 'package:titikkita/controller/cmdbuild_controller.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';

class AddNewCommodity extends StatefulWidget {
  AddNewCommodity();

  @override
  _AddNewCommodityState createState() => _AddNewCommodityState();
}

class _AddNewCommodityState extends State<AddNewCommodity> {
  List<Asset> images = <Asset>[];
  dynamic selectedCommodity;
  String reportTitle;
  List<DropdownMenuItem> commodities = [];
  List<DropdownMenuItem> subCommodities = [];
  List photos = [];
  dynamic dataEdit;
  bool isLoading = false;
  String subCommodityLookup;
  String subCommodity;
  bool isShow = false;
  dynamic newCommodity = {
    "Code": '',
    "Description": '',
    "JenisKomoditi": 0,
    "SubKomoditi": "",
    "Jumlah": 0,
    "PerkiraanWaktuPanen": 0,
    "LuasArea": 0,
    "HargaJual": 0,
    "UserID": 0,
    "JumlahProduksi": '0'
  };

  void initState() {
    defaultData();
    super.initState();
  }

  void defaultData() async {
    isLoading = true;
    await CmdbuildController.getOneLookup('JenisKomoditi', context)
        .then((value) {
      for(var i=0;i<value['data'].length;i++){
        commodities.add(DropdownMenuItem(
          child: Text('${value['data'][i]['description']}'),
          value: value['data'][i],
        ));
      }
      setState(() {
        isLoading = false;
      });
    });
  }

  dateFormat() {
    var now = new DateTime.now();
    var formatter = new DateFormat('yyyy-MM-dd');
    String formattedDate = formatter.format(now);
    return formattedDate;
  }

  void deleteImageFromList(index) {
    setState(() {
      images.removeAt(index);
    });
  }

  void onSubmitAddOne() async {
    setState(() {
      var user = provider.Provider.of<LocalProvider>(context, listen: false)
          .principalConstraint['data'][0];
      isLoading = true;
      newCommodity["UserID"] = user['_id'];
      newCommodity['Code'] = user['Code'];
      newCommodity['Description'] = user['Description'];
    });

    await CmdbuildController.commitAddNewCard(
            newCommodity, 'app_comodity', context)
        .then((value) async {
          print(value);
      await getComodityData(context).then((value) {
        ScaffoldMessenger.of(context).showSnackBar(
            ShowPopupNotification.showSnackBar(
                content: 'Komoditas berhasil ditambahkan'));
      });
    }).catchError((e) {
      ShowPopupNotification.errorNotification(
          context: context,
          content: 'Terjadi error. Coba lagi nanti!',
          action: () {
            Navigator.pop(context);
          });
    });
    setState(() {
      isLoading = false;
    });
    Navigator.pop(context);
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (BuildContext context) => CommodityView()));
  }

  void onChangedValue(item, value, lookupName) {
    setState(() {
      if(item == 'Jumlah' || item == 'LuasArea' || item == 'JumlahProduksi'){
        value = value.replaceAll(',','.');
      }
      newCommodity[item] = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBarCustom.buildAppBarCustom(
          title: 'Tambah Komoditas', context: context),
      body: isLoading
          ? Center(
              child: LoadingIndicator.containerSquareLoadingIndicator(),
            )
          : SingleChildScrollView(
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SingleChildScrollView(
                      child: Container(
                        height: 850,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 20),
                                child: Column(
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.only(top: 10),
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              2.8,
                                          child: Text(
                                            'Jenis Komoditi',
                                            style: TextStyle(
                                                color: Color(0xff084A9A),
                                                fontFamily: "roboto",
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Container(
                                          height: 70,
                                          width: 235,
                                          // padding: EdgeInsets.symmetric(horizontal: 0),
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Colors.black45,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(5.0)),
                                          child: SearchableDropdown.single(
                                            items: commodities,
                                            onChanged: (value) async {
                                              setState(() {
                                                isShow = false;
                                                subCommodities = [];
                                                newCommodity[
                                                '_JenisKomoditi_code'] =
                                                value['_id'];
                                                newCommodity[
                                                'JenisKomoditi'] =
                                                value['description'];
                                              });
                                              subCommodityLookup =
                                                  value['code'].replaceAll(
                                                      RegExp(r"\s+"), "");
                                              await CmdbuildController
                                                  .getOneLookup(
                                                  subCommodityLookup,
                                                  context)
                                                  .then((value) {
                                                setState(() {
                                                  value['data'].forEach((el) {
                                                    subCommodities
                                                        .add(DropdownMenuItem(
                                                      child: Text(
                                                          '${el['description']}'),
                                                      value: el,
                                                    ));
                                                  });
                                                  isShow = true;

                                                });
                                              });
                                            },
                                            value: commodities[0],
                                            isExpanded: true,
                                            style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.black),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10,),
                                    isShow
                                        ? Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                padding:
                                                    EdgeInsets.only(top: 10),
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    2.8,
                                                child: Text(
                                                  'Sub Komoditi',
                                                  style: TextStyle(
                                                      color: Color(0xff084A9A),
                                                      fontFamily: "roboto",
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                              Container(
                                                height: 70,
                                                width: 225,
                                                // padding: EdgeInsets.symmetric(horizontal: 0),
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                      color: Colors.black45,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5.0)),
                                                child:
                                                    SearchableDropdown.single(
                                                  items: subCommodities,
                                                  onChanged: (value)async {
                                                    setState(() {
                                                      newCommodity['SubKomoditi'] = value['description'];
                                                    });

                                                  },
                                                  value: subCommodities[0],
                                                  isExpanded: true,
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      color: Colors.black),
                                                ),
                                              ),
                                            ],
                                          )
                                        : Container(),
                                    SizedBox(
                                      height: 70,
                                      child: InputTextForm
                                          .buildContainerInputHorizontal(
                                        keyboardTypeDate: false,
                                        keyboardType: TextInputType.number,
                                        buildContext: context,
                                        title: 'Jumlah (Pohon/Ekor)',
                                        isDropdownList: false,
                                        onChangedAction: onChangedValue,
                                        key: 'Jumlah',
                                      ),
                                    ),
                                    SizedBox(
                                      height: 70,
                                      child: InputTextForm
                                          .buildContainerInputHorizontal(
                                        keyboardTypeDate: false,
                                        buildContext: context,
                                        keyboardType: TextInputType.number,
                                        title: 'Luas (m2)',
                                        isDropdownList: false,
                                        onChangedAction: onChangedValue,
                                        key: 'LuasArea',
                                      ),
                                    ),
                                    SizedBox(
                                      height: 70,
                                      child: InputTextForm
                                          .buildContainerInputHorizontal(
                                        keyboardTypeDate: false,
                                        buildContext: context,
                                        title: 'Jumlah Produksi (kg/tahun)',
                                        isDropdownList: false,
                                        keyboardType: TextInputType.number,
                                        onChangedAction: onChangedValue,
                                        key: 'JumlahProduksi',
                                      ),
                                    ),
                                    SizedBox(
                                      height: 70,
                                      child: InputTextForm
                                          .buildContainerInputHorizontal(
                                        keyboardTypeDate: true,
                                        keyboardType: TextInputType.datetime,
                                        buildContext: context,
                                        title: 'Perkiraan Waktu Panen',
                                        isDropdownList: false,
                                        onChangedAction: onChangedValue,
                                        key: 'PerkiraanWaktuPanen',
                                      ),
                                    ),
                                    SizedBox(
                                      height: 70,
                                      child: InputTextForm
                                          .buildContainerInputHorizontal(
                                        keyboardTypeDate: false,
                                        keyboardType: TextInputType.number,
                                        buildContext: context,
                                        title: 'Harga Jual (Rp)',
                                        isDropdownList: false,
                                        onChangedAction: onChangedValue,
                                        key: 'HargaJual',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              BottomNavigation.buildContainerBottom2Navigation(
                                  title1: 'Simpan',
                                  title2: 'Batal',
                                  buildContext: context,
                                  action1: onSubmitAddOne,
                                  action2: () {
                                    Navigator.pop(context);
                                  }),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
