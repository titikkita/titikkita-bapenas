import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import "package:latlong/latlong.dart" as latlong;
import 'package:flutter_map/flutter_map.dart';
import 'package:titikkita/controller/cmdbuild_controller.dart';
import 'package:titikkita/controller/location_controller.dart';
import 'package:titikkita/state/local_provider.dart';
import 'package:titikkita/state/location_provider.dart';
import 'package:titikkita/util/mapIconHelper.dart';
import 'package:titikkita/views/widgets/const.dart';
import 'package:titikkita/views/widgets/mapWidgetBuilder.dart';
import 'package:titikkita/views/widgets/loadingIndicator.dart';
import 'package:titikkita/views/widgets/mapLabel.dart';
import 'package:titikkita/views/widgets/mapAlignIcon.dart';
import 'package:titikkita/views/widgets/bottomNavigation.dart';
import 'package:provider/provider.dart' as provider;

class TaggingMapView extends StatefulWidget {
  TaggingMapView(
      {this.isEditMode, this.cardId, this.localIndex, this.cardName});
  final bool isEditMode;
  final int cardId;
  final int localIndex;
  final String cardName;

  @override
  _TaggingMapViewState createState() => _TaggingMapViewState();
}

class _TaggingMapViewState extends State<TaggingMapView> {
  double lat;
  double long;
  String address;
  MapController mapController;
  bool isStartTagging = false;
  bool _isLoading = false;
  bool _toggled = false;
  dynamic familyLocation;

  SphericalMercator mercator = SphericalMercator();

  @override
  void initState() {
    defaultData();
    mapController = MapController();
    super.initState();
  }

  void defaultData() {
    setState(() {
      _isLoading = true;
    });
    var _familyLocation =
        provider.Provider.of<LocationProvider>(context, listen: false)
            .familyLocation;

    if (_familyLocation != null) {
      setState(() {
        familyLocation = _familyLocation;
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  void onChangeLocation(value) async {
    print(value.latitude);
    var newAddress = await LocationController.getCurrentAddres(
        value.latitude, value.longitude);

    setState(() {
      isStartTagging = true;
      lat = value.latitude;
      long = value.longitude;
      address = newAddress;
    });
  }

  void onSubmit() {
    var xy = mercator.project(latlong.LatLng(lat, long));
    var dataToUpdate = {"_type": "point", "x": xy.x, "y": xy.y};
    provider.Provider.of<LocalProvider>(context, listen: false)
        .updateInfoLocationPoint(dataToUpdate);

    provider.Provider.of<LocalProvider>(context, listen: false)
        .updateInfoLocationAddress(address);
    Navigator.pop(context);
  }

  void onEditSubmit() async {
    setState(() {
      _isLoading = true;
    });

    var xy = mercator.project(latlong.LatLng(lat, long));
    var dataToUpdate = {"_type": "point", "x": xy.x, "y": xy.y};

    var addGeomValue =
        await CmdbuildController.commitAddReportLocationGeomValue(
            dataToUpdate, widget.cardId, widget.cardName, context);

    if (addGeomValue['success'] == true) {
      var value = {'Lokasi': address};
      var edit = await CmdbuildController.commitEditReportDetail(
          widget.cardId, value, widget.cardName, context);
      if (edit['success'] == true) {
        provider.Provider.of<LocalProvider>(context, listen: false)
            .updateOneReporList(
                widget.localIndex, edit['data'], widget.cardName);
        Navigator.pop(context);
      } else {
        print('Edit address when edit location failed. Error = $edit');
      }
    } else {
      print('Edit location failed');
    }
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
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Color(0xff084A9A),
              title: Text(
                'Menandai Lokasi',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              leading: Container(),
            ),
            bottomNavigationBar:
                BottomNavigation.buildContainerBottom2Navigation(
              title1: 'Simpan',
              title2: 'Batal',
              action1: widget.isEditMode == false ? onSubmit : onEditSubmit,
              action2: () {
                Navigator.pop(context);
              },
              buildContext: context,
            ),
            body: _isLoading == true
                ? Center(
                    child: LoadingIndicator.containerSquareLoadingIndicator())
                : Container(
                    child: SafeArea(
                      child: Container(
                        height: 600,
                        child: Stack(
                          children: [
                            MapLabel(
                              toggle: onToggled,
                              isOn: _toggled,
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 50.0),
                              child: FlutterMap(
                                mapController: mapController,
                                options: MapOptions(
                                  maxZoom: 25,
                                  interactiveFlags: kMapRotation,
                                  onTap: (value) {
                                    onChangeLocation(value);
                                  },
                                  center: familyLocation != null
                                      ? latlong.LatLng(
                                          familyLocation['latitude'],
                                          familyLocation['longitude'])
                                      : snapshot.hasData
                                          ? latlong.LatLng(
                                              snapshot.data.latitude,
                                              snapshot.data.longitude)
                                          : latlong.LatLng(provider.Provider.of<LocationProvider>(context).latitude, provider.Provider.of<LocationProvider>(context).longitude),
                                  zoom: 18,
                                ),
                                layers: [
                                  MapWidgetBuilder.mapTileLayer(
                                      toggled: _toggled),
                                  MarkerLayerOptions(
                                    markers: [
                                      lat != null && long != null
                                          ? Marker(
                                              width: 100.0,
                                              height: 100.0,
                                              point: latlong.LatLng(lat, long),
                                              builder: (ctx) => Container(
                                                child: IconButton(
                                                  icon: Icon(Icons.place),
                                                  color: Colors.blue.shade400,
                                                  iconSize: 45,
                                                  onPressed: () {
                                                    print('$lat $long');
                                                    print('i got pressed');
                                                  },
                                                ),
                                              ),
                                            )
                                          : Marker(),
                                      familyLocation != null
                                          ? Marker(
                                              point: latlong.LatLng(
                                                  familyLocation['latitude'],
                                                  familyLocation['longitude']),
                                              builder: (ctx) => Container(
                                                child: Stack(
                                                  children: [
                                                    IconButton(
                                                        icon: Icon(Icons.home),
                                                        color: Colors.blue,
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
                                                  snapshot.data.longitude),
                                              builder: (ctx) => IconButton(
                                                icon: Icon(Icons.my_location),
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
                            ),
                            isStartTagging == true
                                ? Align(
                                    alignment: Alignment.topCenter,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5)),
                                      ),
                                      margin: EdgeInsets.only(top: 70.0),
                                      padding: EdgeInsets.all(10.0),
                                      // height: 70.0,
                                      width: 230.0,
                                      child: Text(address),
                                    ),
                                  )
                                : Container(),
                            // Row(
                            //   crossAxisAlignment: CrossAxisAlignment.stretch,
                            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //   children: [
                            //     Column(
                            //       crossAxisAlignment: CrossAxisAlignment.center,
                            //       children: [
                            //         MapAlignIcon.mapAlignIcon(
                            //           top: 80.0,
                            //           left: 20.0,
                            //           right: 0.0,
                            //           color: Colors.blue[900],
                            //           icon: Icons.add,
                            //           action: () {
                            //             var newZoom = mapController.zoom + 0.5;
                            //             mapController.move(
                            //                 mapController.center, newZoom);
                            //           },
                            //         ),
                            //         MapAlignIcon.mapAlignIcon(
                            //             top: 5.0,
                            //             left: 20.0,
                            //             right: 0.0,
                            //             color: Colors.blue[900],
                            //             icon: Icons.remove,
                            //             action: () {
                            //               var newZoom =
                            //                   mapController.zoom - 0.5;
                            //               mapController.move(
                            //                   mapController.center, newZoom);
                            //             })
                            //       ],
                            //     ),
                            //     Column(
                            //       crossAxisAlignment: CrossAxisAlignment.center,
                            //       children: [
                            //         MapAlignIcon.mapAlignIcon(
                            //           top: 80.0,
                            //           left: 0.0,
                            //           right: 20.0,
                            //           color: Colors.red,
                            //           icon: Icons.my_location,
                            //           action: (){
                            //             mapController.move(
                            //                 latlong.LatLng(
                            //                     snapshot.data
                            //                         .latitude,
                            //                     snapshot.data
                            //                         .longitude),
                            //                 mapController.zoom);
                            //           },
                            //         ),
                            //         familyLocation != null ?
                            //         MapAlignIcon.mapAlignIcon(
                            //           top: 5.0,
                            //           left: 0.0,
                            //           right: 20.0,
                            //           color: Colors.blue,
                            //           icon: Icons.home,
                            //           action: () {
                            //             mapController.move(
                            //                 latlong.LatLng(
                            //                     familyLocation['latitude'],
                            //                     familyLocation['longitude']),
                            //                 mapController.zoom);
                            //           },
                            //         ) : Container(),
                            //       ],
                            //     )
                            //   ],
                            // )
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
                                    latitude: familyLocation['latitude'],
                                    longitude: familyLocation['longitude']);
                              },
                              isTaggingMap: 'yes',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
          );
        });
  }
}
