import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:titikkita/controller/cmdbuild_controller.dart';
import 'package:titikkita/state/local_provider.dart';
import 'package:titikkita/util/attachImage.dart';
import 'package:titikkita/util/getDefaultLocation.dart';
import 'package:titikkita/util/getHomeImages.dart';
import 'package:titikkita/util/getReports.dart';
import 'package:titikkita/util/navigation.dart';
import 'package:titikkita/views/forms/addNewReport.dart';
import 'package:titikkita/views/pages/map/HomeGallery.dart';
import 'package:titikkita/views/widgets/tagging_map.dart';
import 'package:titikkita/views/widgets/appBar.dart';
import 'package:titikkita/views/widgets/bottomNavigation.dart';
import 'package:titikkita/views/widgets/const.dart';
import 'package:titikkita/views/widgets/loadingIndicator.dart';
import 'package:titikkita/views/widgets/modal.dart';
import 'package:provider/provider.dart' as provider;
import 'package:titikkita/views/widgets/popupNotif.dart';
import 'package:intl/intl.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

class ReportActionView extends StatefulWidget {
  ReportActionView({this.title, this.cardName});
  final String title;
  final String cardName;
  @override
  _ReportActionViewState createState() => _ReportActionViewState();
}

class _ReportActionViewState extends State<ReportActionView>
    with SingleTickerProviderStateMixin {
  // TabController _tabController;
  String reportTitle;
  String userOpinion;
  String reportDate;
  String reportEdit;
  bool _isLoading = false;
  List<Asset> images = <Asset>[];
  List photos = [];
  String _imageName;
  dynamic dataEdit;

  SphericalMercator mercator = SphericalMercator();

  void initState() {
    getDefaultReport();
    // _tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  dateFormat() {
    var now = new DateTime.now();
    var formatter = new DateFormat('yyyy-MM-dd');
    String formattedDate = formatter.format(now);
    return formattedDate;
  }

  void getDefaultReport() async {
    setState(() {
      _isLoading = true;
    });
    if (provider.Provider.of<LocalProvider>(context, listen: false)
            .report['${widget.cardName}'] ==
        null) {
      await defaultReport();
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> defaultReport() async {
    try {
      await getReportData(
          context,
          widget.cardName,
          provider.Provider.of<LocalProvider>(context, listen: false)
              .principalConstraint['data'][0]['_id']);

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

  void onSubmitReport() async {
    try {
      Navigator.pop(context);
      setState(() {
        _isLoading = true;
      });
      var data = {
        "_tenant": provider.Provider.of<LocalProvider>(context, listen: false)
            .principalConstraint['data'][0]['Desa'],
        "Description": reportTitle,
        // "Tanggapan": 15807,
        "UserID": provider.Provider.of<LocalProvider>(context, listen: false)
            .principalConstraint['data'][0]['_id'],
        "Time": dateFormat(),
        "Code": provider.Provider.of<LocalProvider>(context, listen: false)
            .infoLocationAddress,
      };

      var response = await CmdbuildController.commitAddReport(
          data, widget.cardName, images, context);

      if (response['success'] == true) {
        provider.Provider.of<LocalProvider>(context, listen: false)
            .addReportListInLocal(response['data'], widget.cardName);

        var dataToAdd =
            provider.Provider.of<LocalProvider>(context, listen: false)
                .infoLocationPoint;
        var addGeomValue =
            await CmdbuildController.commitAddReportLocationGeomValue(
                dataToAdd, response['data']['_id'], widget.title, context);

        if (addGeomValue['success'] == true) {
          setState(() {
            _isLoading = false;
          });
        }
      }
      setState(() {
        _isLoading = false;
      });

      provider.Provider.of<LocalProvider>(context, listen: false)
          .updateInfoLocationAddress('');

      ScaffoldMessenger.of(context).showSnackBar(
          ShowPopupNotification.showSnackBar(content: 'Laporan terkirim'));
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ShowPopupNotification.errorNotification(
          context: context,
          content: 'Terjadi error: $e. Coba lagi nanti!',
          action: onSubmitReport);
      print('Error adding report on report list view. Error: $e');
    }
  }

  void changeDate(value) {
    setState(() {
      reportDate = value;
    });
  }

  void changeTitle(value) {
    setState(() {
      reportTitle = value;
    });
  }

  void changeUserOpinion(value) {
    setState(() {
      userOpinion = value;
    });
  }

  void onSubmitEditReportDetail(id, index) async {
    try {
      setState(() {
        _isLoading = true;
      });
      var value = {'Description': reportEdit};
      print(value);
      var edit = await CmdbuildController.commitEditReportDetail(
          id, value, widget.cardName, context);

      if (edit['success'] == true) {
        provider.Provider.of<LocalProvider>(context, listen: false)
            .updateOneReporList(index, edit['data'], widget.cardName);

        Navigator.pop(context);
        setState(() {
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
          action: onSubmitReport);
    }
  }

  void showTaggingMap() async {
    try {
      await getDefaultLocation(context);
      goToPage(
          context,
          TaggingMapView(
            isEditMode: false,
            cardName: widget.cardName,
          ));
    } catch (e) {
      ShowPopupNotification.errorNotification(
          context: context,
          content: 'Terjadi error. Coba lagi nanti!',
          action: () {
            Navigator.pop(context);
          });
    }
  }

  Future <void> getReportAttachment(id)async{
    await getReportImages(context, id,widget.cardName).then((value) {
      final otherAreaPhotos =
      provider.Provider.of<LocalProvider>(context, listen: false)
          .attachments[widget.cardName];

      if (otherAreaPhotos.length != 0) {
        if (otherAreaPhotos[0]['success']) {
          setState(() {
            photos = otherAreaPhotos;
          });
        }
      }
    });
  }

  _selectImage() async {
    await AttachFile.selectMultipleImage(
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

  void showAddModal() {
    setState(() {
      reportTitle = '';
      userOpinion = '';
      reportDate = '';
      reportEdit = '';
    });

    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: SingleChildScrollView(
                child: SafeArea(
              child: Container(
                // padding: EdgeInsets.only(bottom: 20.0),
                child: Modal.buildModalBottomSheet(
                    context: context,
                    onSubmit: onSubmitReport,
                    onChangeDate: changeDate,
                    onChangeTitle: changeTitle,
                    onChangeUserOpinion: changeUserOpinion,
                    onTapMapIcon: showTaggingMap,
                    imageData: {
                      'selectImage': _selectImage,
                      'imageName': _imageName,
                      'photos': photos,
                      'images': images,
                      'deleteImageFromList': deleteImageFromList,
                      'dataEdit': dataEdit,
                    }),
              ),
            )),
          );
        });
  }

  void editReportDetailModal(value, id, index) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        isDismissible: false,
        builder: (context) {
          return Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: SingleChildScrollView(
              child: SafeArea(
                child: Container(
                  padding: EdgeInsets.only(bottom: 20.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20)),
                    ),
                    child: Container(
                      margin: EdgeInsets.only(top: 5, left: 20, right: 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Divider(
                            color: Colors.grey[400],
                            thickness: 2,
                            indent: 135,
                            endIndent: 135,
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Text('Isi Laporan', style: ktextTitleBlue),
                          SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            controller: TextEditingController(text: '$value'),
                            // initialValue: 'hello',
                            obscureText: false,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              // contentPadding: EdgeInsets.symmetric(vertical: 40.0),
                            ),

                            onChanged: (value) {
                              // print(value);
                              setState(() {
                                reportEdit = value;
                              });
                            },

                            style: TextStyle(
                                fontFamily: 'roboto',
                                fontSize: 15,
                                color: Colors.black54),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          BottomNavigation.buildContainerBottom1Navigation(
                              title: 'Simpan',
                              action: () {
                                if (reportEdit == null) {
                                  setState(() {
                                    reportEdit = value;
                                  });
                                }
                                onSubmitEditReportDetail(id, index);
                              })
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          goToPage(
              context,
              AddNewReport(
                title: widget.title,
                cardName: widget.cardName,
              ));
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
      appBar:
          AppBarCustom.buildAppBarCustom(title: widget.title, context: context),
      body: _isLoading == true
          ? Center(
              child: LoadingIndicator.containerSquareLoadingIndicator(),
            )
          : provider.Consumer<LocalProvider>(
              builder: (context, localProvider, child) {

                return localProvider.report['${widget.cardName}'] == null
                    ? Center(
                        child: Text(
                        'Belum ada laporan',
                        style: kTextValueBlack,
                      ))
                    : buildReportView(
                        localProvider:
                            localProvider.report['${widget.cardName}']);
              },
            ),
    );
  }

  buildReportView({localProvider}) {
    return localProvider.length == 0
        ? Center(
            child: Text(
              'Belum ada laporan',
              style: kTextValueBlack,
            ),
          )
        : Container(
            margin: EdgeInsets.only(top: 20),
            child: ListView.builder(
              itemCount: localProvider.length,
              itemBuilder: (context, index) {
                var reportData = localProvider;
                return Container(
                  padding: EdgeInsets.only(bottom: 20),
                  child: Card(
                    margin: EdgeInsets.only(left: 20, right: 20),
                    elevation: 6,
                    child: Container(
                      margin: EdgeInsets.only(left: 25, right: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Align(
                            alignment: Alignment.topRight,
                            child: Container(
                              margin: EdgeInsets.only(top: 10),
                              child: Text(
                                reportData[index]['Time'] == null
                                    ? '-'
                                    : reportData[index]['Time'],
                                style: kTextValueBlack,
                              ),
                            ),
                          ),
                          Divider(
                            color: Colors.black54,
                          ),
                          Container(
                            padding: EdgeInsets.only(bottom: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Isi", style: ktextTitleBlue),
                                reportData[index]['_Tanggapan_code'] ==
                                        'Terkirim'
                                    ? IconButton(
                                        icon: Icon(Icons.edit),
                                        iconSize: 18.0,
                                        color: Colors.blue,
                                        onPressed: () {
                                          editReportDetailModal(
                                              reportData[index]['Description'],
                                              reportData[index]['_id'],
                                              index);
                                        },
                                      )
                                    : Container(),
                              ],
                            ),
                          ),
                          Container(
                            // padding: EdgeInsets.only(bottom: 20),
                            child: Text('${reportData[index]['Description']}',
                                style: kTextValueBlack),
                          ),
                          Divider(
                            color: Colors.black54,
                          ),
                          Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Lokasi", style: ktextTitleBlue),
                                reportData[index]['_Tanggapan_description'] ==
                                        'Terkirim'
                                    ? IconButton(
                                        icon: Icon(Icons.edit),
                                        iconSize: 18.0,
                                        color: Colors.blue,
                                        onPressed: () async {
                                          var getLocation =
                                              await CmdbuildController
                                                  .getReportLocation(
                                                      reportData[index]['_id'],
                                                      context);
                                          if (getLocation['success'] == true) {
                                            goToPage(
                                                context,
                                                TaggingMapView(
                                                  isEditMode: true,
                                                  cardId: reportData[index]
                                                      ['_id'],
                                                  localIndex: index,
                                                  cardName: widget.cardName,
                                                ));
                                          } else {
                                            goToPage(
                                                context,
                                                TaggingMapView(
                                                  isEditMode: true,
                                                  cardId: reportData[index]
                                                      ['_id'],
                                                  localIndex: index,
                                                  cardName: widget.cardName,
                                                ));
                                          }
                                        },
                                      )
                                    : Container(),
                              ],
                            ),
                          ),
                          Container(
                            child: Text(
                                reportData[index]['Code'] == null
                                    ? '-'
                                    : reportData[index]['Code'],
                                style: kTextValueBlack),
                          ),
                          Divider(
                            color: Colors.black54,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding:
                                        EdgeInsets.only(top: 5, bottom: 10),
                                    child: Text("Tanggapan",
                                        style: ktextTitleBlue),
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(bottom: 10),
                                    child: Text(reportData[index]['_Tanggapan_code'] == null ? 'Terkirim' :
                                        '${reportData[index]['_Tanggapan_code']}',
                                        style: kTextValueBlack),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 10.0),
                                child: GestureDetector(
                                  onTap: ()async{
                                    await getReportAttachment(reportData[index]
                                    ['_id']).then((value){
                                      goToPage(context, ShowHomeGallery(photos: photos,cardId: reportData[index]
                                      ['_id'],className: widget.cardName,));
                                    });
                                  },
                                    child: Icon(
                                  Icons.photo,
                                  color: Colors.blue,
                                )),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
  }
}
