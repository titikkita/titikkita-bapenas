import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_dragmarker/dragmarker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:titikkita/state/location_provider.dart';
import 'package:titikkita/util/vertex.dart';
import 'package:titikkita/views/widgets/appBar.dart';
import 'package:titikkita/views/widgets/const.dart';
import 'package:titikkita/views/widgets/mapWidgetBuilder.dart';
import 'package:provider/provider.dart' as provider;
import "package:latlong/latlong.dart" as latlong;

class VertexEditingCustom extends StatefulWidget {
  const VertexEditingCustom();

  @override
  _VertexEditingCustomState createState() => _VertexEditingCustomState();
}

class _VertexEditingCustomState extends State<VertexEditingCustom> {
  List<DragMarker> markers = [];
  Polygon polygon;
  List<latlong.LatLng> points = [];

  @override
  void initState() {
    super.initState();
    points = [
      latlong.LatLng(-6.935809, 107.769261),
      latlong.LatLng(-6.936117,107.769186),
      latlong.LatLng(-6.936156, 107.769654),
      latlong.LatLng(-6.935815,107.76967),
    ];
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
            setState(() {
              markers[i].point=newPoint;
              polygon.points[i]=newPoint;
            });
          },
        ),
      );
    });
  }

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
        return provider.ChangeNotifierProvider.value(
          value: LocationProvider(),
          child: Scaffold(
            appBar: AppBarCustom.buildAppBarCustom(
              title: 'Vertex Custom Edit',
              context: context,
            ),
            body: Container(
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      color: Colors.blue[100],
                      child: Stack(
                        children: [
                          FlutterMap(
                            options: MapOptions(
                              plugins: [
                                DragMarkerPlugin(),
                              ],
                              maxZoom: 25,
                              interactiveFlags: kMapRotation,
                              center: snapshot.hasData
                                  ? latlong.LatLng(snapshot.data.latitude,
                                      snapshot.data.longitude)
                                  : latlong.LatLng(
                                      provider.Provider.of<LocationProvider>(
                                              context)
                                          .latitude,
                                      provider.Provider.of<LocationProvider>(
                                              context)
                                          .longitude),
                              zoom: 18,
                            ),
                            layers: [
                              TileLayerOptions(
                                retinaMode: true,
                                maxZoom: 25,
                                overrideTilesWhenUrlChanges: true,
                                tileFadeInDuration: 0,
                                tileFadeInStartWhenOverride: 1.0,
                                wmsOptions: WMSTileLayerOptions(
                                  baseUrl: kMapWMS,
                                  version: '1.1.0',
                                  layers: kMapLayers,
                                ),
                              ),
                              PolygonLayerOptions(polygons: [
                                polygon,
                              ]),
                              DragMarkerPluginOptions(markers: markers),
                            ],
                          ),
                          MapWidgetBuilder.mapIconHelper(deleteAction: () {
                            setState(() {
                              markers.removeLast();
                              polygon.points.removeLast();
                            });
                          }),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
