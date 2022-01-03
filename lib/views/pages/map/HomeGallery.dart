import 'package:flutter/material.dart';
import 'package:titikkita/controller/cmdbuild_controller.dart';
import 'package:titikkita/state/local_provider.dart';
import 'package:titikkita/util/downloadImage.dart';
import 'package:titikkita/views/widgets/appBar.dart';
import 'package:titikkita/views/widgets/const.dart';
import 'package:titikkita/views/widgets/loadingIndicator.dart';
import 'package:titikkita/views/widgets/popupNotif.dart';
import 'package:provider/provider.dart' as provider;
import 'package:percent_indicator/percent_indicator.dart';
import 'package:image_downloader/image_downloader.dart';

class ShowHomeGallery extends StatefulWidget {
  ShowHomeGallery({this.photos,this.cardId,this.className});
  final List photos;
  final int cardId;
  final String className;
  @override
  _ShowHomeGalleryState createState() => _ShowHomeGalleryState();
}

class _ShowHomeGalleryState extends State<ShowHomeGallery> {
  List<bool> isLoading = [];
  int downloadProgress;
  List images;
  bool _isSubmitLoading = false;

  @override
  void initState() {
    super.initState();
    images = widget.photos;
    widget.photos.forEach((element) {
      isLoading.add(false);
    });
  }

  imageDownloadProgress() {
    ImageDownloader.callback(onProgressUpdate: (String imageId, int progress) {
      setState(() {
        downloadProgress = progress;
      });
      return progress;
    });
  }

  // void downloadImage(imageId, ind) async {
  //   try {
  //     var cardId =
  //         provider.Provider.of<LocalProvider>(context, listen: false)
  //             .familyData['AlamatTinggal'];
  //     var className = "app_address";
  //     var download = await CmdbuildController.commitDownloadImage(
  //         className, cardId, imageId, context);
  //
  //     if (download != null) {
  //       var path = await ImageDownloader.findPath(download);
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         ShowPopupNotification.showSnackBar(
  //             content: '✓ Sukses. Tersimpan di $path',
  //             action: () {
  //               OpenFile.open(path);
  //             }),
  //       );
  //       setState(() {
  //         isLoading[ind] = false;
  //       });
  //     } else {
  //       throw new Error();
  //     }
  //   } catch (e) {
  //     print('Error: $e');
  //     ShowPopupNotification.errorNotification(
  //         context: context,
  //         content: 'Terjadi error. Coba lagi nanti!',
  //         action: () {
  //           Navigator.pop(context);
  //         });
  //   }
  // }
  void deleteTheImage(ind){
    deleteImage(
        images[ind]['data']['_id'],
        ind);
  }

  void deleteImage(imageId, index) async {
    setState(() {
      _isSubmitLoading = true;
    });
    try {

      // var cardId =
      //     provider.Provider.of<LocalProvider>(context, listen: false)
      //         .familyData['AlamatTinggal'];
      var delete = await CmdbuildController.commitDeleteAttach(
          widget.className, widget.cardId, imageId, context);
      if (delete['success'] == true) {
        setState(() {
          images.removeAt(index);
        });
        setState(() {
          _isSubmitLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
            ShowPopupNotification.showSnackBar(
                content: 'Berhasil menghapus gambar.'));
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        _isSubmitLoading = false;
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
    return StreamBuilder(
        stream: imageDownloadProgress(),
        builder: (buildContext, snapshot) {
          return Scaffold(
            appBar: AppBarCustom.buildAppBarNoNavigation(
                context: context,
                title: "Galeri Foto",
                iconAction: true,
                icon: IconButton(
                  icon: kIconCloseAppBar,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )),
            body:
            images.length != 0 ?
            Column(
              // crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Container(
                    margin: EdgeInsets.all(10),
                    child: ListView.builder(
                        itemCount: images.length,
                        itemBuilder: (context, ind) {
                          return Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(5)),
                            padding: EdgeInsets.only(left: 10, right: 5),
                            height: 60,
                            width: MediaQuery.of(context).size.width / 1.5,
                            child: Center(
                              child: Row(
                                children: [
                                  Text(
                                    '${ind + 1}.  ',
                                    style: TextStyle(fontSize: 11),
                                  ),
                                  Expanded(
                                    child: Container(
                                      child: Text(
                                        images[ind]['data']['name'],
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.black54),
                                      ),
                                    ),
                                  ),
                                  isLoading[ind]
                                      ? Padding(
                                          padding:
                                              const EdgeInsets.only(left: 8.0),
                                          child: Align(
                                            alignment: Alignment.center,
                                            child: CircularPercentIndicator(
                                              radius: 45.0,
                                              percent: downloadProgress != null
                                                  ? downloadProgress / 100
                                                  : 0.1,
                                              lineWidth: 2,
                                              center: Icon(
                                                Icons.download_rounded,
                                                color: Colors.blueAccent,
                                              ),
                                              backgroundColor: Colors.grey,
                                              progressColor: Colors.blue,
                                            ),
                                          ),
                                        )
                                      : IconButton(
                                          onPressed: () async{
                                            setState(() {
                                              isLoading[ind] = true;
                                            });
                                            // downloadImage(
                                            //     images[ind]['data']['_id'],
                                            //     ind);
                                            await downloadImage(images[ind]['data']['_id'], context).then((value) {
                                              setState(() {
                                                isLoading[ind] = false;
                                              });
                                            });
                                          },
                                          icon: Icon(
                                            Icons.download_rounded,
                                            color: Colors.blueAccent,
                                          ),
                                        ),
                                  IconButton(
                                    onPressed: () {
                                      ShowPopupNotification.deleteNotification(
                                          context: context,
                                          title: 'foto',
                                          content:
                                              'Apakah anda yakin ingin menghapus ${images[ind]['data']['name']}?',
                                          action:(){
                                            deleteTheImage(ind);
                                          });
                                    },
                                    icon: Icon(
                                      Icons.clear,
                                      color: Colors.blueAccent,
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                  ),
                ),
                _isSubmitLoading == true
                    ? Center(
                        child: Align(
                          alignment: Alignment.center,
                          child:
                              LoadingIndicator.containerWhiteLoadingIndicator(),
                        ),
                      )
                    : Container(),
              ],
            ) :
                Center(
                  child: Text('Belum ada foto yang ditambahkan.',style: kTextValueBlack,),
                )
          );
        });
  }
}
