import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:titikkita/controller/cmdbuild_controller.dart';
import 'package:titikkita/state/indivivual_provider.dart';
import 'package:titikkita/state/local_provider.dart';
import 'package:titikkita/state/location_provider.dart';
import 'package:titikkita/util/getComodityData.dart';
import 'package:titikkita/util/getDefaultLocation.dart';
import 'package:titikkita/util/getLookupData.dart';
import 'package:titikkita/util/mapIconHelper.dart';
import 'package:titikkita/views/pages/family_data/Comodity.dart';
import 'package:titikkita/views/widgets/actionPopupMap.dart';
import 'package:titikkita/views/widgets/appBar.dart';
import 'package:titikkita/views/widgets/bottomNavigation.dart';
import 'package:titikkita/views/widgets/const.dart';
import 'package:titikkita/views/widgets/mapWidgetBuilder.dart';
import 'package:provider/provider.dart' as provider;
import 'package:map_controller/map_controller.dart';
import "package:latlong/latlong.dart" as latlong;
import 'package:titikkita/views/widgets/loadingIndicator.dart';
import 'package:titikkita/views/widgets/mapLabel.dart';
import 'package:titikkita/views/widgets/popupNotif.dart';
import 'package:flutter_map_dragmarker/dragmarker.dart';

class ComodityMapView extends StatefulWidget {
  ComodityMapView({this.data});
  final dynamic data;

  @override
  _ComodityMapViewState createState() => _ComodityMapViewState();
}

class _ComodityMapViewState extends State<ComodityMapView> {
  dynamic familyLocation;
  String markerIcon;
  double latMarker;
  double longMarker;
  String orientation;
  List<dynamic> neighborData;
  List<Marker> markers = [];
  String locationName;
  bool isShowPopup;
  MapController mapController;
  bool showForm = false;
  StatefulMapController statefulMapController;
  bool isAddModeActive = false;
  bool isEditMode = false;
  int indexEdit;
  int idEdit;
  dynamic dataEdit;
  bool isAddMarkerAvailable = false;
  bool _isLoading = false;
  bool _isAlertLoading = false;
  bool _isShowPopUp = false;
  bool showNewKomodityPopup = false;
  dynamic data;
  bool isShowForm = false;
  dynamic comodity;
  String comodityName;
  bool _toggled = false;
  latlong.LatLng editPoint;
  bool isAddPolygon = false;
  List<Polygon> allPolygon = [];
  List<latlong.LatLng> newPolygonPoints = [];
  String polygonName;
  bool isDeletePointAllowed = false;
  List<DragMarker> vertexMarker = [];

  SphericalMercator mercator = SphericalMercator();

  @override
  void initState() {
    getDefaultData();
    mapController = MapController();
    statefulMapController = StatefulMapController(mapController: mapController);
    super.initState();
  }

  void getDefaultData() async {

    try {
      setState(() {
        _isLoading = true;
      });

      final individualProvider =
          provider.Provider.of<IndividualProvider>(context, listen: false);
      var _familyLocation;

      if (individualProvider.isIndividualLogin) {
        final location = individualProvider.individualLocation;
        if (location == null) {
          await getDefaultIndividualLocation(context);
        }
        _familyLocation = individualProvider.individualLocation;
      } else {
        final location =
            provider.Provider.of<LocationProvider>(context, listen: false)
                .familyLocation;
        if (location == null) {
          await getDefaultLocation(context);
        }
        _familyLocation =
            provider.Provider.of<LocationProvider>(context, listen: false)
                .familyLocation;
      }

      if (_familyLocation != null) {
        setState(() {
          familyLocation = _familyLocation;
        });
      }

      if (widget.data['x'] != null) {
        var point = CustomPoint(widget.data['x'], widget.data['y']);
        var latLng = mercator.unproject(point);
        markers.add(Marker(
          point: latlong.LatLng(latLng.latitude, latLng.longitude),
          builder: (ctx) => GestureDetector(
              child: Container(
                  width: 500,
                  height: 900,
                  child: Image.asset(
                    'assets/map_icon/question_mark.png',
                    fit: BoxFit.fill,
                  )),
              onTap: () {
                setState(() {
                  // polygonName = polygon[index]['_id'];
                  dataEdit = widget.data;
                  editPoint = latlong.LatLng(latLng.latitude, latLng.longitude);
                  _isShowPopUp = !_isShowPopUp;
                  allPolygon.asMap().forEach((ind, e) {
                    if (ind == indexEdit) {
                      allPolygon[indexEdit] = Polygon(
                        points: e.points,
                        color: Colors.deepOrange.shade200.withOpacity(0.7),
                        borderColor: Colors.redAccent,
                        borderStrokeWidth: 3,
                      );
                    } else {
                      allPolygon[ind] = Polygon(
                        points: e.points,
                        color: Colors.white54.withOpacity(0.4),
                        borderColor: Colors.redAccent,
                        borderStrokeWidth: 3,
                      );
                    }
                  });
                });
              }),
        ));
      }
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ShowPopupNotification.errorNotification(
          context: context,
          content: 'Terjadi error: $e. Coba lagi nanti!',
          action: () {
            Navigator.pop(context);
          });
      print('This is error on getdefault comodity data Error: $e');
    }
  }

  void onEditButton() {
    setState(() {
      _isShowPopUp = false;
      isEditMode = true;
      isShowForm = true;
      isAddMarkerAvailable = true;
    });
  }

  void onSubmitAddOne() async {
    try {
      setState(() {
        _isLoading = true;
        showForm = false;
      });

      var convert = mercator.project(latlong.LatLng(latMarker, longMarker));
      var newGeom = {"_type": "point", "x": convert.x, "y": convert.y};

       await CmdbuildController.commitEditGeometryPoint(
          widget.data['data']['_id'], 'app_comodity', newGeom, context).then((value){
            print(value);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) {
              return CommodityView();
            },
          ),
        );
      });
      setState(() {
        isEditMode = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
          ShowPopupNotification.showSnackBar(
              content: 'Data komoditas berhasil ditambahkan'));
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print(e);
      ShowPopupNotification.errorNotification(
          context: context,
          content: 'Terjadi error. Coba lagi nanti!',
          action: () {
            Navigator.pop(context);
          });
    }
  }

  void cancelButton() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) {
          return ComodityMapView();
        },
      ),
    );
  }

  void onSubmitEdit() async {
    try {
      setState(() {
        _isLoading = true;
        showForm = false;
      });

      var convert = mercator.project(editPoint);
      var points = {"_type": "point", "x": convert.x, "y": convert.y};
      var send = await CmdbuildController.commitEditComodityData(
          dataEdit['data']['_id'], dataEdit['data'], points, '');

      await getComodityData(context);
      setState(() {
        isEditMode = false;
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) {
            return ComodityMapView();
          },
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
          ShowPopupNotification.showSnackBar(
              content: 'Data komoditas berhasil diedit'));
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ShowPopupNotification.errorNotification(
          context: context,
          content: 'Terjadi error. Coba lagi nanti!',
          action: () {
            Navigator.pop(context);
          });
    }
  }

  void deletePoints() {
    setState(() {
      if (isEditMode && isAddMarkerAvailable) {
        markers[indexEdit] = Marker();
        isAddMarkerAvailable = false;
      } else {
        markers.removeLast();
        latMarker = null;
        longMarker = null;
        isAddMarkerAvailable = false;
        showNewKomodityPopup = false;
      }
    });
  }

  void onChangeLocation(value) {
    setState(() {
      latMarker = value.latitude;
      longMarker = value.longitude;

      if (isEditMode) {
        editPoint = latlong.LatLng(latMarker, longMarker);
        comodityName = dataEdit['data']['_JenisKomoditi_code'];
      }
      if (isEditMode) {
        markers[indexEdit] = Marker(
            point: latlong.LatLng(latMarker, longMarker),
            builder: (ctx) {
              return GestureDetector(
                  child: Container(
                      width: 500,
                      height: 900,
                      child: Image.asset(
                        'assets/map_icon/question_mark.png',
                        fit: BoxFit.fill,
                      )),
                  onTap: () {
                    setState(() {
                      showNewKomodityPopup = true;
                    });
                  });
            });
      } else {
        markers.add(Marker(
          point: latlong.LatLng(latMarker, longMarker),
          builder: (ctx) {
            return GestureDetector(
                child: Container(
                    width: 500,
                    height: 900,
                    child: Image.asset(
                      'assets/map_icon/question_mark.png',
                      fit: BoxFit.fill,
                    )),
                onTap: () {
                  setState(() {
                    showNewKomodityPopup = true;
                  });
                });
          },
        ));
      }
    });
    isAddMarkerAvailable = true;
  }

  void onToggled(value) {
    setState(() {
      _toggled = value;
    });
  }

  void addPolygon(value) {
    setState(() {
      newPolygonPoints.add(latlong.LatLng(value.latitude, value.longitude));

      statefulMapController.addPolygon(
          name: 'NewPolygon',
          points: newPolygonPoints,
          color: Colors.deepOrange.shade200.withOpacity(0.7),
          borderWidth: 3,
          borderColor: Colors.redAccent);
    });
  }

  void editPolygonPoint() {
    setState(() {
      if (allPolygon[indexEdit].points.length != 0) {
        if (allPolygon[indexEdit].points.length >= 1) {
          allPolygon[indexEdit].points.removeLast();
        }
      }
    });
  }

  void deletePolygonPoint() {
    setState(() {
      if (newPolygonPoints.length >= 1) {
        newPolygonPoints.removeLast();
      } else {
        newPolygonPoints = [];
      }
    });
  }

  void onClosePopupButton() {
    setState(() {
      _isShowPopUp = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Geolocator.getPositionStream(
            locationSettings:AndroidSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 0,
              forceLocationManager: true,
            )),
        builder: (buildContext, snapshot) {
          return provider.ChangeNotifierProvider.value(
            value: LocationProvider(),
            child: Scaffold(
                appBar: AppBarCustom.buildAppBarCustom(
                    title: "Peta Komoditas", context: context),
                body: _isLoading == true || _isAlertLoading
                    ? Center(
                        child:
                            LoadingIndicator.containerSquareLoadingIndicator())
                    : Container(
                        child: Column(
                          children: [
                            MapLabel(
                              toggle: onToggled,
                              isOn: _toggled,
                            ),
                            Expanded(
                              child: Container(
                                color: Colors.blue[100],
                                child: Stack(
                                  children: [
                                    FlutterMap(
                                      mapController: mapController,
                                      options: MapOptions(
                                        plugins: [
                                          DragMarkerPlugin(),
                                        ],
                                        interactiveFlags: kMapRotation,
                                        maxZoom: 25,
                                        onTap: (value) {
                                          if (isAddMarkerAvailable &&
                                              isAddPolygon &&
                                              !isEditMode) {
                                            // addPolygon(value);
                                          }
                                          if (isAddModeActive &&
                                              isAddMarkerAvailable == false) {
                                            onChangeLocation(value);
                                          }
                                          if (isEditMode) {
                                            if (!isAddMarkerAvailable) {
                                              setState(() {
                                                onChangeLocation(value);
                                              });
                                            }
                                          }
                                        },
                                        center: familyLocation != null
                                            ? latlong.LatLng(
                                                familyLocation['latitude'],
                                                familyLocation['longitude'])
                                            : snapshot.hasData
                                                ? latlong.LatLng(
                                                    snapshot.data.latitude,
                                                    snapshot.data.longitude)
                                                : latlong.LatLng(
                                                    provider.Provider.of<
                                                                LocationProvider>(
                                                            context)
                                                        .latitude,
                                                    provider.Provider.of<
                                                                LocationProvider>(
                                                            context)
                                                        .longitude),
                                        zoom: 18,
                                        // rotationThreshold: 20,
                                      ),
                                      layers: [
                                        MapWidgetBuilder.mapTileLayer(
                                            toggled: _toggled),
                                        MarkerLayerOptions(
                                          markers: markers,
                                        ),
                                        DragMarkerPluginOptions(
                                            markers:
                                                isEditMode ? vertexMarker : []),
                                        MarkerLayerOptions(
                                          markers: [
                                            familyLocation != null
                                                ? Marker(
                                                    point: latlong.LatLng(
                                                        familyLocation[
                                                            'latitude'],
                                                        familyLocation[
                                                            'longitude']),
                                                    builder: (ctx) => Container(
                                                      child: Stack(
                                                        children: [
                                                          IconButton(
                                                              icon: Icon(
                                                                  Icons.home),
                                                              color:
                                                                  Colors.blue,
                                                              iconSize: 40,
                                                              onPressed: () {}),
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                                : Marker(),
                                            snapshot.hasData
                                                ? Marker(
                                                    point: latlong.LatLng(
                                                        snapshot.data.latitude,
                                                        snapshot
                                                            .data.longitude),
                                                    builder: (ctx) =>
                                                        IconButton(
                                                      icon: Icon(
                                                          Icons.my_location),
                                                      color: Colors.red,
                                                      iconSize: 30,
                                                      onPressed: () {
                                                        print('i got pressed');
                                                      },
                                                    ),
                                                  )
                                                : Marker(),
                                          ],
                                        ),
                                      ],
                                    ),
                                    _isShowPopUp == true
                                        ? Align(
                                            alignment: Alignment.topCenter,
                                            child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.white70,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(5)),
                                                ),
                                                margin:
                                                    EdgeInsets.only(top: 20.0),
                                                // padding: EdgeInsets.all(10.0),
                                                height: 50,
                                                width: 150.0,
                                                child: PopupMap.actionPopup(
                                                    onEdit: onEditButton,
                                                    onClose: onClosePopupButton,
                                                    content: null)),
                                          )
                                        : Container(),
                                    MapWidgetBuilder.mapIconHelper(
                                      zoomInAction: () {
                                        MapIconHelper.zoomIn(mapController);
                                      },
                                      zoomOutAction: () {
                                        MapIconHelper.zoomOut(mapController);
                                      },
                                      myLocationAction: () {
                                        MapIconHelper.goToMyLocation(
                                            mapController: mapController,
                                            latitude: snapshot.data.latitude,
                                            longitude: snapshot.data.longitude);
                                      },
                                      myHomeAction: () {
                                        MapIconHelper.goToMyHomeLocation(
                                            mapController: mapController,
                                            latitude:
                                                familyLocation['latitude'],
                                            longitude:
                                                familyLocation['longitude']);
                                      },
                                      deleteAction: isAddModeActive &&
                                                  isAddMarkerAvailable &&
                                                  isDeletePointAllowed ||
                                              isEditMode &&
                                                  isAddMarkerAvailable &&
                                                  isDeletePointAllowed
                                          ? deletePoints
                                          : null,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                bottomNavigationBar: isShowForm == false && _isLoading == false
                    ? BottomNavigation.buildContainerBottom1Navigation(
                        title: 'Tambah Lokasi Komoditas',
                        action: () {
                          setState(() {
                            isShowForm = true;
                            isAddModeActive = true;
                            isDeletePointAllowed = true;
                          });
                        })
                    : isShowForm == true && isAddMarkerAvailable ||
                            isShowForm == true &&
                                isAddMarkerAvailable == false &&
                                isEditMode == true
                        ? BottomNavigation.buildContainerBottom2Navigation(
                            buildContext: context,
                            title1: 'Simpan',
                            title2: 'Batal',
                            action1: isEditMode ? onSubmitEdit : onSubmitAddOne,
                            action2: cancelButton)
                        : isShowForm == true &&
                                isAddMarkerAvailable == false &&
                                isAddModeActive == true
                            ? BottomNavigation.buildContainerBottom1Navigation(
                                title: 'Batal',
                                action: () {
                                  setState(() {
                                    _isShowPopUp = false;
                                    isShowForm = false;
                                    isAddModeActive = false;
                                    isEditMode = false;
                                    comodityName = null;
                                  });
                                },
                              )
                            : null),
          );
        });
  }
}
