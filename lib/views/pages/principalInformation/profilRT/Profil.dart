import 'package:flutter/material.dart';
import 'package:titikkita/controller/cmdbuild_controller.dart';
import 'package:titikkita/state/local_provider.dart';
import 'package:titikkita/state/principal_provider.dart';
import 'package:titikkita/util/getFamilyOnPrincipal.dart';
import 'package:titikkita/views/widgets/appBar.dart';
import 'package:titikkita/views/widgets/const.dart';
import 'package:provider/provider.dart' as provider;
import 'package:titikkita/views/widgets/loadingIndicator.dart';

class RTProfilView extends StatefulWidget {
  // const RTProfilView({Key? key}) : super(key: key);

  @override
  _RTProfilViewState createState() => _RTProfilViewState();
}

class _RTProfilViewState extends State<RTProfilView> {
  String key;
  dynamic data;
  bool isLoading = false;
  int totalFamily;
  String cardName;

  void initState() {
    getDefaultData();
    super.initState();
  }

  void getDefaultData() async {
    var family =
        provider.Provider.of<PrincipalProvider>(context, listen: false);
    if (family.family.length != 0) {
      totalFamily = family.family.length;
    } else {
      await getFamilyListForPrincipal(context).then((value) {

        totalFamily = family.family.length;
      });
    }


    isLoading = true;
    var principalConstraint =
        provider.Provider.of<LocalProvider>(context, listen: false)
            .principalConstraint['data'][0];
    if (principalConstraint['_Jabatan_code'] == 'Ketua RT') {
      key = 'RT';
      cardName = 'pti_neighborhood';
    }
    if (principalConstraint['_Jabatan_code'] == 'Ketua RW') {
      key = 'RW';
      cardName = 'pti_upperneighbor';
    }
    if (principalConstraint['_Jabatan_code'] == 'Kepala Desa') {
      key = 'Desa';
      cardName = 'pti_upperneighbor';
    }
    if (principalConstraint['_Jabatan_code'] == 'Ketua Dusun') {
      key = 'Dusun';
      cardName = 'pti_upperneighbor';
    }


    await CmdbuildController.findCardWith2Filter(
            context: context,
            cardName: cardName,
            key: ['_id', 'Desa'],
            value: [principalConstraint[key], principalConstraint['Desa']])
        .then((value) {

      data = value['data'][0];
    }).catchError((e) {
      print(e);
    });
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    var principalState = provider.Provider.of<PrincipalProvider>(context);
    var datKetuaRT = provider.Provider.of<LocalProvider>(context, listen: false)
        .principalConstraint['data'][0];

    return Scaffold(
      appBar:
          AppBarCustom.buildAppBarCustom(title: 'Data RT', context: context),
      body: isLoading && data == null
          ? Center(child: LoadingIndicator.containerSquareLoadingIndicator())
          : Container(
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ketua $key',
                    style: ktextTitleBlue,
                  ),
                  Card(
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Nama',
                                style: kTextValueBlack,
                              ),
                              Text( data != null ?
                                '${datKetuaRT['Description']}' :'',
                                style: kTextValueBlack,
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'NIK',
                                style: kTextValueBlack,
                              ),
                              Text(data != null ?
                                '${datKetuaRT['Code']}':'',
                                style: kTextValueBlack,
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Menjabat Sejak',
                                style: kTextValueBlack,
                              ),
                              Text( data != null ?
                                data['TahunJabatanKetua'] != null
                                    ? '${data['TahunJabatanKetua']}'
                                    : '-' :'',
                                style: kTextValueBlack,
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Sekretaris $key',
                    style: ktextTitleBlue,
                  ),
                  Card(
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Nama',
                                style: kTextValueBlack,
                              ),
                              Text(data != null ?
                                data['_SekretarisRT_description'] != null
                                    ? '${data['_SekretarisRT_description']}'
                                    : '-' :'',
                                style: kTextValueBlack,
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'NIK',
                                style: kTextValueBlack,
                              ),
                              Text(data != null ?
                                data['_SekretarisRT_code'] != null
                                    ? '${data['_SekretarisRT_code']}'
                                    : '-':'',
                                style: kTextValueBlack,
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Menjabat Sejak',
                                style: kTextValueBlack,
                              ),
                              Text(data != null ?
                                data['TahunJabatanSek'] != null
                                    ? '${data['TahunJabatanSek']}'
                                    : '-':'',
                                style: kTextValueBlack,
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Bendahara $key',
                    style: ktextTitleBlue,
                  ),
                  Card(
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Nama',
                                style: kTextValueBlack,
                              ),
                              Text(data != null ?
                                data['_BendaharaRT_description'] != null
                                    ? '${data['_BendaharaRT_description']}'
                                    : '-':'',
                                style: kTextValueBlack,
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'NIK',
                                style: kTextValueBlack,
                              ),
                              Text(data != null ?
                                data['_BendaharaRT_code'] != null
                                    ? '${data['_BendaharaRT_code']}'
                                    : '-':'',
                                style: kTextValueBlack,
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Menjabat Sejak',
                                style: kTextValueBlack,
                              ),
                              Text(data != null ?
                                data['TahunJabatanBendhra'] != null
                                    ? '${data['TahunJabatanBendhra']}'
                                    : '-':'',
                                style: kTextValueBlack,
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  Card(
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Jumlah Kepala Keluarga',
                                style: kTextValueBlack,
                              ),
                              Text(
                                totalFamily != null ? '$totalFamily' : '-',
                                style: kTextValueBlack,
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Jumlah Warga',
                                style: kTextValueBlack,
                              ),
                              Text(
                               principalState.citizen.length != 0 ? '${principalState.citizen.length}' : '-',
                                style: kTextValueBlack,
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Jumlah Non Warga',
                                style: kTextValueBlack,
                              ),
                              Text(
                                principalState.nonCitizen.length != 0 ? '${principalState.nonCitizen.length}' : '0',
                                style: kTextValueBlack,
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
