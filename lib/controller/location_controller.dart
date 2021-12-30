import 'package:titikkita/model/location_model.dart';

var newModelHelper = LocationModel();

class LocationController {
  static Future<dynamic> getCurrentLocation() async {
    var result = await newModelHelper.readCurrentLocation();

    return result;
  }

  static Future<dynamic> getCurrentAddres(lat, long) async {
    var result = await newModelHelper.readCurrentAddress(lat, long);

    return result;
  }
}
