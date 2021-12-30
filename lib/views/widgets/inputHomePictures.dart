import 'package:flutter/material.dart';
import 'package:titikkita/util/navigation.dart';
import 'package:titikkita/views/pages/map/HomeGallery.dart';
import 'package:titikkita/views/widgets/const.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

class InputHomeImageForm {
  static Container inputForm({imageName, initialValue, className,action,deleteImage, additionalImages,imageCardId,context}) {

    return Container(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        imageName == null && initialValue == null
            ? Container(
                padding: const EdgeInsets.only(top: 10.0),
                child: OutlinedButton(
                  onPressed: () {
                    action();
                  },
                  child: Text("Tambahkan foto "),
                ),
              )
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text('Galeri Foto', style: ktextTitleBlue),
                  SizedBox(height: 10,),
                  additionalImages.length != 0
                      ? Scrollbar(
                          hoverThickness: 4,
                          isAlwaysShown: true,
                          child: Container(
                            height: 60,
                            margin: EdgeInsets.only(right:30.0),
                            child: GridView.count(
                              crossAxisCount: 5,
                              children:
                                  List.generate(additionalImages.length, (index) {
                                Asset asset = additionalImages[index];
                                return Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        width: 100,
                                        height: 90,
                                        padding: EdgeInsets.only(bottom:5),
                                        child:
                                        AssetThumb(
                                          asset: asset,
                                          width: 10,
                                          height: 20,
                                          quality: 100,
                                          spinner: Center(
                                              child: SizedBox(
                                                  width: 15,
                                                  height: 15,
                                                  child:
                                                  CircularProgressIndicator())),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.topLeft,
                                        child: GestureDetector(
                                          onTap: () {
                                            deleteImage(index);
                                          },
                                          child: Icon(
                                            Icons.clear,
                                            size: 13,
                                            color: Colors.blue[800],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }),
                            ),
                          ),
                        )
                      :  Container(),
                  initialValue.length == 0?
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(top:8.0),
                      child: Text(
                        '  *Belum ada foto di galeri anda.',
                        style: TextStyle(color: Colors.grey[700],fontSize: 11),
                      ),
                    ),
                  ) : Container(),
                  SizedBox(height: 5.0),
                  Row(
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: IconButton(icon: Icon(Icons.add_a_photo),
                         color: Colors.grey,
                          onPressed: action,
                        ),
                      ),
                      initialValue.length != 0 ?
                      Align(
                        alignment: Alignment.topLeft,
                        child: IconButton(icon: Icon(Icons.photo_library),
                          color: Colors.grey,
                          onPressed:(){
                            goToPage(context, ShowHomeGallery(photos: initialValue,cardId: imageCardId,className: className,));
                          } ,
                        ),
                      ) : Container(),
                    ],
                  )
                ],
              ),
      ],
    ));
  }
}
