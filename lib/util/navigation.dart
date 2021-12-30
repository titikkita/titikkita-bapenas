import 'package:flutter/material.dart';

goToPage(context, page) {
  var pageDestination =
      Navigator.push(context, MaterialPageRoute(builder: (context) {
    return page;
  }));
  return pageDestination;
}
