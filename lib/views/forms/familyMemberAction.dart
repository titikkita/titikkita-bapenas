import 'package:flutter/material.dart';
import 'package:titikkita/controller/cmdbuild_controller.dart';
import 'package:titikkita/state/indivivual_provider.dart';
import 'package:titikkita/state/local_provider.dart';
import 'package:titikkita/util/attachImage.dart';
import 'package:titikkita/util/generateToken.dart';
import 'package:titikkita/util/getLookupData.dart';
import 'package:titikkita/util/navigation.dart';
import 'package:titikkita/views/pages/family_member/List.dart';
import 'package:titikkita/views/widgets/generalInputText.dart';
import 'package:titikkita/views/widgets/inputDropdownFullWidth.dart';
import 'package:titikkita/views/widgets/memberActionInputFormSteps.dart';
import 'package:titikkita/views/widgets/bottomNavigation.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart' as provider;
import 'package:titikkita/views/widgets/loadingIndicator.dart';
import 'dart:io';
import 'package:titikkita/views/widgets/popupNotif.dart';
import 'package:titikkita/util/getFamilyData.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';

class FamilyMembersForm extends StatefulWidget {
  FamilyMembersForm(
      {this.stepName,
      this.data,
      this.formMode,
      this.cardName,
      this.isPrincipal,
      this.familyId});
  final String stepName;
  final dynamic data;
  final String formMode;
  final String cardName;
  final bool isPrincipal;
  final int familyId;

  @override
  _FamilyMembersFormState createState() => _FamilyMembersFormState();
}

class _FamilyMembersFormState extends State<FamilyMembersForm> {
  final format = DateFormat("yyyy-MM-dd");
  File _image;
  String _imageName;
  dynamic imageData;
  bool _isLoading = false;
  String code;
  String error;
  bool isError = false;
  bool showSubmitButton;
  String nextStepName;
  String formMode;
  dynamic originMemberData;
  dynamic newMemberData = {};
  final TextEditingController textController = TextEditingController();
  Map<String, TextEditingController> initialValueController = {};
  Map<String, bool> isValidate = {};
  Map<String, List<DropdownMenuItem>> lookupData = {};
  Map<String, String> validation = {};
  List<MultiSelectItem<int>> multiSelectItems = [];

  @override
  void initState() {
    setState(() {
      _isLoading = true;
      lookupData = provider.Provider.of<LocalProvider>(context, listen: false)
          .lookupPerson;
    });
    isValidate['Code'] = false;
    isValidate['Description'] = false;
    formMode = widget.formMode;
    if (widget.formMode == 'edit') {
      getImage(widget.data['_id']);
      newMemberData = widget.data;
      print(newMemberData['_StatusKehamilan_code']);
    }
    if (widget.formMode == 'add' && widget.stepName != 'Data Diri') {
      setState(() {
        newMemberData = widget.data;
      });
    }
    if (widget.stepName == 'Data Diri') {

      if (provider.Provider.of<LocalProvider>(context, listen: false)
              .lookupPerson
              .length ==
          0) {
        defaultLookup();
      }

      showSubmitButton = false;
      nextStepName = 'Pekerjaan dan Penghasilan';
    }
    if (widget.stepName == 'Pekerjaan dan Penghasilan') {
      showSubmitButton = false;
      nextStepName = 'Kesehatan dan Disabilitas';
    }
    if (widget.stepName == 'Kesehatan dan Disabilitas') {
      showSubmitButton = false;
      nextStepName = 'Pendidikan';
    }
    if (widget.stepName == 'Pendidikan') {
      showSubmitButton = false;
      nextStepName = 'Sosial';
    }
    if (widget.stepName == 'Sosial') {
      showSubmitButton = false;
      nextStepName = 'Upload Image';
    }
    if (widget.stepName == 'Upload Image') {
      showSubmitButton = true;
    }
    // defaultLookup();
    setState(() {
      _isLoading = false;
    });
    super.initState();
  }

  void defaultLookup() async {

    try {
      await getLookupData(context, 'memberLookup').then((value) {
        for (var i in value.keys) {
          lookupData['$i'] = [];
          for (var j = 0; j < value['$i']['data'].length; j++) {
            lookupData['$i'].add(DropdownMenuItem(
              child: Text('${value[i]['data'][j]['description']}'),
              value: value[i]['data'][j],
            ));
          }
        }
        provider.Provider.of<LocalProvider>(context, listen: false).updateLookupPerson(lookupData);

        setState(() {
          _isLoading = false;
        });


      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ShowPopupNotification.errorNotification(
          context: context,
          content: 'Terjadi error. Coba lagi nanti!',
          action: () {
            Navigator.of(context, rootNavigator: true).pop();
          });
      print('This happens when try to get lookup data. Error: $e');
    }
    // getMultiSelectItem();
  }

  _selectImage() {
    AttachFile.selectImage(
        buildContext: context,
        action: (image) {
          setState(() {
            _image = image;
          });
        });
  }

  void onChangedValue(key, value) {
    print(key);
    print(newMemberData[key]);
    setState(() {
      isError = false;
      newMemberData[key] = value;
      isValidate[key] = false;
    });
    print(newMemberData[key]);
  }

  void onChangedDropdownLocal(item, value, lookupName) {
    setState(() {
      isError = false;
      newMemberData[item] = value;
      isValidate[item] = false;
      // textController.text = value;
    });
  }

  void onChangedDropdownList2(item, value,lookupName) {
    var getDataLookup =
        provider.Provider.of<LocalProvider>(context, listen: false)
            .lookupDataDetail['citizenLookupData'];

    setState(() {
      isError = false;
      var id = getDataLookup['$lookupName']['data'].where((e) {

        return e['code'] == value;
      }).toList();

      newMemberData['$item'] = id[0]['_id'];
    });
    print(newMemberData['$item'] );

  }

  void onChangedDropdownList(item, value) {
    setState(() {
      isError = false;
      newMemberData['$item'] = value['_id'];
    });
  }

  void onSendImage(id, path, author) async {
    await CmdbuildController.commitSendImage(
        id, path, author, widget.cardName, context);
  }

  void onChangedDate(value) {
    setState(() {
      isError = false;
      newMemberData['TanggalLahir'] = value;
    });
  }

  void getImage(id) async {
    var image = await CmdbuildController.getImage(id, widget.cardName, context);

    if (image['data'].length != 0) {
      _imageName = image['data'][0]['name'];
      imageData = image;
    }
  }

  void onSubmitted() async {
    print(newMemberData);
    try {
      var data;
      if (widget.formMode == 'edit') {
        setState(() {
          _isLoading = true;
        });
        var id = newMemberData['_id'];
        data = await CmdbuildController.commitUpdateMemberData(
            newMemberData, id, widget.cardName, context);

        if (_image != null) {
          if (imageData != null) {
            await CmdbuildController.deleteImage(data['data']['_id'],
                imageData['data']['_id'], widget.cardName, context);
          }

          await CmdbuildController.commitSendImage(
                  data['data']['_id'],
                  _image.path,
                  data['data']['Description'],
                  widget.cardName,
                  context)
              .then((value) {});
        }
      } else {
        setState(() {
          _isLoading = true;
        });

        newMemberData['_tenant'] =
            provider.Provider.of<LocalProvider>(context, listen: false)
                .principalConstraint['data'][0]['Desa'];
        newMemberData['Keluarga'] = widget.isPrincipal
            ? widget.familyId
            : provider.Provider.of<LocalProvider>(context, listen: false)
                .familyData['_id'];
        data = await CmdbuildController.commitAddNewMember(
            newMemberData, widget.cardName, context);

        if (_image != null) {
          await CmdbuildController.commitSendImage(
              data['data']['_id'],
              _image.path,
              data['data']['NamaLengkap'],
              widget.cardName,
              context);
        }


      }
      if (data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
            ShowPopupNotification.showSnackBar(
                content: widget.cardName == 'app_localcitizen'
                    ? 'Anggota keluarga berhasil ditambahkan'
                    : 'Anggota non keluarga berhasil ditambahkan'));
        widget.isPrincipal
            ? Navigator.pop(context)
            : await fetchingDataFamilyMembers(context);

        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pop(context);
      } else {
        throw new Error();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        ShowPopupNotification.showSnackBar(
            content: 'Error. Coba lagi nanti',
      ));
      print(
          'This error happens when submitted add new member on familyMemberAction.dart');
      print('Error: $e');
    }
  }

  myInitialValue(val) {
    return TextEditingController(text: val);
  }

  @override
  Widget build(BuildContext context) {

    if(lookupData.length == 0){
      setState(() {
        _isLoading = true;
      });
    }
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('${widget.stepName}',
              style: TextStyle(
                  color: Colors.white,
                  fontFamily: "roboto",
                  fontSize: 17,
                  fontWeight: FontWeight.bold)),
          backgroundColor: Color(0xff084A9A),
          leading: Container(),
        ),
        bottomNavigationBar: _isLoading == false && showSubmitButton == true
            ? BottomNavigation.buildContainerBottom2Navigation(
                buildContext: context,
                title1: 'Kembali',
                title2: 'Simpan',
                action2: onSubmitted,
                action1: () {
                  Navigator.pop(context);
                })
            : BottomNavigation.buildContainerBottom2Navigation(
                buildContext: context,
                title1: 'Kembali',
                title2: 'Selanjutnya',
                action1: () async {
                  if (widget.stepName == 'Data Diri') {
                    setState(() {
                      _isLoading = true;
                    });
                    if (widget.isPrincipal ||
                        provider.Provider.of<IndividualProvider>(context,
                                listen: false)
                            .isIndividualLogin) {
                      Navigator.pop(context);
                    } else {
                      await generateToken(context);
                      await fetchingDataFamilyMembers(context);
                      Navigator.pop(context);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return FamilyMembersDetailsView(
                                category: widget.cardName == "app_localcitizen"
                                    ? 'app_localcitizen'
                                    : 'app_nonlocalcitizen');
                          },
                        ),
                      );
                    }
                  } else {
                    Navigator.pop(context);
                  }
                },
                action2: () {
                  if (newMemberData['Code'] == null ||
                      newMemberData['Code'].length == 0) {
                    setState(() {
                      isValidate['Code'] = true;
                      validation['Code'] = 'No KK harus diisi.';
                    });
                  }
                  if (newMemberData['Description'] == null ||
                      newMemberData['Description'].length == 0) {
                    setState(() {
                      isValidate['Description'] = true;
                      validation['Description'] = 'Nama lengkap harus diisi.';
                    });
                  }
                  if (!isValidate['Code'] && !isValidate['Description']) {
                    goToPage(
                        context,
                        FamilyMembersForm(
                          stepName: nextStepName,
                          data: newMemberData,
                          formMode: formMode,
                          cardName: widget.cardName,
                          isPrincipal: widget.isPrincipal,
                          familyId: widget.familyId,
                        ));
                  }
                }),
        body: _isLoading
            ? Center(child: LoadingIndicator.containerSquareLoadingIndicator())
            : Align(
                alignment: Alignment.topLeft,
                child: Container(
                  padding: EdgeInsets.all(30.0),
                  child: SingleChildScrollView(
                      child: widget.stepName == 'Data Diri'
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      widget.formMode == 'add' ?
                                      InputTextForm.textInputFieldWithBorder(
                                        title: '*NIK',
                                        keyboardType: TextInputType.number,
                                        initialValue: newMemberData['Code'],
                                        attributeName: 'Code',
                                        action: onChangedValue,
                                        isValidate: isValidate['Code'],
                                        validation: validation['Code'],
                                      ) : Container(),
                                      InputTextForm.textInputFieldWithBorder(
                                        title: '*Nama Lengkap',
                                        keyboardType: TextInputType.text,
                                        initialValue:
                                            newMemberData['Description'],
                                        attributeName: 'Description',
                                        action: onChangedValue,
                                        isValidate: isValidate['Description'],
                                        validation: validation['Description'],
                                      ),
                                      InputTextForm.textInputFieldWithBorder(
                                        title: '*No urut dalam KK',
                                        keyboardType: TextInputType.number,
                                        initialValue: newMemberData['NoUrutKK'],
                                        attributeName: 'NoUrutKK',
                                        action: onChangedValue,
                                      ),
                                      InputDropdownFullWidth(
                                          title: 'Jenis Kelamin',
                                          lookupData: lookupData['JenisKelamin'],
                                          onChangedDropdownList:
                                          onChangedDropdownList,
                                          initialValue: newMemberData['_JenisKelamin_description'],
                                          param: 'JenisKelamin'),
                                      InputTextForm.textInputFieldWithBorder(
                                        title: 'Alamat Asal',
                                        keyboardType: TextInputType.text,
                                        initialValue:
                                            newMemberData['AlamatAsal'],
                                        attributeName: 'AlamatAsal',
                                        action: onChangedValue,
                                      ),
                                      InputTextForm.textInputFieldWithBorder(
                                        title: 'Tempat Lahir',
                                        keyboardType: TextInputType.text,
                                        initialValue:
                                            newMemberData['TempatLahir'],
                                        attributeName: 'TempatLahir',
                                        action: onChangedValue,
                                      ),
                                      InputTextForm
                                          .dateTimeInputFieldWithBorder(
                                        title: 'Tanggal Lahir',
                                        initialDateValue:
                                            newMemberData['TanggalLahir'],
                                        action: onChangedDate,
                                        dateFormat: format,
                                      ),
                                      InputTextForm.textInputFieldWithBorder(
                                        title: 'Usia',
                                        keyboardType: TextInputType.number,
                                        initialValue: newMemberData['Umur'],
                                        attributeName: 'Umur',
                                        action: onChangedValue,
                                      ),
                                      InputTextForm.textInputFieldWithBorder(
                                        title: 'Nomor akte kelahiran',
                                        initialValue:
                                            newMemberData['NomorAktaKelahiran'],
                                        attributeName: 'NomorAktaKelahiran',
                                        action: onChangedValue,
                                      ),
                                    ],
                                  ),
                                InputDropdownFullWidth(
                                    title: 'Golongan Darah',
                                    lookupData: lookupData['GolonganDarah'],
                                    initialValue: newMemberData['_GolonganDarah_description'],
                                    onChangedDropdownList:
                                    onChangedDropdownList,
                                    param: 'GolonganDarah'),
                                InputDropdownFullWidth(
                                    title: 'Kepemilikan E-KTP',
                                    lookupData: lookupData['PilihanYaTidak2'],
                                    initialValue: newMemberData['_KepemilikanEKTP_description'],
                                    onChangedDropdownList:
                                    onChangedDropdownList,
                                    param: 'KepemilikanEKTP'),
                                InputDropdownFullWidth(
                                    title: 'Status Kawin',
                                    lookupData: lookupData['StatusKawin'],
                                    initialValue: newMemberData['_StatusKawin_description'],
                                    onChangedDropdownList:
                                    onChangedDropdownList,
                                    param: 'StatusKawin'),
                                  InputTextForm.textInputFieldWithBorder(
                                    title: 'Nomor akta nikah/cerai',
                                    initialValue:
                                        newMemberData['NomorAktaNikah'],
                                    attributeName: 'NomorAktaNikah',
                                    action: onChangedValue,
                                  ),
                                  InputTextForm.textInputFieldWithBorder(
                                    title: 'Nama ibu kandung',
                                    initialValue: newMemberData['NamaIbu'],
                                    attributeName: 'NamaIbu',
                                    action: onChangedValue,
                                  ),
                                InputTextForm.textInputFieldWithBorder(
                                  title: 'Nama bapak kandung',
                                  initialValue: newMemberData['NamaAyah'],
                                  attributeName: 'NamaAyah',
                                  action: onChangedValue,
                                ),
                                InputDropdownFullWidth(
                                    title: 'Status Dalam Keluarga',
                                    lookupData: lookupData['StatusDalamKeluarga'],
                                    initialValue: newMemberData['_StatusDalamKeluarga_description'],
                                    onChangedDropdownList:
                                    onChangedDropdownList,
                                    param: 'StatusDalamKeluarga'),
                                InputDropdownFullWidth(
                                    title: 'Agama',
                                    initialValue: newMemberData['_Agama_description'],
                                    lookupData: lookupData['Agama'],
                                    onChangedDropdownList:
                                    onChangedDropdownList,
                                    param: 'Agama'),
                                  InputTextForm.textInputFieldWithBorder(
                                    title: 'Suku Bangsa',
                                    initialValue: newMemberData['SukuBangsa'],
                                    attributeName: 'SukuBangsa',
                                    action: onChangedValue,
                                  ),
                                InputDropdownFullWidth(
                                    title: 'Warga Negara',
                                    lookupData: lookupData['Negara'],
                                    initialValue: newMemberData['_WargaNegara_description'],
                                    onChangedDropdownList:
                                    onChangedDropdownList,
                                    param: 'WargaNegara'),
                                InputDropdownFullWidth(
                                    title: 'Status Tempat Tinggal',
                                    lookupData: lookupData['StatusTempatTinggal'],
                                    initialValue: newMemberData['_StatusTempatTinggal_description'],
                                    onChangedDropdownList:
                                    onChangedDropdownList,
                                    param: 'StatusTempatTinggal'),
                                  InputTextForm.textInputFieldWithBorder(
                                    title: 'Nomor Telepon',
                                    keyboardType: TextInputType.number,
                                    initialValue: newMemberData['NomorHP'],
                                    attributeName: 'NomorHP',
                                    action: onChangedValue,
                                  ),
                                  InputTextForm.textInputFieldWithBorder(
                                    title: 'Nomor WhatsApp',
                                    keyboardType: TextInputType.number,
                                    initialValue:
                                        newMemberData['NomorWhatsapp'],
                                    attributeName: 'NomorWhatsapp',
                                    action: onChangedValue,
                                  ),
                                  InputTextForm.textInputFieldWithBorder(
                                    title: 'Alamat Email',
                                    initialValue: newMemberData['AlamatEmail'],
                                    attributeName: 'AlamatEmail',
                                    action: onChangedValue,
                                  ),
                                  InputTextForm.textInputFieldWithBorder(
                                    title: 'Alamat Facebook',
                                    initialValue:
                                        newMemberData['AlamatFacebook'],
                                    attributeName: 'AlamatFacebook',
                                    action: onChangedValue,
                                  ),
                                  InputTextForm.textInputFieldWithBorder(
                                    title: 'Alamat Twitter',
                                    initialValue:
                                        newMemberData['AlamatTwitter'],
                                    attributeName: 'AlamatTwitter',
                                    action: onChangedValue,
                                  ),
                                  InputTextForm.textInputFieldWithBorder(
                                    title: 'Alamat Instagram',
                                    initialValue:
                                        newMemberData['AlamatInstagram'],
                                    attributeName: 'AlamatInstagram',
                                    action: onChangedValue,
                                  ),
                                InputDropdownFullWidth(
                                    title: 'Sumber Internet',
                                    lookupData: lookupData['SumberInternet'],
                                    initialValue: newMemberData['_SumberInternet_description'],
                                    onChangedDropdownList:
                                    onChangedDropdownList,
                                    param: 'SumberInternet'),
                                InputDropdownFullWidth(
                                    title: 'Kecepatan Internet',
                                    lookupData: lookupData['KecepatanInternet'],
                                    initialValue: newMemberData['_KecepatanInternet_description'],
                                    onChangedDropdownList:
                                    onChangedDropdownList,
                                    param: 'KecepatanInternet'),
                                ]
                              )
                          : widget.stepName == 'Pekerjaan dan Penghasilan'
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                      InputDropdownFullWidth(
                                          title: 'Kondisi Pekerjaan',
                                          lookupData:
                                              lookupData['KondisiPekerjaan'],
                                          initialValue: newMemberData['_KondisiPekerjaan_description'],
                                          onChangedDropdownList:
                                              onChangedDropdownList,
                                          param: 'KondisiPekerjaan'),
                                      InputDropdownFullWidth(
                                          title: 'Pekerjaan Utama',
                                          lookupData: lookupData['Pekerjaan'],
                                          onChangedDropdownList:
                                              onChangedDropdownList,
                                          initialValue: newMemberData['_PekerjaanUtama_description'],
                                          param: 'PekerjaanUtama'),
                                      InputDropdownFullWidth(
                                          title: 'Bidang Pekerjaan',
                                          lookupData:
                                          lookupData['BidangPekerjaan'],
                                          onChangedDropdownList:
                                          onChangedDropdownList,
                                          initialValue: newMemberData['_BidangPekerjaan_description'],
                                          param: 'BidangPekerjaan'),
                                      InputDropdownFullWidth(
                                          title:
                                              'Jaminan sosial ketenagakerjaan',
                                          lookupData: lookupData[
                                              'JaminanSosialKetenagakerjaan'],
                                          onChangedDropdownList:
                                              onChangedDropdownList,
                                          initialValue: newMemberData['_JaminanSosialKerja_description'],
                                          param: 'JaminanSosialKerja'),
                                      InputDropdownFullWidth(
                                          title: 'Penghasilan perbulan',
                                          lookupData:
                                          lookupData['PenghasilanPerbulan'],
                                          onChangedDropdownList:
                                          onChangedDropdownList,
                                          initialValue: newMemberData['_PenghasilanPerbulan_description'],
                                          param: 'PenghasilanPerbulan'),
                                      InputDropdownFullWidth(
                                          title: 'Pensiunan',
                                          lookupData:
                                              lookupData['PilihanYaTidak'],
                                          initialValue: newMemberData['_Pensiunan_description'],
                                          onChangedDropdownList:
                                              onChangedDropdownList,
                                          param: 'Pensiunan'),
                                    ]
                                  )
                              : widget.stepName == 'Kesehatan dan Disabilitas'
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children:
                                      MemberActionFormSteps.step3(
                                        isEditMode: widget.formMode == 'add'
                                            ? false
                                            : true,
                                        buildContext: context,
                                        data: newMemberData,
                                        onChangedValue: onChangedValue,
                                        onChangedDate: onChangedDate,
                                        onChangedDropdownList:
                                        onChangedDropdownList2,
                                        formatDate: format,
                                      ),
                                    )
                                  : widget.stepName == 'Pendidikan'
                                      ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // InputDropdownFullWidth(
                                            //     title: 'Partisipasi sekolah',
                                            //     lookupData: lookupData['PartisipasiSekolah'],
                                            //     onChangedDropdownList:
                                            //     onChangedDropdownList,
                                            //     param: 'PastisipasiSekolah'),
                                            InputDropdownFullWidth(
                                                title: 'Pendidikan terakhir',
                                                lookupData: lookupData['Pendidikan'],
                                                onChangedDropdownList:
                                                onChangedDropdownList,
                                                initialValue: newMemberData['_PendidikanTerakhir_description'],
                                                param: 'PendidikanTerakhir'),
                                            InputTextForm.textInputFieldWithBorder(
                                              title: 'Lama Pendidikan Dasar(Tahun)',
                                              initialValue:
                                              newMemberData['LamaPendidikanDasar'],
                                              attributeName: 'LamaPendidikanDasar',
                                              action: onChangedValue,
                                              keyboardType: TextInputType.number
                                            ),
                                            InputDropdownFullWidth(
                                                title: 'Ijazah pendidikan terakhir',
                                                lookupData: lookupData['Pendidikan'],
                                                onChangedDropdownList:
                                                onChangedDropdownList,
                                                initialValue: newMemberData['_IjazahTerakhir_description'],
                                                param: 'IjazahTerakhir'),
                                            InputDropdownFullWidth(
                                                title: 'Kesulitan baca tulis',
                                                lookupData: lookupData['PilihanYaTidak'],
                                                onChangedDropdownList:
                                                onChangedDropdownList,
                                                initialValue: newMemberData['_BisaBacaTulis_description'],
                                                param: 'BisaBacaTulis'),
                                          ]
                                        )
                                      : widget.stepName == 'Sosial'
                                          ? Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children:
                                                  MemberActionFormSteps.step5(
                                                isEditMode:
                                                    widget.formMode == 'add'
                                                        ? false
                                                        : true,
                                                buildContext: context,
                                                data: newMemberData,
                                                onChangedValue: onChangedValue,
                                                onChangedDate: onChangedDate,
                                                onChangedDropdownList:
                                                onChangedDropdownList2,
                                                formatDate: format,
                                              ),
                                            )
                                          : Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children:
                                                  MemberActionFormSteps.step6(
                                                      context: context,
                                                      data: imageData,
                                                      isEditMode:
                                                          widget.formMode ==
                                                                  'add'
                                                              ? false
                                                              : true,
                                                      imageName: _imageName,
                                                      imageFile: _image,
                                                      selectImage:
                                                          _selectImage),
                                            )),
                ),
              ),
      ),
    );
  }
}
