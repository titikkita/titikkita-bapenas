import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:map_controller/map_controller.dart';
import 'package:titikkita/controller/cmdbuild_controller.dart';
import 'package:titikkita/state/indivivual_provider.dart';
import 'package:titikkita/state/polyline_provider.dart';
import 'package:titikkita/state/location_provider.dart';
import 'package:provider/provider.dart' as provider;
import 'package:titikkita/util/getFamilyPolygon.dart';
import 'package:titikkita/util/mapIconHelper.dart';
import 'package:titikkita/views/pages/map/AddOtherPointMap.dart';
import 'package:titikkita/views/widgets/actionPopupMap.dart';
import 'package:titikkita/views/widgets/appBar.dart';
import 'package:titikkita/views/widgets/bottomNavigation.dart';
import 'package:titikkita/views/widgets/const.dart';
import 'package:titikkita/views/widgets/generalInputText.dart';
import 'package:titikkita/views/widgets/inputDropdownFullWidth.dart';
import 'package:titikkita/views/widgets/mapWidgetBuilder.dart';
import 'package:titikkita/views/widgets/loadingIndicator.dart';
import 'package:titikkita/views/widgets/mapLabel.dart';
import 'package:flutter_map/flutter_map.dart';
import "package:latlong/latlong.dart" as latlong;
import 'package:titikkita/views/widgets/popupNotif.dart';
import 'package:geodesy/geodesy.dart';
import 'package:flutter_map_dragmarker/dragmarker.dart';

class OtherFamilyMap extends StatefulWidget {
  @override
  _OtherFamilyMapState createState() => _OtherFamilyMapState();
}

class _OtherFamilyMapState extends State<OtherFamilyMap> {
  MapController mapController;
  Geodesy geodesy = Geodesy();
  StatefulMapController statefulMapController;
  SphericalMercator mercator = SphericalMercator();

  List<latlong.LatLng> _polylinePoints = [];
  List<latlong.LatLng> familyPolylinePointsFromDB = [];
  bool _isLoading = false;
  dynamic familyLocation;
  bool _isSubmitLoading = false;
  List<Polygon> polyWidget = [];
  bool _isShowPopUp = false;
  dynamic dataThatOnTap;
  List otherPointsData = [];
  bool _toggled = false;
  List convertedFamilyPoints = [];
  List allPolygonData = [];
  int indexEdit;
  List<Marker> markerList = [];
  dynamic dataEdit;
  String neighborName;
  final TextEditingController textController = TextEditingController();
  dynamic editDataPointCard;
  bool isShowEditForm = false;
  Map<String, List<DropdownMenuItem>> lookupData = {
    "StatusTanah" :[],
    "GunaLahan":[]
  };

  @override
  void initState() {
    defaultPolylinePoints();
    mapController = MapController();
    statefulMapController = StatefulMapController(mapController: mapController);

    super.initState();
  }

  void defaultPolylinePoints() async {

    try {
      setState(() {
        _isLoading = true;
      });
      await CmdbuildController.getOneLookup('GunaLahan', context).then((value) {
        for (var i = 0; i < value['data'].length; i++) {
          lookupData['GunaLahan'].add(DropdownMenuItem(
            child: Text('${value['data'][i]['description']}'),
            value: value['data'][i],
          ));
        }
      });

      await CmdbuildController.getOneLookup('StatusTanah', context)
          .then((value) {
        for (var i = 0; i < value['data'].length; i++) {
          lookupData['StatusTanah'].add(DropdownMenuItem(
            child: Text('${value['data'][i]['description']}'),
            value: value['data'][i],
          ));
        }
      });

      final individualProvider =
          provider.Provider.of<IndividualProvider>(context, listen: false);

      var _familyLocation;
      var getOtherFamilyPoints;

      if (individualProvider.isIndividualLogin) {
        _familyLocation = individualProvider.individualLocation;
        await getIndividualPolygonPoints(context);
        getOtherFamilyPoints = individualProvider.polygonPoints;

      } else {

        _familyLocation =
            provider.Provider.of<LocationProvider>(context, listen: false)
                .familyLocation;

      }
      await getFamilyPolygonPoints(context).then((value){
        getOtherFamilyPoints =
            provider.Provider.of<PolylineProvider>(context, listen: false)
                .otherFamilyPoints;

      });

      if (_familyLocation != null) {
        setState(() {
          familyLocation = _familyLocation;
        });
      }

      setState(() {
        if (getOtherFamilyPoints.length != 0) {
          otherPointsData = getOtherFamilyPoints;
        }
      });

      otherPointsData.asMap().forEach((int, e) async {
        List<latlong.LatLng> points = [];

        var point = CustomPoint(e['x'], e['y']);

        var converted = mercator.unproject(point);

        points.add(latlong.LatLng(converted.latitude, converted.longitude));

        setState(() {
          convertedFamilyPoints.add(points);
        });
        markerList.add(Marker(
          point: latlong.LatLng(converted.latitude, converted.longitude),
          builder: (ctx) => GestureDetector(
            onTap: () {
              setState(() {
                dataThatOnTap = e;
                if (_isShowPopUp == false) {
                  setState(() {
                    _isShowPopUp = true;
                  });
                } else {
                  setState(() {
                    _isShowPopUp = false;
                  });
                }
              });
            },
            child: Icon(
              Icons.home,
              color: Colors.green,
              size: 30,
            ),
          ),
        ));
      });
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print(e);
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

  void onChangedValue(item, value) {
    setState(() {
      dataThatOnTap['cardData'][item] = value;
    });
  }

  void onEditPopupButton() {
    setState(() {
      isShowEditForm = true;
    });
  }

  void onChangedDropdownList(param, value) {
    setState(() {
      dataThatOnTap['cardData'][param] = value['_id'];
    });
  }


  void onSubmitEdit() async {
    setState(() {
      isShowEditForm = false;
      _isSubmitLoading = true;
    });
     await CmdbuildController.commitEditPersilCard(
        dataThatOnTap['cardData'], dataThatOnTap['cardData']['_id'], context).then((value){
       Navigator.pushReplacement(
         context,
         MaterialPageRoute(
           builder: (buildContext) {
             return OtherFamilyMap();
           },
         ),
       );
     });

  }

  void onDeleteOne() async {
    try {
      setState(() {
        _isLoading = true;
      });

      var deleteOne = await CmdbuildController.commitDeletePersilCard(
          dataThatOnTap['cardData']['_id'], context);
      if (deleteOne['success'] == true) {
        await getFamilyPolygonPoints(context).then((value) {
          setState(() {
            _isLoading = false;
          });
        });

        ScaffoldMessenger.of(context).showSnackBar(
            ShowPopupNotification.showSnackBar(
                content: 'Bidang tanah dihapus'));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (buildContext) {
              return OtherFamilyMap();
            },
          ),
        );
      }
    } catch (err) {
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

  void onToggled(value) {
    setState(() {
      _toggled = value;
    });
  }

  void onDeletePopupButton() {
    ShowPopupNotification.deleteNotification(
      context: context,
      title: 'Lokasi Tanah',
      content:
          'Apakah anda yakin ingin menghapus tanah dengan NIB: ${dataThatOnTap['cardData']['Code']}?',
      action: onDeleteOne,
    );
  }

  void onClosePopupButton() {
    setState(() {
      _isShowPopUp = false;
      isShowEditForm = false;
      polyWidget[indexEdit] = Polygon(
        points: _polylinePoints,
        color: Colors.white38,
        borderColor: Colors.black87,
        borderStrokeWidth: 1,
      );
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
                    title: 'Bidang tanah', context: context),
                body: _isLoading
                    ? Center(
                        child:
                            LoadingIndicator.containerSquareLoadingIndicator())
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
                                          onTap: (value) {
                                            //   for (var i = 0;
                                            //       i < convertedFamilyPoints.length;
                                            //       i++) {
                                            //     bool isGeoPointInPolygon =
                                            //         geodesy.isGeoPointInPolygon(
                                            //             latlong.LatLng(
                                            //                 value.latitude,
                                            //                 value.longitude),
                                            //             convertedFamilyPoints[i]);
                                            //     if (isGeoPointInPolygon) {
                                            //       setState(() {
                                            //         if (_isShowPopUp) {
                                            //           _isShowPopUp = false;
                                            //
                                            //           statefulMapController.polygons.insert(indexEdit, Polygon(
                                            //             points: _polylinePoints,
                                            //             color: Colors.white38,
                                            //             borderColor:
                                            //             Colors.black87,
                                            //             borderStrokeWidth: 1,
                                            //           ));
                                            //
                                            //           // polyWidget[indexEdit] =
                                            //           //     Polygon(
                                            //           //   points: _polylinePoints,
                                            //           //   color: Colors.white38,
                                            //           //   borderColor:
                                            //           //       Colors.black87,
                                            //           //   borderStrokeWidth: 1,
                                            //           // );
                                            //
                                            //           statefulMapController.polygons.insert(i, Polygon(
                                            //             points:
                                            //             convertedFamilyPoints[i],
                                            //             color: Colors.white38,
                                            //             borderColor:
                                            //             Colors.black87,
                                            //             borderStrokeWidth: 1,
                                            //           ));
                                            //
                                            //         } else {
                                            //           _isShowPopUp = true;
                                            //           indexEdit = i;
                                            //           dataThatOnTap =
                                            //               allPolygonData[i];
                                            //           _polylinePoints =
                                            //               convertedFamilyPoints[i];
                                            //
                                            //           statefulMapController.polygons.insert(i,Polygon(
                                            //             points: _polylinePoints,
                                            //             color: Colors
                                            //                 .deepOrange.shade200
                                            //                 .withOpacity(0.7),
                                            //             borderColor: Colors
                                            //                 .deepOrange.shade200,
                                            //             borderStrokeWidth: 1,
                                            //           ) );
                                            //
                                            //         }
                                            //       });
                                            //     }
                                            //   }
                                          },
                                          maxZoom: 25,
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
                                          zoom: 19,
                                          rotationThreshold: 20,
                                        ),
                                        layers: [
                                          MapWidgetBuilder.mapTileLayer(
                                              toggled: _toggled),
                                          MarkerLayerOptions(
                                            markers: markerList,
                                          ),
                                          MarkerLayerOptions(
                                            markers: [
                                              familyLocation != null
                                                  ? Marker(
                                                      point: latlong.LatLng(
                                                          familyLocation[
                                                              'latitude'],
                                                          familyLocation[
                                                              'longitude']),
                                                      builder: (ctx) =>
                                                          Container(
                                                        child: Stack(
                                                          children: [
                                                            IconButton(
                                                                icon: Icon(
                                                                    Icons.home),
                                                                color:
                                                                    Colors.blue,
                                                                iconSize: 40,
                                                                onPressed:
                                                                    () {}),
                                                          ],
                                                        ),
                                                      ),
                                                    )
                                                  : Marker(),
                                              snapshot.hasData
                                                  ? Marker(
                                                      point: latlong.LatLng(
                                                          snapshot
                                                              .data.latitude,
                                                          snapshot
                                                              .data.longitude),
                                                      builder: (ctx) =>
                                                          IconButton(
                                                        icon: Icon(
                                                            Icons.my_location),
                                                        color: Colors.red,
                                                        iconSize: 30,
                                                        onPressed: () {
                                                          print(
                                                              'i got pressed');
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
                                                  margin: EdgeInsets.only(
                                                      top: 20.0),
                                                  // padding: EdgeInsets.all(10.0),
                                                  height: 80,
                                                  width: 200.0,
                                                  child: PopupMap.actionPopup(
                                                    onEdit: onEditPopupButton,
                                                    onDelete:
                                                        onDeletePopupButton,
                                                    onClose: onClosePopupButton,
                                                    content: dataThatOnTap !=
                                                            null
                                                        ? 'NIB: ${dataThatOnTap['cardData']['Code']}'
                                                        : 'NIB: -',
                                                  )),
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
                                              longitude:
                                                  snapshot.data.longitude);
                                        },
                                        myHomeAction: () {
                                          MapIconHelper.goToMyHomeLocation(
                                              mapController: mapController,
                                              latitude:
                                                  familyLocation['latitude'],
                                              longitude:
                                                  familyLocation['longitude']);
                                        },
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
                              isShowEditForm == true
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
                                                            attributeName:
                                                                'Code',
                                                            action:
                                                                onChangedValue,
                                                            keyboardType:
                                                                TextInputType
                                                                    .text,
                                                            initialValue:
                                                                dataThatOnTap[
                                                                        'cardData']
                                                                    ['Code']),
                                                  ),
                                                  Padding(
                                                    padding:
                                                    const EdgeInsets.only(
                                                        right: 10.0),
                                                    child: InputTextForm
                                                        .textInputFieldWithBorder(
                                                        title: 'NOP',
                                                        attributeName:
                                                        'NOP',
                                                        action:
                                                        onChangedValue,
                                                        keyboardType:
                                                        TextInputType
                                                            .text,
                                                        initialValue:
                                                        dataThatOnTap[
                                                        'cardData']
                                                        ['NOP']),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 10.0),
                                                    child: InputTextForm
                                                        .textInputFieldWithBorder(
                                                            title: 'Luas (m2)',
                                                            keyboardType: TextInputType.number,
                                                            attributeName:
                                                                'Luas',
                                                            action:
                                                                onChangedValue,
                                                            initialValue:
                                                                dataThatOnTap[
                                                                        'cardData']
                                                                    ['Luas']),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 10.0),
                                                    child:
                                                    InputDropdownFullWidth(
                                                      title: 'Guna Lahan',
                                                      lookupData: lookupData[
                                                      'GunaLahan'],
                                                      onChangedDropdownList:
                                                      onChangedDropdownList,
                                                      param: 'GunaLahan1',
                                                      initialValue:
                                                      dataThatOnTap['cardData'][
                                                      '_GunaLahan1_description'],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 10.0),
                                                    child: InputDropdownFullWidth(
                                                      title: 'Status Tanah',
                                                      lookupData: lookupData[
                                                      'StatusTanah'],
                                                      onChangedDropdownList:
                                                      onChangedDropdownList,
                                                      param: 'StatusTanah1',
                                                      initialValue:
                                                      dataThatOnTap['cardData'][
                                                      '_StatusTanah1_description'],
                                                    ),
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
                bottomNavigationBar:
                    BottomNavigation.buildContainerBottom1Navigation(
                        title:
                            isShowEditForm ? 'Simpan' : 'Tambah lokasi tanah',
                        action: () {
                          isShowEditForm
                              ? onSubmitEdit()
                              : Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return AddOtherPointMap(data: polyWidget);
                                    },
                                  ),
                                );
                        })),
          );
        });
  }
}
