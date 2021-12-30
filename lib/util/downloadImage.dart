import 'package:flutter/material.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:titikkita/views/widgets/popupNotif.dart';
import 'package:titikkita/controller/cmdbuild_controller.dart';
import 'package:titikkita/state/local_provider.dart';
import 'package:provider/provider.dart' as provider;
import 'package:open_file/open_file.dart';

Future<void> downloadImage(imageId,context) async {
  try {
    var cardId =
    provider.Provider.of<LocalProvider>(context, listen: false)
        .familyData['AlamatTinggal'];
    var className = "app_address";
    var download = await CmdbuildController.commitDownloadImage(
        className, cardId, imageId, context);

    if (download != null) {
      var path = await ImageDownloader.findPath(download);
      ScaffoldMessenger.of(context).showSnackBar(
        ShowPopupNotification.showSnackBar(
            content: '✓ Sukses. Tersimpan di $path',
            action: () {
              OpenFile.open(path);
            }),
      );
    } else {
      throw new Error();
    }
  } catch (e) {
    print('Error: $e');
    ShowPopupNotification.errorNotification(
        context: context,
        content: 'Terjadi error. Coba lagi nanti!',
        action: () {
          Navigator.pop(context);
        });
  }
}