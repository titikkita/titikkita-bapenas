import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';


class LoadingIndicator {
  static containerSquareLoadingIndicator() {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10), color: Colors.grey[850]),
      width: 80.0,
      height: 80.0,
      child: SpinKitFadingCircle(
        color: Colors.white,
        size: 40.0,
      ),
    );
  }

  static containerWhiteLoadingIndicator() {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10), color: Colors.white60),
      width: 80.0,
      height: 80.0,
      child: SpinKitFadingCircle(
        color: Colors.black,
        size: 40.0,
      ),
    );
  }
}
