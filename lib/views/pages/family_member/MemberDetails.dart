import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider;
import 'package:titikkita/controller/cmdbuild_controller.dart';
import 'package:titikkita/state/local_provider.dart';
import 'package:titikkita/views/forms/familyMemberAction.dart';
import 'package:titikkita/views/widgets/appBar.dart';
import 'package:titikkita/views/widgets/bottomNavigation.dart';
import 'package:titikkita/views/widgets/containerBuilder.dart';
import 'package:titikkita/views/widgets/loadingIndicator.dart';
import 'package:titikkita/views/widgets/popupNotif.dart';

class PersonDetailsView extends StatefulWidget {
  PersonDetailsView({this.dataPerson, this.memberIndex, this.cardName, this.isPrincipal,this.isFromSearch});
  final dynamic dataPerson;
  final int memberIndex;
  final String cardName;
  final bool isPrincipal;
  final bool isFromSearch;

  @override
  _PersonDetailsViewState createState() => _PersonDetailsViewState();
}

class _PersonDetailsViewState extends State<PersonDetailsView> {
  dynamic dataMembers;
  int indexOfMember;
  String imageName;
  bool isDataAvailable = false;
  bool _isAlertLoading = false;
  dynamic data;

  @override
  void initState() {

    updateDataMembers(widget.dataPerson, widget.memberIndex);
    getImageName(widget.dataPerson['_id'],widget.cardName);

    super.initState();
  }

  void getImageName(id,memberStatus) async {

    try {
       await CmdbuildController.getImage(id, memberStatus,context).then((value){
        if (value['data'].length != 0) {
          imageName = value['data'][0]['name'];
          setState(() {
            isDataAvailable = true;
          });
        } else {
          setState(() {
            isDataAvailable = true;
          });
        }
      });

    } catch (e) {
      print('===$e');
      setState(() {
        isDataAvailable = false;
        _isAlertLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
          ShowPopupNotification.showSnackBar(content: 'Silahkan login kembali!'));
    }
  }

// update data each members to this local widget, get that data from widget FamilyMembersDetails
  void updateDataMembers(data, index) {
    setState(() {
      dataMembers = data;
      indexOfMember = index;
    });
  }

  void popupDeleteActionByPrincipal() async {
    try {
      setState(() {
        _isAlertLoading = true;
      });

      var result = await CmdbuildController.commitDeleteMember(
         dataMembers['_id'],context);
      if(result['success']){
        // if(widget.cardName == 'app_localcitizen'){
        //   provider.Provider.of<PrincipalProvider>(context, listen: false).deleteMember('familyMembers', indexOfMember);
        // }
        // if(widget.cardName == 'app_nonlocalcitizen'){
        //   provider.Provider.of<PrincipalProvider>(context, listen: false).deleteMember('familyNonMembers', indexOfMember);
        // }
        Navigator.pop(context);
        Navigator.pop(context);
      }else{
        setState(() {
          _isAlertLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isAlertLoading = false;
      });
      print(
          'This error happened when processing delete member on MemberDetails.dart');
      print('Error: $e');
    }
  }

  void popupDeleteActionByLocal() async {
    try {
      setState(() {
        _isAlertLoading = true;
      });

      var result = await CmdbuildController.commitDeleteMember( dataMembers['_id'],context);
      if(result['success']){
        if(widget.cardName == 'app_localcitizen'){
          provider.Provider.of<LocalProvider>(context, listen: false).deleteMember('familyMembers', indexOfMember);
        }
        if(widget.cardName == 'app_nonlocalcitizen'){
          provider.Provider.of<LocalProvider>(context, listen: false).deleteMember('familyNonMembers', indexOfMember);
        }
        Navigator.pop(context);
      }else{
        setState(() {
          _isAlertLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isAlertLoading = false;
      });
      print(
          'This error happened when processing delete member on MemberDetails.dart');
      print('Error: $e');
    }
  }

  String address(value) {
    return '${value['_RT_description']} ${value['_Desa_description']} ${value['_Kecamatan_description']} ${value['_Kabupaten_description']}';
  }

  @override
  Widget build(BuildContext myContext) {

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBarCustom.buildAppBarCustom(
          title: widget.cardName == 'app_localcitizen' ? 'Data Anggota Keluarga' :widget.cardName == 'app_nonlocalcitizen' ? 'Data Anggota Non Keluarga' : 'Data Warga', context: context),
      bottomNavigationBar: isDataAvailable && widget.isFromSearch == null
          ? BottomNavigation.buildContainerBottom2Navigation(
              buildContext: context,
              title1: 'Edit',
              title2: 'Hapus',
              action1: () {
                // goToPage(context,  FamilyMembersForm(stepName: 'Data Diri', formMode: 'edit', data: dataMembers,index: widget.memberIndex,cardName: widget.cardName,)
                // );
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return
                          FamilyMembersForm(stepName: 'Data Diri', formMode: 'edit', data: dataMembers,cardName: widget.cardName,isPrincipal: widget.isPrincipal,);
                    },
                  ),
                );
              },
              action2: () {
                ShowPopupNotification.deleteNotification(
                  context: myContext,
                  title: ' Anggota',
                  content:
                   widget.cardName == 'app_localcitizen' ?   'Apakah anda yakin ingin menghapus ${dataMembers['Description']} dari daftar anggota keluarga anda?'
                  : 'Apakah anda yakin ingin menghapus ${dataMembers['Description']} dari daftar non anggota keluarga anda?',
                  action:widget.isPrincipal ? popupDeleteActionByPrincipal : popupDeleteActionByLocal,
                );
              })
          : BottomNavigation.buildContainerBottom1Navigation(
        title: 'Edit',
        action: () {
          // goToPage(context,  FamilyMembersForm(stepName: 'Data Diri', formMode: 'edit', data: dataMembers,index: widget.memberIndex,cardName: widget.cardName,)
          // );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) {
                return
                  FamilyMembersForm(stepName: 'Data Diri', formMode: 'edit', data: dataMembers,cardName: widget.cardName,isPrincipal: widget.isPrincipal,);
              },
            ),
          );
        },
      ),
      body: isDataAvailable == false || _isAlertLoading
          ? Center(child: LoadingIndicator.containerSquareLoadingIndicator())
          : SingleChildScrollView(
              child: Container(
                height: 2000,
                margin: EdgeInsets.all(10),
                child:
                Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          ContainerBuilder.buildContainerFamilyInternalData(
                              title: 'NIK',
                              value: dataMembers['Code'],
                              crossAxis: CrossAxisAlignment.start),
                          ContainerBuilder.buildContainerFamilyInternalData(
                              title: 'Jenis Kelamin',
                              value: dataMembers["_JenisKelamin_code"],
                              crossAxis: CrossAxisAlignment.start),
                          ContainerBuilder.buildContainerFamilyInternalData(
                              title: 'Tanggal Lahir',
                              value: '${dataMembers['TanggalLahir']}',
                              crossAxis: CrossAxisAlignment.start),
                          ContainerBuilder.buildContainerFamilyInternalData(
                              title: 'Alamat Tinggal',
                              value: dataMembers['_AlamatTinggal_description'] != null ?
                                  '${dataMembers['_AlamatTinggal_description']}' :'-',
                              crossAxis: CrossAxisAlignment.start),
                          ContainerBuilder.buildContainerFamilyInternalData(
                              title: 'Alamat Asal',
                              value: dataMembers['AlamatAsal'],
                              crossAxis: CrossAxisAlignment.start),
                          ContainerBuilder.buildContainerFamilyInternalData(
                              title: 'Status Kawin',
                              value: dataMembers['_StatusKawin_code'],
                              crossAxis: CrossAxisAlignment.start),
                          ContainerBuilder.buildContainerFamilyInternalData(
                              title: 'Suku Bangsa',
                              value: dataMembers['SukuBangsa'],
                              crossAxis: CrossAxisAlignment.start),
                          ContainerBuilder.buildContainerFamilyInternalData(
                              title: 'Nomor Telepon',
                              value: dataMembers['NomorHP'],
                              crossAxis: CrossAxisAlignment.start),
                          ContainerBuilder.buildContainerFamilyInternalData(
                              title: 'Alamat Email',
                              value: dataMembers['AlamatEmail'],
                              crossAxis: CrossAxisAlignment.start),
                          ContainerBuilder.buildContainerFamilyInternalData(
                              title: 'Alamat Twitter',
                              value: dataMembers['AlamatTwitter'],
                              crossAxis: CrossAxisAlignment.start),
                          ContainerBuilder.buildContainerFamilyInternalData(
                              title: 'Status Dalam Keluarga',
                              value: dataMembers['_StatusDalamKeluarga_description'],
                              crossAxis: CrossAxisAlignment.start),
                          ContainerBuilder.buildContainerFamilyInternalData(
                              title: 'Kecepatan Internet',
                              value: dataMembers['_KecepatanInternet_description'],
                              crossAxis: CrossAxisAlignment.start),
                          ContainerBuilder.buildContainerFamilyInternalData(
                              title: 'Pekerjaan Utama',
                              value: dataMembers['_PekerjaanUtama_description'],
                              crossAxis: CrossAxisAlignment.start),
                          ContainerBuilder.buildContainerFamilyInternalData(
                              title: 'Penghasilan',
                              value: dataMembers['PenghasilanPerbulan'],
                              crossAxis: CrossAxisAlignment.start),
                          ContainerBuilder.buildContainerFamilyInternalData(
                              title: 'Jaminan sosial ketenagakerjaan',
                              value: dataMembers['_JaminanSosialKerja_description'],
                              crossAxis: CrossAxisAlignment.start),
                          ContainerBuilder.buildContainerFamilyInternalData(
                              title: 'Pendidikan Terakhir',
                              value: dataMembers['_PendidikanTerakhir_description'],
                              crossAxis: CrossAxisAlignment.start),
                          ContainerBuilder.buildContainerFamilyInternalData(
                              title: 'Penyakit yang diderita',
                              value: dataMembers['Penyakit'],
                              crossAxis: CrossAxisAlignment.start),
                          ContainerBuilder.buildContainerFamilyInternalData(
                              title: 'Cacat',
                              value: dataMembers['Cacat'],
                              crossAxis: CrossAxisAlignment.start),
                          ContainerBuilder.buildContainerFamilyInternalData(
                              title: 'Nama ayah kandung',
                              value: dataMembers['NamaAyah'],
                              crossAxis: CrossAxisAlignment.start),
                          ContainerBuilder.buildContainerFamilyInternalData(
                              title: 'File',
                              value: imageName,
                              crossAxis: CrossAxisAlignment.start,
                              isShowImageFile: true),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        // mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          ContainerBuilder.buildContainerFamilyInternalData(
                              title: 'Nama Lengkap',
                              value: dataMembers['Description'],
                              crossAxis: CrossAxisAlignment.end),
                          ContainerBuilder.buildContainerFamilyInternalData(
                              title: 'Nomor urut dalam KK',
                              value: dataMembers['NoUrutKK'],
                              crossAxis: CrossAxisAlignment.end),
                          ContainerBuilder.buildContainerFamilyInternalData(
                              title: 'Tempat Lahir',
                              value: dataMembers['TempatLahir'],
                              crossAxis: CrossAxisAlignment.end),
                          ContainerBuilder.buildContainerFamilyInternalData(
                              title: 'Status Tempat Tinggal',
                              value: dataMembers['_StatusTempatTinggal_description'],
                              crossAxis: CrossAxisAlignment.end),
                          ContainerBuilder.buildContainerFamilyInternalData(
                              title: 'Usia',
                              value: dataMembers['Umur'],
                              crossAxis: CrossAxisAlignment.end),
                          ContainerBuilder.buildContainerFamilyInternalData(
                              title: 'Golongan Darah',
                              value: dataMembers['_GolonganDarah_code'],
                              crossAxis: CrossAxisAlignment.end),
                          ContainerBuilder.buildContainerFamilyInternalData(
                              title: 'Agama',
                              value: dataMembers['_Agama_description'],
                              crossAxis: CrossAxisAlignment.end),
                          ContainerBuilder.buildContainerFamilyInternalData(
                              title: 'Warga Negara',
                              value: dataMembers['_WargaNegara_code'],
                              crossAxis: CrossAxisAlignment.end),
                          ContainerBuilder.buildContainerFamilyInternalData(
                              title: 'Pendidikan Terakhir',
                              value: dataMembers['_PendidikanTerakhir_description'],
                              crossAxis: CrossAxisAlignment.end),
                          ContainerBuilder.buildContainerFamilyInternalData(
                              title: 'Lama Pendidikan Dasar',
                              value: dataMembers['LamaPendidikanDasar'],
                              crossAxis: CrossAxisAlignment.end),
                          ContainerBuilder.buildContainerFamilyInternalData(
                              title: 'Nomor WhatsApp',
                              value: dataMembers['NomorWhatsapp'],
                              crossAxis: CrossAxisAlignment.end),
                          ContainerBuilder.buildContainerFamilyInternalData(
                              title: 'Alamat Facebook',
                              value: dataMembers['AlamatFacebook'],
                              crossAxis: CrossAxisAlignment.end),
                          ContainerBuilder.buildContainerFamilyInternalData(
                              title: 'Alamat Instagram',
                              value: dataMembers['AlamatInstagram'],
                              crossAxis: CrossAxisAlignment.end),
                          ContainerBuilder.buildContainerFamilyInternalData(
                              title: 'Sumber Internet',
                              value: dataMembers['_SumberInternet_description'],
                              crossAxis: CrossAxisAlignment.end),
                          ContainerBuilder.buildContainerFamilyInternalData(
                              title: 'Kondisi Pekerjaan',
                              value: dataMembers['_KondisiPekerjaan_description'],
                              crossAxis: CrossAxisAlignment.end),
                          ContainerBuilder.buildContainerFamilyInternalData(
                              title: 'Jaminan sosial kesehatan',
                              value: dataMembers['_JaminanSosialKerja_description'],
                              crossAxis: CrossAxisAlignment.end),
                          ContainerBuilder.buildContainerFamilyInternalData(
                              title: 'Bahasa Formal',
                              value: dataMembers['BahasaFormal'],
                              crossAxis: CrossAxisAlignment.end),
                          ContainerBuilder.buildContainerFamilyInternalData(
                              title: 'Status Covid',
                              value: dataMembers['_StatusCovid_description'],
                              crossAxis: CrossAxisAlignment.end),
                          ContainerBuilder.buildContainerFamilyInternalData(
                              title: 'Nama Ibu Kandung',
                              value: dataMembers['NamaIbu'],
                              crossAxis: CrossAxisAlignment.end),
                          ContainerBuilder.buildContainerFamilyInternalData(
                              title: 'Bahasa Keseharian',
                              value: dataMembers['BahasaKeseharian'],
                              crossAxis: CrossAxisAlignment.end),
                          // ContainerBuilder.buildContainerFamilyInternalData(
                          //     title: '',
                          //     value: '',
                          //     crossAxis: CrossAxisAlignment.end),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
