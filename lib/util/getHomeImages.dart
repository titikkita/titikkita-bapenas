import 'package:provider/provider.dart' as provider;
import 'package:titikkita/controller/cmdbuild_controller.dart';
import 'package:titikkita/state/indivivual_provider.dart';
import 'package:titikkita/state/local_provider.dart';

Future<void> getHomeImages(context) async {
  try {
    var id = provider.Provider.of<LocalProvider>(context, listen: false)
        .familyData['AlamatTinggal'];
   await CmdbuildController.getImageFromAddress(id, context).then((value){
      provider.Provider.of<LocalProvider>(context, listen: false)
          .updateAttachment('homeImages', value);
    });


  } catch (e) {
    print(e);
  }
}

Future<void> getIndividualHomeImages(context) async {
  try {
    var individualProvider =
        provider.Provider.of<IndividualProvider>(context, listen: false);
    var data = await CmdbuildController.getImageFromCitizen(
        individualProvider.individualData['_id'],
        individualProvider.individualData['_type'],
        context);
    individualProvider.updateAttachment('homeImages', data);
  } catch (e) {
    print(e);
  }
}

Future<void> getOtherAreaImages(context, id) async {
  try {
    // var id = provider.Provider.of<LocalProvider>(context,listen: false).familyData['AlamatTinggal'];
    var data = await CmdbuildController.getImageFromOtherArea(id, context);
    provider.Provider.of<LocalProvider>(context, listen: false)
        .updateAttachment('otherAreaImages', data);
  } catch (e) {
    print(e);
  }
}

Future<void> getReportImages(context, id, cardName) async {
  try {
    // var id = provider.Provider.of<LocalProvider>(context,listen: false).familyData['AlamatTinggal'];
    var data =
        await CmdbuildController.getImageFromReport(id, context, cardName);
    provider.Provider.of<LocalProvider>(context, listen: false)
        .updateAttachment(cardName, data);
  } catch (e) {
    print(e);
  }
}
