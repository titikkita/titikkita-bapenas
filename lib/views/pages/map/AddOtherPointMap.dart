import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:map_controller/map_controller.dart';
import 'package:titikkita/state/indivivual_provider.dart';
import 'package:titikkita/state/location_provider.dart';
import 'package:titikkita/state/polyline_provider.dart';
import 'package:provider/provider.dart' as provider;
import 'package:titikkita/util/getDefaultLocation.dart';
import 'package:titikkita/util/mapIconHelper.dart';
import 'package:titikkita/views/pages/map/ShowFamilyOtherMap.dart';
import 'package:titikkita/views/widgets/appBar.dart';
import 'package:titikkita/views/widgets/bottomNavigation.dart';
import 'package:titikkita/views/widgets/inputDropdownFullWidth.dart';
import 'package:titikkita/views/widgets/mapWidgetBuilder.dart';
import 'package:titikkita/views/widgets/const.dart';
import 'package:titikkita/views/widgets/generalInputText.dart';
import 'package:titikkita/views/widgets/loadingIndicator.dart';
import 'package:titikkita/views/widgets/mapLabel.dart';
import 'package:flutter_map/flutter_map.dart';
import "package:latlong/latlong.dart" as latlong;
import 'package:titikkita/state/local_provider.dart';
import 'package:titikkita/controller/cmdbuild_controller.dart';
import 'package:titikkita/views/widgets/popupNotif.dart';

class AddOtherPointMap extends StatefulWidget {
  AddOtherPointMap({this.data});
  final List<Polygon> data;

  @override
  _AddOtherPointMapState createState() => _AddOtherPointMapState();
}

class _AddOtherPointMapState extends State<AddOtherPointMap> {
  MapController mapController;
  StatefulMapController statefulMapController;
  SphericalMercator mercator = SphericalMercator();
  List<Polygon> allPolygon = [];
  bool _isLoading = false;
  dynamic familyLocation;
  bool _isSubmitLoading = false;
  bool startDraw = false;
  String lotNumber;
  String lotOwner;
  bool showForm = false;
  bool _toggled = false;
  bool isAddNewPointAvailable = false;
  List<Marker> markers = [];
  Marker newMarker;
  Map<String, List<DropdownMenuItem>> lookupData = {
    "StatusTanah" :[],
    "GunaLahan":[]
  };
  List<DropdownMenuItem> commodities = [];
  dynamic newPointData = {
    'Code': '',
    'Description': '',
    'Luas': 0,
    'GunaLahan1': '',
    'StatusTanah1': '',
    "Desa": 0,
    "Kecamatan": 0,
    "Kabupaten": 0,
    'AlamatTinggal': 0,
    "NIKPemilik":0
  };

  dynamic newLocation;
  List listNewLocation = [];

  @override
  void initState() {
    getDefaultData();
    mapController = MapController();
    statefulMapController = StatefulMapController(mapController: mapController);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void onChangeLocation(value) async {
    if (showForm == true) {
      try {
        setState(() {
          newLocation = {
            'latitude': value.latitude,
            'longitude': value.longitude
          };

          newMarker = Marker(
            point: latlong.LatLng(
                newLocation['latitude'], newLocation['longitude']),
            builder: (ctx) => Container(
              child: Stack(
                children: [
                  IconButton(
                      icon: Icon(Icons.home),
                      color: Colors.green,
                      iconSize: 40,
                      onPressed: () {}),
                ],
              ),
            ),
          );
        });
      } catch (e) {
        print(e);
        ShowPopupNotification.errorNotification(
            context: context,
            content: 'Terjadi error. Coba lagi nanti!',
            action: () {
              Navigator.pop(context);
            });
      }
    }
  }

  void getDefaultData() async {
    setState(() {
      allPolygon = widget.data;
      _isLoading = true;
    });
    try {
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

      var _familyLocation;
      final individualProvider =
          provider.Provider.of<IndividualProvider>(context, listen: false);
      if (individualProvider.isIndividualLogin) {
        familyLocation = individualProvider.individualLocation;
      } else {
        _familyLocation =
            provider.Provider.of<LocationProvider>(context, listen: false)
                .familyLocation;
      }

      if (_familyLocation != null) {
        setState(() {
          familyLocation = _familyLocation;
        });
      }
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

  void onSubmitAddNewPoint() async {
    try {
      setState(() {
        _isSubmitLoading = true;
      });
      var user = provider.Provider.of<LocalProvider>(context, listen: false)
          .principalConstraint['data'][0];
      var familyAddress;

      final individualProvider =
          provider.Provider.of<IndividualProvider>(context, listen: false);
      if (!individualProvider.isIndividualLogin) {
        if (provider.Provider.of<LocalProvider>(context, listen: false)
                .address ==
            null) {
          await getDefaultLocation(context);
        }
        familyAddress =
            provider.Provider.of<LocalProvider>(context, listen: false).address;

        newPointData['Desa'] = familyAddress['data'][0]['Desa'];
        newPointData["Kecamatan"] = familyAddress['data'][0]['Kecamatan'];
        newPointData["Kabupaten"] = familyAddress['data'][0]['Kabupaten'];
        newPointData['AlamatTinggal'] = familyAddress['data'][0]['_id'];
      }

      newPointData['_tenant'] =
         user['Desa'];
      newPointData['UserID'] =
         user['_id'];
      newPointData['NIK'] = user['Code'];
      newPointData['Description'] = user['Description'];

      var convert = mercator.project(
          latlong.LatLng(newLocation['latitude'], newLocation['longitude']));

      var newDataPoint = {"_type": "point", "x": convert.x, "y": convert.y};

      var addNewDataPoint = await CmdbuildController.commitAddNewPersilCard(
          newPointData, context);
      // print("=====${addNewDataPoint['data']['_id']}");
      var submitPersilPoint =
          await CmdbuildController.commitAddFamilyPolygonePoints(
              addNewDataPoint['data']['_id'], newDataPoint, context);

      if (submitPersilPoint['success'] == true) {
        setState(() {
          _isSubmitLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
            ShowPopupNotification.showSnackBar(
                content: 'Berhasil menambahkan tanah'));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (buildContext) {
              return OtherFamilyMap();
            },
          ),
        );
      }
    } catch (e) {
      print(e);
      setState(() {
        _isSubmitLoading = false;
        _isLoading = false;
      });
      ShowPopupNotification.errorNotification(
          context: context,
          content: 'Terjadi error: $e. Coba lagi nanti!',
          action: () {
            Navigator.of(context, rootNavigator: true).pop();
          });
    }
  }

  void onChangedValue(item, value) {
    setState(() {
      newPointData[item] = value;
    });
  }

  void onToggled(value) {
    setState(() {
      _toggled = value;
    });
  }

  void onChangedDropdownList(param, value) {
    setState(() {
      newPointData[param] = value['_id'];
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
                    title: 'Tambah Bidang Tanah', context: context),
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
                                          interactiveFlags: kMapRotation,
                                          maxZoom: 25,
                                          onTap: (value) {
                                            if (startDraw == true) {
                                              setState(() {
                                                onChangeLocation(value);
                                                setState(() {
                                                  isAddNewPointAvailable = true;
                                                });
                                              });
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
                                          zoom: 19,
                                          rotationThreshold: 20,
                                        ),
                                        layers: [
                                          MapWidgetBuilder.mapTileLayer(
                                              toggled: _toggled),
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
                                          newMarker != null
                                              ? MarkerLayerOptions(
                                                  markers: [newMarker])
                                              : MarkerLayerOptions(),
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
                                                      action: onChangedValue,
                                                      keyboardType:
                                                          TextInputType.text,
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 10.0),
                                                    child: InputTextForm
                                                        .textInputFieldWithBorder(
                                                      title: 'NOP',
                                                      attributeName: 'NOP',
                                                      action: onChangedValue,
                                                      keyboardType:
                                                          TextInputType.text,
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 10.0),
                                                    child: InputTextForm
                                                        .textInputFieldWithBorder(
                                                            title: 'Luas (m2)',
                                                            attributeName:
                                                                'Luas',
                                                            action:
                                                                onChangedValue,
                                                            keyboardType:
                                                                TextInputType
                                                                    .number),
                                                  ),
                                                  // Padding(
                                                  //   padding: const EdgeInsets.only(right:10.0),
                                                  //   child: InputTextForm.textInputFieldWithBorder(
                                                  //     title: 'Guna Lahan',
                                                  //     attributeName: 'GunaLahan',
                                                  //     action: onChangedValue,
                                                  //   ),
                                                  // ),
                                                  // Padding(
                                                  //   padding: const EdgeInsets.only(right:10.0),
                                                  //   child: InputTextForm.textInputFieldWithBorder(
                                                  //     title: 'Status Tanah',
                                                  //     attributeName: 'StatusTanah',
                                                  //     action: onChangedValue,
                                                  //   ),
                                                  // ),
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
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 10.0),
                                                    child:
                                                        InputDropdownFullWidth(
                                                      title: 'Status Tanah',
                                                      lookupData: lookupData[
                                                          'StatusTanah'],
                                                      onChangedDropdownList:
                                                          onChangedDropdownList,
                                                      param: 'StatusTanah1',
                                                    ),
                                                  )
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
                    : startDraw == true && newLocation != null
                        ? BottomNavigation.buildContainerBottom2Navigation(
                            buildContext: context,
                            title1: 'Simpan',
                            title2: 'Batal',
                            action1: onSubmitAddNewPoint,
                            action2: () {
                              if (isAddNewPointAvailable) {
                                statefulMapController
                                    .removePolygon('NewPolygon');
                                isAddNewPointAvailable = false;
                              }
                              setState(() {
                                newMarker = null;
                                newLocation = {};
                                showForm = false;
                                startDraw = false;
                              });
                            },
                          )
                        : BottomNavigation.buildContainerBottom1Navigation(
                            title: 'Batal',
                            action: () {
                              setState(() {
                                if (isAddNewPointAvailable) {
                                  statefulMapController
                                      .removePolygon('NewPolygon');
                                  isAddNewPointAvailable = false;
                                }
                                newLocation = {};
                                newMarker = null;
                                showForm = false;
                                startDraw = false;
                              });
                            })),
          );
        });
  }
}
