import 'package:flutter/material.dart';
import 'package:titikkita/util/getComodityData.dart';
import 'package:titikkita/views/pages/family_data/Comodity.dart';
import 'package:titikkita/views/widgets/appBar.dart';
import 'package:titikkita/views/widgets/bottomNavigation.dart';
import 'package:titikkita/views/widgets/generalInputText.dart';
import 'package:titikkita/views/widgets/loadingIndicator.dart';
import 'package:titikkita/views/widgets/popupNotif.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:intl/intl.dart';
import 'package:titikkita/controller/cmdbuild_controller.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';

class EditNewCommodity extends StatefulWidget {
  EditNewCommodity({this.data});
  final dynamic data;

  @override
  _EditNewCommodityState createState() => _EditNewCommodityState();
}

class _EditNewCommodityState extends State<EditNewCommodity> {
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
  dynamic newCommodity;

  void initState() {
    defaultData();
    super.initState();
  }

  void defaultData() async {
    setState(() {
      newCommodity = widget.data['data'];
    });
    isLoading = true;
    await CmdbuildController.getOneLookup('JenisKomoditi', context)
        .then((value) {
      for (var i = 0; i < value['data'].length; i++) {
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

  void onSubmitEditOne() async {
    
    await CmdbuildController.commitEditCardById(
            newCommodity['_id'], newCommodity, 'app_comodity', context)
        .then((value) async {
      print(value);
      await getComodityData(context).then((value) {
        ScaffoldMessenger.of(context).showSnackBar(
            ShowPopupNotification.showSnackBar(
                content: 'Komoditas berhasil diedit'));
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
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (BuildContext context) => CommodityView()));
  }

  void onChangedValue(item, value, lookupName) {
    setState(() {
      newCommodity[item] = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBarCustom.buildAppBarCustom(
          title: 'Edit Komoditas', context: context),
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
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold),
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
                                                newCommodity['JenisKomoditi'] =
                                                    value['description'];
                                              });
                                              subCommodityLookup = value['code']
                                                  .replaceAll(
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
                                            hint: newCommodity[
                                                '_JenisKomoditi_description'],
                                            isExpanded: true,
                                            style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.black),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
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
                                                  onChanged: (value) async {
                                                    setState(() {
                                                      newCommodity[
                                                              'SubKomoditi'] =
                                                          value['description'];
                                                    });
                                                  },
                                                  hint: newCommodity[
                                                      '_SubKomoditi_description'],
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
                                              keyboardType:
                                                  TextInputType.number,
                                              buildContext: context,
                                              title: 'Jumlah (Pohon/Ekor)',
                                              isDropdownList: false,
                                              onChangedAction: onChangedValue,
                                              key: 'Jumlah',
                                              initialValue:
                                                  '${newCommodity['Jumlah']}'),
                                    ),
                                    SizedBox(
                                      height: 70,
                                      child: InputTextForm
                                          .buildContainerInputHorizontal(
                                              keyboardTypeDate: false,
                                              buildContext: context,
                                              keyboardType:
                                                  TextInputType.number,
                                              title: 'Luas (m2)',
                                              isDropdownList: false,
                                              onChangedAction: onChangedValue,
                                              key: 'LuasArea',
                                              initialValue:
                                                  "${newCommodity['LuasArea']}"),
                                    ),
                                    SizedBox(
                                      height: 70,
                                      child: InputTextForm
                                          .buildContainerInputHorizontal(
                                              keyboardTypeDate: false,
                                              buildContext: context,
                                              title:
                                                  'Jumlah Produksi (kg/tahun)',
                                              isDropdownList: false,
                                              keyboardType:
                                                  TextInputType.number,
                                              onChangedAction: onChangedValue,
                                              key: 'JumlahProduksi',
                                              initialValue: "${
                                            newCommodity['JumlahProduksi']
                                          }"),
                                    ),
                                    SizedBox(
                                      height: 70,
                                      child: InputTextForm
                                          .buildContainerInputHorizontal(
                                              keyboardTypeDate: true,
                                              keyboardType:
                                                  TextInputType.datetime,
                                              buildContext: context,
                                              title: 'Perkiraan Waktu Panen',
                                              isDropdownList: false,
                                              onChangedAction: onChangedValue,
                                              key: 'PerkiraanWaktuPanen',
                                              initialValue: '${newCommodity[
    'PerkiraanWaktuPanen']}'),
                                    ),
                                    SizedBox(
                                      height: 70,
                                      child: InputTextForm
                                          .buildContainerInputHorizontal(
                                              keyboardTypeDate: false,
                                              keyboardType:
                                                  TextInputType.number,
                                              buildContext: context,
                                              title: 'Harga Jual (Rp)',
                                              isDropdownList: false,
                                              onChangedAction: onChangedValue,
                                              key: 'HargaJual',
                                              initialValue:
                                                  "${newCommodity['HargaJual']}"),
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
                                  action1: onSubmitEditOne,
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
