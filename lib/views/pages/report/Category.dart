import 'package:flutter/material.dart';
import 'package:titikkita/util/navigation.dart';
import 'package:titikkita/views/pages/report/Covid19.dart';
import 'package:titikkita/views/pages/report/PemulihanEkonomi.dart';
import 'package:titikkita/views/pages/report/Questionnaires.dart';
import 'package:titikkita/views/pages/report/List.dart';
import 'package:titikkita/views/widgets/appBar.dart';
import 'package:titikkita/views/widgets/menuListBuilder.dart';

class ReportCategoryView extends StatefulWidget {
  @override
  _ReportCategoryViewState createState() => _ReportCategoryViewState();
}

class _ReportCategoryViewState extends State<ReportCategoryView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBarCustom.buildAppBarCustom(
            title: 'Kategori Laporan', context: context),
        body: SingleChildScrollView(
          child: Container(
            child: Center(
              child: Column(
                children: <Widget>[
                  MenuListWidget.subMenuCategorySVG(
                      action: () {
                        goToPage(
                            context,
                            ReportActionView(
                              title: 'Laporan Umum',
                              cardName: 'app_generalreport',
                            ));
                      },
                      savage: "assets/images/label_lapor_umum.svg"),
                  MenuListWidget.subMenuCategorySVG(
                      action: () {
                        goToPage(
                            context,
                         Covid19View());
                      },
                      savage: "assets/images/label_lapor_covid.svg"),
                  MenuListWidget.subMenuCategorySVG(
                      action: () {
                        goToPage(
                            context, PemulihanEkonomi());
                      },
                      savage: "assets/images/label_lapor_pemulihan_ekonomi.svg"),
                  MenuListWidget.subMenuCategorySVG(
                      action: () {
                        goToPage(
                            context,
                            ReportActionView(
                              title: 'Infrastruktur',
                              cardName: 'app_insfrastructurer',
                            ));
                      },
                      savage: "assets/images/label_lapor_infrastruktur.svg"),
                  MenuListWidget.subMenuCategorySVG(
                      action: () {
                        goToPage(
                            context, ReportActionView(title:'Izin Kegiatan',cardName: 'app_eventpermitrepor'));
                      },
                      savage: "assets/images/label_lapor_kegiatan.svg"),
                  MenuListWidget.subMenuCategorySVG(
                      action: () {
                        goToPage(
                            context, ReportActionView(title:'Izin Bangunan',cardName: 'app_buildpermitrepor'));
                      },
                      savage: "assets/images/label_lapor_izin_membangun.svg"),
                  // MenuListWidget.subMenuCategorySVG(
                  //     action: () {
                  //       goToPage(
                  //           context, ReportActionView(title: 'Keadaan Darurat', cardName: 'app_emergencyreport',));
                  //     },
                  //     savage: "assets/images/label_lapor_darurat.svg"),
                  // MenuListWidget.subMenuCategorySVG(
                  //     action: () {
                  //       goToPage(
                  //           context, QuestionnairesView());
                  //     },
                  //     savage: "assets/images/label_lapor_kuesioner.svg"),
                ],
              ),
            ),
          ),
        ));
  }
}
