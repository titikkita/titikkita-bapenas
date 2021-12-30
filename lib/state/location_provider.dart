

import 'package:flutter/foundation.dart';

class LocationProvider extends ChangeNotifier {
  double latitude = -6.936296;
  double longitude = 107.769423;
  dynamic familyLocation;
  // {'latitude': -6.845846, 'longitude':107.902756};
  String currentAddress = 'Padasuka, Sumedang';
  dynamic myStreamLocation;

  void updateCoordinateAndAddress(data) {
   familyLocation = data;
    notifyListeners();
  }

  void updateAddressData(data) {
    currentAddress = data;
    notifyListeners();
  }

  void updateStreamLocation(data){
    myStreamLocation = data;
    notifyListeners();
  }

}
