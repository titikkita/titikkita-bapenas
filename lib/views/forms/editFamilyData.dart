import 'package:flutter/material.dart';
import 'package:titikkita/controller/cmdbuild_controller.dart';
import 'package:titikkita/state/local_provider.dart';
import 'package:titikkita/util/getInternalFamilyData.dart';
import 'package:titikkita/util/getLookupData.dart';
import 'package:titikkita/views/widgets/bottomNavigation.dart';
import 'package:titikkita/views/widgets/generalInputText.dart';
import 'package:provider/provider.dart' as provider;
import 'package:titikkita/views/widgets/inputDropdownHalfWidth.dart';
import 'package:titikkita/views/widgets/loadingIndicator.dart';
import 'package:titikkita/views/widgets/popupNotif.dart';

class EditInternalDataFamilyForm extends StatefulWidget {
  @override
  _EditInternalDataFamilyFormState createState() =>
      _EditInternalDataFamilyFormState();
}

class _EditInternalDataFamilyFormState
    extends State<EditInternalDataFamilyForm> {
  List<String> options = ['Pilih salah satu:', 'Ada', 'Tidak Ada'];
  dynamic dataEditToSend;
  bool _isLoading = true;
  bool _isLoadingIndicator = false;
  dynamic initialData;
  String errorType;
  Map<String, List<DropdownMenuItem>> lookupData = {};

  @override
  void initState() {
    dataEditToSend =
        provider.Provider.of<LocalProvider>(context, listen: false).address;
    initialData = provider.Provider.of<LocalProvider>(context, listen: false)
        .address['data'][0];
    defaultLookup();
    super.initState();
  }

  void defaultLookup()async{
    await getLookupData(context, 'addressLookup').then((value) {
      for (var i in value.keys) {
        lookupData['$i'] = [];
        for (var j = 0; j < value['$i']['data'].length; j++) {
          lookupData['$i'].add(DropdownMenuItem(
            child: Text('${value[i]['data'][j]['description']}'),
            value: value[i]['data'][j],
          ));
        }
      }
      provider.Provider.of<LocalProvider>(context, listen: false).updateLookupFamily(lookupData);

      setState(() {
        _isLoading = false;
      });


    });
  }

  void onChangedDropdown(item, value) async {
    setState(() {
      dataEditToSend[item] = value['_id'];
    });
  }

  void onChanged(key, value, lookupName) {
    setState(() {
      if(key == 'LuasLahan' || key == 'LuasLantai'){
        value = value.replaceAll(',','.');
      }
      print(value);
      dataEditToSend[key] = value;
    });
  }

  void onSubmit() async {
    try {
      setState(() {
        _isLoading = true;
      });
      var submitData = await CmdbuildController.commitUpdateFamilyInternalData(
          dataEditToSend,
          provider.Provider.of<LocalProvider>(context, listen: false)
              .familyData['AlamatTinggal'],
          context);

      if (submitData['success'] == true) {
        await fetchingInternalDataFamily(context);
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
            ShowPopupNotification.showSnackBar(
                content: 'Data rumah tangga berhasil diedit'));
        Navigator.pop(context);
      } else {
        print(submitData);
        setState(() {
          _isLoading = false;
        });
        ShowPopupNotification.errorNotification(
            context: context,
            content: 'Gagal. Pastikan mengisi luas dengan nomor.',
            action: () {
              Navigator.of(context, rootNavigator: true).pop();
              setState(() {
                errorType = 'Semua pilihan';
              });
            });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ShowPopupNotification.errorNotification(
          context: context,
          content: 'Terjadi error. Coba lagi nanti!',
          action: () {
            Navigator.pop(context);
          });
      print(
          'This error happens when try to submit edit family data on edit internal family data form. Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child:Scaffold(
              appBar: AppBar(
                backgroundColor: Color(0xff084A9A),
                title: Text(
                  'Edit Data Rumah Tangga',
                  style: TextStyle(
                      fontFamily: "roboto",
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                leading: Container(),
              ),
              bottomNavigationBar:
                  BottomNavigation.buildContainerBottom2Navigation(
                      title1: 'Simpan',
                      title2: 'Batal',
                      buildContext: context,
                      action1: onSubmit,
                      action2: () {
                        Navigator.pop(context);
                      }),
              body: _isLoading == true
                  ? Center(child: LoadingIndicator.containerSquareLoadingIndicator())
                  :  Center(
                child: Container(
                  margin: EdgeInsets.only(left:10.0),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 80,
                          child: InputTextForm.buildContainerInputHorizontal(
                              keyboardType: TextInputType.number,
                              title: 'No. Rumah',
                              isDropdownList: false,
                              initialValue: dataEditToSend['data'][0]['NomorRumah'],
                              onChangedAction: onChanged,
                              key: 'NomorRumah',
                              buildContext: context),
                        ), 
                        InputDropdownHalfWidth(
                          title: 'Air Minum',
                          lookupData: lookupData['AirMinum'],
                          onChangedDropdownList: onChangedDropdown,
                          param: 'AirMinum',
                          initialValue: initialData['_AirMinum_description'],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        InputDropdownHalfWidth(
                          title: 'Air Rumah',
                          lookupData: lookupData['AirRumah'],
                          onChangedDropdownList: onChangedDropdown,
                          param: 'AirRumah',
                          initialValue: initialData['_AirRumah_description'],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        InputDropdownHalfWidth(
                          title: 'Internet',
                          lookupData: lookupData['KeteranganMemiliki'],
                          onChangedDropdownList: onChangedDropdown,
                          param: 'Internet',
                          initialValue: initialData['_Internet_description'],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        InputDropdownHalfWidth(
                          title: 'Listrik',
                          lookupData: lookupData['Listrik'],
                          onChangedDropdownList: onChangedDropdown,
                          param: 'Listrik',
                          initialValue: initialData['_Listrik_description'],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        InputDropdownHalfWidth(
                          title: 'Air Buangan',
                          lookupData: lookupData['AirBuangan'],
                          onChangedDropdownList: onChangedDropdown,
                          param: 'AirBuangan',
                          initialValue: initialData['_AirBuangan_description'],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        InputDropdownHalfWidth(
                          title: 'Bahan Bakar Masak',
                          lookupData: lookupData['BahanBakarMasak'],
                          onChangedDropdownList: onChangedDropdown,
                          param: 'BahanBakarMasak',
                          initialValue: initialData['_BahanBakarMasak_description'],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        InputDropdownHalfWidth(
                          title: 'Sumber Kayu Bakar',
                          lookupData: lookupData['SumberKayuBakar'],
                          onChangedDropdownList: onChangedDropdown,
                          param: 'SumberKayuBakar',
                          initialValue: initialData['_SumberKayuBakar_description'],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          height: 70,
                          child: InputTextForm.buildContainerInputHorizontal(
                              buildContext: context,
                              title: 'Nomor Telepon',
                              isDropdownList: false,
                              initialValue: initialData['NomorTelepon'],
                              onChangedAction: onChanged,
                              key: 'NomorTelepon',
                              keyboardType: TextInputType.number),
                        ),
                        SizedBox(
                          height: 70,
                          child: InputTextForm.buildContainerInputHorizontal(
                            buildContext: context,
                            title: 'Luas Lahan (meter2)',
                            isDropdownList: false,
                            initialValue: initialData['LuasLahan'],
                            onChangedAction: onChanged,
                            key: 'LuasLahan',
                            keyboardType: TextInputType.numberWithOptions(decimal: true)
                          ),
                        ),
                        SizedBox(
                          height: 70,
                          child: InputTextForm.buildContainerInputHorizontal(
                            buildContext: context,
                            title: 'Luas Lantai (meter2)',
                            isDropdownList: false,
                            initialValue: initialData['LuasLantai'],
                            onChangedAction: onChanged,
                            key: 'LuasLantai',
                              keyboardType: TextInputType.number
                          ),
                        ),
                        InputDropdownHalfWidth(
                          title: 'Jenis Lantai',
                          lookupData: lookupData['JenisLantai'],
                          onChangedDropdownList: onChangedDropdown,
                          param: 'JenisLantai',
                          initialValue: initialData['_JenisLantai_description'],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        InputDropdownHalfWidth(
                          title: 'Keterangan Jendela',
                          lookupData: lookupData['KeteranganJendela'],
                          onChangedDropdownList: onChangedDropdown,
                          param: 'KeteranganJendela',
                          initialValue: initialData['_KeteranganJendela_description'],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        InputDropdownHalfWidth(
                          title: 'Penerangan Rumah',
                          lookupData: lookupData['SumberPenerangan'],
                          onChangedDropdownList: onChangedDropdown,
                          param: 'SumberPenerangan',
                          initialValue: initialData['_SumberPenerangan_description'],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        InputDropdownHalfWidth(
                          title: 'Fasilitas MCK',
                          lookupData: lookupData['FasilitasMCK'],
                          onChangedDropdownList: onChangedDropdown,
                          param: 'FasilitasMCK',
                          initialValue: initialData['_FasilitasMCK_description'],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        InputDropdownHalfWidth(
                          title: 'Lokasi Dekat Gunung',
                          lookupData: lookupData['PilihanYaTidak'],
                          onChangedDropdownList: onChangedDropdown,
                          param: 'LokasiDekatGunung',
                          initialValue: initialData['_LokasiDekatGunung_description'],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          height: 70,
                          child: InputTextForm.buildContainerInputHorizontal(
                            buildContext: context,
                            title: 'Kondisi rumah secara keseluruhan',
                            initialValue: initialData['KondisiRumah'],
                            isDropdownList: false,
                            onChangedAction: onChanged,
                            key: 'KondisiRumah',
                          ),
                        ),
                        SizedBox(
                          height: 90,
                          child: InputTextForm.buildContainerInputHorizontal(
                            buildContext: context,
                            keyboardType: TextInputType.number,
                            title:
                                'Jumlah pengguna transportasi umum (bulan terakhir)',
                            initialValue:
                                initialData['PenggunaanTransprtsi'],
                            isDropdownList: false,
                            onChangedAction: onChanged,
                            key: 'PenggunaanTransprtsi',
                          ),
                        ),
                        SizedBox(
                          height: 90,
                          child: InputTextForm.buildContainerInputHorizontal(
                            keyboardType: TextInputType.number,
                            buildContext: context,
                            title:
                                'Jumlah pengguna transportasi umum (bulan sebelumnya)',
                            initialValue:
                                initialData['PenggunaanTrnsprtsi2'],
                            isDropdownList: false,
                            onChangedAction: onChanged,
                            key: 'PenggunaanTrnsprtsi2',
                          ),
                        ),
                        InputDropdownHalfWidth(
                          title: 'Status Tempat Tinggal',
                          lookupData: lookupData['StatusTempatTinggal'],
                          onChangedDropdownList: onChangedDropdown,
                          param: 'StatusTempatTinggal',
                          initialValue: initialData['_StatusTempatTinggal_description'],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        InputDropdownHalfWidth(
                          title: 'Status Lahan Tinggal',
                          lookupData: lookupData['StatusLahanTempatTinggal'],
                          onChangedDropdownList: onChangedDropdown,
                          param: 'StatusLahan',
                          initialValue: initialData['_StatusLahan_description'],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        InputDropdownHalfWidth(
                          title: 'Jenis Bahan Dinding',
                          lookupData: lookupData['JenisDinding'],
                          onChangedDropdownList: onChangedDropdown,
                          param: 'JenisDinding',
                          initialValue: initialData['_JenisDinding_description'],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        InputDropdownHalfWidth(
                          title: 'Jenis Atap',
                          lookupData: lookupData['JenisAtap'],
                          onChangedDropdownList: onChangedDropdown,
                          param: 'JenisAtap',
                          initialValue: initialData['_JenisAtap_description'],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        InputDropdownHalfWidth(
                          title: 'Tempat Pembuangan Sampah',
                          lookupData: lookupData['TempatPembuanganSampah'],
                          onChangedDropdownList: onChangedDropdown,
                          param: 'PembuanganSampah',
                          initialValue: initialData['_PembuanganSampah_description'],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        InputDropdownHalfWidth(
                          title: 'Fasilitas BAB',
                          lookupData: lookupData['FasilitasBAB'],
                          onChangedDropdownList: onChangedDropdown,
                          param: 'FasilitasBAB',
                          initialValue: initialData['_FasilitasBAB_description'],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          height: 90,
                          child: InputTextForm.buildContainerInputHorizontal(
                            keyboardType: TextInputType.text,
                            buildContext: context,
                            title:
                            'Bantuan pemerintah yang diterima',
                            initialValue:
                            initialData['BantuanPemerintah'],
                            isDropdownList: false,
                            onChangedAction: onChanged,
                            key: 'BantuanPemerintah',
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        InputDropdownHalfWidth(
                          title: 'Posisi rumah di bawah SUTET/SUTT/SUTTAS?',
                          lookupData: lookupData['PilihanYaTidak'],
                          onChangedDropdownList: onChangedDropdown,
                          param: 'LokasiRumah',
                          initialValue: initialData['_LokasiRumah_description'],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        InputDropdownHalfWidth(
                          title: 'Lokasi Dekat Sungai',
                          lookupData: lookupData['PilihanYaTidak'],
                          onChangedDropdownList: onChangedDropdown,
                          param: 'LokasiBantaranSungai',
                          initialValue: initialData['_LokasiBantaranSungai_description'],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
