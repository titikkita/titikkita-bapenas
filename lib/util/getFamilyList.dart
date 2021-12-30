
import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider;
import 'package:titikkita/controller/cmdbuild_controller.dart';
import 'package:titikkita/state/local_provider.dart';
import 'package:titikkita/views/widgets/popupNotif.dart';

Future <dynamic> getFamilyList(context) async {
  var result;
  if (provider.Provider.of<LocalProvider>(context, listen: false)
      .familyListDropdown
      .length ==
      0) {
      await CmdbuildController.getAllFamilyList(context).then((value){
        provider.Provider.of<LocalProvider>(context, listen: false)
            .updateFamilyList(value);
        // provider.Provider.of<LocalProvider>(context, listen: false)
        //     .updateFamilyListDetails(value);
        // result = provider.Provider.of<LocalProvider>(context, listen: false)
        //     .familyList;

      }).catchError((e){
        ShowPopupNotification.errorNotification(
            context: context,
            content: 'Terjadi error: $e. Coba lagi nanti!',
            action: () {
              Navigator.pop(context);
            });
      });
  } else {
    result = provider.Provider.of<LocalProvider>(context, listen: false)
        .familyList;

  }
  return result;
}