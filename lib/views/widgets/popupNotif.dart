import 'package:flutter/material.dart';
import 'package:titikkita/views/widgets/const.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ShowPopupNotification {
  static deleteNotification(
      {BuildContext context, String title, String content, action}) {
    AlertDialog alert = AlertDialog(
      title: Text(
        'Delete $title',
        style: ktextTitleBlue,
      ),
      content: Text(
        content,
        style: kTextValueBlack,
      ),
      actions: [
        TextButton(
            onPressed: () {
              action();
              Navigator.of(context, rootNavigator: true).pop();
            },
            child: Text(
              'OK',
              style: ktextTitleBlue,
            )),
        TextButton(
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
            },
            child: Text(
              'BATAL',
              style: ktextTitleBlue,
            ))
      ],
    );

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        });
  }

  static errorNotification({BuildContext context, String content, action}) {
    AlertDialog alert = AlertDialog(
      content: Text(content, style: kTextValueBlack),
      actions: [
        TextButton(
            onPressed: () {
              // Navigator.of(context, rootNavigator: true).pop();
              action();
            },
            child: Text(
              'OK',
              style: ktextTitleBlue,
            )),
      ],
    );

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        });
  }

  static showSnackBar({content,action}) {
    return SnackBar(
        content: GestureDetector(
            onTap: () {
              print('yess');
              action();
            },
            child: Text(content)));
  }
}
