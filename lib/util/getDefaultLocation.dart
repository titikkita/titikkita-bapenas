import 'package:flutter_map/flutter_map.dart';
import 'package:titikkita/state/indivivual_provider.dart';
import 'package:titikkita/state/location_provider.dart';
import 'package:titikkita/state/local_provider.dart';
import 'package:provider/provider.dart' as provider;
import 'package:titikkita/controller/cmdbuild_controller.dart';

Future<void> getDefaultLocation(context) async {
  SphericalMercator mercator = SphericalMercator();
  try {
    var id =
        provider.Provider.of<LocalProvider>(context, listen: false).familyData;

    var result = await CmdbuildController.getFamilyLocationPoint(
        id['AlamatTinggal'], context);



    if (result['success'] == true) {
      var x = result['data']['x'];
      var y = result['data']['y'];

      var point = CustomPoint(x, y);
      var afterConvert = mercator.unproject(point);

      // var address = await LocationController.getCurrentAddres(
      //     afterConvert.latitude, afterConvert.longitude);

      provider.Provider.of<LocationProvider>(context, listen: false)
          .updateCoordinateAndAddress({
        'latitude': afterConvert.latitude,
        'longitude': afterConvert.longitude,
        // 'address': address
      });

    }

    var dataAddress = await CmdbuildController.getFamilyAddress(
        filterValue: provider.Provider.of<LocalProvider>(context, listen: false)
            .familyData['AlamatTinggal']);
    if (dataAddress['success']) {
      provider.Provider.of<LocalProvider>(context, listen: false)
          .updateAddressData(dataAddress);
    }
  } catch (err) {
    var dataAddress = await CmdbuildController.getFamilyAddress(
        filterValue: provider.Provider.of<LocalProvider>(context, listen: false)
            .familyData['AlamatTinggal']);
    if (dataAddress['success'] == true) {
      provider.Provider.of<LocalProvider>(context, listen: false)
          .updateAddressData(dataAddress);
    }
  }
}

Future<void> getDefaultIndividualLocation(context) async {
  SphericalMercator mercator = SphericalMercator();
  final individualProvider =
      provider.Provider.of<IndividualProvider>(context, listen: false);
  try {

    var result = await CmdbuildController.getGeometryPoint(
        individualProvider.individualData['_type'],
        individualProvider.individualData['_id'],
        context);

    if (result['success'] == true) {
      var x = result['data']['x'];
      var y = result['data']['y'];

      var point = CustomPoint(x, y);
      var afterConvert = mercator.unproject(point);

      // var address = await LocationController.getCurrentAddres(
      //     afterConvert.latitude, afterConvert.longitude);

      individualProvider.updateIndividualLocation({
        'latitude': afterConvert.latitude,
        'longitude': afterConvert.longitude,
        // 'address': address
      });
    }
    // var dataAddress = await CmdbuildController.getFamilyAddress(
    //     filterValue: provider.Provider.of<LocalProvider>(context, listen: false)
    //         .familyData['AlamatTinggal']);
    // if (dataAddress['success']) {
    //   provider.Provider.of<LocalProvider>(context, listen: false)
    //       .updateAddressData(dataAddress);
    // }
  } catch (err) {
    print(err);
    // var dataAddress = await CmdbuildController.getFamilyAddress(
    //     filterValue: provider.Provider.of<LocalProvider>(context, listen: false)
    //         .familyData['AlamatTinggal']);
    // if (dataAddress['success'] == true) {
    //   provider.Provider.of<LocalProvider>(context, listen: false)
    //       .updateAddressData(dataAddress);
    // }
  }
}
