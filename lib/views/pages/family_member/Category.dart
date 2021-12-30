import 'package:flutter/material.dart';
import 'package:titikkita/util/generateToken.dart';
import 'package:titikkita/util/getFamilyData.dart';
import 'package:titikkita/util/navigation.dart';
import 'package:titikkita/views/widgets/appBar.dart';
import 'package:titikkita/views/pages/family_member/List.dart';
import 'package:titikkita/views/widgets/loadingIndicator.dart';
import 'package:titikkita/views/widgets/popupNotif.dart';
import 'package:provider/provider.dart' as provider;
import 'package:titikkita/state/local_provider.dart';
import 'package:titikkita/views/widgets/menuListBuilder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FamilyMembersCategoryView extends StatefulWidget {
  @override
  _FamilyMembersCategoryViewState createState() =>
      _FamilyMembersCategoryViewState();
}

class _FamilyMembersCategoryViewState extends State<FamilyMembersCategoryView> {
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
            Navigator.of(context, rootNavigator: true).pop();
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBarCustom.buildAppBarCustom(
            title: 'Status Keluarga', context: context),
        body: isLoading
            ? Center(child: LoadingIndicator.containerSquareLoadingIndicator())
            : Container(
                child: Center(
                  child: Column(
                    children: <Widget>[
                      MenuListWidget.subMenuCategorySVG(
                          action: () async{
                            goToPage(
                                context,
                                FamilyMembersDetailsView(
                                    category: 'app_localcitizen'));
                          },
                          savage: "assets/images/label_familyMember.svg"),
                      MenuListWidget.subMenuCategorySVG(
                          action: () {
                            goToPage(
                                context,
                                FamilyMembersDetailsView(
                                    category: 'app_nonlocalcitizen'));
                          },
                          savage: "assets/images/label_familyNonmember.svg"),
                    ],
                  ),
                ),
              ));
  }
}
