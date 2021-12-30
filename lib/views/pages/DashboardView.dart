import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart' as provider;
import 'package:titikkita/controller/cmdbuild_controller.dart';
import 'package:titikkita/main.dart';
import 'package:titikkita/state/indivivual_provider.dart';
import 'package:titikkita/state/location_provider.dart';
import 'package:titikkita/state/polyline_provider.dart';
import 'package:titikkita/state/principal_provider.dart';
import 'package:titikkita/util/navigation.dart';
import 'package:titikkita/state/local_provider.dart';
import 'package:titikkita/views/pages/HelpDeskView.dart';
import 'package:titikkita/views/pages/family_data/Category.dart';
import 'package:titikkita/views/pages/family_member/MemberDetails.dart';
import 'package:titikkita/views/pages/information/Category.dart';
import 'package:titikkita/views/pages/information/List.dart';
import 'package:titikkita/views/pages/map/Category.dart';
import 'package:titikkita/views/pages/principalInformation/Category.dart';
import 'package:titikkita/views/pages/report/Category.dart';
import 'package:titikkita/views/pages/family_member/Category.dart';
import 'package:titikkita/views/widgets/menuListBuilder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardView extends StatefulWidget {
  DashboardView({this.isCitizen});
  final bool isCitizen;
  @override
  _DashboardViewState createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  dynamic data;
  int totalMessage;

  @override
  void initState() {
    getPersonalInformation(context);
    super.initState();
  }

  void getPersonalInformation(context) async {

    var dataInfo = await CmdbuildController.getPersonalInformation(
        provider.Provider.of<LocalProvider>(context, listen: false)
            .principalConstraint['data'][0]['_id'],
        context);

    if (dataInfo['success'] == true) {
      setState(() {
        data = dataInfo['data'];
        totalMessage = dataInfo['data'].length;
      });
    }
  }

  Widget build(BuildContext context) {

    return StreamBuilder(
        stream: null,
        builder: (buildContext, snapshot) {
          return Scaffold(
            endDrawer: Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.only(
                            top: 10,
                            bottom: 10,
                          ),
                          child: Image.asset("assets/images/bapenas.png",
                              height: 50, width: 50),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 10,
                            ),
                            provider.Provider.of<IndividualProvider>(context).isIndividualLogin ?
                            Text(
                              'Hi, ${provider.Provider.of<IndividualProvider>(context).individualData['Description']}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                              ),
                            ):
                            Text(
                              'Hi, ${provider.Provider.of<LocalProvider>(context).familyData['Description']}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: Icon(Icons.message),
                        title: Text('Pesan Pemberitahuan Desa',
                            style: TextStyle(fontSize: 12.0)),
                        subtitle: Text(
                          data != null
                              ? '$totalMessage pesan masuk'
                              : 'Belum ada pesan masuk',
                          style: TextStyle(
                              color: data != null
                                  ? Colors.red[400]
                                  : Colors.black54,
                              fontSize: 11.0),
                        ),
                        onTap: () {
                          goToPage(
                              context,
                              InformationListView(
                                title: 'Pribadi',
                              ));
                        },
                      ),
                    ],
                  ),
                  ListTile(
                      leading: Icon(Icons.contact_support),
                      title: Text('Pusat Bantuan',
                          style: TextStyle(fontSize: 12.0)),
                      onTap: () {
                        goToPage(context, HelpDeskView());
                      }),
                  ListTile(
                    leading: Icon(Icons.logout),
                    title: Text('Keluar', style: TextStyle(fontSize: 12.0)),
                    onTap: () async {
                      final SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                      prefs.remove('userLoginId');
                      prefs.remove('token');
                      provider.Provider.of<LocalProvider>(context,
                          listen: false)
                          .dispose();
                      provider.Provider.of<LocationProvider>(context,
                          listen: false)
                          .dispose();
                      provider.Provider.of<PolylineProvider>(context,
                          listen: false)
                          .dispose();
                      provider.Provider.of<PrincipalProvider>(context,
                          listen: false)
                          .dispose();

                      Navigator.pop(context);
                      Navigator.pop(context);
                      goToPage(context, MyApp());

                    },
                  ),
                ],
              ),
            ),
            body: Builder(builder: (context) {
              return SafeArea(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: ListView(
                    children: <Widget>[
                      Container(
                        color: Colors.blue,
                        height: 900,
                        width: double.infinity,
                        child: Stack(
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(
                                top: 15,
                                left: 30,
                                right: 30,
                              ),
                              height: 50,
                              width: 50,
                              child: Image.asset(
                                  "assets/images/bapenas.png"),
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                top: 30,
                                left: 90,
                              ),
                              child: Text(
                                "BAPPENAS",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontStyle: FontStyle.normal,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.none),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                getPersonalInformation(context);
                                Scaffold.of(context).openEndDrawer();
                              },
                              child: Align(
                                alignment: Alignment.topRight,
                                child: Container(
                                  margin: EdgeInsets.only(
                                    top: 10,
                                  ),
                                  height: 40,
                                  width: 40,
                                  child: SvgPicture.asset(
                                    "assets/images/icon_setting.svg",
                                    cacheColorFilter: false,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              height: 100,
                              width: double.infinity,
                              margin: EdgeInsets.only(
                                  top: 80, left: 30, right: 200),
                              child:
                              provider.Provider.of<IndividualProvider>(context).isIndividualLogin ?
                              Text(
                                "Hai ${provider.Provider.of<IndividualProvider>(context).individualData['Description']}, selamat datang diaplikasi Titik Kita.",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontStyle: FontStyle.normal,
                                    fontWeight: FontWeight.normal,
                                    decoration: TextDecoration.none),
                              ):
                              Text(
                                "Hai ${provider.Provider.of<LocalProvider>(context).familyData['Description']}, selamat datang diaplikasi Titik Kita.",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontStyle: FontStyle.normal,
                                    fontWeight: FontWeight.normal,
                                    decoration: TextDecoration.none),
                              ),
                            ),
                            Align(
                              alignment: Alignment.topRight,
                              child: Container(
                                height: 450,
                                width: 180,
                                margin: EdgeInsets.only(
                                  top: 60,
                                ),
                                child: SvgPicture.asset(
                                    "assets/images/icon_man.svg"),
                              ),
                            ),
                            Container(
                              color: Colors.white,
                              // height: 1500,
                              width: double.infinity,
                              margin: EdgeInsets.only(top: 250),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 190),
                              child: Center(
                                child: Column(
                                  children: [
                                    MenuListWidget.mainMenuListSVG(
                                        action: () {
                                          widget.isCitizen
                                              ? goToPage(context,
                                              FamilyMembersCategoryView())
                                              : goToPage(
                                              context,   PersonDetailsView(
                                            dataPerson: provider.Provider.of<IndividualProvider>(context,listen: false).individualData,
                                            cardName: provider.Provider.of<IndividualProvider>(context,listen: false).individualData['_type'],
                                            isPrincipal: false,
                                          ));
                                        },
                                        savage:
                                        "assets/images/label_anggota.svg"),
                                    MenuListWidget.mainMenuListSVG(
                                        action: () {
                                          goToPage(context, MapCategoryView());
                                        },
                                        savage:
                                        "assets/images/label_peta.svg"),
                                    MenuListWidget.mainMenuListSVG(
                                        action: () {
                                          goToPage(
                                              context, FamilyDataCategoryView());
                                        },
                                        savage:
                                        "assets/images/label_data.svg"),
                                    // MenuListWidget.mainMenuListSVG(
                                    //     action: () {
                                    //       goToPage(context, ECommerceView());
                                    //     },
                                    //     savage:
                                    //     "assets/images/label_pasar.svg"),
                                    MenuListWidget.mainMenuListSVG(
                                        action: () {
                                          goToPage(context, ReportCategoryView());
                                        },
                                        savage:
                                        "assets/images/label_lapor.svg"),
                                    MenuListWidget.mainMenuListSVG(
                                        action: () {
                                          goToPage(
                                              context, InformationCategoryView());
                                        },
                                        savage:
                                        "assets/images/label_informasi.svg"),
                                    provider.Provider.of<LocalProvider>(context,listen: false).principalConstraint['data'] != null &&
                                        provider.Provider.of<LocalProvider>(context,listen: false).principalConstraint['data'][0]['Jabatan'] != null ?
                                    MenuListWidget.mainMenuListSVG(
                                        action: () {
                                          goToPage(
                                              context, PrincipalnformationCategoryView());
                                        },
                                        savage:
                                        "assets/images/label_daftar_keluarga.svg")
                                        : Container(),

                                  ],
                                ),
                              ),
                            ),
                            // SizedBox(height:100.0,)
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          );
        });
  }
}
