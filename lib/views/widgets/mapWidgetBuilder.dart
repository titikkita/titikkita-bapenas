import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:titikkita/views/widgets/const.dart';
import 'package:flutter_map/src/layer/tile_layer.dart';
import 'package:titikkita/views/widgets/mapAlignIcon.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'dart:math' as math;

class MapWidgetBuilder {
  static TileLayerOptions mapTileLayer({toggled}) {
    return TileLayerOptions(
      maxZoom: 25,
      overrideTilesWhenUrlChanges: true,
      tileFadeInDuration: 0,
      tileFadeInStartWhenOverride: 1.0,

      wmsOptions: WMSTileLayerOptions(
        baseUrl: kMapWMS,
        version: '1.1.0',
        layers: toggled ? kMapLayers : [kMapLayers[0]],

      ),
      // urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
      // subdomains: ['a', 'b', 'c'],

    );
  }

  static TileLayerOptions mapBaseTileLayer({toggled}) {
    return TileLayerOptions(
      maxZoom: 25,
      overrideTilesWhenUrlChanges: true,
      tileFadeInDuration: 0,
      tileFadeInStartWhenOverride: 1.0,
      urlTemplate: "http://{s}.google.com/vt/lyrs=s&x={x}&y={y}&z={z}",
      subdomains: ['mt0','mt1','mt2','mt3'],
    );
  }
  static Row mapIconHelper(
      {zoomInAction,
      zoomOutAction,
      myLocationAction,
      myHomeAction,
      deleteAction,
      isTaggingMap}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            MapAlignIcon.mapAlignIcon(
              top: isTaggingMap != null ? 80.0 : 30.0,
              left: 20.0,
              right: 0.0,
              icon: Icon(
                Icons.add,
                color: Colors.blue[900],
              ),
              action: () {
                zoomInAction();
              },
            ),
            MapAlignIcon.mapAlignIcon(
                top: 5.0,
                left: 20.0,
                right: 0.0,
                icon: Icon(
                  Icons.remove,
                  color: Colors.blue[900],
                ),
                action: () {
                  zoomOutAction();
                }),
            MapAlignIcon.mapAlignIcon(
              top: 5.0,
              left: 20.0,
              right: 0.0,
              icon: StreamBuilder(
                stream: FlutterCompass.events,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    print(snapshot.error);
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container();
                  }
                  double direction = snapshot.data;

                  return Material(
                    shape: CircleBorder(),
                    clipBehavior: Clip.antiAlias,
                    elevation: 4.0,
                    child: Container(
                      alignment: Alignment.center,
                      child: Transform.rotate(
                        angle: (direction * (math.pi / 180) * -1),
                        child: Container(
                          width:25.0,
                          child: Image.asset(
                            'assets/map_icon/compass.png',
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              action: () {
                zoomInAction();
              },
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            MapAlignIcon.mapAlignIcon(
              top:isTaggingMap != null ? 80.0 : 30.0,
              left: 0.0,
              right: 20.0,
              icon: Icon(
                Icons.my_location,
                color: Colors.red[400],
              ),
              action: () {
                myLocationAction();
              },
            ),
            myHomeAction != null
                ? MapAlignIcon.mapAlignIcon(
                    top: 5.0,
                    left: 0.0,
                    right: 20.0,
                    icon: Icon(
                      Icons.home,
                      color: Colors.blue,
                    ),
                    action: () {
                      myHomeAction();
                    },
                  )
                : Container(),
            deleteAction != null
                ? MapAlignIcon.mapAlignIcon(
                    top: 5.0,
                    left: 0.0,
                    right: 20.0,
                    icon: Icon(
                      Icons.delete,
                      color: Colors.red[400],
                    ),
                    action: deleteAction,
                  )
                : Container(),
          ],
        ),
      ],
    );
  }
}
