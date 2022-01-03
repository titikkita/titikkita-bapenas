import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:titikkita/controller/cmdbuild_controller.dart';
import 'package:titikkita/state/local_provider.dart';
import 'package:titikkita/state/location_provider.dart';
import 'package:titikkita/util/mapIconHelper.dart';
import 'package:titikkita/views/pages/principalInformation/FamilyList.dart';
import 'package:titikkita/views/widgets/actionPopupMap.dart';
import 'package:titikkita/views/widgets/appBar.dart';
import 'package:titikkita/views/widgets/bottomNavigation.dart';
import 'package:titikkita/views/widgets/const.dart';
import 'package:titikkita/views/widgets/mapWidgetBuilder.dart';
import 'package:titikkita/views/widgets/loadingIndicator.dart';
import 'package:titikkita/views/widgets/mapLabel.dart';
import 'package:provider/provider.dart' as provider;
import 'package:map_controller/map_controller.dart';
import "package:latlong/latlong.dart" as latlong;
import 'package:titikkita/views/widgets/popupNotif.dart';

class PrincipalMapView extends StatefulWidget {
  PrincipalMapView(this.data);
  final dynamic data;
  @override
  _PrincipalMapViewState createState() => _PrincipalMapViewState();
}

class _PrincipalMapViewState extends State<PrincipalMapView> {
  dynamic myStreamLocation;
  bool showForm = false;
  MapController mapController;
  StatefulMapController statefulMapController;
  SphericalMercator mercator = SphericalMercator();
  bool _isLoading = false;
  bool _isSubmitLoading = false;
  bool _toggled = false;
  latlong.LatLng centerPoints;
  latlong.LatLng familyLocation;
  List<Marker> markers = [];
  TextEditingController textController = TextEditingController();
  dynamic constraintData;
  bool _isShowPopUp = false;
  String onClickMarkerDataInfo;

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
        // textController.text = widget.data['_AlamatTinggal_description'];
        constraintData =
            provider.Provider.of<LocalProvider>(context, listen: false)
                .principalConstraint['data'][0];
      });

      try {
        //find location from address table
        var locationOnAddress = await CmdbuildController.getFamilyLocationPoint(
            widget.data['AlamatTinggal'], context);
        if (locationOnAddress['success']) {

          setState(() {
           addMarker(locationOnAddress, 'Ditandai oleh user sendiri.', Colors.blue);
          });
        }

        //find location from neighborhood table
       await CmdbuildController.findCardWithFilter(
            context: context,
            cardName: 'app_neighborhood',
            filter: 'equal',
            key: 'Keluarga',
            value: widget.data['_id']).then((result){
          if(result['success']){
            result['data'].forEach((el) async{

              await CmdbuildController.getGeometryPoint('app_neighborhood', el['_id'], context).then((point){

                if(point['success']){
                  addMarker(point, 'Ditandai oleh ${el['_UserID_description']}',Colors.green);
                  print('Total marker ====${markers.length}');
                }
              });
            });
          }
        });
      } catch (err) {
        print(err);
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
            Navigator.of(context, rootNavigator: true).pop();
          });
    }
  }

  void addMarker(val,e,color){
    var convertPoint = mercator
        .unproject(CustomPoint(val['data']['x'], val['data']['y']));
    if(centerPoints == null){
      setState(() {
        centerPoints = convertPoint;
      });
    }
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
                      onClickMarkerDataInfo = e;
                    });
                  },
                  child: Icon(
                    Icons.home,
                    size: 40,
                    color:color
                  )),
            ],
          ),
        ),
      ));
    });
  }


  void onSubmitMyMap() async {
    setState(() {
      _isSubmitLoading = true;
    });

    if (familyLocation != null) {
      var dataToAdd = {
        '_tenant': constraintData['Desa'],
        'Code': constraintData['Code'],
        'Description':
            '${constraintData['Description']} menandai ${widget.data['Description']}',
        'UserID': constraintData['_id'],
        'TetanggaDari': widget.data['AlamatTinggal'],
        'Keluarga': widget.data['_id'],
      };

      var xy = mercator.project(familyLocation);
      var geomData = {"_type": "point", "x": xy.x, "y": xy.y};
      await CmdbuildController.commitAddFamilyLocationPointByPrincipal(
              dataToAdd, geomData, context)
          .then((value) async {
        ScaffoldMessenger.of(context).showSnackBar(
            ShowPopupNotification.showSnackBar(content: 'Data tersimpan'));
        setState(() {
          _isSubmitLoading = false;
        });
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
          return FamilyListView();
        }));
      }).catchError((e) {
        print(e);
        setState(() {
          _isLoading = false;
          _isSubmitLoading = false;
        });
        ShowPopupNotification.errorNotification(
            context: context,
            content: 'Terjadi error: $e. Coba lagi nanti!',
            action: () {
              Navigator.of(context, rootNavigator: true).pop();
            });
      });
    } else {
      setState(() {
        _isSubmitLoading = false;
      });
      ShowPopupNotification.errorNotification(
          context: context,
          content: 'Silahkan tambahkan lokasi anda terlebih dahulu',
          action: () {
            setState(() {
              _isSubmitLoading = false;
            });
          });
    }
  }

  void setShowForm() {
    setState(() {
      showForm == true ? showForm = false : showForm = true;
      familyLocation = null;
    });
  }

  void onChangeLocation(value) async {
    if (showForm == true) {
      try {
        setState(() {
          familyLocation = latlong.LatLng(value.latitude, value.longitude);
          centerPoints = familyLocation;
        });
      } catch (e) {
        print(e);
        ShowPopupNotification.errorNotification(
            context: context,
            content: 'Terjadi error. Coba lagi nanti!',
            action: () {
              Navigator.of(context, rootNavigator: true).pop();
            });
      }
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
        return provider.ChangeNotifierProvider.value(
          value: LocationProvider(),
          child: Scaffold(
              appBar: AppBarCustom.buildAppBarCustom(
                title: 'Lokasi Rumah ${widget.data['Description']}',
                context: context,
              ),
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
                                      maxZoom: 25,
                                      interactiveFlags: kMapRotation,
                                      onTap: (value) {
                                        onChangeLocation(value);
                                      },
                                      center: centerPoints != null
                                          ? centerPoints
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
                                        markers: [
                                          snapshot.data != null
                                              ? Marker(
                                                  point: latlong.LatLng(
                                                      snapshot.data.latitude,
                                                      snapshot.data.longitude),
                                                  builder: (ctx) => Container(
                                                    child: IconButton(
                                                      icon: Icon(
                                                          Icons.my_location),
                                                      color: Colors.red,
                                                      iconSize: 30,
                                                      onPressed: () {},
                                                    ),
                                                  ),
                                                )
                                              : Marker(),
                                          familyLocation != null
                                              ? Marker(
                                                  point: familyLocation,
                                                  builder: (ctx) => Container(
                                                    child: IconButton(
                                                      icon: Icon(Icons.home),
                                                      color: Colors.greenAccent,
                                                      iconSize: 45,
                                                      onPressed: () {},
                                                    ),
                                                  ),
                                                )
                                              : Marker(),
                                        ],
                                      ),
                                      markers.length != 0 ?
                                      MarkerLayerOptions(
                                          markers: markers
                                      ) :
                                      MarkerLayerOptions()
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
                                        content: onClickMarkerDataInfo,
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
                                    // myHomeAction: () {
                                    //   MapIconHelper.goToMyHomeLocation(
                                    //     mapController: mapController,
                                    //     latitude: centerPoints.latitude,
                                    //     longitude: centerPoints.longitude,
                                    //   );
                                    // },
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
                        ],
                      ),
                    ),
              bottomNavigationBar: showForm == false && _isLoading == false
                  ? BottomNavigation.buildContainerBottom1Navigation(
                      title: 'Tambah',
                      action: setShowForm,
                    )
                  : showForm == true && familyLocation != null
                      ? BottomNavigation.buildContainerBottom2Navigation(
                          title1: 'Simpan',
                          title2: 'Batal',
                          action1: onSubmitMyMap,
                          action2: setShowForm,
                          buildContext: context,
                        )
                      : null),
        );
      },
    );
  }
}
