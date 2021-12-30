import 'package:flutter/material.dart';
import "package:latlong/latlong.dart" as latlong;
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_dragmarker/dragmarker.dart';

class Vertex {

  Polygon polygon;
  List <latlong.LatLng>points = [];
  List <DragMarker> markers = [];

 buildDraggablePolygon({point}){
   points= point;
    polygon=Polygon(
        points: points,
        color: Colors.deepOrange.shade200.withOpacity(0.7),
        borderStrokeWidth: 3,
        borderColor: Colors.redAccent);

    points.asMap().forEach((i,e) {
      markers.add(
        DragMarker(
          point: e,
          width: 80.0,
          height: 80.0,
          builder: (ctx) => Container( child:  Icon(Icons.circle,size: 10,color: Colors.black,) ),
          onDragUpdate: (details,newPoint){
              markers[i].point=newPoint;
              polygon.points[i]=newPoint;
          },
        ),
      );
    });
    return {
      'markers': this.markers,
      'polygon': this.polygon
    };
  }
}