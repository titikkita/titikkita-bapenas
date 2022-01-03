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
import 'package:titikkita/util/mapIconHelper.dart';
import 'package:titikkita/util/navigation.dart';
import 'package:titikkita/views/widgets/appBar.dart';
import 'package:titikkita/views/widgets/bottomNavigation.dart';
import 'package:titikkita/views/widgets/const.dart';
import 'package:titikkita/views/widgets/inputHomePictures.dart';
import 'package:titikkita/views/widgets/mapWidgetBuilder.dart';
import 'package:titikkita/views/widgets/generalInputText.dart';
import 'package:titikkita/views/widgets/loadingIndicator.dart';
import 'package:titikkita/views/widgets/mapLabel.dart';
import 'package:provider/provider.dart' as provider;
import 'package:map_controller/map_controller.dart';
import "package:latlong/latlong.dart" as latlong;
import 'package:titikkita/views/widgets/popupNotif.dart';
import 'package:titikkita/views/pages/map/ShowFamilyOtherMap.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

class MyMapView extends StatefulWidget {
  @override
  _MyMapViewState createState() => _MyMapViewState();
}

class _MyMapViewState extends State<MyMapView> {
  dynamic myStreamLocation;
  dynamic familyLocation;
  String address;
  bool showForm = false;
  MapController mapController;
  StatefulMapController statefulMapController;
  SphericalMercator mercator = SphericalMercator();
  List<latlong.LatLng> polylinePoint = [];
  bool _isLoading = false;
  bool _isSubmitLoading = false;
  bool _toggled = false;
  latlong.LatLng centerPoints;
  List<Marker> markers = [];
  String _imageName;
  dynamic imageData;
  List<Asset> images = <Asset>[];
  List photos = [];
  ScrollController _scrollController;
  TextEditingController textController = TextEditingController();

  @override
  void initState() {
    getDefaultData();
    _scrollController = ScrollController();
    mapController = MapController();
    statefulMapController = StatefulMapController(mapController: mapController);
    super.initState();
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

  void onChanged(key, value) {
    setState(() {
      address = value;
    });
  }

  void getDefaultData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final individualProvider =
          provider.Provider.of<IndividualProvider>(context, listen: false);

      if (individualProvider.isIndividualLogin) {
        final geometryPoint = individualProvider.individualLocation;

        if (geometryPoint == null) {
          await getDefaultIndividualLocation(context);
        }

        // Get image attachments
        await getIndividualHomeImages(context).then((value) {
          final homePhotos = individualProvider.attachments['homeImages'];
          if (homePhotos != null) {
            if (homePhotos.length != 0) {
              if (homePhotos[0]['success']) {
                setState(() {
                  photos = homePhotos;
                });
              }
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
                ShowPopupNotification.showSnackBar(
                    content: 'Alfresco attachment got error'));
          }
        });
        // ========================================== //
        setState(() {
          if (individualProvider.individualLocation != null) {
            familyLocation = individualProvider.individualLocation;

            centerPoints = latlong.LatLng(
                familyLocation['latitude'], familyLocation['longitude']);
          }

          if (individualProvider.individualData['AlamatIndividu'] != null) {
            address = individualProvider.individualData['AlamatIndividu'];
          }
          _isLoading = false;
        });
      } else {
        // get geometry point
        final location =
            provider.Provider.of<LocationProvider>(context, listen: false)
                .familyLocation;
        if (location == null) {
          await getDefaultLocation(context);
        }
        // ========================================== //

        // get image attachments
        await getHomeImages(context).then((value) {
          final homePhotos =
              provider.Provider.of<LocalProvider>(context, listen: false)
                  .attachments['homeImages'];
          if (homePhotos != null) {
            if (homePhotos.length != 0) {
              if (homePhotos[0]['success']) {
                setState(() {
                  photos = homePhotos;
                });
              }
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
                ShowPopupNotification.showSnackBar(
                    content: 'Alfresco attachment got error'));
          }
        });
        // ========================================== //

        setState(() {
          if (provider.Provider.of<LocationProvider>(context, listen: false)
                  .familyLocation !=
              null) {
            familyLocation =
                provider.Provider.of<LocationProvider>(context, listen: false)
                    .familyLocation;

            centerPoints = latlong.LatLng(
                familyLocation['latitude'], familyLocation['longitude']);
          }

          if (provider.Provider.of<LocalProvider>(context, listen: false)
                  .address !=
              null) {
            address =
                provider.Provider.of<LocalProvider>(context, listen: false)
                    .address['data'][0]['Description'];
          }
          _isLoading = false;
        });
      }
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

  void attachHomePictures() async {
    try {
      final individualProvider =
          provider.Provider.of<IndividualProvider>(context, listen: false);

      if (individualProvider.isIndividualLogin) {
        var id = individualProvider.individualData['_id'];
        var dataToSend = images;
        await CmdbuildController.commitAddIndividualHomeImages(
            id: id,
            cardName: individualProvider.individualData['_type'],
            body: dataToSend);
      } else {
        var id = provider.Provider.of<LocalProvider>(context, listen: false)
            .familyData['AlamatTinggal'];
        var dataToSend = images;
        await CmdbuildController.commitAddHomeImages(
            familyId: id, body: dataToSend);
      }
    } catch (e) {
      print('error: $e');
    }
  }

  void onSubmitMyMap() async {
    setState(() {
      _isSubmitLoading = true;
    });

    final individualProvider =
        provider.Provider.of<IndividualProvider>(context, listen: false);

    if (individualProvider.isIndividualLogin) {
      if (familyLocation != null) {
        var id = individualProvider.individualData['_id'];

        if (images.length != 0) {
          await CmdbuildController.commitAddIndividualHomeImages(
              id: id,
              cardName: individualProvider.individualData['_type'],
              body: images,
              context: context);
        }

        var xy = mercator.project(latlong.LatLng(
            familyLocation['latitude'], familyLocation['longitude']));

        var dataToUpdate = {"_type": "point", "x": xy.x, "y": xy.y};

        try {
          var onSubmitGeomValue =
              await CmdbuildController.commitUpdateIndividualLocationPoint(
                  id,
                  individualProvider.individualData['_type'],
                  dataToUpdate,
                  context);

          var dataToSend = {
            'AlamatIndividu': address,
          };
          if (onSubmitGeomValue['success'] == true) {
            var onSubmitLocationNote =
                await CmdbuildController.commitUpdateData(
                    dataToSend,
                    individualProvider.individualData['_id'],
                    individualProvider.individualData['_type'],
                    context);

            if (onSubmitLocationNote['success']) {
              var id = individualProvider.individualData['_id'];
              var data = await CmdbuildController.getImageFromCitizen(
                  id, individualProvider.individualData['_type'], context);

              if (data.length != 0) {
                if (data[0]['success']) {
                  setState(() {
                    photos = data;
                  });
                }
              }

              await getIndividualHomeImages(context).then((value) async {
                ScaffoldMessenger.of(context).showSnackBar(
                    ShowPopupNotification.showSnackBar(
                        content: 'Data tersimpan'));
                setState(() {
                  _isLoading = false;
                });
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return MyMapView();
                    },
                  ),
                );
              });
            }
          }
        } catch (e) {
          setState(() {
            _isLoading = false;
          });

          print(
              'This error happened try to submit update location point on map_view.dart');
          print('Error: $e');
        }
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
    } else {
      if (familyLocation != null) {
        var idAddress =
            provider.Provider.of<LocalProvider>(context, listen: false)
                .familyData['AlamatTinggal'];

        if (images.length != 0) {
          await CmdbuildController.commitAddHomeImages(
              familyId: idAddress, body: images);
        }

        var xy = mercator.project(latlong.LatLng(
            familyLocation['latitude'], familyLocation['longitude']));

        var id = provider.Provider.of<LocalProvider>(context, listen: false)
            .familyData;

        var dataToUpdate = {"_type": "point", "x": xy.x, "y": xy.y};

        try {
          var onSubmitGeomValue =
              await CmdbuildController.commitUpdateFamilyLocationPoint(
                  id['AlamatTinggal'], dataToUpdate, context);

          var dataToSend = {
            'Description': address,
            'KeteranganLokasi':
                provider.Provider.of<LocalProvider>(context, listen: false)
                    .familyData['Description']
          };
          if (onSubmitGeomValue['success'] == true) {
            var onSubmitLocationNote =
                await CmdbuildController.commitUpdateFamilyInternalData(
                    dataToSend,
                    provider.Provider.of<LocalProvider>(context, listen: false)
                        .familyData['AlamatTinggal'],
                    context);

            if (onSubmitLocationNote['success']) {
              var id =
                  provider.Provider.of<LocalProvider>(context, listen: false)
                      .familyData['AlamatTinggal'];
              var data =
                  await CmdbuildController.getImageFromAddress(id, context);
              if (data.length != 0) {
                if (data[0]['success']) {
                  setState(() {
                    photos = data;
                  });
                }
              }
              await getDefaultLocation(context);
              await getHomeImages(context).then((value) async {
                ScaffoldMessenger.of(context).showSnackBar(
                    ShowPopupNotification.showSnackBar(
                        content: 'Data tersimpan'));
                setState(() {
                  _isLoading = false;
                });
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return MyMapView();
                    },
                  ),
                );
              });
            }
          }
        } catch (e) {
          setState(() {
            _isLoading = false;
          });

          print(
              'This error happened try to submit update location point on map_view.dart');
          print('Error: $e');
        }
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
  }

  void setShowForm() {
    setState(() {
      showForm == true ? showForm = false : showForm = true;
      images = [];
      final individualProvider =
          provider.Provider.of<IndividualProvider>(context, listen: false);

      if (individualProvider.isIndividualLogin) {
        address = individualProvider.individualData['AlamatIndividu'];
      } else {
        if (provider.Provider.of<LocalProvider>(context, listen: false)
                .address !=
            null) {
          address = provider.Provider.of<LocalProvider>(context, listen: false)
              .address['data'][0]['Description'];
        }
      }

      textController.value =
          TextEditingValue(text: address != null ? '$address' : '');
    });
  }

  void onChangeLocation(value) async {
    if (showForm == true) {
      try {
        if (familyLocation == null) {
          setState(() {
            familyLocation = {
              'latitude': value.latitude,
              'longitude': value.longitude
            };
          });
        } else {
          setState(() {
            familyLocation['latitude'] = value.latitude;
            familyLocation['longitude'] = value.longitude;
          });
        }
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
                title: 'Lokasi Rumah Saya',
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
                                      zoom: 18,
                                    ),
                                    layers: [
                                      // MapWidgetBuilder.mapBaseTileLayer(toggled: _toggled),
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
                                                  point: latlong.LatLng(
                                                      familyLocation[
                                                          'latitude'],
                                                      familyLocation[
                                                          'longitude']),
                                                  builder: (ctx) => Container(
                                                    child: IconButton(
                                                      icon: Icon(Icons.home),
                                                      color: Colors.blue,
                                                      iconSize: 45,
                                                      onPressed: () {},
                                                    ),
                                                  ),
                                                )
                                              : Marker(),
                                        ],
                                      ),
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
                                    height: 200,
                                    padding: EdgeInsets.all(20.0),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                    ),
                                    child: Scrollbar(
                                      isAlwaysShown: false,
                                      controller: _scrollController,
                                      thickness: 4,
                                      child: SingleChildScrollView(
                                        child: Column(
                                          children: [
                                            InputTextForm
                                                .textInputFieldWithBorder(
                                                    title: 'Lokasi',
                                                    keyboardType:
                                                        TextInputType.text,
                                                    action: onChanged,
                                                    controller: textController),
                                            InputHomeImageForm.inputForm(
                                              action: _selectImage,
                                              imageName: _imageName,
                                              initialValue: photos,
                                              additionalImages: images,
                                              deleteImage: deleteImageFromList,
                                              imageCardId: provider.Provider.of<
                                                              IndividualProvider>(
                                                          context)
                                                      .isIndividualLogin
                                                  ? provider.Provider.of<
                                                              IndividualProvider>(
                                                          context)
                                                      .individualData['_id']
                                                  : provider.Provider.of<
                                                                  LocalProvider>(
                                                              context)
                                                          .familyData[
                                                      'AlamatTinggal'],
                                              context: context,
                                              className: provider.Provider.of<
                                                              IndividualProvider>(
                                                          context)
                                                      .isIndividualLogin
                                                  ? provider.Provider.of<
                                                              IndividualProvider>(
                                                          context)
                                                      .individualData['_type']
                                                  : 'app_address',
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : Container()
                        ],
                      ),
                    ),
              bottomNavigationBar: showForm == false && _isLoading == false
                  ? BottomNavigation.buildContainerBottom2Navigation(
                      title1: 'Rumah Saya',
                      action1: setShowForm,
                      title2: 'Tanah Lainnya',
                      action2: () {
                        goToPage(context, OtherFamilyMap());
                      },
                      buildContext: context)
                  : showForm == true
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
