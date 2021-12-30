import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class BottomNavigation {
  static GestureDetector buildContainerBottomLoading(
      {title, action, isShowForm}) {
    return GestureDetector(
      onTap: action,
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          color: Color(0xff084A9A),
          borderRadius: BorderRadius.all(Radius.circular(0)),
        ),
        child: Center(
          child:  SpinKitFadingCircle(
            color: Colors.white,
            size: 40.0,
          ),
        ),
      ),
    );
  }

  static GestureDetector buildContainerBottom1Navigation(
      {title, action, isShowForm}) {
    return GestureDetector(
      onTap: action,
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          color: Color(0xff084A9A),
          borderRadius: BorderRadius.all(Radius.circular(0)),
        ),
        child: Center(
          child: Text(
            "$title",
            style: TextStyle(
              color: Color(0xffFFFFFF),
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  static Container buildContainerBottom2Navigation(
      {buildContext, showForm, title1, title2, action1, action2}) {
    return Container(
      width: MediaQuery.of(buildContext).size.width,
      // padding: EdgeInsets.all(10),
      child: Row(
          // crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            GestureDetector(
              onTap: action1,
              child: Container(
                width: MediaQuery.of(buildContext).size.width / 2,
                height: 50,
                color: Color(0xff084A9A),
                child: Center(
                  child: Text(
                    "$title1",
                    style: TextStyle(
                        color: Color(0xffFFFFFF),
                        fontSize: 15,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: action2,
              child: Container(
                height: 50,
                width: MediaQuery.of(buildContext).size.width / 2,
                color: Colors.white,
                child: Center(
                  child: Text(
                    "$title2",
                    style: TextStyle(
                        color: Color(0xff084A9A),
                        fontSize: 15,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
      ),
    );
  }
}
