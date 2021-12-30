import 'package:provider/provider.dart' as provider;
import 'package:titikkita/controller/cmdbuild_controller.dart';
import 'package:titikkita/state/local_provider.dart';

Future<dynamic> getLookupData(context, kind) async {
  List lookupList;
  Map<String, dynamic> lookupData;
  switch (kind) {
    case 'memberLookup':
      lookupList = [
        'Agama',
        'JenisKelamin',
        'Negara',
        'Pekerjaan',
        'GolonganDarah',
        'StatusKawin',
        'StatusTempatTinggal',
        'JenisCacat',
        'Pendidikan',
        'PilihanYaTidak',
        'PilihanYaTidak2',
        'KecepatanInternet',
        'SumberInternet',
        'KondisiPekerjaan',
        'JaminanSosialKetenagakerjaan',
        'Penyakit',
        'TingkatKepuasanLayanan',
        'StatusDalamKeluarga',
        'BidangPekerjaan',
        'PenghasilanPerbulan',
        'JenisImunisasi',
        'PartisipasiSekolah',
        'PenyakitKelainan',
      ];
      lookupData = await CmdbuildController.getLookupData(lookupList, context);
      break;
    case 'comodityLookup':
      lookupList = [
        'JenisKomoditi',
        'TanamanPangan',
        'Buahbuahan',
        'TanamanObat',
        'TanamanPerkebunan',
        'Perikanan',
        'HasilHutan',
        'HasilTernak'
      ];
      lookupData = await CmdbuildController.getLookupData(lookupList, context);
      break;
    case 'addressLookup':
      lookupList = [
        'BahanBakarMasak',
        'AirRumah',
        'AirMinum',
        'ProgramPemerintah',
        'Pendidikan',
        'PilihanYaTidak',
        'SumberKayuBakar',
        'JenisLantai',
        'KeteranganJendela',
        'FasilitasMCK',
        'StatusTempatTinggal',
        'StatusLahanTempatTinggal',
        'JenisDinding',
        'TempatPembuanganSampah',
        'FasilitasBAB',
        'JenisAtap',
        'KeteranganMemiliki',
        'AirBuangan',
        'SumberPenerangan',
        'Listrik'
      ];
      lookupData = await CmdbuildController.getLookupData(lookupList, context);
      break;
    case 'orientationLookup':
      lookupList = ['OrientasiLokasi'];
      lookupData = await CmdbuildController.getLookupData(lookupList, context);
      break;
  }

  provider.Provider.of<LocalProvider>(context, listen: false)
      .updateLookupData(lookupData, kind);
  return lookupData;
}
