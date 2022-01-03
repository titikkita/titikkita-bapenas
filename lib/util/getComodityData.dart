import 'package:titikkita/state/local_provider.dart';
import 'package:provider/provider.dart' as provider;
import 'package:titikkita/controller/cmdbuild_controller.dart';
import 'package:titikkita/state/polyline_provider.dart';

Future<void> getComodityData(context) async {
  try {
    provider.Provider.of<PolylineProvider>(context,listen: false).emptyComodityPolygon();
    var getComodityList = await CmdbuildController.getComodityData(context,
        provider.Provider.of<LocalProvider>(context, listen: false)
            .principalConstraint['data'][0]['_id']);

    if (getComodityList['success'] == true) {
      provider.Provider.of<LocalProvider>(context, listen: false)
          .emptyComodityPoints();

      for(var i=0; i<getComodityList['data'].length; i++) {
        var getComodityPoints =
              await CmdbuildController.getComodityPoints(getComodityList['data'][i]['_id']);
    var newLocation;
          if (getComodityPoints['dataPoints']['success'] == true) {

            var data = getComodityPoints['dataPoints']['data'];
            newLocation = {
              'x': data['x'],
              'y': data['y'],
              'data': getComodityList['data'][i],
             };
          }else{
            newLocation = {
              'x': null,
              'y': null,
              'data': getComodityList['data'][i]
            };
          }
        provider.Provider.of<LocalProvider>(context, listen: false)
            .updateComodityPoints(newLocation);
        if (getComodityPoints['dataPolygon']['success'] == true) {
          var data = getComodityPoints['dataPolygon']['data'];
          provider.Provider.of<PolylineProvider>(context, listen: false)
              .updateComodityPolygon(data);
        }
        else{
          var data =  {"points":[]};
          provider.Provider.of<PolylineProvider>(context, listen: false)
              .updateComodityPolygon(data);
        }
      }
    }

    // print(getComodityPoints);

  } catch (e) {
    print(e);
    print('Error get comodity data. Error: $e');
  }
}
