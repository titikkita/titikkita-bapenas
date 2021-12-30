import 'package:flutter/material.dart';
import 'package:titikkita/controller/cmdbuild_controller.dart';
import 'package:titikkita/util/generateToken.dart';
import 'package:titikkita/util/getFamilyData.dart';
import 'package:titikkita/util/navigation.dart';
import 'package:titikkita/views/pages/principalInformation/AllFamilyMap.dart';
import 'package:titikkita/views/pages/principalInformation/CitizenList.dart';
import 'package:titikkita/views/pages/principalInformation/FamilyList.dart';
import 'package:titikkita/views/pages/principalInformation/FilteringFamilyView.dart';
import 'package:titikkita/views/pages/principalInformation/profilRT/Map.dart';
import 'package:titikkita/views/pages/principalInformation/profilRT/Category.dart';
import 'package:titikkita/views/widgets/appBar.dart';
import 'package:titikkita/views/pages/family_member/List.dart';
import 'package:titikkita/views/widgets/loadingIndicator.dart';
import 'package:titikkita/views/widgets/popupNotif.dart';
import 'package:provider/provider.dart' as provider;
import 'package:titikkita/state/local_provider.dart';
import 'package:titikkita/views/widgets/menuListBuilder.dart';

class PrincipalnformationCategoryView extends StatefulWidget {
  @override
  _PrincipalnformationCategoryViewState createState() =>
      _PrincipalnformationCategoryViewState();
}

class _PrincipalnformationCategoryViewState
    extends State<PrincipalnformationCategoryView> {
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    if (provider.Provider.of<LocalProvider>(context, listen: false)
            .members['familyMembers'] ==
        null) {
      fetchFamilyMember();
    }
  }

  void fetchFamilyMember() async {
    setState(() {
      isLoading = true;
    });

    try {
      await generateToken(context);
      await fetchingDataFamilyMembers(context);
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Erroer: $e');
      ShowPopupNotification.errorNotification(
          context: context,
          content: 'Terjadi error. Coba lagi nanti!',
          action: () {
            Navigator.pop(context);
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    var user = provider.Provider.of<LocalProvider>(context, listen: false)
        .principalConstraint['data'][0];
    return Scaffold(
        appBar: AppBarCustom.buildAppBarCustom(
            title: 'Manajemen Informasi Warga', context: context),
        body: isLoading
            ? Center(child: LoadingIndicator.containerSquareLoadingIndicator())
            : Container(
                child: Center(
                  child: ListView(
                    children: <Widget>[
                      MenuListWidget.subMenuCategorySVG(
                          action: () {
                            if (user['_Jabatan_description'] == 'Ketua RW' ||
                                user['_Jabatan_description'] == 'Ketua RT') {
                              goToPage(context, FamilyListView());
                            } else {
                              goToPage(
                                  context,
                                  FilteringFamilyView(
                                    type: 'family',
                                  ));
                            }
                          },
                          savage: "assets/images/label_daftarKeluarga.svg"),
                      MenuListWidget.subMenuCategorySVG(
                          action: () {
                            if (user['_Jabatan_description'] == 'Ketua RW' ||
                                user['_Jabatan_description'] == 'Ketua RT') {
                              goToPage( context, CitizenListView() );
                            } else {
                              goToPage(
                                  context,
                                  FilteringFamilyView(
                                    type: 'people',
                                  ));
                            }
                          },
                          savage: "assets/images/label_daftarWarga.svg"),
                      MenuListWidget.subMenuCategorySVG(
                          action: () {
                            goToPage(context, PrincipalAllMapView());
                          },
                          savage: "assets/images/label_petaKeluarga.svg"),
                      MenuListWidget.subMenuCategorySVG(
                          action: () {
                            goToPage(context, CategoryProfilRT());
                          },
                          savage: "assets/images/label_profilRT.svg"),

                      // provider.Provider.of<LocalProvider>(context).principalConstraint['data'][0]['_Jabatan_description']=='Ketua RT' ?
                      // MenuListWidget.subMenuCategorySVG(
                      //     action: ()  {
                      //       goToPage( context, VillageMapView() );
                      //     },
                      //     savage: "assets/images/label_petaBatasDesa.svg") :
                      //     Container(),
                    ],
                  ),
                ),
              ));
  }
}
