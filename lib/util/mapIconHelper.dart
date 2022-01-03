import "package:latlong/latlong.dart" as latlong;

class MapIconHelper {
  static void zoomIn(mapController) {
    var newZoom = mapController.zoom + 0.5;
    mapController.move(mapController.center, newZoom);
  }

  static void zoomOut(mapController) {
    var newZoom = mapController.zoom - 0.5;
    mapController.move(
      mapController.center,
      newZoom,
    );
  }

  static void goToMyLocation({mapController, latitude, longitude}) {
    var newZoom = mapController.zoom - 0.5;
    mapController.move(
        latlong.LatLng(latitude, longitude),
        mapController.zoom);
  }

  static void goToMyHomeLocation({mapController, latitude, longitude}) {
    mapController.move(
        latlong.LatLng(latitude, longitude),
        mapController.zoom);
  }
}
