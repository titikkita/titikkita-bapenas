import 'package:flutter/material.dart';
import 'package:titikkita/state/indivivual_provider.dart';
import 'package:titikkita/util/navigation.dart';
import 'package:titikkita/views/pages/family_data/Comodity.dart';
import 'package:titikkita/views/pages/family_data/ComodityMap.dart';
import 'package:titikkita/views/pages/family_data/FamilyDataDasar.dart';
import 'package:titikkita/views/pages/family_data/FamilyDataView.dart';
import 'package:titikkita/views/widgets/appBar.dart';
import 'package:titikkita/views/widgets/menuListBuilder.dart';
import 'package:provider/provider.dart' as provider;


class FamilyDataCategoryView extends StatefulWidget {
  @override
  _FamilyDataCategoryViewState createState() => _FamilyDataCategoryViewState();
}

class _FamilyDataCategoryViewState extends State < FamilyDataCategoryView > {
  @override
  Widget build( BuildContext context ) {
    return Scaffold(
      appBar: AppBarCustom.buildAppBarCustom(
        title: 'Kategori Data Rumah Tangga', context: context ),
      body: SingleChildScrollView(
        child: Container(
          child: Center(
            child: Column(
              children: < Widget > [
                provider.Provider.of<IndividualProvider>(context).isIndividualLogin ? Container() :
                MenuListWidget.subMenuCategorySVG(
                    action: () {
                      goToPage( context, FamilyDataView());
                    },
                    savage: "assets/images/label_permukiman.svg"),
                MenuListWidget.subMenuCategorySVG(
                    action: () {
                      goToPage( context, CommodityView());
                    },
                    savage: "assets/images/label_comodity.svg"),
                // MenuListWidget.subMenuCategorySVG(
                //     action: () {
                //       goToPage( context, FamilyDataDasar());
                //     },
                //     savage: "assets/images/label_data_dasar.svg"),
              ],
            ),
          ),
        ),
      ) );
  }
}