import 'package:provider/provider.dart' as provider;
import 'package:titikkita/state/local_provider.dart';
import 'package:titikkita/controller/cmdbuild_controller.dart';

Future<void> fetchingDataFamilyMembers(context) async {

  try {
    var familyId =
        provider.Provider.of<LocalProvider>(context, listen: false).familyData['_id'];
    var addressId =
        provider.Provider.of<LocalProvider>(context, listen: false)
            .familyData['AlamatTinggal'];

    var familyMembers = await CmdbuildController.getAllFamilyMembersData(membersFilterValue: '$familyId');
    var familyNonMembers = await CmdbuildController.getAllFamilyNonMembersData(membersFilterValue: '$familyId');


    if( provider.Provider.of<LocalProvider>(context, listen: false).address == null){
      var address = await CmdbuildController.getFamilyAddress(filterValue: '$addressId');

      provider.Provider.of<LocalProvider>(context, listen: false)
          .updateAddressData(address);
    }

    provider.Provider.of<LocalProvider>(context, listen: false)
        .updateMembers(familyMembers,familyNonMembers);
  } catch (e) {
    print('error fetch data members on category $e');
  }
}
