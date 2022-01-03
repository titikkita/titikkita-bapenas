import 'package:image_picker/image_picker.dart';
import 'package:titikkita/views/widgets/modal.dart';
import 'dart:io';
import 'package:multi_image_picker/multi_image_picker.dart';

class AttachFile {

  static selectImage({buildContext, action}) {
    Modal.popUpImage(
        context: buildContext,
        action1: () {
          imgFromCamera(action: action);
        },
        action2: () {
          imgFromGallery(action: action);
        });
  }

  static imgFromCamera({action, image}) async {
    final XFile image = await ImagePicker().pickImage(
        source: ImageSource.camera, imageQuality: 50);

    action(image);
  }

  static imgFromGallery({action}) async {
    final XFile image = await ImagePicker().pickImage(
        source: ImageSource.gallery, imageQuality: 50);

    action(image);
  }

  static Future<void> selectMultipleImage({images, action}) async {
    List<Asset> resultList = <Asset>[];

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 300,
        enableCamera: true,
        selectedAssets: images,
        materialOptions: MaterialOptions(
          actionBarColor: "#abcdef",
          actionBarTitle: "Pilih Gambar",
          allViewTitle: "All Photos",
          useDetailsView: false,
          selectCircleStrokeColor: "#000000",
        ),
      );
    } on Exception catch (e) {
      print('Error: $e');
    }
    action(resultList);
  }
}
