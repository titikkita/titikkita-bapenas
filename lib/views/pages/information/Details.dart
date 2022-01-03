import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:titikkita/controller/cmdbuild_controller.dart';
import 'package:titikkita/state/location_provider.dart';
import 'package:titikkita/views/widgets/appBar.dart';
import 'package:titikkita/views/widgets/const.dart';
import "package:latlong/latlong.dart" as latlong;
import 'package:provider/provider.dart' as provider;
import 'package:flutter_map/flutter_map.dart';
import 'package:titikkita/views/widgets/loadingIndicator.dart';
import 'package:titikkita/views/widgets/mapAlignIcon.dart';
import 'package:titikkita/views/widgets/popupNotif.dart';

class InformationDetailView extends StatefulWidget {
  InformationDetailView({this.details});
  final dynamic details;

  @override
  _InformationDetailViewState createState() => _InformationDetailViewState();
}

class _InformationDetailViewState extends State<InformationDetailView> {
  final MapController mapController = MapController();
  bool isLocationAvailable;
  double lat;
  double long;
  bool _isLoading = false;
  dynamic familyLocation;

  SphericalMercator mercator = SphericalMercator();

  @override
  void initState() {
    getLocation();
    super.initState();
  }

  void getLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      var _familyLocation =
          provider.Provider.of<LocationProvider>(context, listen: false)
              .familyLocation;

      if (_familyLocation != null) {
        setState(() {
          familyLocation = _familyLocation;
        });
      }


      var geomValue =
          await CmdbuildController.getInfoGeomValue(widget.details['_id'],context);
      if (geomValue['success'] == true) {
        // var latLong = Conv().m2ll(geomValue['data']['x'], geomValue['data']['y']);
        var point = CustomPoint(geomValue['data']['x'], geomValue['data']['y']);
        var latLong = mercator.unproject(point);
        setState(() {
          isLocationAvailable = true;
          lat = latLong.latitude;
          long = latLong.longitude;
          _isLoading = false;
        });
      } else {
        setState(() {
          isLocationAvailable = false;
          _isLoading = false;
        });
      }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarCustom.buildAppBarCustom(
          title: 'Detail Informasi', context: context),
      body: _isLoading == true
          ? Center(
              child: LoadingIndicator.containerSquareLoadingIndicator(),
            )
          : Container(
              child: ListView(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(top: 25),
                    padding: EdgeInsets.only(left: 25, right: 25),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey,
                          blurRadius: 1,
                        ),
                      ],
                    ),
                    child: Container(
                      padding: EdgeInsets.only(top: 30, bottom: 30),
                      child: Text(
                        widget.details['Detail'] == null
                            ? '-'
                            : widget.details['Detail'],
                        style: kTextValueBlack,
                      ),
                    ),
                  ),
                  isLocationAvailable == false
                      ? Container()
                      : StreamBuilder(
                          stream: Geolocator.getPositionStream(
                              locationSettings:AndroidSettings(
                                accuracy: LocationAccuracy.high,
                                distanceFilter: 0,
                                forceLocationManager: true,
                              )),
                          builder: (buildContext, snapshot) {
                            return Container(
                              margin: EdgeInsets.all(20.0),
                              height: 300.0,
                              color: Colors.blue[100],
                              child: Stack(
                                children: [
                                  FlutterMap(
                                    mapController: mapController,
                                    options: MapOptions(
                                      maxZoom: 30,
                                      center: latlong.LatLng(lat, long),
                                      zoom: 16,
                                      // crs: Epsg4326(),
                                    ),
                                    layers: [
                                      TileLayerOptions(

                                        wmsOptions: WMSTileLayerOptions(
                                          baseUrl:
                                              'http://103.233.103.22:8090/geoserver/smartvillage/wms?',
                                          version: '1.1.0',
                                          // format: 'application/openlayers',
                                          layers: ['fotoudara'],

                                        ),
                                      ),
                                      MarkerLayerOptions(
                                        markers: [
                                          Marker(
                                            width: 100.0,
                                            height: 100.0,
                                            point: latlong.LatLng(lat, long),
                                            builder: (ctx) => Container(
                                              child: IconButton(
                                                icon: Icon(Icons.place),
                                                color: Colors.blue.shade900,
                                                iconSize: 35,
                                                onPressed: () {},
                                              ),
                                            ),
                                          ),
                                          familyLocation != null ?
                                          Marker(
                                            point: latlong.LatLng(
                                                familyLocation['latitude'], familyLocation['longitude']),
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
                                          ) : Marker(),
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
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          MapAlignIcon.mapAlignIcon(
                                            top: 30.0,
                                            left: 20.0,
                                            right: 0.0,
                                            color: Colors.blue[900],
                                            icon: Icons.add,
                                            action: () {
                                              var newZoom =
                                                  mapController.zoom + 0.5;
                                              mapController.move(
                                                  mapController.center,
                                                  newZoom);
                                            },
                                          ),
                                          MapAlignIcon.mapAlignIcon(
                                              top: 5.0,
                                              left: 20.0,
                                              right: 0.0,
                                              color: Colors.blue[900],
                                              icon: Icons.remove,
                                              action: () {
                                                var newZoom =
                                                    mapController.zoom - 0.5;
                                                mapController.move(
                                                    mapController.center,
                                                    newZoom);
                                              })
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          MapAlignIcon.mapAlignIcon(
                                            top: 30.0,
                                            left: 0.0,
                                            right: 20.0,
                                            color: Colors.red,
                                            icon: Icons.my_location,
                                            action: (){
                                              mapController.move(
                                                  latlong.LatLng(
                                                      snapshot.data
                                                          .latitude,
                                                      snapshot.data
                                                          .longitude),
                                                  mapController.zoom);
                                            },
                                          ),
                                          familyLocation != null ?
                                          MapAlignIcon.mapAlignIcon(
                                            top: 5.0,
                                            left: 0.0,
                                            right: 20.0,
                                            color: Colors.blue,
                                            icon: Icons.home,
                                            action: () {
                                              mapController.move(
                                                  latlong.LatLng(
                                                      familyLocation['latitude'],
                                                      familyLocation['longitude']),
                                                  mapController.zoom);
                                            },
                                          ) : Container(),
                                        ],
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            );
                          })
                ],
              ),
            ),
    );
  }
}
