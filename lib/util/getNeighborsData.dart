import 'package:titikkita/state/local_provider.dart';
import 'package:provider/provider.dart' as provider;
import 'package:titikkita/controller/cmdbuild_controller.dart';
import 'package:titikkita/util/getLookupData.dart';

Future<void> getNeighborData(context) async {
  try {
    var getLookupOrientation =
    await getLookupData(context, 'orientationLookup');

    var getNeighborList = await CmdbuildController.getNeighborList(
        provider.Provider.of<LocalProvider>(context, listen: false)
            .principalConstraint['data'][0]['_id'],context);

    if (getNeighborList['success'] == true) {
      provider.Provider.of<LocalProvider>(context, listen: false)
          .emptyNeighborLocation();

      for(var i=0; i<getNeighborList['data'].length; i++) {
        var getNeighborLocation =
        await CmdbuildController.getNeighborLocation(
            getNeighborList['data'][i]['_id'],context);

        if (getNeighborLocation['success'] == true) {
          var newLocation = {
            'x': getNeighborLocation['data']['x'],
            'y': getNeighborLocation['data']['y'],
            'data': getNeighborList['data'][i],
          };

          provider.Provider.of<LocalProvider>(context, listen: false)
              .updateNeighborLocation(newLocation);
        }
      }
    }
  } catch (e) {
    print('Error in map category when try to get neighbor data. Error: $e');
  }
}
