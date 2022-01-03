import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:map_controller/map_controller.dart';
import 'package:titikkita/state/polyline_provider.dart';
import 'package:titikkita/state/location_provider.dart';
import 'package:provider/provider.dart' as provider;
import 'package:titikkita/util/mapIconHelper.dart';
import 'package:titikkita/views/widgets/appBar.dart';
import 'package:titikkita/views/widgets/bottomNavigation.dart';
import 'package:titikkita/views/widgets/const.dart';
import 'package:titikkita/views/widgets/mapWidgetBuilder.dart';
import 'package:titikkita/views/widgets/generalInputText.dart';
import 'package:titikkita/views/pages/map/ShowFamilyOtherMap.dart';
import 'package:titikkita/views/widgets/loadingIndicator.dart';
import 'package:flutter_map/flutter_map.dart';
import "package:latlong/latlong.dart" as latlong;
import 'package:titikkita/controller/cmdbuild_controller.dart';
import 'package:titikkita/views/widgets/mapLabel.dart';
import 'package:titikkita/views/widgets/popupNotif.dart';
import 'package:flutter_map_dragmarker/dragmarker.dart';

class EditPolygonMap extends StatefulWidget {
  EditPolygonMap({this.data, this.polylinePoints});
  final dynamic data;
  final List<latlong.LatLng> polylinePoints;

  @override
  _EditPolygonMapState createState() => _EditPolygonMapState();
}

class _EditPolygonMapState extends State<EditPolygonMap> {
  MapController mapController;
  SphericalMercator mercator = SphericalMercator();
  List<latlong.LatLng> _polylinePoints = [];
  bool _isLoading = false;
  double lat;
  double long;
  bool _isSubmitLoading = false;
  bool startDraw = false;
  String lotNumber;
  String lotOwner;
  bool showForm = false;
  dynamic dataToEdit;
  bool _toggled = false;
  dynamic familyLocation;
  StatefulMapController statefulMapController;
  List <DragMarker> vertexMarker = [];

  @override
  void initState() {
    super.initState();
    _polylinePoints = widget.polylinePoints;
    dataToEdit = widget.data['data'];
    mapController = MapController();
    statefulMapController = StatefulMapController(mapController: mapController);
    defaultData();
  }

  void defaultData() {

    statefulMapController.addPolygon(
        name: 'NewPolygon',
        points: _polylinePoints,
        color: Colors.deepOrange.shade200.withOpacity(0.7),
        borderWidth: 3,
        borderColor: Colors.redAccent);


    ////////////////////////
    _polylinePoints.removeLast();

    _polylinePoints.asMap().forEach((i, e) {
      vertexMarker.add(
        DragMarker(
          point: e,
          width: 80.0,
          height: 80.0,
          builder: (ctx) => Container(
              child: Icon(
                Icons.crop_square,
                size: 20,
                color: Colors.black,
              )),
          onDragUpdate: (details, newPoint) {
            setState(() {
              vertexMarker[i].point = newPoint;
              statefulMapController.namedPolygons['NewPolygon'].points[i] =
                  newPoint;
            });
          },
        ),
      );
    });
    ///////////////////////////


    var _familyLocation =
        provider.Provider.of<LocationProvider>(context, listen: false)
            .familyLocation;

    if (_familyLocation != null) {
      setState(() {
        familyLocation = _familyLocation;
      });
    }
  }

  void onSubmitEditPolyline() async {
    try {
      setState(() {
        _isSubmitLoading = true;
      });
      var polylinePointList = [];

      for (var i = 0; i < _polylinePoints.length; i++) {
        var xy = mercator.project(_polylinePoints[i]);
        polylinePointList.add({"x": xy.x, "y": xy.y});
        if (i == _polylinePoints.length - 1) {
          polylinePointList.add(
              {"x": polylinePointList[0]["x"], "y": polylinePointList[0]["y"]});
        }
      }

      var dataToUpdate = {"_type": "polygon", "points": polylinePointList};
      var submitData = await CmdbuildController.commitEditPersilCard(
          dataToEdit, dataToEdit['_id'], context);

      if (submitData['success'] == true) {
        var submitData = await CmdbuildController.commitAddFamilyPolygonePoints(
            dataToEdit['_id'], dataToUpdate, context);
        if (submitData['success'] == true) {
          setState(() {
            _polylinePoints = [];
            _isSubmitLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
              ShowPopupNotification.showSnackBar(
                  content: 'Bidang tanah berhasil diedit'));

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (buildContext) {
                return OtherFamilyMap();
              },
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isSubmitLoading = false;
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
      if (_polylinePoints.length > 1) {
        _polylinePoints.removeLast();
      } else {
        _polylinePoints = [];
      }
    });
  }

  void onChangedValue(item, value) {
    setState(() {
      dataToEdit[item] = value;
    });
  }

  void onToggled(value) {
    setState(() {
      _toggled = value;
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
            value: PolylineProvider(),
            child: Scaffold(
              appBar: AppBarCustom.buildAppBarCustom(
                  title: 'Edit Bidang tanah', context: context),
              body: _isLoading
                  ? Center(
                      child: LoadingIndicator.containerSquareLoadingIndicator())
                  : SafeArea(
                      child: Container(
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
                                          if (startDraw == true) {
                                            setState(() {
                                              _polylinePoints.add(
                                                  latlong.LatLng(value.latitude,
                                                      value.longitude));
                                            });
                                          }
                                        },
                                        center: _polylinePoints.length != 0
                                            ? _polylinePoints[0]
                                            : latlong.LatLng(
                                                provider.Provider.of<
                                                            LocationProvider>(
                                                        context)
                                                    .latitude,
                                                provider.Provider.of<
                                                            LocationProvider>(
                                                        context)
                                                    .longitude),
                                        zoom: 19,
                                        rotationThreshold: 20,
                                      ),
                                      layers: [
                                        MapWidgetBuilder.mapTileLayer(
                                            toggled: _toggled),
                                        // DragMarkerPluginOptions(markers: vertexMarker),
                                        PolygonLayerOptions(
                                          polygons: statefulMapController.polygons,
                                        ),

                                        DragMarkerPluginOptions(
                                            markers: startDraw ? vertexMarker : [])
                                        // PolygonLayerOptions(
                                        //   polygons: [
                                        //     Polygon(
                                        //         points:
                                        //             _polylinePoints.length != 0
                                        //                 ? _polylinePoints
                                        //                 : [],
                                        //         color: Colors
                                        //             .deepOrange.shade200
                                        //             .withOpacity(0.7),
                                        //         borderColor:
                                        //             Colors.deepOrange.shade300,
                                        //         borderStrokeWidth: 3),
                                        //   ],
                                        // ),
                                      ],
                                    ),
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
                                      deleteAction: _polylinePoints.length == 0
                                          ? null
                                          : deletePoints,
                                    ),
                                    _isSubmitLoading == true
                                        ? Center(
                                            child: Align(
                                              alignment: Alignment.center,
                                              child: LoadingIndicator
                                                  .containerWhiteLoadingIndicator(),
                                            ),
                                          )
                                        : Container(),
                                  ],
                                ),
                              ),
                            ),
                            showForm == true
                                ? Container(
                                    color: Colors.blue[100],
                                    child: Container(
                                        height: 200.0,
                                        padding: EdgeInsets.all(20.0),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                        ),
                                        child: Scrollbar(
                                          isAlwaysShown: true,
                                          thickness: 2.0,
                                          child: SingleChildScrollView(
                                            child: Column(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 10.0),
                                                  child: InputTextForm
                                                      .textInputFieldWithBorder(
                                                          title: 'NIB',
                                                          attributeName: 'Code',
                                                          action:
                                                              onChangedValue,
                                                          initialValue:
                                                              dataToEdit[
                                                                  'Code']),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 10.0),
                                                  child: InputTextForm
                                                      .textInputFieldWithBorder(
                                                          title: 'Nama Pemilik',
                                                          attributeName:
                                                              'Description',
                                                          action:
                                                              onChangedValue,
                                                          initialValue:
                                                              dataToEdit[
                                                                  'Description']),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 10.0),
                                                  child: InputTextForm
                                                      .textInputFieldWithBorder(
                                                          title: 'Alamat',
                                                          attributeName:
                                                              'Alamat',
                                                          action:
                                                              onChangedValue,
                                                          initialValue:
                                                              dataToEdit[
                                                                  'Alamat']),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 10.0),
                                                  child: InputTextForm
                                                      .textInputFieldWithBorder(
                                                          title: 'Letak Tanah',
                                                          attributeName:
                                                              'LetakTanah',
                                                          action:
                                                              onChangedValue,
                                                          initialValue:
                                                              dataToEdit[
                                                                  'LetakTanah']),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 10.0),
                                                  child: InputTextForm
                                                      .textInputFieldWithBorder(
                                                          title: 'Luas',
                                                          attributeName: 'Luas',
                                                          action:
                                                              onChangedValue,
                                                          initialValue:
                                                              dataToEdit[
                                                                  'Luas']),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 10.0),
                                                  child: InputTextForm
                                                      .textInputFieldWithBorder(
                                                          title: 'Guna Lahan',
                                                          attributeName:
                                                              'GunaLahan',
                                                          action:
                                                              onChangedValue,
                                                          initialValue:
                                                              dataToEdit[
                                                                  'GunaLahan']),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 10.0),
                                                  child: InputTextForm
                                                      .textInputFieldWithBorder(
                                                          title: 'Status Tanah',
                                                          attributeName:
                                                              'StatusTanah',
                                                          action:
                                                              onChangedValue,
                                                          initialValue:
                                                              dataToEdit[
                                                                  'StatusTanah']),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )),
                                  )
                                : Container()
                          ],
                        ),
                      ),
                    ),
              bottomNavigationBar: startDraw == false
                  ? BottomNavigation.buildContainerBottom1Navigation(
                      title: 'Mulai',
                      action: () {
                        setState(() {
                          startDraw = true;
                          showForm = true;
                        });
                      })
                  : BottomNavigation.buildContainerBottom2Navigation(
                      buildContext: context,
                      title1: 'Simpan',
                      title2: 'Batal',
                      action1: onSubmitEditPolyline,
                      action2: () {
                        setState(() {
                          showForm = false;
                          startDraw = false;
                        });
                      },
                    ),
            ),
          );
        });
  }
}
