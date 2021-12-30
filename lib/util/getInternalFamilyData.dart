import 'package:provider/provider.dart' as provider;
import 'package:titikkita/state/local_provider.dart';
import 'package:titikkita/controller/cmdbuild_controller.dart';

Future<void> fetchingInternalDataFamily(context) async {
  try {
    var addressId =
        provider.Provider.of<LocalProvider>(context, listen: false)
            .familyData['AlamatTinggal'];

    var address = await CmdbuildController.getFamilyAddress(filterValue: '$addressId');

    provider.Provider.of<LocalProvider>(context, listen: false)
        .updateAddressData(address);
  } catch (e) {
    print('error fetch data members on dashboard $e');
  }
}
