
import 'package:titikkita/state/local_provider.dart';
import 'package:provider/provider.dart' as provider;
import 'package:titikkita/controller/cmdbuild_controller.dart';
import 'package:titikkita/state/polyline_provider.dart';

Future <void> getFamilyPolygonPoints(context) async {

  try {

    provider.Provider.of<PolylineProvider>(context, listen: false)
        .emptyOtherFamilyPoints();

    var id = provider.Provider.of<LocalProvider>(context, listen: false)
        .principalConstraint['data'][0]['_id'];



    var persilId = await CmdbuildController.getFamilyLotId(id,context);

    if (persilId['success'] == true && persilId['data'].length != 0) {

      for(var i=0; i<persilId['data'].length; i++){
        var getPoints =
        await CmdbuildController.getFamilyPolylinePoints(persilId['data'][i]['_id'],context);

        getPoints['data']['cardData']=persilId['data'][i];

        // provider.Provider.of<PolylineProvider>(context, listen: false)
        //     .updatePolylinePoints({'geomValue':getPoints['data']['points'], 'data':persilId['data'][i]});
        provider.Provider.of<PolylineProvider>(context, listen: false)
            .updateOtherFamilyPoints(getPoints['data']);

      }
    }
  } catch (e) {
    print('Error get family polygon : $e');
  }
}

Future <void> getIndividualPolygonPoints(context) async {

  try {

    provider.Provider.of<PolylineProvider>(context,listen: false).emptyPolygonPoint();

    var id = provider.Provider.of<LocalProvider>(context, listen: false)
        .principalConstraint['data'][0]['_id'];


    var persilId = await CmdbuildController.getFamilyLotId(id,context);

    if (persilId['success'] == true && persilId['data'].length != 0) {

      for(var i=0; i<persilId['data'].length; i++){

        var getPoints =
        await CmdbuildController.getFamilyPolylinePoints(persilId['data'][i]['_id'],context);

        provider.Provider.of<PolylineProvider>(context, listen: false)
            .updatePolylinePoints({'geomValue':getPoints['data']['points'], 'data':persilId['data'][i]});
      }
    }
  } catch (e) {
    print('Error get family polygon : $e');
  }
}
