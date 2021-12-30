import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:titikkita/views/widgets/const.dart';

class PopupMap {
  static Column actionPopup({onEdit, onDelete, onClose, content}) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(
                Icons.edit,
                size: 20.0,
                color: Colors.green[900],
              ),
              onPressed: () {
                onEdit();
              },
            ),
            IconButton(
              icon: Icon(
                Icons.delete,
                size: 20.0,
                color: Colors.green[900],
              ),
              onPressed: () {
                onDelete();
              },
            ),
            IconButton(
              icon: Icon(
                Icons.clear,
                size: 20.0,
                color: Colors.green[900],
              ),
              onPressed: () {
                onClose();
              },
            ),
          ],
        ),
        content != null
            ? Text(
                '$content',
                textAlign: TextAlign.center,
                style: kTextValueBlack,
              )
            : Container()
      ],
    );
  }

  static Row showPopupMap({onClose, content}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        IconButton(
          icon: Icon(
            Icons.clear,
            size: 15.0,
            color: Colors.green[900],
          ),
          onPressed: () {
            onClose();
          },
        ),
        content != null
            ? Expanded(
                child: Text(
                '$content',
                textAlign: TextAlign.left,
                style: kTextValueBlack,
              ))
            : Container()
      ],
    );
  }
}
