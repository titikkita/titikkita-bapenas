import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:titikkita/controller/cmdbuild_controller.dart';
import 'package:titikkita/state/indivivual_provider.dart';
import 'package:titikkita/state/local_provider.dart';
import 'package:titikkita/state/location_provider.dart';
import 'package:titikkita/util/getDefaultLocation.dart';
import 'package:titikkita/util/getFamilyList.dart';
import 'package:titikkita/util/getNeighborsData.dart';
import 'package:titikkita/util/mapIconHelper.dart';
import 'package:titikkita/views/widgets/actionPopupMap.dart';
import 'package:titikkita/views/widgets/appBar.dart';
import 'package:titikkita/views/widgets/bottomNavigation.dart';
import 'package:titikkita/views/widgets/const.dart';
import 'package:titikkita/views/widgets/inputDropdownFullWidth.dart';
import 'package:titikkita/views/widgets/mapWidgetBuilder.dart';
import 'package:titikkita/views/widgets/generalInputText.dart';
import 'package:provider/provider.dart' as provider;
import 'package:map_controller/map_controller.dart';
import "package:latlong/latlong.dart" as latlong;
import 'package:titikkita/views/widgets/loadingIndicator.dart';
import 'package:titikkita/views/widgets/mapLabel.dart';
import 'package:titikkita/views/widgets/popupNotif.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';

class NeighborMapView extends StatefulWidget {
  @override
  _NeighborMapViewState createState() => _NeighborMapViewState();
}

class _NeighborMapViewState extends State<NeighborMapView> {
  dynamic myStreamLocation;
  dynamic familyLocation;
  double latMarker;
  double longMarker;
  String orientation;
  List<dynamic> neighborData;
  List<Marker> markers = [];
  String neighborName;
  dynamic neighborDetail;
  bool isShowPopup;
  MapController mapController;
  bool showForm = false;
  StatefulMapController statefulMapController;
  SphericalMercator mercator = SphericalMercator();
  bool isAddModeActive = false;
  bool isEditMode = false;
  int indexEdit;
  int idEdit;
  dynamic dataEdit;
  bool isAddMarkerAvailable = false;
  bool _isLoading = false;
  bool _isAlertLoading = false;
  bool _isShowPopUp = false;
  bool _toggled = false;
  bool isValidate = false;
  String validation;
  List<DropdownMenuItem> familyList = [];
  List<dynamic> familyListDetail = [];
  List<String> neighborSearchFound = [];
  List<dynamic> neighborSearchFoundDetail = [];
  dynamic chosedFamily;

  String searchWord = '';
  final TextEditingController textController = TextEditingController();

  @override
  void initState() {
    getDefaultData();
    getListOfFamily(context);
    mapController = MapController();
    statefulMapController = StatefulMapController(mapController: mapController);
    super.initState();
  }

  myKey(value) {
    return Key(value);
  }

  void onDeleteOne() async {
    try {
      setState(() {
        _isAlertLoading = true;
        _isLoading = true;
      });
      var deleteOne = await CmdbuildController.commitDeleteNeighborLocation(
          idEdit, context);

      if (deleteOne['success'] == true) {
        await getNeighborData(context);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) {
              return NeighborMapView();
            },
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(
            ShowPopupNotification.showSnackBar(
                content: 'Berhasil menghapus lokasi tetangga'));
      }
    } catch (e) {
      setState(() {
        _isAlertLoading = false;
        _isLoading = false;
      });
      ShowPopupNotification.errorNotification(
          context: context,
          content: 'Terjadi error: $e. Coba lagi nanti!',
          action: () {
            Navigator.pop(context);
          });
    }
  }

  void onEditButton() {
    setState(() {
      isEditMode = true;
      showForm = true;
      orientation = dataEdit['data']['_OrientasiRumah_code'];
    });
  }

  void onSubmitEditOne() async {
    try {
      if (chosedFamily == null) {
        setState(() {
          isValidate = true;
          validation = '* Anda tidak mengubah nama tetangga, klik batal!';
        });
      } else {
        setState(() {
          isValidate = false;
          _isLoading = true;
        });
        var newNeighbor = getDataNeighborToSend();

        var send = await CmdbuildController.commitEditNeighborData(
            dataEdit['data']['_id'], newNeighbor, context);

        if (send['success'] == true) {
          await getNeighborData(context);

          setState(() {
            isEditMode = false;
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
              ShowPopupNotification.showSnackBar(
                  content: 'Lokasi tetangga berhasil diedit'));
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) {
                return NeighborMapView();
              },
            ),
          );
        }
      }
    } catch (e) {
      print(e);
      setState(() {
        isEditMode = false;
        _isLoading = false;
      });
      ShowPopupNotification.errorNotification(
          context: context,
          content: 'Terjadi error: $e Coba lagi !',
          action: () {
            // Navigator.pop(context);
            setState(() {
              isEditMode = true;
              showForm = true;
              _isLoading = false;
            });

            Navigator.of(context, rootNavigator: true).pop();
          });
    }
  }

  getListOfFamily(context) async {
    await getFamilyList(context).then((value) {
      setState(() {
        // familyList = value;
        familyList = provider.Provider.of<LocalProvider>(context, listen: false)
            .familyListDropdown;
        setState(() {
          _isLoading = false;
        });
      });
    }).catchError((e) {
      setState(() {
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

  void getDefaultData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final neighborLocation =
          provider.Provider.of<LocalProvider>(context, listen: false)
              .neighborData;
      if (neighborLocation.length == 0) {
        await getNeighborData(context);
      }

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
        markers.add(Marker(
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
        ));
      }

      provider.Provider.of<LocalProvider>(context, listen: false)
          .neighborData
          .asMap()
          .forEach((index, e) {
        var point = CustomPoint(e['x'], e['y']);
        var latLng = mercator.unproject(point);

        markers.add(Marker(
          point: latlong.LatLng(latLng.latitude, latLng.longitude),
          builder: (ctx) => GestureDetector(
            onTap: () {
              setState(() {
                dataEdit = e;
                neighborName = e['data']['_Keluarga_description'];
                textController.value = TextEditingValue(text: '$neighborName');
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
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void editButton() {
    setState(() {
      isAddModeActive = true;
      showForm = true;
      textController.value = TextEditingValue.empty;
    });
  }

  void cancelButton() {
    setState(() {
      _isShowPopUp = false;
      chosedFamily = null;
      isValidate = false;
      if (isAddMarkerAvailable == true) {
        markers.removeLast();
        isAddMarkerAvailable = false;
      }
      isAddModeActive = false;
      showForm = false;
      isEditMode = false;
    });
  }

  void deletePoints() {
    setState(() {
      markers.removeLast();
      isAddMarkerAvailable = false;
    });
  }
  //
  // void onChangedNeighborsName(key, value) {
  //   setState(() {
  //     neighborName = value;
  //     searchWord = value;
  //
  //     List<String> foundData = [];
  //     List<dynamic> foundDataDetail = [];
  //     for (var i = 0; i < familyList.length; i++) {
  //       if (familyList[i] != null) {
  //         if (familyList[i].toLowerCase().contains(searchWord.toLowerCase())) {
  //           foundData.add(familyList[i]);
  //           foundDataDetail.add(familyListDetail[i]);
  //         }
  //       }
  //     }
  //     neighborSearchFound = foundData;
  //     neighborSearchFoundDetail = foundDataDetail;
  //   });
  // }

  void onChangedOrientationName(attribute, value, lookupName) {
    setState(() {
      orientation = value;
    });
  }

  void onChangeLocation(value) async {
    try {
      setState(
        () {
          latMarker = value.latitude;
          longMarker = value.longitude;
          markers.add(
            Marker(
              point: latlong.LatLng(latMarker, longMarker),
              builder: (ctx) {
                return IconButton(
                  icon: Icon(Icons.home),
                  color: Colors.greenAccent,
                  iconSize: 30,
                  onPressed: () {},
                );
              },
            ),
          );
        },
      );
    } catch (e) {
      ShowPopupNotification.errorNotification(
          context: context,
          content: 'Terjadi error. Coba lagi nanti!',
          action: () {
            Navigator.pop(context);
          });
    }
  }

  getDataNeighborToSend() {
    var newNeighbor;
    var orientationLookup =
        provider.Provider.of<LocalProvider>(context, listen: false)
            .lookupDataDetail['orientationLookupData'];

    var foundOrientation =
        orientationLookup['OrientasiLokasi']['data'].where((e) {
      return e['code'] == orientation;
    }).toList();

    newNeighbor = {
      "_tenant": provider.Provider.of<LocalProvider>(context, listen: false)
          .principalConstraint['data'][0]['Desa'],
      // "Code": provider.Provider.of<LocalProvider>(context, listen: false)
      //     .familyData['Code'],
      "Code": provider.Provider.of<LocalProvider>(context, listen: false)
          .principalConstraint['data'][0]['Code'],
      "Description":
          '${provider.Provider.of<LocalProvider>(context, listen: false).principalConstraint['data'][0]['Description']} bertetanggan dengan ${chosedFamily['Description']}',
      "OrientasiRumah":
          foundOrientation.length == 0 ? null : foundOrientation[0]['_id'],
      "TetanggaDari": chosedFamily['AlamatTinggal'],
      "UserID": provider.Provider.of<LocalProvider>(context, listen: false)
          .principalConstraint['data'][0]['_id'],
      "Keluarga": chosedFamily['_id'],
    };

    return newNeighbor;
  }

  void onAddNeighborSubmit() async {
    try {
      if (chosedFamily == null) {
        setState(() {
          isValidate = true;
          validation = '* Pilih nama tetangga terlebih dahulu !';
        });
      } else {
        setState(() {
          isValidate = false;
          _isLoading = true;
        });

        var newNeighbor = getDataNeighborToSend();

        var convert = mercator.project(latlong.LatLng(latMarker, longMarker));

        var newGeom = {"_type": "point", "x": convert.x, "y": convert.y};

        var send = await CmdbuildController.commitAddNewNeighborLocation(
            newNeighbor, newGeom, context);

        if (send['success'] == true) {
          await getNeighborData(context);
          setState(() {
            showForm = false;
            isAddMarkerAvailable = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
              ShowPopupNotification.showSnackBar(
                  content: 'Lokasi tetangga berhasil ditambahkan'));
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) {
                return NeighborMapView();
              },
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print(e);
      ShowPopupNotification.errorNotification(
          context: context,
          content: 'Terjadi error: $e. Coba lagi nanti!',
          action: () {
            Navigator.of(context, rootNavigator: true).pop();
          });
    }
  }

  void onToggled(value) {
    setState(() {
      _toggled = value;
    });
  }

  void onDeletePopupButton() {
    setState(() {
      idEdit = dataEdit['data']['_id'];
      // indexEdit = index;
    });
    ShowPopupNotification.deleteNotification(
      context: context,
      title: 'Lokasi Tetangga',
      content: 'Apakah anda yakin ingin menghapus lokasi $neighborName?',
      action: onDeleteOne,
    );
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
                    title: "Lokasi Tetangga Saya", context: context),
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
                                        interactiveFlags: kMapRotation,
                                        maxZoom: 25,
                                        onTap: (value) {
                                          if (isAddModeActive == true &&
                                              isAddMarkerAvailable == false) {
                                            onChangeLocation(value);
                                            setState(() {
                                              isAddMarkerAvailable = true;
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
                                        zoom: 17,
                                        rotationThreshold: 20,
                                      ),
                                      layers: [
                                        MapWidgetBuilder.mapTileLayer(
                                            toggled: _toggled),
                                        MarkerLayerOptions(
                                          markers: markers,
                                        ),
                                        MarkerLayerOptions(markers: [
                                          snapshot.hasData
                                              ? Marker(
                                                  point: latlong.LatLng(
                                                      snapshot.data.latitude,
                                                      snapshot.data.longitude),
                                                  builder: (ctx) => Container(
                                                    child: Stack(
                                                      children: [
                                                        IconButton(
                                                            icon: Icon(Icons
                                                                .my_location),
                                                            color: Colors.red,
                                                            iconSize: 30,
                                                            onPressed: () {}),
                                                      ],
                                                    ),
                                                  ),
                                                )
                                              : Marker(),
                                        ]),
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
                                              margin:
                                                  EdgeInsets.only(top: 20.0),
                                              height: 90,
                                              width: 180.0,
                                              child: PopupMap.actionPopup(
                                                onEdit: onEditButton,
                                                onDelete: onDeletePopupButton,
                                                onClose: onClosePopupButton,
                                                content: neighborName,
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
                                            latitude:
                                                familyLocation['latitude'],
                                            longitude:
                                                familyLocation['longitude']);
                                      },
                                      deleteAction: isAddModeActive == true &&
                                              isAddMarkerAvailable == true
                                          ? deletePoints
                                          : null,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            showForm == true
                                ? Container(
                                    padding: EdgeInsets.only(
                                        top: 20.0, right: 20, left: 20),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(20.0),
                                        topRight: Radius.circular(20.0),
                                      ),
                                    ),
                                    child: Container(
                                        height: 180,
                                        child: Scrollbar(
                                          thickness: 2,
                                          isAlwaysShown: true,
                                          child: SingleChildScrollView(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 10.0),
                                                  child: InputTextForm.dropdownInputFieldWithBorder(
                                                      attributeName:
                                                          'OrientasiRumah',
                                                      title:
                                                          'Posisi Rumah Tetangga',
                                                      lookupName:
                                                          'OrientasiLokasi',
                                                      itemList: provider
                                                                  .Provider
                                                              .of<LocalProvider>(
                                                                  context)
                                                          .lookupData,
                                                      initialValue: isEditMode ==
                                                              true
                                                          ? dataEdit['data'][
                                                              '_OrientasiRumah_code']
                                                          : null,
                                                      action:
                                                          onChangedOrientationName),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 10.0),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Container(
                                                        padding:
                                                            EdgeInsets.only(
                                                                bottom: 5),
                                                        width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width,
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              'Nama Tetangga (Kepala Keluarga)',
                                                              style: TextStyle(
                                                                  color: Color(
                                                                      0xff084A9A),
                                                                  fontFamily:
                                                                      "roboto",
                                                                  fontSize: 13,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                            isValidate
                                                                ? Text(
                                                                    '$validation',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .red,
                                                                        fontSize:
                                                                            11),
                                                                  )
                                                                : Container()
                                                          ],
                                                        ),
                                                      ),
                                                      Container(
                                                        height: 70,
                                                        width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width,
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal: 0),
                                                        margin: EdgeInsets.only(
                                                            bottom: 20),
                                                        decoration:
                                                            BoxDecoration(
                                                                border:
                                                                    Border.all(
                                                                  color: Colors
                                                                      .black45,
                                                                ),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            5.0)),
                                                        child:
                                                            SearchableDropdown
                                                                .single(
                                                          items: familyList,
                                                          onChanged: (value) {
                                                            setState(() {
                                                              chosedFamily =
                                                                  value;
                                                            });
                                                          },
                                                          hint: 'Pilih salah satu:',
                                                          isExpanded: true,
                                                          style: TextStyle(
                                                              fontSize: 13,
                                                              color:
                                                                  Colors.black),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )),
                                  )
                                : Container(),
                          ],
                        ),
                      ),
                bottomNavigationBar: showForm == false &&
                        isEditMode == false &&
                        _isLoading == false
                    ? BottomNavigation.buildContainerBottom1Navigation(
                        title: 'Tambah Tetangga',
                        action: editButton,
                      )
                    : isEditMode == true &&
                            showForm == true &&
                            _isLoading == false
                        ? BottomNavigation.buildContainerBottom2Navigation(
                            buildContext: context,
                            title1: 'Simpan',
                            title2: 'Batal',
                            action1: () {
                              onSubmitEditOne();
                            },
                            action2: cancelButton,
                          )
                        : isEditMode == false &&
                                _isLoading == false &&
                                isAddMarkerAvailable
                            ? BottomNavigation.buildContainerBottom2Navigation(
                                buildContext: context,
                                title1: 'Tambahkan',
                                title2: 'Batal',
                                action1: onAddNeighborSubmit,
                                action2: cancelButton,
                              )
                            : isEditMode == false &&
                                    _isLoading == false &&
                                    isAddMarkerAvailable == false
                                ? BottomNavigation
                                    .buildContainerBottom1Navigation(
                                    title: 'Batal',
                                    action: cancelButton,
                                  )
                                : null),
          );
        });
  }
}
