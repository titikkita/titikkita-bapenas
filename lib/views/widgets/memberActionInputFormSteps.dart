import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:titikkita/state/local_provider.dart';
import 'package:titikkita/views/widgets/generalInputText.dart';
import 'package:provider/provider.dart' as provider;
import 'package:titikkita/views/widgets/multiSelectBuilder.dart';

class MemberActionFormSteps {

  static step1(
      {buildContext,
      data,
      onChangedValue,
      onChangedDropdownList,
      onChangedDate,
      isEditMode,
      formatDate,
      isValidate,
      validation,
      onChangedDropdownLocal}) {
    return [
      InputTextForm.textInputFieldWithBorder(
        title: '*NIK',
        keyboardType: TextInputType.number,
        initialValue: data['Code'],
        attributeName: 'Code',
        action: onChangedValue,
        isValidate: isValidate['Code'],
        validation: validation['Code'],
      ),
      // //smartvillage2
      InputTextForm.textInputFieldWithBorder(
        title: '*Nama Lengkap',
        keyboardType: TextInputType.text,
        initialValue: data['Description'],
        attributeName: 'Description',
        action: onChangedValue,
        isValidate: isValidate['Description'],
        validation: validation['Description'],
      ),
      InputTextForm.textInputFieldWithBorder(
        title: '*No urut dalam KK',
        keyboardType: TextInputType.number,
        initialValue: data['NoUrutKK'],
        attributeName: 'NoUrutKK',
        action: onChangedValue,
      ),
      InputTextForm.dropdownInputFieldWithBorder(
        attributeName: 'JenisKelamin',
        lookupName: 'JenisKelamin',
        title: "Jenis Kelamin",
        itemList:
            provider.Provider.of<LocalProvider>(buildContext, listen: false)
                .lookupData,
        action: onChangedDropdownList,
        initialValue: data['_JenisKelamin_code'],
      ),
      InputTextForm.textInputFieldWithBorder(
        title: 'Alamat Asal',
        keyboardType: TextInputType.text,
        initialValue: data['AlamatAsal'],
        attributeName: 'AlamatAsal',
        action: onChangedValue,
      ),
      InputTextForm.textInputFieldWithBorder(
        title: 'Tempat Lahir',
        keyboardType: TextInputType.text,
        initialValue: data['TempatLahir'],
        attributeName: 'TempatLahir',
        action: onChangedValue,
      ),
      InputTextForm.dateTimeInputFieldWithBorder(
        title: 'Tanggal Lahir',
        initialDateValue: data['TanggalLahir'],
        action: onChangedDate,
        dateFormat: formatDate,
      ),
      InputTextForm.textInputFieldWithBorder(
        title: 'Usia',
        keyboardType: TextInputType.number,
        initialValue: data['Umur'],
        attributeName: 'Umur',
        action: onChangedValue,
      ),
      InputTextForm.textInputFieldWithBorder(
        title: 'Nomor akte kelahiran',
        keyboardType: TextInputType.number,
        initialValue: data['NoAkteKelahiran'],
        attributeName: 'NoAkteKelahiran',
        action: onChangedValue,
      ),
      InputTextForm.dropdownInputFieldWithBorder(
        attributeName: 'GolonganDarah',
        lookupName: 'GolonganDarah',
        title: "Golongan Darah",
        itemList:
            provider.Provider.of<LocalProvider>(buildContext, listen: false)
                .lookupData,
        action: onChangedDropdownList,
        initialValue: data['_GolonganDarah_code'],
      ),
      InputTextForm.dropdownInputFieldWithBorder(
        attributeName: 'KepemilikanEKTP',
        lookupName: 'PilihanYaTidak2',
        title: 'Kepemilikan E-KTP',
        itemList:
            provider.Provider.of<LocalProvider>(buildContext, listen: false)
                .lookupData,
        action: onChangedDropdownList,
        initialValue: data['_KepemilikanEKTP_code'],
      ),
      InputTextForm.dropdownInputFieldWithBorder(
          attributeName: 'StatusKawin',
          lookupName: 'StatusKawin',
          title: 'Status Kawin',
          itemList:
              provider.Provider.of<LocalProvider>(buildContext, listen: false)
                  .lookupData,
          action: onChangedDropdownList,
          initialValue: data['_StatusKawin_code']),
      InputTextForm.textInputFieldWithBorder(
        title: 'Nomor akta nikah/cerai',
        keyboardType: TextInputType.number,
        initialValue: data['NoAktaNikahAtauCerai'],
        attributeName: 'NoAktaNikahAtauCerai',
        action: onChangedValue,
      ),
      InputTextForm.textInputFieldWithBorder(
        title: 'Nama bapak/ibu kandung',
        initialValue: data['NamaOrangTua'],
        attributeName: 'NamaOrangTua',
        action: onChangedValue,
      ),
      InputTextForm.dropdownInputFieldWithBorder(
        attributeName: 'StatusDalamKeluarga',
        lookupName: 'StatusDalamKeluarga',
        title: 'Status Dalam Keluarga',
        itemList:
            provider.Provider.of<LocalProvider>(buildContext, listen: false)
                .lookupData,
        action: onChangedDropdownList,
        initialValue: data['_StatusDalamKeluarga_code'],
      ),
      InputTextForm.dropdownInputFieldWithBorder(
        attributeName: 'Agama',
        lookupName: 'Agama',
        title: 'Agama',
        itemList:
            provider.Provider.of<LocalProvider>(buildContext, listen: false)
                .lookupData,
        action: onChangedDropdownList,
        initialValue: data['_Agama_code'],
      ),
      InputTextForm.textInputFieldWithBorder(
        title: 'Suku Bangsa',
        initialValue: data['SukuBangsa'],
        attributeName: 'SukuBangsa',
        action: onChangedValue,
      ),
      InputTextForm.dropdownInputFieldWithBorder(
        attributeName: 'WargaNegara',
        lookupName: 'Negara',
        title: 'Warga Negara',
        itemList:
            provider.Provider.of<LocalProvider>(buildContext, listen: false)
                .lookupData,
        action: onChangedDropdownList,
        initialValue: data['_WargaNegara_code'],
      ),
      InputTextForm.dropdownInputFieldWithBorder(
        attributeName: 'StatusTempatTinggal',
        lookupName: 'StatusTempatTinggal',
        title: 'Status Tempat Tinggal',
        itemList:
            provider.Provider.of<LocalProvider>(buildContext, listen: false)
                .lookupData,
        action: onChangedDropdownList,
        initialValue: data['_StatusTempatTinggal_code'],
      ),
      InputTextForm.textInputFieldWithBorder(
        title: 'Nomor Telepon',
        keyboardType: TextInputType.number,
        initialValue: data['NomorHP'],
        attributeName: 'NomorHP',
        action: onChangedValue,
      ),
      InputTextForm.textInputFieldWithBorder(
        title: 'Nomor WhatsApp',
        keyboardType: TextInputType.number,
        initialValue: data['NomorWhatsapp'],
        attributeName: 'NomorWhatsapp',
        action: onChangedValue,
      ),
      InputTextForm.textInputFieldWithBorder(
        title: 'Alamat Email',
        initialValue: data['AlamatEmail'],
        attributeName: 'AlamatEmail',
        action: onChangedValue,
      ),
      InputTextForm.textInputFieldWithBorder(
        title: 'Alamat Facebook',
        initialValue: data['AlamatFacebook'],
        attributeName: 'AlamatFacebook',
        action: onChangedValue,
      ),
      InputTextForm.textInputFieldWithBorder(
        title: 'Alamat Twitter',
        initialValue: data['AlamatTwitter'],
        attributeName: 'AlamatTwitter',
        action: onChangedValue,
      ),
      InputTextForm.textInputFieldWithBorder(
        title: 'Alamat Instagram',
        initialValue: data['AlamatInstagram'],
        attributeName: 'AlamatInstagram',
        action: onChangedValue,
      ),
      InputTextForm.dropdownInputFieldWithBorder(
        attributeName: 'SumberInternet',
        lookupName: 'SumberInternet',
        title: 'Sumber Internet',
        itemList:
            provider.Provider.of<LocalProvider>(buildContext, listen: false)
                .lookupData,
        action: onChangedDropdownList,
        initialValue: data['_SumberInternet_code'],
      ),
      InputTextForm.dropdownInputFieldWithBorder(
        attributeName: 'KecepatanInternet',
        lookupName: 'KecepatanInternet',
        title: "Kecepatan Internet",
        itemList:
            provider.Provider.of<LocalProvider>(buildContext, listen: false)
                .lookupData,
        action: onChangedDropdownList,
        initialValue: data['_KecepatanInternet_code'],
      ),
    ];
  }

  static step2(
      {buildContext,
      data,
      controller,
      onChangedValue,
      onChangedDropdownList,
      onChangedDate,
      isEditMode,
      formatDate}) {
    return [
      InputTextForm.dropdownInputFieldWithBorder(
        attributeName: 'KondisiPekerjaan',
        lookupName: 'KondisiPekerjaan',
        title: 'Kondisi Pekerjaan',
        itemList:
            provider.Provider.of<LocalProvider>(buildContext, listen: false)
                .lookupData,
        action: onChangedDropdownList,
        initialValue: data['_KondisiPekerjaan_code'],
      ),
      InputTextForm.dropdownInputFieldWithBorder(
        attributeName: 'PekerjaanUtama',
        lookupName: 'Pekerjaan',
        title: 'Pekerjaan Utama',
        itemList:
            provider.Provider.of<LocalProvider>(buildContext, listen: false)
                .lookupData,
        action: onChangedDropdownList,
        initialValue: data['_PekerjaanUtama_code'],
      ),
      InputTextForm.dropdownInputFieldWithBorder(
        attributeName: 'BidangPekerjaan',
        lookupName: 'BidangPekerjaan',
        title: 'Bidang Pekerjaan',
        itemList:
            provider.Provider.of<LocalProvider>(buildContext, listen: false)
                .lookupData,
        action: onChangedDropdownList,
        initialValue: data['_BidangPekerjaan_code'],
      ),
      InputTextForm.dropdownInputFieldWithBorder(
        attributeName: 'JaminanSosialKerja',
        lookupName: 'JaminanSosialKetenagakerjaan',
        title: 'Jaminan sosial ketenagakerjaan',
        itemList:
            provider.Provider.of<LocalProvider>(buildContext, listen: false)
                .lookupData,
        action: onChangedDropdownList,
        initialValue: data['_JaminanSosialKerja_code'],
      ),
      InputTextForm.dropdownInputFieldWithBorder(
        attributeName: 'PenghasilanPerbulan',
        lookupName: 'PenghasilanPerbulan',
        title: 'Penghasilan perbulan',
        itemList:
            provider.Provider.of<LocalProvider>(buildContext, listen: false)
                .lookupData,
        action: onChangedDropdownList,
        initialValue: data['_PenghasilanPerbulan_code'],
      ),
      InputTextForm.dropdownInputFieldWithBorder(
        attributeName: 'Pensiunan',
        lookupName: 'PilihanYaTidak',
        title: 'Pensiunan',
        itemList:
            provider.Provider.of<LocalProvider>(buildContext, listen: false)
                .lookupData,
        action: onChangedDropdownList,
        initialValue: data['_Pensiunan_code'],
      ),
    ];
  }

  static step3(
      {buildContext,
      data,
      isEditMode,
      onChangedValue,
      onChangedDropdownList,
      onChangedDate,
      formatDate,
      initialSelected}) {
    print(data['StatusASIAnak'],);
    return [
      MultiSelectBuilder.modalCheckBoxList(
          buildContext: buildContext,
          onChangedValue: onChangedValue,
          data: data,
        lookupName: 'Penyakit',
        attributeName: 'Penyakit',
        title:'Penyakit yang diderita setahun terakhir'
      ),
      MultiSelectBuilder.modalCheckBoxList(
          buildContext: buildContext,
          onChangedValue: onChangedValue,
          data: data,
          lookupName: 'JenisImunisasi',
          attributeName: 'Imunisasi',
          title:'Cakupan imunisasi'
      ),
      data['_JenisKelamin_code'] == 'Perempuan' ?
      Column(
        children: [
          InputTextForm.dropdownInputFieldWithBorder(
            attributeName: 'StatusKehamilan',
            lookupName: 'PilihanYaTidak',
            title: 'Status kehamilan(khusus wanita)',
            itemList:
                provider.Provider.of<LocalProvider>(buildContext, listen: false)
                    .lookupData,
            action: onChangedDropdownList,
            initialValue: data['_StatusKehamilan_code'],
          ),
          InputTextForm.textInputFieldWithBorder(
            title: 'Alat KB(khusus wanita usia 10-49 th)',
            initialValue: data['AlatKB'],
            attributeName: 'AlatKB',
            action: onChangedValue,
          ),
          InputTextForm.dropdownInputFieldWithBorder(
            attributeName: 'StatusASIAnak',
            lookupName: 'PilihanYaTidak',
            title: 'Apakah bayi Bapak/Ibu memperoleh ASI eksklusif?',
            itemList:
                provider.Provider.of<LocalProvider>(buildContext, listen: false)
                    .lookupData,
            action: onChangedDropdownList,
            initialValue: data['_StatusASIAnak_code'],
          ),
        ],
      ) : Container(),

      InputTextForm.dropdownInputFieldWithBorder(
        attributeName: 'PenderitaKelainan',
        lookupName: 'PilihanYaTidak',
        title: 'Penderita sakit dan kelainan',
        itemList:
            provider.Provider.of<LocalProvider>(buildContext, listen: false)
                .lookupData,
        action: onChangedDropdownList,
        initialValue: data['_PenderitaKelainan_code'],
      ),
      MultiSelectBuilder.modalCheckBoxList(
          buildContext: buildContext,
          onChangedValue: onChangedValue,
          data: data,
          lookupName: 'PenyakitKelainan',
          attributeName: 'PenyakitKelainan',
          title:'Jenis kelainan'
      ),
      MultiSelectBuilder.modalCheckBoxList(
          buildContext: buildContext,
          onChangedValue: onChangedValue,
          data: data,
          lookupName: 'JenisCacat',
          attributeName: 'Cacat',
          title:'Cacat'
      ),
      InputTextForm.dropdownInputFieldWithBorder(
        attributeName: 'JaminanKesehatan',
        lookupName: 'JaminanSosialKetenagakerjaan',
        title: 'Jaminan sosial kesehatan',
        itemList:
            provider.Provider.of<LocalProvider>(buildContext, listen: false)
                .lookupData,
        action: onChangedDropdownList,
        initialValue: data['_JaminanKesehatan_code'],
      ),
    ];
  }

  static step4(
      {buildContext,
      data,
      isEditMode,
      onChangedValue,
      onChangedDropdownList,
      onChangedDate,
      formatDate}) {
    return [
      InputTextForm.dropdownInputFieldWithBorder(
        attributeName: 'PastisipasiSekolah',
        lookupName: 'PartisipasiSekolah',
        title: 'Partisipasi sekolah',
        itemList:
            provider.Provider.of<LocalProvider>(buildContext, listen: false)
                .lookupData,
        action: onChangedDropdownList,
        initialValue: data['_PastisipasiSekolah_code'],
      ),
      InputTextForm.dropdownInputFieldWithBorder(
        attributeName: 'PendidikanTerakhir',
        lookupName: 'Pendidikan',
        title: 'Pendidikan terakhir',
        itemList:
            provider.Provider.of<LocalProvider>(buildContext, listen: false)
                .lookupData,
        action: onChangedDropdownList,
        initialValue: data['_PendidikanTerakhir_code'],
      ),
      InputTextForm.textInputFieldWithBorder(
        title: 'Kelas tertinggi',
        initialValue: data['LamaPendidikanDasar'],
        attributeName: 'LamaPendidikanDasar',
        action: onChangedValue,
        keyboardType: TextInputType.number,
      ),
      InputTextForm.dropdownInputFieldWithBorder(
        attributeName: 'IjazahTerakhir',
        lookupName: 'Pendidikan',
        title: 'Ijazah pendidikan terakhir',
        itemList:
            provider.Provider.of<LocalProvider>(buildContext, listen: false)
                .lookupData,
        action: onChangedDropdownList,
        initialValue: data['_IjazahTerakhir_code'],
      ),
      InputTextForm.dropdownInputFieldWithBorder(
        attributeName: 'BisaBacaTulis',
        lookupName: 'PilihanYaTidak',
        title: 'Kesulitan baca tulis',
        itemList:
            provider.Provider.of<LocalProvider>(buildContext, listen: false)
                .lookupData,
        action: onChangedDropdownList,
        initialValue: data['_BisaBacaTulis_code'],
      ),
    ];
  }

  static step5(
      {buildContext,
      data,
      isEditMode,
      onChangedValue,
      onChangedDropdownList,
      onChangedDate,
      formatDate}) {
    return [
      InputTextForm.textInputFieldWithBorder(
        title: 'Bahasa yang digunakan di rumah dan permukiman:',
        initialValue: data['BahasaKeseharian'],
        attributeName: 'BahasaKeseharian',
        action: onChangedValue,
      ),
      InputTextForm.textInputFieldWithBorder(
        title: 'Bahasa digunakan di lembaga formal (sekolah, tempat kerja):',
        initialValue: data['BahasaFormal'],
        attributeName: 'BahasaFormal',
        action: onChangedValue,
      ),
      InputTextForm.textInputFieldWithBorder(
        title: 'Pesta rakyat setahun terakhir (jumlah):',
        initialValue: data['PestaRakyat'],
        attributeName: 'PestaRakyat',
        action: onChangedValue,
        keyboardType: TextInputType.number,
      ),
      InputTextForm.textInputFieldWithBorder(
        title: 'Kerja bakti setahun terakhir (jumlah):',
        initialValue: data['KerjaBakti'],
        attributeName: 'KerjaBakti',
        action: onChangedValue,
        keyboardType: TextInputType.number,
      ),
      InputTextForm.textInputFieldWithBorder(
        title: 'Siskamling setahun terakhir (jumlah):',
        initialValue: data['Siskamling'],
        attributeName: 'Siskamling',
        action: onChangedValue,
        keyboardType: TextInputType.number,
      ),
      // InputTextForm.textInputFieldWithBorder(
      //   title: 'Pesta rakyat/adat setahun terakhir (jumlah): ',
      //   initialValue: data['PestaRakyat'],
      //   attributeName: 'PestaRakyat',
      //   action: onChangedValue,
      //   keyboardType: TextInputType.number,
      // ),
      InputTextForm.textInputFieldWithBorder(
        title:
            'Menolong warga yang mengalami kematian keluarga setahun terakhir (jumlah):',
        initialValue: data['MenolongKematian'],
        attributeName: 'MenolongKematian',
        action: onChangedValue,
        keyboardType: TextInputType.number,
      ),
      InputTextForm.textInputFieldWithBorder(
        title: 'Menolong warga yang sedang sakit setahun terakhir (jumlah):',
        initialValue: data['MenolongYangSakit'],
        attributeName: 'MenolongYangSakit',
        action: onChangedValue,
        keyboardType: TextInputType.number,
      ),
      InputTextForm.textInputFieldWithBorder(
        title: 'Menolong warga yang kecelakaan setahun terakhir (jumlah): ',
        initialValue: data['MenolongKecelakaan'],
        attributeName: 'MenolongKecelakaan',
        action: onChangedValue,
        keyboardType: TextInputType.number,
      ),
      InputTextForm.dropdownInputFieldWithBorder(
        attributeName: 'PelayananDesa',
        lookupName: 'PilihanYaTidak',
        title: 'Dalam setahun terakhir memperoleh pelayanan desa: ',
        itemList:
            provider.Provider.of<LocalProvider>(buildContext, listen: false)
                .lookupData,
        action: onChangedDropdownList,
        initialValue: data['_PelayananDesa_code'],
      ),
      InputTextForm.dropdownInputFieldWithBorder(
        attributeName: 'StatusPelayananDesa',
        lookupName: 'TingkatKepuasanLayanan',
        title: 'Bagaimana pelayanan desa yang diperoleh: ',
        itemList:
            provider.Provider.of<LocalProvider>(buildContext, listen: false)
                .lookupData,
        action: onChangedDropdownList,
        initialValue: data['_StatusPelayananDesa_code'],
      ),
      InputTextForm.dropdownInputFieldWithBorder(
        attributeName: 'SaranUntukDesa',
        lookupName: 'PilihanYaTidak',
        title:
            'Dalam setahun terakhir apakah pernah menyampaikan masukan/saran kepada pihak desa: ',
        itemList:
            provider.Provider.of<LocalProvider>(buildContext, listen: false)
                .lookupData,
        action: onChangedDropdownList,
        initialValue: data['_SaranUntukDesa_code'],
      ),
      InputTextForm.dropdownInputFieldWithBorder(
        attributeName: 'KeterbukaanDesa',
        lookupName: 'TingkatKepuasanLayanan',
        title: 'Bagaimana keterbukaan desa terhadap masukan: ',
        itemList:
            provider.Provider.of<LocalProvider>(buildContext, listen: false)
                .lookupData,
        action: onChangedDropdownList,
        initialValue: data['_KeterbukaanDesa_code'],
      ),
      InputTextForm.dropdownInputFieldWithBorder(
        attributeName: 'TerjadiBencana',
        lookupName: 'PilihanYaTidak',
        title: 'Dalam setahun terakhir apakah terjadi bencana: ',
        itemList:
            provider.Provider.of<LocalProvider>(buildContext, listen: false)
                .lookupData,
        action: onChangedDropdownList,
        initialValue: data['_TerjadiBencana_code'],
      ),
      InputTextForm.dropdownInputFieldWithBorder(
        attributeName: 'TerdampakBencana',
        lookupName: 'PilihanYaTidak',
        title: 'Apakah anda pernah terdampak bencana?:  ',
        itemList:
            provider.Provider.of<LocalProvider>(buildContext, listen: false)
                .lookupData,
        action: onChangedDropdownList,
        initialValue: data['_TerdampakBencana_code'],
      ),
      InputTextForm.dropdownInputFieldWithBorder(
        attributeName: 'BantuanBencana',
        lookupName: 'PilihanYaTidak',
        title:
            'Apakah menerima pemenuhan kebutuhan dasar saat bencana (makanan,pakaian,tempat tinggal)?: ',
        itemList:
            provider.Provider.of<LocalProvider>(buildContext, listen: false)
                .lookupData,
        action: onChangedDropdownList,
        initialValue: data['_BantuanBencana_code'],
      ),
      InputTextForm.dropdownInputFieldWithBorder(
        attributeName: 'BantuanPsikologi',
        lookupName: 'PilihanYaTidak',
        title:
            'Apakah ada penanganan psikososial keluarga terdampak bencana (penyuluhan/konseling/terapi)?:  ',
        itemList:
            provider.Provider.of<LocalProvider>(buildContext, listen: false)
                .lookupData,
        action: onChangedDropdownList,
        initialValue: data['_BantuanPsikologi_code'],
      ),
    ];
  }

  static step6({imageName, selectImage, isEditMode, imageFile, data, context}) {
    return [
      InputTextForm.imageInputField(
        imageData: data,
        title: 'Foto KTP',
        initialValue: imageFile,
        action: selectImage,
        isImageShow: true,
        onEditImage: imageFile,
        imageName: imageName,
        context: context,
      ),
    ];
  }
}
