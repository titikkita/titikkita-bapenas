import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:titikkita/views/widgets/appBar.dart';

class ImageView extends StatefulWidget {
  ImageView({this.image});
  final File image;
  @override
  _ImageViewState createState() => _ImageViewState();
}

class _ImageViewState extends State<ImageView> {
  File _image;
  @override
  void initState() {
    _image = widget.image;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarCustom.buildAppBarCustom(title: 'Image'),
      body: Container(
        width: 50,
        height: 50,
        child: Image.file(_image),
      ),
    );
  }
}
