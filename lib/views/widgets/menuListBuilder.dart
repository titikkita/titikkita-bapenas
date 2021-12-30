import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class MenuListWidget {
  static GestureDetector mainMenuListSVG({action, savage}) {
    return GestureDetector(
      onTap: action,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: Colors.grey[350],
                spreadRadius: (-8),
                blurRadius: 10,
                offset: Offset(4, 1)),
          ],
        ),
        height: 90,
        child: SvgPicture.asset(
          savage,
          fit: BoxFit.fitHeight,
        ),
      ),
    );
  }

  static GestureDetector subMenuCategorySVG({action, savage}) {
    return GestureDetector(
      onTap: () {
        action();
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: Colors.grey[350],
                spreadRadius: (-8),
                blurRadius: 10,
                offset: Offset(4, 1)),
          ],
        ),
        height: 110,
        margin: EdgeInsets.only(
          top: 10,
          left: 10,
          right: 10,
        ),
        child: SvgPicture.asset(
          savage,
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}
