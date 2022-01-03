import 'package:flutter/material.dart';
import 'package:titikkita/controller/cmdbuild_controller.dart';
import 'package:titikkita/state/local_provider.dart';
import 'package:titikkita/util/getComodityData.dart';
import 'package:titikkita/views/pages/family_data/ComodityMap.dart';
import 'package:titikkita/views/widgets/addNewComodity.dart';
import 'package:titikkita/views/widgets/appBar.dart';
import 'package:titikkita/views/widgets/const.dart';
import 'package:titikkita/views/widgets/editNewComodity.dart';
import 'package:titikkita/views/widgets/loadingIndicator.dart';
import 'package:provider/provider.dart' as provider;
import 'package:titikkita/views/widgets/popupNotif.dart';

class CommodityView extends StatefulWidget {
  // const CommodityView({Key? key}) : super(key: key);

  @override
  _CommodityViewState createState() => _CommodityViewState();
}

class _CommodityViewState extends State<CommodityView> {
  bool isLoading = false;
  List<dynamic> commodities = [];
  bool isAddMode = false;
  dynamic dataEdit;
  dynamic newCommodity;

  void initState() {
    defaultData();
    super.initState();
  }

  void defaultData() async {
    isLoading = true;
    commodities = provider.Provider.of<LocalProvider>(context, listen: false)
        .comodityPoints;

    if (commodities.length == 0) {
      await getComodityData(context).then((value) {
        commodities =
            provider.Provider.of<LocalProvider>(context, listen: false)
                .comodityPoints;
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  void onChangedValue() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return AddNewCommodity();
              },
            ),
          );
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
      appBar:
          AppBarCustom.buildAppBarCustom(title: "Komoditas", context: context),
      body: isLoading
          ? Center(
              child: LoadingIndicator.containerSquareLoadingIndicator(),
            )
          : Container(
              margin: EdgeInsets.only(top: 20),
              // padding: EdgeInsets.symmetric(horizontal: 10),
              child: commodities.length == 0
                  ? Center(
                      child: Text('Belum ada data komoditas'),
                    )
                  : ListView.builder(
                      itemBuilder: (context, index) {
                        return Card(
                          child: Container(
                            padding: EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Jenis Komodity',
                                                style: ktextTitleBlue,
                                              ),
                                              Card(
                                                child: Text(
                                                    '${commodities[index]['data']['_JenisKomoditi_description']}', style: kTextValueBlack,),
                                              )
                                            ],
                                          ),
                                          Container(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  'Sub Komoditi',
                                                  style: ktextTitleBlue,
                                                ),
                                                Card(
                                                  child: Text(
                                                      '${commodities[index]['data']['SubKomoditi']}', style: kTextValueBlack,),
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      )),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text('Jumlah (Pohon atau Ekor)',
                                                  style: ktextTitleBlue),
                                              Card(
                                                child: Text(
                                                    '${commodities[index]['data']['Jumlah']}', style: kTextValueBlack,),
                                              )
                                            ],
                                          )),
                                    ),
                                    Container(
                                      child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text('Luas (m2)',
                                                  style: ktextTitleBlue),
                                              Card(
                                                child: Text(
                                                    '${commodities[index]['data']['LuasArea']}', style: kTextValueBlack,),
                                              )
                                            ],
                                          )),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text('Produksi (Kg/tahun)',
                                                  style: ktextTitleBlue),
                                              Card(
                                                child: Text(
                                                    '${commodities[index]['data']['JumlahProduksi']}', style: kTextValueBlack,),
                                              )
                                            ],
                                          )),
                                    ),
                                    Container(
                                      child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text('Perkiraan Waktu Panen',
                                                  style: ktextTitleBlue),
                                              Card(
                                                child: Text(
                                                    '${commodities[index]['data']['PerkiraanWaktuPanen']}', style: kTextValueBlack,),
                                              )
                                            ],
                                          )),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (BuildContext
                                                            context) =>
                                                        ComodityMapView(
                                                          data: commodities[
                                                              index],
                                                        )));
                                          },
                                          icon: Icon(
                                              Icons.add_location_alt_sharp,
                                              size: 20,
                                              color: Colors.blue),
                                        ),
                                        IconButton(
                                          onPressed: () async {
                                            await CmdbuildController
                                                    .deleteOneCard(
                                                        cardName:
                                                            "app_comodity",
                                                        id: commodities[index]
                                                            ['data']['_id'],
                                                        context: context)
                                                .then((value) async {

                                              await getComodityData(context).then((value) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                    ShowPopupNotification.showSnackBar(
                                                        content: 'Komoditas berhasil dihapus'));
                                              }).then((value) {
                                                Navigator.pushReplacement(context,
                                                    MaterialPageRoute(builder:
                                                        (BuildContext context) {
                                                      return CommodityView();
                                                    }));
                                              });

                                            });
                                          },
                                          icon: Icon(Icons.delete,
                                              size: 20, color: Colors.red),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (BuildContext
                                                            context) =>
                                                        EditNewCommodity(
                                                          data: commodities[
                                                              index],
                                                        )));
                                          },
                                          icon: Icon(Icons.edit,
                                              size: 20, color: Colors.green),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text('Harga Jual (Rp)',
                                                  style: ktextTitleBlue),
                                              Card(
                                                child: Text(
                                                    '${commodities[index]['data']['HargaJual']}', style: kTextValueBlack,),
                                              )
                                            ],
                                          )),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      itemCount: commodities.length,
                    ),
            ),
    );
  }
}
