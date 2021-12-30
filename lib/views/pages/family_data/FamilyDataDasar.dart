import 'package:flutter/material.dart';
import 'package:titikkita/util/generateToken.dart';
import 'package:titikkita/util/getInternalFamilyData.dart';
import 'package:titikkita/util/getLookupData.dart';
import 'package:titikkita/views/forms/editFamilyData.dart';
import 'package:titikkita/views/widgets/appBar.dart';
import 'package:titikkita/views/widgets/bottomNavigation.dart';
import 'package:titikkita/views/widgets/containerBuilder.dart';
import 'package:provider/provider.dart' as provider;
import 'package:titikkita/state/local_provider.dart';
import 'package:titikkita/views/widgets/loadingIndicator.dart';
import 'package:titikkita/views/widgets/popupNotif.dart';

class FamilyDataDasar extends StatefulWidget {
  FamilyDataDasar({this.data});
  final dynamic data;

  @override
  _FamilyDataDasarState createState() => _FamilyDataDasarState();
}

class _FamilyDataDasarState extends State<FamilyDataDasar> {
  bool _isLoading = false;
  dynamic data;

  void initState() {

    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return provider.Consumer<LocalProvider>(
      builder:(context,cmdBuild,child){
        if(cmdBuild
            .address != null){
            data = cmdBuild
                .address['data'][0];
        }
        return Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBarCustom.buildAppBarCustom(
              title: 'Data Dasar', context: context),
          body: _isLoading == true
              ? Center(
            child: LoadingIndicator.containerSquareLoadingIndicator(),
          ) : SingleChildScrollView(
            child: Container(
              child: Container(
                // color: Colors.white,
                color: Colors.grey[100],
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.only(left: 20, right: 20, top: 30),
                margin: EdgeInsets.only(top: 30, bottom: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ContainerBuilder.buildContainerFamilyInternalData(
                        title:
                        'Jumlah penghasilan perbulan:',
                        // value: data['PenggunaanTransprtsi'],
                        crossAxis: CrossAxisAlignment.start),
                    ContainerBuilder.buildContainerFamilyInternalData(
                        title:
                        'Jumlah pengeluaran perbulan:',
                        // value: data['PenggunaanTrnsprtsi2'],
                        crossAxis: CrossAxisAlignment.start),
                  ],
                ),
              ),
            ),
          ),
          bottomNavigationBar:  _isLoading ? null :
              BottomNavigation.buildContainerBottom1Navigation(
              title: 'Edit',
              action: () {

              }),

        );
      }
    );
  }
}
