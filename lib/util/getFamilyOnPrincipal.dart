import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart' as provider;
import 'package:titikkita/controller/cmdbuild_controller.dart';
import 'package:titikkita/state/local_provider.dart';
import 'package:titikkita/state/principal_provider.dart';
import 'package:titikkita/views/widgets/popupNotif.dart';

Future <dynamic> getFamilyListForPrincipal(context)async{
  var returnResult;

  var findData = provider.Provider.of<LocalProvider>(context, listen: false)
      .principalInformationData['familyList'];

  if (findData == null) {
    var constraintDataFromState =
    provider.Provider.of<LocalProvider>(context, listen: false)
        .principalConstraint['data'][0];

    // get family list
    var filterKey;
    if(constraintDataFromState['_Jabatan_code'] == 'Ketua RT'){
      filterKey = 'RT';
    }
    if(constraintDataFromState['_Jabatan_code'] == 'Ketua RW'){
      filterKey = 'RW';
    }
    if(constraintDataFromState['_Jabatan_code'] == 'Kepala Desa'){
      filterKey = '_tenant';
    }
    if(constraintDataFromState['_Jabatan_code'] == 'Ketua Dusun'){
      filterKey = 'Dusun';
    }

    await CmdbuildController.findCardWithFilter(
        context: context,
        cardName: 'app_family',
        filter: 'equal',
        key: '$filterKey',
        value:filterKey == '_tenant' ?  constraintDataFromState['Desa'] : constraintDataFromState['$filterKey'])
        .then((family) {

      if (family['data'].length != 0) {
        provider.Provider.of<LocalProvider>(context, listen: false)
            .updatePrincipalInformationData('familyList', family['data']);
        provider.Provider.of<PrincipalProvider>(context, listen: false)
            .updateFamily(family['data']);
       returnResult = family['data'];
      }
    }).catchError((e) {
      print(e);
      ShowPopupNotification.errorNotification(
          context: context,
          content: 'Terjadi error: $e. Coba lagi nanti!',
          action: () {
            Navigator.of(context, rootNavigator: true).pop();
          });
    });
  } else {

    returnResult = findData;
  }

  return returnResult;
}