import 'package:geolocator/geolocator.dart';
import 'package:geocoder/geocoder.dart';

class LocationModel {
  LocationModel();
  double latitude;
  double longitude;
  String currentAddress;

  Future<dynamic> readCurrentLocation() async {
    try {
      LocationPermission permission;
      double latitude;
      double longitude;

      var serviceEnabled = await Geolocator.isLocationServiceEnabled();
      permission = await Geolocator.checkPermission();

      if (!serviceEnabled) {
        // Location services are not enabled don't continue
        // accessing the position and request users of the
        // App to enable the location services.
        return false;
      }

      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low);
      latitude = position.latitude;
      longitude = position.longitude;

      var coordinates = Coordinates(latitude, longitude);

      var result =
          await Geocoder.local.findAddressesFromCoordinates(coordinates);

      currentAddress = result.first.addressLine;
      return ['$currentAddress', latitude, longitude];
    } catch (e) {

      print(
          'this is error in model location for getCurrentLocation methods, error = $e');
      return false;
    }
  }

  Future<dynamic> readCurrentAddress(lat, long) async {
    try {
      // print(lat);
      // print(long);
      var coordinates = Coordinates(lat, long);
 
      var result =
          await Geocoder.local.findAddressesFromCoordinates(coordinates);

      currentAddress = result.first.addressLine;

      return currentAddress;
    } catch (e) {
      return 'Alamat tidak diketahui';
      print(
          'this is error in model location for getCurrentAddress methods, error = $e');

    }
  }
}
