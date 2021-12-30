import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:titikkita/controller/cmdbuild_controller.dart';
import 'package:titikkita/state/local_provider.dart';
import 'package:titikkita/state/location_provider.dart';
import 'package:titikkita/util/getDefaultLocation.dart';
import 'package:titikkita/util/getFamilyOnPrincipal.dart';
import 'package:titikkita/util/getLocationOnNeighbor.dart';
import 'package:titikkita/util/mapIconHelper.dart';
import 'package:titikkita/views/widgets/actionPopupMap.dart';
import 'package:titikkita/views/widgets/appBar.dart';
import 'package:titikkita/views/widgets/bottomNavigation.dart';
import 'package:titikkita/views/widgets/const.dart';
import 'package:titikkita/views/widgets/generalInputText.dart';
import 'package:titikkita/views/widgets/mapWidgetBuilder.dart';
import 'package:titikkita/views/widgets/loadingIndicator.dart';
import 'package:titikkita/views/widgets/mapLabel.dart';
import 'package:provider/provider.dart' as provider;
import 'package:map_controller/map_controller.dart';
import "package:latlong/latlong.dart" as latlong;
import 'package:titikkita/views/widgets/popupNotif.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';

class PrincipalAllMapView extends StatefulWidget {
  @override
  _PrincipalAllMapViewState createState() => _PrincipalAllMapViewState();
}

class _PrincipalAllMapViewState extends State<PrincipalAllMapView> {
  dynamic myStreamLocation;
  MapController mapController;
  StatefulMapController statefulMapController;
  SphericalMercator mercator = SphericalMercator();
  bool _isLoading = false;
  bool _isSubmitLoading = false;
  bool _toggled = false;
  bool _isShowPopUp = false;
  bool clickedPointOnAddress = false;
  int indexOnClick;
  latlong.LatLng centerPoints;
  latlong.LatLng familyLocation;
  latlong.LatLng newFamilyPoint;
  List<Marker> markers = [];
  String onClickMarkerData;
  TextEditingController textController = TextEditingController();
  bool showForm = false;
  bool isPointAvailable = false;
  List<DropdownMenuItem> familyList = [];
  String familyName;
  String searchWord;
  List<String> familySearchFound = [];
  bool addPointStarted = false;
  List<dynamic> familySearchFoundDetail = [];
  dynamic foundFamilyDetail;
  dynamic constraintData;
  List idAddressList = [];
  dynamic chosedFamily;

  @override
  void initState() {
    getDefaultData();
    getFamilyList();
    getLocationTagByPrincipalOnNeighbor();
    mapController = MapController();
    statefulMapController = StatefulMapController(mapController: mapController);
    super.initState();
  }

  void getDefaultData() async {
    try {
      setState(() {
        _isLoading = true;
        constraintData =
            provider.Provider.of<LocalProvider>(context, listen: false)
                .principalConstraint['data'][0];
      });

      //find 'AlamatTinggal_ID' by filtering with user principal position
      dynamic idAddress;
      if (constraintData['_Jabatan_code'] == 'Ketua RT') {
        idAddress = await CmdbuildController.findCardWithSomeFilter(
            context: context,
            cardName: 'app_address',
            filter: 'equal',
            key: [
              'RT',
              'RW',
              'Desa'
            ],
            value: [
              constraintData['RT'],
              constraintData['RW'],
              constraintData['Desa']
            ]);
      }
      if (constraintData['_Jabatan_code'] == 'Ketua RW') {
        idAddress = await CmdbuildController.findCardWith2Filter(
            context: context,
            cardName: 'app_address',
            filter: 'equal',
            key: ['RW', 'Desa'],
            value: [constraintData['RW'], constraintData['Desa']]);
      }
      if (constraintData['_Jabatan_code'] == 'Kepala Desa') {
        // idAddress = await CmdbuildController.findCardWith2Filter(
        //     context: context,
        //     cardName: 'app_address',
        //     filter: 'equal',
        //     key: ['_Desa_description', 'Desa'],
        //     value: [constraintData['_Desa_description'], constraintData['Desa']]);

        idAddress = await CmdbuildController.findCardWithFilter(
          context: context,
          cardName: 'app_address',
          filter: 'equal',
          key: 'Desa',
          value:  constraintData['Desa']
        );

      }

      setState(() {
        idAddressList = idAddress['data'];
      });
      // find geometry poin.
      idAddress['data'].forEach((element) async {

        await CmdbuildController.getGeometryPoint(
                'app_address', element['_id'], context)
            .then((val) {

          if (val['success']) {
            var convertPoint = mercator
                .unproject(CustomPoint(val['data']['x'], val['data']['y']));
            setState(() {
              markers.add(Marker(
                point: convertPoint,
                builder: (ctx) => Container(
                  child: Stack(
                    children: [
                      GestureDetector(
                          onTap: () async {
                            var family =
                                await CmdbuildController.findCardWithFilter(
                                    context: context,
                                    cardName: 'app_family',
                                    filter: 'equal',
                                    key: 'AlamatTinggal',
                                    value: val['data']['_owner_id']);
                            setState(() {
                              _isShowPopUp = !_isShowPopUp;
                              clickedPointOnAddress = true;
                              onClickMarkerData =
                                  family['data'][0]['Description'];
                            });
                          },
                          child: Icon(
                            Icons.home,
                            size: 40,
                            color: familyLocation != null &&
                                    familyLocation == convertPoint
                                ? Colors.red
                                : Colors.blue,
                          )),
                    ],
                  ),
                ),
              ));
            });
          }
        });
      });

      textController.text = '';
      var userLocation =
          provider.Provider.of<LocationProvider>(context, listen: false)
              .familyLocation;

      if (userLocation != null) {
        setState(() {
          centerPoints = latlong.LatLng(
              userLocation['latitude'], userLocation['longitude']);
          familyLocation = centerPoints;
        });

      } else {
        //
        // await getDefaultLocation(context);
        setState(() {
          userLocation =
              provider.Provider.of<LocationProvider>(context, listen: false)
                  .familyLocation;
          if (userLocation != null) {
            familyLocation = latlong.LatLng(
                userLocation['latitude'], userLocation['longitude']);
            centerPoints = latlong.LatLng(
                userLocation['latitude'], userLocation['longitude']);
          }
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
          content: 'Terjadi : $e. Coba lagi nanti!',
          action: () {
            Navigator.of(context, rootNavigator: true).pop();
          });
    }
  }

  void getFamilyList() async {
    // find familyName
    String paramValue = '';
    List<dynamic> foundFamilyDetail = [];
    List<String> foundFamilyName = [];
    var family = await getFamilyListForPrincipal(context);

    setState(() {
      family.forEach((e){
        familyList.add(DropdownMenuItem(
          child: Text('${e['Description']}, ${e['_RT_description']}-${e['_RW_description']}'),
          value: e,
        ));
      });

    });
  }

  void addMarker(val, e) {
    var convertPoint =
        mercator.unproject(CustomPoint(val['data']['x'], val['data']['y']));
    setState(() {
      markers.add(Marker(
        point: convertPoint,
        builder: (ctx) => Container(
          child: Stack(
            children: [
              GestureDetector(
                  onTap: () {
                    setState(() {
                      _isShowPopUp = !_isShowPopUp;
                      onClickMarkerData = e['_Keluarga_description'];
                    });
                  },
                  child: Icon(
                    Icons.home,
                    size: 40,
                    color:
                        familyLocation != null && familyLocation == convertPoint
                            ? Colors.red
                            : Colors.green,
                  )),
            ],
          ),
        ),
      ));
    });
  }

  void getLocationTagByPrincipalOnNeighbor() async {
    await getLocationOnNeighbor(constraintData, context, addMarker);
  }

  void onToggled(value) {
    setState(() {
      _toggled = value;
    });
  }
  //
  // void onChangedFamilyName(key, value) {
  //   setState(() {
  //     familyName = value;
  //     searchWord = value;
  //     var listFamily = familyList.where((e) {
  //       return e.toLowerCase().contains(searchWord.toLowerCase());
  //     }).toList();
  //
  //     familySearchFoundDetail = familyListDetails.where((e) {
  //       return e['Description']
  //           .toLowerCase()
  //           .contains(searchWord.toLowerCase());
  //     }).toList();
  //     familySearchFound = listFamily;
  //   });
  //
  //   // setState(() {
  //   //   familyName = value;
  //   //   searchWord = value;
  //   //
  //   //   List<String> foundData = [];
  //   //   List<dynamic> foundDataDetail = [];
  //   //   for (var i = 0; i < familyList.length; i++) {
  //   //     if (familyList[i] != null) {
  //   //       if (familyList[i].toLowerCase().contains(searchWord.toLowerCase())) {
  //   //         foundData.add(familyList[i]);
  //   //         foundDataDetail.add(familyListDetails[i]);
  //   //       }
  //   //     }
  //   //   }
  //   //   familySearchFound = foundData;
  //   //   familySearchFoundDetail = foundDataDetail;
  //   // });
  // }

  void onSubmitted() async {
    setState(() {
      _isLoading = true;
    });

    var dataToAdd = {
      '_tenant': constraintData['Desa'],
      'Code': constraintData['Code'],
      'Description': '${constraintData['Description']} menandai ${chosedFamily['Description']}',
      'UserID': constraintData['_id'],
      'TetanggaDari': chosedFamily['AlamatTinggal'],
      'Keluarga': chosedFamily['_id'],
    };
    var xy = mercator.project(newFamilyPoint);
    var geomData = {"_type": "point", "x": xy.x, "y": xy.y};
    await CmdbuildController.commitAddFamilyLocationPointByPrincipal(
            dataToAdd, geomData, context)
        .then((value) async {
      ScaffoldMessenger.of(context).showSnackBar(
          ShowPopupNotification.showSnackBar(content: 'Data tersimpan'));
      Navigator.pop(context);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
        return PrincipalAllMapView();
      }));
    }).catchError((e) {
      print(e);
      ShowPopupNotification.errorNotification(
          context: context,
          content: 'Terjadi error: $e. Coba lagi nanti!',
          action: () {
            Navigator.of(context, rootNavigator: true).pop();
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
              title: 'Lokasi Rumah Warga',
              context: context,
            ),
            body: _isLoading == true
                ? Center(
                    child: LoadingIndicator.containerSquareLoadingIndicator())
                : Container(
                    height: MediaQuery.of(context).size.height / 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
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
                                    maxZoom: 25,
                                    interactiveFlags: kMapRotation,
                                    onTap: (value) {
                                      if (addPointStarted) {
                                        setState(() {
                                          statefulMapController.addMarker(
                                              marker: Marker(
                                                point: value,
                                                builder: (ctx) => Container(
                                                  child: Stack(
                                                    children: [
                                                      GestureDetector(
                                                          onTap: () {},
                                                          child: Icon(
                                                            Icons.home,
                                                            size: 40,
                                                            color: Colors
                                                                .greenAccent,
                                                          )),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              name: 'new');

                                          isPointAvailable = true;
                                          newFamilyPoint = value;
                                        });
                                      }
                                    },
                                    center: familyLocation != null
                                        ? familyLocation
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
                                  ),
                                  layers: [
                                    MapWidgetBuilder.mapTileLayer(
                                        toggled: _toggled),
                                    MarkerLayerOptions(
                                      markers: markers,
                                    ),
                                    MarkerLayerOptions(
                                      markers: statefulMapController.markers,
                                    ),
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
                                  ],
                                ),
                                _isShowPopUp == true
                                    ? Align(
                                        alignment: Alignment.topCenter,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white70,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(5)),
                                          ),
                                          margin: EdgeInsets.only(top: 10.0),
                                          height: 65,
                                          width: 180.0,
                                          child: PopupMap.showPopupMap(
                                            // onEdit: onEditButton,
                                            // onDelete: onDeletePopupButton,
                                            onClose: () {
                                              setState(() {
                                                _isShowPopUp = false;
                                              });
                                            },
                                            content: onClickMarkerData,
                                          ),
                                        ),
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
                                      latitude: centerPoints.latitude,
                                      longitude: centerPoints.longitude,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
            bottomNavigationBar: !isPointAvailable && !addPointStarted
                ? BottomNavigation.buildContainerBottom1Navigation(
                    title: 'Mulai menandai',
                    action: () {
                      getFamilyList();
                      setState(() {
                        addPointStarted = true;
                      });
                    },
                  )
                : isPointAvailable
                    ? BottomNavigation.buildContainerBottom2Navigation(
                        buildContext: context,
                        title1: 'Tambah',
                        title2: 'Batal',
                        action2: () {
                          setState(() {
                            statefulMapController.removeMarker(name: 'new');
                            isPointAvailable = false;
                            addPointStarted = false;
                          });
                        },
                        action1: () {
                          showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              isDismissible: false,
                              builder: (context) {
                                return Padding(
                                  padding: MediaQuery.of(context).viewInsets,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        height: 170,
                                        padding: EdgeInsets.all(20.0),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                        ),
                                        child: Scrollbar(
                                          isAlwaysShown: true,
                                          // controller: _scrollController,
                                          thickness: 2,
                                          child: SingleChildScrollView(
                                            child: Column(
                                              children: [
                                                Column(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      padding: EdgeInsets.only(bottom: 5),
                                                      width: MediaQuery.of(context)
                                                          .size
                                                          .width,
                                                      child: Text(
                                                        'Nama Tetangga (Kepala Keluarga)',
                                                        style: TextStyle(
                                                            color: Color(0xff084A9A),
                                                            fontFamily: "roboto",
                                                            fontSize: 13,
                                                            fontWeight: FontWeight.bold),
                                                      ),
                                                    ),
                                                    Container(
                                                      height: 70,
                                                      width: MediaQuery.of(context)
                                                          .size
                                                          .width,
                                                      padding: EdgeInsets.symmetric(
                                                          horizontal: 0),
                                                      margin: EdgeInsets.only(bottom: 20),
                                                      decoration: BoxDecoration(
                                                          border: Border.all(
                                                            color: Colors.black45,
                                                          ),
                                                          borderRadius:
                                                          BorderRadius.circular(5.0)),
                                                      child: SearchableDropdown.single(
                                                        items: familyList,
                                                        onChanged: (value){
                                                          setState(() {
                                                            print(value);
                                                            chosedFamily = value;
                                                          });

                                                        },
                                                        hint: 'Pilih salah satu:',
                                                        isExpanded: true,
                                                        style: TextStyle(
                                                            fontSize: 13,
                                                            color: Colors.black),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                // Padding(
                                                //   padding: EdgeInsets.only(
                                                //       right: 8.0),
                                                //   child: InputTextForm
                                                //       .textInputFieldWithBorder(
                                                //           title:
                                                //               'Nama Kepala Keluarga',
                                                //           initialValue:
                                                //               familyName,
                                                //           action:
                                                //               onChangedFamilyName,
                                                //           controller:
                                                //               textController),
                                                // ),
                                                // familySearchFound.length != 0 ?
                                                // Container(
                                                //   height: 130.0,
                                                //   child: ListView.builder(
                                                //     itemCount: familySearchFound
                                                //                 .length !=
                                                //             0
                                                //         ? familySearchFound
                                                //             .length
                                                //         : 0,
                                                //     itemBuilder:
                                                //         (BuildContext context,
                                                //             int index) {
                                                //       return GestureDetector(
                                                //           onTap: () {
                                                //             setState(() {
                                                //               familyName =
                                                //                   familySearchFound[
                                                //                       index];
                                                //               foundFamilyDetail =
                                                //                   familySearchFoundDetail[
                                                //                       index];
                                                //               textController
                                                //                       .text =
                                                //                   familyName;
                                                //               familySearchFound =
                                                //                   [];
                                                //             });
                                                //           },
                                                //           child: Padding(
                                                //             padding:
                                                //                 const EdgeInsets
                                                //                     .all(5.0),
                                                //             child: Text(
                                                //               '${familySearchFound[index]}',
                                                //               style: TextStyle(
                                                //                 fontSize: 11.0,
                                                //                 color: Colors
                                                //                     .black54,
                                                //               ),
                                                //             ),
                                                //           ));
                                                //     },
                                                //   ),
                                                // ):Container(),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      BottomNavigation
                                          .buildContainerBottom2Navigation(
                                              title1: 'Simpan',
                                              action1: () {
                                                setState(() {
                                                  showForm = false;
                                                  isPointAvailable = false;
                                                  addPointStarted = false;
                                                });
                                                onSubmitted();
                                              },
                                              buildContext: context,
                                              title2: 'Batal',
                                              action2: () {
                                                Navigator.pop(context);
                                              })
                                    ],
                                  ),
                                );
                              });
                        },
                      )
                    : null,
          ),
        );
      },
    );
  }
}
