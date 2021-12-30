
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:titikkita/controller/cmdbuild_controller.dart';
import 'package:titikkita/state/location_provider.dart';
import 'package:titikkita/util/mapIconHelper.dart';
import 'package:titikkita/views/widgets/appBar.dart';
import 'package:titikkita/views/widgets/bottomNavigation.dart';
import 'package:titikkita/views/widgets/const.dart';
import 'package:titikkita/views/widgets/mapWidgetBuilder.dart';
import 'package:titikkita/views/widgets/loadingIndicator.dart';
import 'package:titikkita/views/widgets/mapLabel.dart';
import 'package:provider/provider.dart' as provider;
import 'package:map_controller/map_controller.dart';
import "package:latlong/latlong.dart" as latlong;
import 'package:titikkita/state/local_provider.dart';
import 'package:titikkita/views/widgets/popupNotif.dart';
import 'package:flutter_map_dragmarker/dragmarker.dart';

class PrincipalMap extends StatefulWidget {
  PrincipalMap();

  @override
  _PrincipalMapState createState() => _PrincipalMapState();
}

class _PrincipalMapState extends State<PrincipalMap> {
  bool _isLoading = true;
  bool _toggled = false;
  Polygon polygon;
  List<DragMarker> markers = [];
  MapController mapController;
  StatefulMapController statefulMapController;
  latlong.LatLng centerPoints;
  dynamic principalConstraint;
  List<latlong.LatLng> newPolygon = [];
  @override
  bool startDraw = false;
  bool _isSubmitLoading = false;
  SphericalMercator mercator = SphericalMercator();
  dynamic value;
  String key;
  String cardName;
  String areaName;
  bool isPolygonAvailable = false;
  bool isEditAvailable = false;

  @override
  void initState() {
    principalConstraint =
        provider.Provider.of<LocalProvider>(context, listen: false)
            .principalConstraint['data'][0];
    getDefaultPolygon();
    mapController = MapController();
    statefulMapController = StatefulMapController(mapController: mapController);
    super.initState();
  }

  void onToggled(value) {
    setState(() {
      _toggled = value;
    });
  }

  void getDefaultPolygon() async {

    if (principalConstraint['_Jabatan_description'] == 'Ketua RT') {
      value = principalConstraint['RT'];
      key = '_id';
      cardName = 'pti_neighborhood';
      areaName = principalConstraint['_RT_description'];
    }
    if (principalConstraint['_Jabatan_description'] == 'Ketua RW') {
      value = principalConstraint['RW'];
      key = '_id';
      cardName = 'pti_upperneighbor';
      areaName = principalConstraint['_RW_description'];
    }
    if (principalConstraint['_Jabatan_description'] == 'Kepala Desa') {
      value = principalConstraint['Desa'];
      key = '_id';
      cardName = 'mtr_village';
      areaName = '${principalConstraint['_Desa_description']}';
    }
    if (principalConstraint['_Jabatan_description'] == 'Ketua Dusun') {
      value = principalConstraint['Dusun'];
      key = '_id';
      cardName = 'pti_hamlet';
      areaName = '${principalConstraint['_Dusun_description']}';
    }

    await CmdbuildController.findOneCard(cardName, value, context).then((value){
      setState(() {
        isEditAvailable =value['data']['BatasPasti'];
      });

    });

    await CmdbuildController.getPrincipalPolyline(value, cardName, context)
        .then((value) {
      List<latlong.LatLng> polylinePoints = [];
      setState(() {
        var data = value['data']['points'];
        for (var i = 0; i < data.length - 1; i++) {
          var point = CustomPoint(data[i]['x'], data[i]['y']);

          var points = mercator.unproject(point);

          polylinePoints.add(latlong.LatLng(points.latitude, points.longitude));
        }
        setState(() {
          newPolygon = polylinePoints;
          isPolygonAvailable = true;
        });

        statefulMapController.addPolygon(
            name: 'NewPolygon',
            points: newPolygon,
            color: Colors.deepOrange.shade200.withOpacity(0.7),
            borderWidth: 3,
            borderColor: Colors.redAccent);
      });

      ////////////////////////

      newPolygon.asMap().forEach((i, e) {
        markers.add(
          DragMarker(
            point: e,
            width: 80.0,
            height: 80.0,
            builder: (ctx) => Container(
                child: Icon(
              Icons.crop_square,
              size: 20,
              color: Colors.black45,
            )),
            onDragUpdate: (details, newPoint) {
              setState(() {
                markers[i].point = newPoint;
                statefulMapController.namedPolygons['NewPolygon'].points[i] =
                    newPoint;
              });
            },
          ),
        );
      });
      setState(() {
        _isLoading = false;
      });
      ///////////////////////////
    }).catchError((e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
          ShowPopupNotification.showSnackBar(
              content: 'Belum ada batas ditambahkan'));
    });
  }

  void deletePoints() {
    setState(() {
      if (newPolygon.length != 0) {
        newPolygon.removeLast();
      }
      if (markers.length != 0) {
        markers.removeLast();
      }
    });
  }

  void clear() async {
    setState(() {
      _isSubmitLoading = true;
      newPolygon = [];
    });
    await CmdbuildController.commitDeleteGeovalue(value, cardName, context);

    ScaffoldMessenger.of(context).showSnackBar(
        ShowPopupNotification.showSnackBar(
            content: 'Berhasil menghapus batas wilayah.'));

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (buildContext) {
          return PrincipalMap();
        },
      ),
    );
  }

  void onSubmitAddPolyline() async {
    setState(() {
      _isSubmitLoading = true;
      startDraw = false;
    });

    var polylinePointList = [];

    for (var i = 0;
        i < statefulMapController.namedPolygons['NewPolygon'].points.length;
        i++) {
      var xy = mercator
          .project(statefulMapController.namedPolygons['NewPolygon'].points[i]);
      polylinePointList.add({"x": xy.x, "y": xy.y});
      if (i ==
          statefulMapController.namedPolygons['NewPolygon'].points.length - 1) {
        polylinePointList.add(
            {"x": polylinePointList[0]["x"], "y": polylinePointList[0]["y"]});
      }
    }

    var dataToUpdate = {"_type": "polygon", "points": polylinePointList};
    //     print('========$dataToUpdate');
    // print('========$cardName');
    // print('========$key');
    // print('========$value');
    // print('========${principalConstraint['Desa']}');
    await CmdbuildController.commitAddPrincipalMap(dataToUpdate, context,
            cardName, key, value, principalConstraint['_Desa_description'])
        .then((value) {
      setState(() {
        _isSubmitLoading = false;
        statefulMapController.removePolygon('NewPolygon');
      });

      ScaffoldMessenger.of(context).showSnackBar(
          ShowPopupNotification.showSnackBar(
              content: 'Berhasil menambahkan batas wilayah.'));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (buildContext) {
            return PrincipalMap();
          },
        ),
      );
    }).catchError((e) {
      print(e);
      setState(() {
        _isSubmitLoading = false;
        _isLoading = false;
      });
      ShowPopupNotification.errorNotification(
          context: context,
          content: 'Terjadi error: $e. Coba lagi nanti!',
          action: () {
            Navigator.pop(context);
          });
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
              title: 'Batas Desa',
              context: context,
            ),
            bottomNavigationBar: _isSubmitLoading
                ? BottomNavigation.buildContainerBottomLoading()
                : !startDraw && newPolygon.length == 0
                    ? BottomNavigation.buildContainerBottom1Navigation(
                        title: 'Tandai Batas $areaName',
                        action: () {
                          setState(() {
                            startDraw = true;
                          });
                        })
                    : newPolygon.length != 0 && !startDraw && !isEditAvailable
                        ? BottomNavigation.buildContainerBottom1Navigation(
                            title: 'Edit',
                            action: () {
                              setState(() {
                                startDraw = true;
                              });
                            },
                          )
                        : newPolygon.length > 2 &&
                                startDraw &&
                                isPolygonAvailable
                            ? BottomNavigation.buildContainerBottom2Navigation(
                                title1: 'Simpan',
                                action1: onSubmitAddPolyline,
                                title2: 'Hapus',
                                action2: clear,
                                buildContext: context)
                            : newPolygon.length > 2 &&
                                    startDraw &&
                                    !isPolygonAvailable
                                ? BottomNavigation
                                    .buildContainerBottom1Navigation(
                                        title: 'Simpan',
                                        action: onSubmitAddPolyline,)
                                : null,
            body: _isLoading == true
                ? Center(
                    child: LoadingIndicator.containerSquareLoadingIndicator())
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
                                    maxZoom: 25,
                                    interactiveFlags: kMapRotation,
                                    onTap: (value) {
                                      if (startDraw == true &&
                                          !isPolygonAvailable) {
                                        setState(() {
                                          newPolygon.add(value);
                                        });

                                        statefulMapController.addPolygon(
                                            name: 'NewPolygon',
                                            points: newPolygon,
                                            color: Colors.deepOrange.shade200
                                                .withOpacity(0.7),
                                            borderWidth: 3,
                                            borderColor: Colors.redAccent);
                                      }
                                    },
                                    center: snapshot.hasData
                                        ? latlong.LatLng(snapshot.data.latitude,
                                            snapshot.data.longitude)
                                        : latlong.LatLng(
                                            provider.Provider.of<
                                                    LocationProvider>(context)
                                                .latitude,
                                            provider.Provider.of<
                                                    LocationProvider>(context)
                                                .longitude),
                                    zoom: 18,
                                  ),
                                  layers: [
                                    MapWidgetBuilder.mapTileLayer(
                                        toggled: _toggled),
                                    MarkerLayerOptions(
                                      markers: [
                                        snapshot.data != null
                                            ? Marker(
                                                point: latlong.LatLng(
                                                    snapshot.data.latitude,
                                                    snapshot.data.longitude),
                                                builder: (ctx) => Container(
                                                  child: IconButton(
                                                    icon:
                                                        Icon(Icons.my_location),
                                                    color: Colors.red,
                                                    iconSize: 30,
                                                    onPressed: () {},
                                                  ),
                                                ),
                                              )
                                            : Marker(),
                                      ],
                                    ),

                                    // PolygonLayerOptions(polygons: [
                                    //   polygon,
                                    // ]),
                                    // DragMarkerPluginOptions(markers: markers),
                                    PolygonLayerOptions(
                                      polygons: statefulMapController.polygons,
                                    ),

                                    DragMarkerPluginOptions(
                                        markers: startDraw ? markers : [])
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
                                      latitude: centerPoints.latitude,
                                      longitude: centerPoints.longitude,
                                    );
                                  },
                                  deleteAction: newPolygon.length != 0 &&
                                          startDraw &&
                                          !isPolygonAvailable
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
          ),
        );
      },
    );
  }
}
