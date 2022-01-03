import 'package:flutter/foundation.dart';
import "package:latlong/latlong.dart" as latlong;


class PolylineProvider extends ChangeNotifier {
  List polylinePoints=[];
  List<int> persilPolygonId = [];
  List<dynamic> comodityPolygon = [];
  List otherFamilyPoints = [];

  void updatePolylinePoints(data) {
    polylinePoints.add(data);
    notifyListeners();
  }

  void updateOtherFamilyPoints(data) {
    otherFamilyPoints.add(data);
    notifyListeners();
  }

  void emptyOtherFamilyPoints() {
    otherFamilyPoints = [];

  }

  void updatePersilId(id) {
    persilPolygonId.add(id);
    notifyListeners();
  }

  void emptyPolygonPoint() {
    polylinePoints = [];
  }

  void updateComodityPolygon(data) {
    comodityPolygon.add(data);
    notifyListeners();
  }

  void emptyComodityPolygon() {
    comodityPolygon = [];
  }
}
