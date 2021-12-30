import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:titikkita/controller/cmdbuild_controller.dart';
import 'package:titikkita/state/indivivual_provider.dart';
import 'package:titikkita/state/local_provider.dart';
import 'package:titikkita/state/location_provider.dart';
import 'package:titikkita/util/attachImage.dart';
import 'package:titikkita/util/getDefaultLocation.dart';
import 'package:titikkita/util/getHomeImages.dart';
import 'package:titikkita/util/getOthersMapData.dart';
import 'package:titikkita/util/mapIconHelper.dart';
import 'package:titikkita/views/widgets/actionPopupMap.dart';
import 'package:titikkita/views/widgets/appBar.dart';
import 'package:titikkita/views/widgets/bottomNavigation.dart';
import 'package:titikkita/views/widgets/const.dart';
import 'package:titikkita/views/widgets/inputHomePictures.dart';
import 'package:titikkita/views/widgets/mapWidgetBuilder.dart';
import 'package:titikkita/views/widgets/generalInputText.dart';
import 'package:titikkita/controller/location_controller.dart';
import 'package:provider/provider.dart' as provider;
import 'package:map_controller/map_controller.dart';
import "package:latlong/latlong.dart" as latlong;
import 'package:titikkita/views/widgets/loadingIndicator.dart';
import 'package:titikkita/views/widgets/mapLabel.dart';
import 'package:titikkita/views/widgets/popupNotif.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';

class OthersMap extends StatefulWidget {
  @override
  _OthersMapState createState() => _OthersMapState();
}

class _OthersMapState extends State<OthersMap> {
  dynamic familyLocation;
  double longMarker;
  double latMarker;
  String locationName;
  int idEdit;
  bool isShowForm = false;
  bool isEditMode = false;
  bool isAddMarkerAvailable = false;
  List<Marker> markers = [];
  dynamic dataEdit;
  int objectCategoryId;
  MapController mapController;
  StatefulMapController statefulMapController;
  SphericalMercator mercator = SphericalMercator();
  bool _isLoading = false;
  bool _isAlertLoading = false;
  bool _isShowPopUp = false;
  bool _toggled = false;
  TextEditingController textController = TextEditingController();
  List<Asset> images = <Asset>[];
  List photos = [];
  String _imageName;
  List <DropdownMenuItem> lookupObjek = [];
  String categoryName;

  @override
  void initState() {
    defaultData();
    mapController = MapController();
    statefulMapController = StatefulMapController(mapController: mapController);
    super.initState();
  }

  void defaultData() async {
    setState(() {
      _isLoading = true;
    });

    await CmdbuildController.getOneLookup('Kategori Objek', context)
        .then((value) {
      for(var i=0;i<value['data'].length;i++){
        lookupObjek.add(DropdownMenuItem(
          child: Text('${value['data'][i]['description']}'),
          value: value['data'][i],
        ));
      }
    });

    try {

      final individualProvider =
      provider.Provider.of<IndividualProvider>(context, listen: false);
      var _familyLocation;

      if(individualProvider.isIndividualLogin){
        final location = individualProvider.individualLocation;
        if (location == null) {
          await getDefaultIndividualLocation(context);
        }
        _familyLocation =individualProvider.individualLocation;
      }else{
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

      final otherAreas = provider.Provider.of<LocalProvider>(context,listen: false).otherAreaList;
      if(otherAreas.length == 0){
        await getOtherAreaData(context);
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
                Icon(Icons.home,color: Colors.blue,
                  size: 40,),
              ],
            ),
          ),
        ));
      }

      provider.Provider.of<LocalProvider>(context, listen: false)
          .otherAreaList
          .asMap()
          .forEach((index, e) async{

        //    add marker for each area
        var point = CustomPoint(e['x'], e['y']);
        var latLng = mercator.unproject(point);
        markers.add(Marker(
          point: latlong.LatLng(latLng.latitude, latLng.longitude),
          builder: (ctx) => GestureDetector(
            onTap: ()async{
              // find attachment for each area
              await getOtherAreaImages(context, e['data']['_id']).then((value){

                final otherAreaPhotos =
                provider.Provider.of<LocalProvider>(context, listen: false)
                    .attachments['otherAreaImages'];

                if (otherAreaPhotos.length != 0) {
                  if (otherAreaPhotos[0]['success']) {
                    setState(() {
                      photos= otherAreaPhotos;
                    });
                  }
                }
              });

              setState(() {
                dataEdit = e;
                locationName = e['data']['NamaArea'];
                categoryName = e['data']['_KategoriObjek_description'];

                textController.value = TextEditingValue(text: locationName == null ? "": '$locationName');
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
            child: Icon(Icons.push_pin,color: Colors.greenAccent,
              size: 30,),
          ),
        ));
      });
      setState(() {
        _isLoading = false;
      });
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

  _selectImage() {
    AttachFile.selectMultipleImage(
        images: images,
        action: (pictures) {
          setState(() {
            images = pictures;
          });
          // Navigator.pop(context);
        });
  }
  void deleteImageFromList(index) {
    setState(() {
      images.removeAt(index);
    });
  }

  void addAreaButton() {
    setState(() {
      isShowForm = true;
      textController.value = TextEditingValue.empty;
    });
  }

  void onEditButton() {
    setState(() {
      isEditMode = true;
      isShowForm = true;
      locationName = dataEdit['data']['NamaArea'];
      categoryName = dataEdit['data']['_KategoriObjek_description'];
    });
  }

  void onSubmitEdit() async {
    try {
      setState(() {
        _isLoading = true;
        isShowForm = false;
      });

      var newNeighbor = {
        "Code":   provider.Provider.of<LocalProvider>(context, listen: false)
            .principalConstraint['data'][0]['Code'],
        "Description":
        provider.Provider.of<LocalProvider>(context, listen: false)
            .principalConstraint['data'][0]['Description'],
        "KategoriObjek": objectCategoryId,
        "NamaArea": locationName,
        "UserID":
            provider.Provider.of<LocalProvider>(context, listen: false)
                .principalConstraint['data'][0]['_id'],
      };



      var send = await CmdbuildController.commitEditOtherArea(
          dataEdit['data']['_id'], newNeighbor,images,context);

      if (send['success'] == true) {
        await getOtherAreaData(context);
        setState(() {
          isEditMode = false;
          locationName = '';
          _isLoading = false;
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) {
              return OthersMap();
            },
          ),
        );

        ScaffoldMessenger.of(context).showSnackBar(
            ShowPopupNotification.showSnackBar(
                content: 'Lokasi berhasil diedit'));
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ShowPopupNotification.errorNotification(
          context: context,
          content: 'Terjadi error. Coba lagi nanti!',
          action: (){
            Navigator.of(context, rootNavigator: true).pop();
          }
      );
    }
  }

  void onChangedLocationName(key, value) {
    setState(() {
      locationName = value;
    });
  }

  void onAddOtherAreaSubmit() async {
    try {
      setState(() {
        _isLoading= true;
      });

      var newNeighbor = {
        "Code": provider.Provider.of<LocalProvider>(context, listen: false)
            .principalConstraint['data'][0]['Code'],
        "Description":  provider.Provider.of<LocalProvider>(context, listen: false)
            .principalConstraint['data'][0]['Description'],
        "NamaArea": locationName,
        "KategoriObjek": objectCategoryId,
        "UserID":
            provider.Provider.of<LocalProvider>(context, listen: false)
                .principalConstraint['data'][0]['_id'],
      };

      var convert = mercator.project(latlong.LatLng(latMarker, longMarker));

      var newGeom = {"_type": "point", "x": convert.x, "y": convert.y};
      var dataImages = images;

      var send =
          await CmdbuildController.commitAddNewOthersArea(newNeighbor, newGeom, dataImages,context);
      print(send);
      if (send['success'] == true) {
        await getOtherAreaData(context);

        setState(() {
          _isLoading = false;
          isEditMode = false;
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) {
              return OthersMap();
            },
          ),
        );
      }
      ScaffoldMessenger.of(context).showSnackBar(
          ShowPopupNotification.showSnackBar(
              content: 'Lokasi berhasil ditambahkan'));
    } catch (e) {
      setState(() {
        _isLoading = false;
        isEditMode = false;
      });
      ShowPopupNotification.errorNotification(
          context: context,
          content: 'Terjadi error. Coba lagi nanti!',
          action: () {
            Navigator.of(context, rootNavigator: true).pop();
          });
    }
  }

  void cancelButton() {
    setState(() {
      _isShowPopUp = false;
      if (isAddMarkerAvailable == true) {
        markers.removeLast();
        isAddMarkerAvailable = false;
      }
      isShowForm = false;
      isEditMode = false;
      locationName = '';

      latMarker = 0;
      longMarker = 0;
    });
  }

  void deletePoints() {
    setState(() {
      markers.removeLast();
      isAddMarkerAvailable = false;
    });
  }

  void onDeleteOne() async {
    try {
      setState(() {
        _isAlertLoading = true;
        isShowForm = false;
        _isLoading = true;
      });
      var deleteOne = await CmdbuildController.commitDeleteOneOthersArea(
          dataEdit['data']['_id'],context);
      if (deleteOne['success'] == true) {
        await getOtherAreaData(context);

        setState(() {
          _isLoading = false;
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) {
              return OthersMap();
            },
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isAlertLoading = false;
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

  void onChangeLocation(value) async {
    try {
      var newAddress = await LocationController.getCurrentAddres(
          value.latitude, value.longitude);

      setState(
        () {
          photos = [];
          isAddMarkerAvailable = true;
          latMarker = value.latitude;
          longMarker = value.longitude;
          markers.add(
            Marker(
              point: latlong.LatLng(latMarker, longMarker),
              builder: (ctx) {
                return IconButton(
                  icon: Icon(Icons.push_pin),
                  color: Colors.blue,
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

  void onToggled(value) {
    setState(() {
      _toggled = value;
    });
  }

  void onDeletePopupButton(){
    setState(() {
      idEdit = dataEdit[
      'data']
      ['_id'];
      // indexEdit = index;
    });
    ShowPopupNotification
        .deleteNotification(
      context: context,
      title:
      'Lokasi Tetangga',
      content:
      'Apakah anda yakin ingin menghapus lokasi ${dataEdit['data']['NamaArea']}?',
      action:
      onDeleteOne,
    );
  }

  void onClosePopupButton(){
    setState(() {
      _isShowPopUp =
      false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Geolocator.getPositionStream(locationSettings:AndroidSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 0,
          forceLocationManager: true,
        )),
        builder: (buildContext, snapshot) {
          return provider.ChangeNotifierProvider.value(
              value: LocationProvider(),
              child: Scaffold(
                  appBar: AppBarCustom.buildAppBarCustom(
                    title: "Lokasi Lainnya",
                    context: context,
                  ),
                  body: _isLoading == true || _isAlertLoading
                      ? Center(
                          child: LoadingIndicator
                              .containerSquareLoadingIndicator(),
                        )
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
                                            if (isAddMarkerAvailable == false &&
                                                isShowForm == true) {
                                              onChangeLocation(value);
                                            }
                                          },
                                          center: familyLocation != null
                                              ? latlong.LatLng(
                                                  familyLocation['latitude'],
                                                  familyLocation['longitude'])
                                              : snapshot.hasData ?
                                          latlong.LatLng(
                                                  snapshot.data.latitude,
                                                  snapshot.data.longitude) : latlong.LatLng(provider.Provider.of<LocationProvider>(context).latitude, provider.Provider.of<LocationProvider>(context).longitude),
                                          zoom: 17,
                                          rotationThreshold: 20,
                                        ),
                                        layers: [
                                          MapWidgetBuilder.mapTileLayer(toggled: _toggled),
                                          MarkerLayerOptions(
                                            markers: markers,
                                          ),
                                          MarkerLayerOptions(markers: [
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
                                          ]),
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
                                                height: 80,
                                                width: 200.0,
                                                child: PopupMap.actionPopup(
                                                  onEdit: onEditButton,
                                                  onDelete: onDeletePopupButton,
                                                  onClose: onClosePopupButton,
                                                  content: locationName,
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
                                        deleteAction:
                                            isAddMarkerAvailable == true
                                            ? deletePoints
                                            : null,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              isShowForm == true || isEditMode == true
                                  ? Container(
                                      height: 200.0,
                                      color: Colors.blue[100],
                                      child: Container(
                                        padding: EdgeInsets.all(20.0),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                        ),
                                        child: Scrollbar(
                                          isAlwaysShown: true,
                                          thickness: 2,
                                          child: SingleChildScrollView(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
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
                                                        'Kategori Objek',
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
                                                        items: lookupObjek,
                                                        onChanged: (value){
                                                          setState(() {
                                                            objectCategoryId = value['_id'];
                                                          });

                                                        },
                                                        hint: categoryName != null ? categoryName: 'Pilih salah satu:',
                                                        isExpanded: true,
                                                        style: TextStyle(
                                                            fontSize: 13,
                                                            color: Colors.black),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.only(right:10.0),
                                                  child: InputTextForm.textInputFieldWithBorder(
                                                    title:'Nama Objek',
                                                    initialValue: locationName,
                                                    action: onChangedLocationName,
                                                    controller: textController,
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.only(right:10.0),
                                                  child:    InputHomeImageForm.inputForm(
                                                    action: _selectImage,
                                                    imageName: _imageName,
                                                    initialValue: photos,
                                                    additionalImages: images,
                                                    deleteImage: deleteImageFromList,
                                                    context: context,
                                                      imageCardId:dataEdit != null? dataEdit['data']['_id']:null,
                                                      className:'app_otherarea'
                                                  )
                                                ),

                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  : Container(),
                            ],
                          ),
                        ),
                  bottomNavigationBar: isEditMode == false &&
                          isShowForm == false &&
                          _isLoading == false
                      ? BottomNavigation.buildContainerBottom1Navigation(
                          title: 'Tambah Objek',
                          action: addAreaButton,
                        )
                      : isShowForm == true && isAddMarkerAvailable || isEditMode
                          // _isLoading == false
                          ? BottomNavigation.buildContainerBottom2Navigation(
                              buildContext: context,
                              title1: 'Simpan',
                              action1: isEditMode == true
                                  ? onSubmitEdit
                                  : onAddOtherAreaSubmit,
                              title2: 'Batal',
                              action2: cancelButton,
                            )
                          : isShowForm == true && isAddMarkerAvailable == false
                              ? BottomNavigation
                                  .buildContainerBottom1Navigation(
                                  title: 'Batal',
                                  action: cancelButton,
                                )
                              : null));
        });
  }
}
