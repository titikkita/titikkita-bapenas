import 'package:flutter_map/flutter_map.dart';
import 'package:titikkita/controller/cmdbuild_controller.dart';
import 'package:flutter/material.dart';

Future <void> getLocationOnNeighbor(constraintData,context,action) async {

  SphericalMercator mercator = SphericalMercator();
  await CmdbuildController.findCardWithFilter(
      context: context,
      cardName: 'app_neighborhood',
      filter: 'equal',
      key: 'UserID',
      value: constraintData['_id'])
      .then((value) {
    value['data'].forEach((e) async {

      await CmdbuildController.getGeometryPoint(
          'app_neighborhood', e['_id'], context)
          .then((val) {
        if (val['success']) {
            action(val,e);
        }
      });

    });
  });

}