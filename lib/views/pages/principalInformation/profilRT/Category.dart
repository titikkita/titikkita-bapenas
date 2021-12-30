import 'package:flutter/material.dart';
import 'package:titikkita/util/generateToken.dart';
import 'package:titikkita/util/getFamilyData.dart';
import 'package:titikkita/util/navigation.dart';
import 'package:titikkita/views/pages/principalInformation/profilRT/Map.dart';
import 'package:titikkita/views/pages/principalInformation/profilRT/Profil.dart';
import 'package:titikkita/views/widgets/appBar.dart';
import 'package:titikkita/views/pages/family_member/List.dart';
import 'package:titikkita/views/widgets/loadingIndicator.dart';
import 'package:titikkita/views/widgets/popupNotif.dart';
import 'package:provider/provider.dart' as provider;
import 'package:titikkita/state/local_provider.dart';
import 'package:titikkita/views/widgets/menuListBuilder.dart';

class CategoryProfilRT extends StatefulWidget {
  @override
  _CategoryProfilRTState createState() =>
      _CategoryProfilRTState();
}

class _CategoryProfilRTState extends State<CategoryProfilRT> {
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
    return Scaffold(
        appBar: AppBarCustom.buildAppBarCustom(
            title: 'Profil', context: context),
        body: isLoading
            ? Center(child: LoadingIndicator.containerSquareLoadingIndicator())
            : Container(
                child: Center(
                  child: Column(
                    children: <Widget>[
                      MenuListWidget.subMenuCategorySVG(
                          action: () {
                            goToPage(
                                context,
                              RTProfilView());
                          },
                          savage: "assets/images/label_dataRT.svg"),
                      MenuListWidget.subMenuCategorySVG(
                          action: () {
                            goToPage(
                                context,
                                PrincipalMap());
                          },
                          savage: "assets/images/label_petaRT.svg"),
                    ],
                  ),
                ),
              ));
  }
}
