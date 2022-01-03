import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:titikkita/state/location_provider.dart';
import 'package:provider/provider.dart' as provider;

class MapBase extends StatefulWidget {
  MapBase({this.returnWidget});
  final Widget returnWidget;

  @override
  _MapBaseState createState() => _MapBaseState();
}

class _MapBaseState extends State<MapBase> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Geolocator.getPositionStream(
          locationSettings:AndroidSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 0,
            forceLocationManager: true,
          )),
      builder: (buildContext, snapshot) {
        if(snapshot.hasData){
          provider.Provider.of<LocationProvider>(buildContext).updateStreamLocation(snapshot.data);
        }
        return provider.ChangeNotifierProvider.value(
          value: LocationProvider(),
          child: widget.returnWidget,
        );
      },
    );
  }
}
