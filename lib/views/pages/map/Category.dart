import 'package:flutter/material.dart';
import 'package:titikkita/util/navigation.dart';
import 'package:titikkita/views/pages/map/FamilyMap.dart';
import 'package:titikkita/views/pages/map/NeighborMap.dart';
import 'package:titikkita/views/pages/map/OthersMap.dart';
import 'package:titikkita/views/widgets/appBar.dart';
import 'package:titikkita/views/widgets/menuListBuilder.dart';

class MapCategoryView extends StatefulWidget {
  @override
  _MapCategoryViewState createState() => _MapCategoryViewState();
}

class _MapCategoryViewState extends State<MapCategoryView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBarCustom.buildAppBarCustom(
            title: 'Kategori Peta', context: context),
        body: SingleChildScrollView(
          child: Container(
            child: Center(
              child: Column(
                children: <Widget>[
                  MenuListWidget.subMenuCategorySVG(
                      action: () {
                        goToPage(
                          context,
                          MyMapView(),
                        );
                      },
                      savage: "assets/images/label_peta_saya.svg"),
                  MenuListWidget.subMenuCategorySVG(
                      action: () {
                        goToPage(context, NeighborMapView());
                      },
                      savage: "assets/images/label_peta_tetangga_saya.svg"),
                  MenuListWidget.subMenuCategorySVG(
                      action: () {
                        goToPage(
                          context,
                          OthersMap(),
                        );
                      },
                      savage: "assets/images/label_peta_lainnya.svg"),
                ],
              ),
            ),
          ),
        ));
  }
}
