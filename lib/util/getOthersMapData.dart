import 'package:titikkita/state/local_provider.dart';
import 'package:provider/provider.dart' as provider;
import 'package:titikkita/controller/cmdbuild_controller.dart';
import 'package:titikkita/util/getLookupData.dart';

Future<void> getOtherAreaData(context) async {
  try {
    await getLookupData(context, 'orientationLookup');

    var getOtherAreaList = await CmdbuildController.getOtherAreaList(
        provider.Provider.of<LocalProvider>(context, listen: false)
            .principalConstraint['data'][0]['_id'],context);

    if (getOtherAreaList['success'] == true) {
      provider.Provider.of<LocalProvider>(context, listen: false)
          .emptyOtherAreaList();

      for (var i = 0; i < getOtherAreaList['data'].length; i++) {
        var getOtherAreaGeom = await CmdbuildController.getOtherAreaGeom(
            getOtherAreaList['data'][i]['_id'],context);

        if (getOtherAreaGeom['success'] == true) {
          var newLocation = {
            'x': getOtherAreaGeom['data']['x'],
            'y': getOtherAreaGeom['data']['y'],
            'data': getOtherAreaList['data'][i],
          };

          provider.Provider.of<LocalProvider>(context, listen: false)
              .updateOtherAreaList(newLocation);
        }
      }
    }

  } catch (e) {
    print('Error in map category when try to get neighbor data. Error: $e');
  }
}
