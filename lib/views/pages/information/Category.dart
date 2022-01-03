import 'package:flutter/material.dart';
import 'package:titikkita/util/navigation.dart';
import 'package:titikkita/views/pages/information/List.dart';
import 'package:titikkita/views/widgets/appBar.dart';
import 'package:titikkita/views/widgets/menuListBuilder.dart';

class InformationCategoryView extends StatefulWidget {
  @override
  _InformationCategoryViewState createState() =>
      _InformationCategoryViewState();
}

class _InformationCategoryViewState extends State<InformationCategoryView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBarCustom.buildAppBarCustom(
            title: 'Kategori Informasi', context: context),
        body: SingleChildScrollView(
          child: Container(
            child: Center(
              child: Column(
                children: <Widget>[
                  MenuListWidget.subMenuCategorySVG(
                      action: () {
                        goToPage(
                            context,
                            InformationListView(
                              title: 'Publik',
                            ));
                      },
                      savage: "assets/images/label_informasi_publik.svg"),
                  MenuListWidget.subMenuCategorySVG(
                      action: () {
                        goToPage(
                            context,
                            InformationListView(
                              title: 'Pribadi',
                            ));
                      },
                      savage: "assets/images/label_informasi_pribadi.svg"),
                ],
              ),
            ),
          ),
        ));
  }
}
