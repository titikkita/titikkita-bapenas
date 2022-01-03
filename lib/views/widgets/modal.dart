import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:titikkita/state/local_provider.dart';
import 'package:titikkita/views/widgets/bottomNavigation.dart';
import 'package:titikkita/views/widgets/const.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:provider/provider.dart' as provider;
import 'package:titikkita/views/widgets/inputHomePictures.dart';

class Modal {
  static buildModalBottomSheet(
      {context,
      onSubmit,
      onChangeTitle,
      onChangeUserOpinion,
      onChangeDate,
        imageData,
      onTapMapIcon}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.only(top: 80.0),
          color: Colors.grey[600],
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            ),
            child: Container(
              padding: EdgeInsets.only(top: 5, left: 20, right: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Divider(
                    color: Colors.grey[400],
                    thickness: 2,
                    indent: 135,
                    endIndent: 135,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text('Isi Laporan', style: ktextTitleBlue),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    height: 100,
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
                        onChangeTitle(value);
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
                        onPressed: onTapMapIcon,
                      ),
                    ],
                  ),
                  Padding(
                      padding: const EdgeInsets.only(right:10.0),
                      child: InputHomeImageForm.inputForm(
                          action: imageData['selectImage'],
                          imageName: imageData['imageName'],
                          initialValue:imageData['photos'],
                          additionalImages: imageData['images'],
                          deleteImage: imageData['deleteImageFromList'],
                          context: context,
                          imageCardId:imageData['dataEdit'] != null? imageData['dataEdit']['data']['_id']:null,
                          className:'app_insfrastructurer'
                      )
                  ),
                  SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
        BottomNavigation.buildContainerBottom2Navigation(
            title1: 'Simpan',
            title2: 'Batal',
            buildContext: context,
            action1: onSubmit,
            action2: () {
              Navigator.pop(context);
            })
      ],
    );
  }

  static popUpImage({context, action1, action2}) {
    return Alert(
      context: context,
      title: "Pilih foto",
      style: AlertStyle(
          descTextAlign: TextAlign.start,
          titleStyle: TextStyle(
            color: Colors.grey[850],
          )),
      content: Container(
        padding: EdgeInsets.all(30.0),
        child: Column(
          children: <Widget>[
            GestureDetector(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Ambil gambar'),
                  Icon(
                    Icons.photo_camera,
                    size: 30.0,
                    color: Colors.grey,
                  ),
                ],
              ),
              onTap: (){
                action1();
                Navigator.pop(context);
              },
            ),
            GestureDetector(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Pilih dari galeri'),
                  Icon(
                    Icons.content_copy,
                    size: 30.0,
                    color: Colors.grey,
                  ),
                ],
              ),
              onTap: (){
                action2();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    ).show();
  }

  static showMultiSelect({context,lookupName,attributeName,action}) async {
    await showDialog(
      context: context,
      builder: (ctx) {
        var data =  provider.Provider.of<LocalProvider>(context).lookupData[lookupName];
        return  MultiSelectDialog(
          searchHint: 'Pencarian',
          itemsTextStyle: TextStyle(fontSize: 12),
          items:data.map((e){
            return MultiSelectItem(data.indexOf(e),e);
          }).toList(),
          initialValue: [],
          onConfirm: (values) {
            var value= '';
            values.forEach((e) {
              value =value+'${data[e]}, ';
            });
            action(attributeName,value);
          },
        );
      },
    );
  }
}
