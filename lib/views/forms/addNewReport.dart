import 'package:flutter/material.dart';
import 'package:titikkita/util/attachImage.dart';
import 'package:titikkita/util/getDefaultLocation.dart';
import 'package:titikkita/util/navigation.dart';
import 'package:titikkita/views/widgets/appBar.dart';
import 'package:titikkita/views/widgets/bottomNavigation.dart';
import 'package:titikkita/views/widgets/const.dart';
import 'package:titikkita/views/widgets/inputHomePictures.dart';
import 'package:titikkita/views/widgets/popupNotif.dart';
import 'package:titikkita/views/widgets/tagging_map.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:provider/provider.dart' as provider;
import 'package:titikkita/state/local_provider.dart';
import 'package:intl/intl.dart';
import 'package:titikkita/controller/cmdbuild_controller.dart';

class AddNewReport extends StatefulWidget {
  AddNewReport({this.title, this.cardName});
  final String title;
  final String cardName;

  @override
  _AddNewReportState createState() => _AddNewReportState();
}

class _AddNewReportState extends State<AddNewReport> {
  List<Asset> images = <Asset>[];
  String reportTitle;
  List photos = [];
  String _imageName;
  dynamic dataEdit;
  bool _isLoading = false;



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

  dateFormat() {
    var now = new DateTime.now();
    var formatter = new DateFormat('yyyy-MM-dd');
    String formattedDate = formatter.format(now);
    return formattedDate;
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
        "Tanggapan": 1222037,
        "UserID": provider.Provider.of<LocalProvider>(context, listen: false)
            .principalConstraint['data'][0]['_id'],
        "Time": dateFormat(),
        "Code": provider.Provider.of<LocalProvider>(context, listen: false)
            .infoLocationAddress,
      };

      var response = await CmdbuildController.commitAddReport(
          data, widget.cardName, images,context);
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
  void deleteImageFromList(index) {
    setState(() {
      images.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBarCustom.buildAppBarCustom(title: 'Tambah Laporan ${widget.title}',context: context),
      body:Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            margin: EdgeInsets.only(left:10, right: 20),
            padding: EdgeInsets.only(left:10, right: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 10,
                ),
                Text('Isi Laporan', style: ktextTitleBlue),
                SizedBox(
                  height: 10,
                ),
                Container(
                  height: 70,
                  child: TextFormField(
                    maxLines: 8,
                    // controller: TextEditingController(text: ''),
                    // initialValue: 'hello',
                    obscureText: false,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      // contentPadding: EdgeInsets.symmetric(vertical: 40.0),
                    ),

                    onChanged: (value) {
                      setState(() {
                        reportTitle = value;
                      });
                    },

                    style: TextStyle(
                        fontFamily: 'roboto', fontSize: 15, color: Colors.black54),
                  ),
                ),
                Row(
                  children: [
                    Text('Lokasi Kejadian', style: ktextTitleBlue),
                    IconButton(
                      icon: Icon(
                        Icons.add_location_alt_outlined,
                        size: 30.0,
                        color: Colors.blue,
                      ),
                      color: Colors.white,
                      onPressed: ()async{
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
                        };
                      },
                    ),
                  ],
                ),
                Padding(
                    padding: const EdgeInsets.only(right:10.0),
                    child: InputHomeImageForm.inputForm(
                        action: _selectImage,
                        imageName: _imageName,
                        initialValue:photos,
                        additionalImages: images,
                        deleteImage: deleteImageFromList,
                        context: context,
                        imageCardId:dataEdit!= null? dataEdit['data']['_id']:null,
                        className:'app_insfrastructurer'
                    )
                ),

              ],
            ),
          ),
          BottomNavigation.buildContainerBottom2Navigation(
              title1: 'Simpan',
              title2: 'Batal',
              buildContext: context,
              action1: onSubmitReport,
              action2: () {
                Navigator.pop(context);
              })
        ],
      ),
    );




  }
}
