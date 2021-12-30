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

class FamilyDataView extends StatefulWidget {
  FamilyDataView({this.data});
  final dynamic data;

  @override
  _FamilyDataViewState createState() => _FamilyDataViewState();
}

class _FamilyDataViewState extends State<FamilyDataView> {
  bool _isLoading = false;
  dynamic data;

  void initState() {
    getDefaultData();
    super.initState();
  }

  void getDefaultData() async {
    try {
      setState(() {
        _isLoading = true;
      });
      if (provider.Provider.of<LocalProvider>(context, listen: false)
              .address ==
          null) {
        // await generateToken(context);
        await fetchingInternalDataFamily(context);
      }

      if (provider.Provider.of<LocalProvider>(context, listen: false)
              .lookupDataDetail['addressLookupData'] ==
          null) {
        // await generateToken(context);
        await getLookupData(context, 'addressLookup');
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print(e);
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
    return provider.Consumer<LocalProvider>(
      builder:(context,cmdbuild,child){
        if(cmdbuild
            .address != null){
            data = cmdbuild
                .address['data'][0];
        }
        return Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBarCustom.buildAppBarCustom(
              title: 'Data Rumah Tangga', context: context),
          body: _isLoading == true
              ? Center(
            child: LoadingIndicator.containerSquareLoadingIndicator(),
          )
              : cmdbuild.address != null
              ? SingleChildScrollView(
            child: Container(
              color: Colors.grey[100],
              child: Container(
                color: Colors.white,
                padding: EdgeInsets.only(left: 20, right: 20, top: 30),
                margin: EdgeInsets.only(top: 30, bottom: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ContainerBuilder
                                  .buildContainerFamilyInternalData(
                                  title: 'Kepala keluarga',
                                  value: provider.Provider.of<
                                      LocalProvider>(context)
                                      .familyData['Description'],
                                  crossAxis:
                                  CrossAxisAlignment.start),
                              ContainerBuilder
                                  .buildContainerFamilyInternalData(
                                  title: 'Alamat',
                                  value: data
                                  ['_Desa_description'],
                                  crossAxis:
                                  CrossAxisAlignment.start),
                              ContainerBuilder
                                  .buildContainerFamilyInternalData(
                                  title: 'Kabupaten',
                                  value: data
                                  ['_Kabupaten_description'],
                                  crossAxis:
                                  CrossAxisAlignment.start),
                              ContainerBuilder
                                  .buildContainerFamilyInternalData(
                                  title: 'Kecamatan',
                                  value: data
                                  ['_Kecamatan_description'],
                                  crossAxis:
                                  CrossAxisAlignment.start),
                              ContainerBuilder
                                  .buildContainerFamilyInternalData(
                                  title: 'Luas lantai',
                                  value: data
                                  ['LuasLantai'],
                                  crossAxis:
                                  CrossAxisAlignment.start),
                              ContainerBuilder
                                  .buildContainerFamilyInternalData(
                                  title: 'Jenis lantai',
                                  value: data
                                  ['_JenisLantai_description'],
                                  crossAxis:
                                  CrossAxisAlignment.start),
                              ContainerBuilder
                                  .buildContainerFamilyInternalData(
                                  title: 'Keterangan jendela',
                                  value: data[
                                  '_KeteranganJendela_description'],
                                  crossAxis:
                                  CrossAxisAlignment.start),
                              ContainerBuilder
                                  .buildContainerFamilyInternalData(
                                  title: 'Penerangan',
                                  value: data[
                                  '_SumberPenerangan_description'],
                                  crossAxis:
                                  CrossAxisAlignment.start),
                              ContainerBuilder
                                  .buildContainerFamilyInternalData(
                                  title: 'Tempat buangan',
                                  value: data[
                                  '_PembuanganSampah_description'],
                                  crossAxis:
                                  CrossAxisAlignment.start),
                              ContainerBuilder
                                  .buildContainerFamilyInternalData(
                                  title: 'Sumber kayu bakar',
                                  value: data[
                                  '_SumberKayuBakar_description'],
                                  crossAxis:
                                  CrossAxisAlignment.start),
                              ContainerBuilder
                                  .buildContainerFamilyInternalData(
                                  title: 'Fasilitas MCK',
                                  value: data
                                  ['_FasilitasMCK_description'],
                                  crossAxis:
                                  CrossAxisAlignment.start),
                              ContainerBuilder
                                  .buildContainerFamilyInternalData(
                                  title: 'Air minum',
                                  value: data
                                  ['_AirMinum_code'],
                                  crossAxis:
                                  CrossAxisAlignment.start),
                              ContainerBuilder
                                  .buildContainerFamilyInternalData(
                                  title: 'Internet',
                                  value: data
                                  ['_Internet_code'],
                                  crossAxis:
                                  CrossAxisAlignment.start),
                              ContainerBuilder
                                  .buildContainerFamilyInternalData(
                                  title: 'Dekat gunung',
                                  value: data[
                                  '_LokasiDekatGunung_description'],
                                  crossAxis:
                                  CrossAxisAlignment.start),
                              ContainerBuilder
                                  .buildContainerFamilyInternalData(
                                  title: 'Kondisi rumah',
                                  value: data
                                  ['KondisiRumah'],
                                  crossAxis:
                                  CrossAxisAlignment.start),
                            ],
                          ),
                        ),
                        Container(
                          child: Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                ContainerBuilder
                                    .buildContainerFamilyInternalData(
                                    title: 'No rumah',
                                    value: cmdbuild
                                        .address['data'][0]
                                    ['NomorRumah'],
                                    crossAxis:
                                    CrossAxisAlignment.end),
                                ContainerBuilder
                                    .buildContainerFamilyInternalData(
                                    title: 'RT/RW',
                                    value: cmdbuild
                                        .address['data'][0]
                                    ['_RT_description'],
                                    crossAxis:
                                    CrossAxisAlignment.end),
                                ContainerBuilder
                                    .buildContainerFamilyInternalData(
                                    title: 'Status hunian',
                                    value: cmdbuild
                                        .address['data'][0]
                                    ['_StatusTempatTinggal_code'],
                                    crossAxis:
                                    CrossAxisAlignment.end),
                                ContainerBuilder
                                    .buildContainerFamilyInternalData(
                                    title: 'Status lahan',
                                    value: cmdbuild
                                        .address['data'][0]
                                    ['_StatusLahan_code'],
                                    crossAxis:
                                    CrossAxisAlignment.end),
                                ContainerBuilder
                                    .buildContainerFamilyInternalData(
                                    title: 'Luas lahan',
                                    value: cmdbuild
                                        .address['data'][0]
                                    ['LuasLahan'],
                                    crossAxis:
                                    CrossAxisAlignment.end),
                                ContainerBuilder
                                    .buildContainerFamilyInternalData(
                                    title: 'Jenis dinding',
                                    value: cmdbuild
                                        .address['data'][0]
                                    ['_JenisDinding_code'],
                                    crossAxis:
                                    CrossAxisAlignment.end),
                                ContainerBuilder
                                    .buildContainerFamilyInternalData(
                                    title: 'Jenis atap',
                                    value: cmdbuild
                                        .address['data'][0]
                                    ['_JenisAtap_code'],
                                    crossAxis:
                                    CrossAxisAlignment.end),
                                ContainerBuilder
                                    .buildContainerFamilyInternalData(
                                    title: 'Air buangan',
                                    value: cmdbuild
                                        .address['data'][0]
                                    ['_AirBuangan_code'],
                                    crossAxis:
                                    CrossAxisAlignment.end),
                                ContainerBuilder
                                    .buildContainerFamilyInternalData(
                                    title: 'Bahan bakar',
                                    value: cmdbuild
                                        .address['data'][0]
                                    ['_BahanBakarMasak_code'],
                                    crossAxis:
                                    CrossAxisAlignment.end),
                                ContainerBuilder
                                    .buildContainerFamilyInternalData(
                                    title: 'Listrik',
                                    value: cmdbuild
                                        .address['data'][0]
                                    ['_Listrik_code'],
                                    crossAxis:
                                    CrossAxisAlignment.end),
                                ContainerBuilder
                                    .buildContainerFamilyInternalData(
                                    title: 'Air rumah',
                                    value: cmdbuild
                                        .address['data'][0]
                                    ['_AirRumah_code'],
                                    crossAxis:
                                    CrossAxisAlignment.end),
                                ContainerBuilder
                                    .buildContainerFamilyInternalData(
                                    title: 'Fasilitas BAB',
                                    value: cmdbuild
                                        .address['data'][0]
                                    ['_FasilitasBAB_code'],
                                    crossAxis:
                                    CrossAxisAlignment.end),
                                ContainerBuilder
                                    .buildContainerFamilyInternalData(
                                    title: ' Telepon',
                                    value: cmdbuild
                                        .address['data'][0]
                                    ['NomorTelepon'],
                                    crossAxis:
                                    CrossAxisAlignment.end),
                                ContainerBuilder
                                    .buildContainerFamilyInternalData(
                                    title: 'Posisi rumah',
                                    value:
                                    'Di bawah SUTET (${cmdbuild.address['data'][0]['_LokasiRumah_description']})',
                                    crossAxis:
                                    CrossAxisAlignment.end),
                                ContainerBuilder
                                    .buildContainerFamilyInternalData(
                                    title: 'Dekat sungai',
                                    value: cmdbuild
                                        .address['data'][0][
                                    '_LokasiBantaranSungai_code'],
                                    crossAxis:
                                    CrossAxisAlignment.end),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    ContainerBuilder.buildContainerFamilyInternalData(
                        title:
                        'Jumlah anggota yang menggunakan transportasi umum sebulan terakhir:',
                        value: data['PenggunaanTransprtsi'],
                        crossAxis: CrossAxisAlignment.start),
                    ContainerBuilder.buildContainerFamilyInternalData(
                        title:
                        'Jumlah anggota yang menggunakan transportasi umum sebulan sebelumnya:',
                        value: data['PenggunaanTrnsprtsi2'],
                        crossAxis: CrossAxisAlignment.start),
                  ],
                ),
              ),
            ),
          )
              : Container(
            color: Colors.grey[100],
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.only(left: 20, right: 20, top: 30),
              margin: EdgeInsets.only(top: 30, bottom: 30),
              child: Row(
                children: <Widget>[
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ContainerBuilder.buildContainerFamilyInternalData(
                            title: 'Alamat',
                            value: '',
                            crossAxis: CrossAxisAlignment.start),
                        ContainerBuilder.buildContainerFamilyInternalData(
                            title: 'No Rumah',
                            value: '',
                            crossAxis: CrossAxisAlignment.start),
                        ContainerBuilder.buildContainerFamilyInternalData(
                            title: 'Listrik',
                            value: '',
                            crossAxis: CrossAxisAlignment.start),
                        ContainerBuilder.buildContainerFamilyInternalData(
                            title: 'Air Minum',
                            value: '',
                            crossAxis: CrossAxisAlignment.start),
                        ContainerBuilder.buildContainerFamilyInternalData(
                            title: 'Internet',
                            value: '',
                            crossAxis: CrossAxisAlignment.start),
                      ],
                    ),
                  ),
                  Container(
                    child: Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          ContainerBuilder
                              .buildContainerFamilyInternalData(
                              title: 'Air Buangan',
                              value: '',
                              crossAxis: CrossAxisAlignment.end),
                          ContainerBuilder
                              .buildContainerFamilyInternalData(
                              title: 'Bahan Bakar Masak',
                              value: '',
                              crossAxis: CrossAxisAlignment.end),
                          ContainerBuilder
                              .buildContainerFamilyInternalData(
                              title: 'Air Cuci',
                              value: '',
                              crossAxis: CrossAxisAlignment.end),
                          ContainerBuilder
                              .buildContainerFamilyInternalData(
                              title: ' Telepon',
                              value: '',
                              crossAxis: CrossAxisAlignment.end),
                          ContainerBuilder
                              .buildContainerFamilyInternalData(
                              title: ' ',
                              value: '',
                              crossAxis: CrossAxisAlignment.end),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          bottomNavigationBar:  _isLoading ? null :
              BottomNavigation.buildContainerBottom1Navigation(
              title: 'Edit',
              action: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return EditInternalDataFamilyForm(
                  );
                }));
                // goToPage(
                //     context,
                //     EditInternalDataFamilyForm(
                //     ));
              }),

        );
      }
    );
  }
}
