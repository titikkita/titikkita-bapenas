import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_absolute_path/flutter_absolute_path.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:titikkita/util/getToken.dart';

class CmdbuildModel extends ChangeNotifier {
  CmdbuildModel();
  String userName = 'admin';
  String password = 'admin';
  String cmdbuildBaseURL =
      // 'http://103.233.103.22:8080/smartvillage2/services/rest/v3';
      'http://103.233.103.22:8080/cmdbuild/services/rest/v3';
  String token;

  Future<String> readAdminToken() async {
    var encodedBody = jsonEncode({'username': userName, 'password': password});
    http.Response response = await http.post(
        Uri.parse("$cmdbuildBaseURL/sessions?scope=service&returnId=true"),
        body: encodedBody);
    if (response.statusCode == 200) {
      var data = response.body;
      var decodeData = jsonDecode(data);

      var id = decodeData['data']['_id'];

      await http.post(Uri.parse('$cmdbuildBaseURL/sessions/$id/keepalive'),
          body: encodedBody);
      token = id;
      return id;
    } else {
      return 'failed';
    }
  }

  Future<dynamic> newRegister({data, context}) async {
    var encodedData = jsonEncode(data);
    var token = await getToken(context);
    http.Response response = await http.post(
        Uri.parse('$cmdbuildBaseURL/classes/mtr_authentification/cards'),
        headers: {'Cmdbuild-authorization': token},
        body: encodedData);
    var result = jsonDecode(response.body);

    return result;
  }


  Future<dynamic> readCard(value,context) async {
    var returnThis;
    await getToken(context).then((mytoken) async {

      http.Response response = await http.get(
          Uri.parse('$cmdbuildBaseURL/classes/app_family/cards?filter=$value'),
          headers: {'Cmdbuild-authorization': mytoken});

      var result = jsonDecode(response.body);
      if (result['success']) {
          returnThis = result;
      }
    });
    return returnThis;
  }


  Future<dynamic> readOneCard(cardName,value,context) async {
    var returnThis;
    await getToken(context).then((mytoken) async {

      http.Response response = await http.get(
          Uri.parse('$cmdbuildBaseURL/classes/$cardName/cards/$value'),
          headers: {'Cmdbuild-authorization': mytoken});

      var result = jsonDecode(response.body);
      if (result['success']) {
        returnThis = result;
      }
    });
    return returnThis;
  }

  Future<dynamic> readFilterCard(value,context,card) async {
    var returnThis;
    await getToken(context).then((mytoken) async {

      http.Response response = await http.get(
          Uri.parse('$cmdbuildBaseURL/classes/$card/cards?filter=$value'),
          headers: {'Cmdbuild-authorization': mytoken});

      var result = jsonDecode(response.body);
      if (result['success']) {
        returnThis = result;
      }
    });
    return returnThis;
  }


  Future<dynamic> readLookupData(lookupList, context) async {
    var token = await getToken(context);
    Map<String, dynamic> returnData = {};
    for (var i = 0; i < lookupList.length; i++) {
      http.Response response = await http.get(
          Uri.parse('$cmdbuildBaseURL/lookup_types/${lookupList[i]}/values'),
          headers: {'Cmdbuild-authorization': token});
      var result = jsonDecode(response.body);
      returnData['${lookupList[i]}'] = result;
    }
    return returnData;
  }

  Future readOneLookup(lookupName, context) async {
    var token = await getToken(context);
      http.Response response = await http.get(
          Uri.parse('$cmdbuildBaseURL/lookup_types/$lookupName/values'),
          headers: {'Cmdbuild-authorization': token});
      var result = jsonDecode(response.body);

    return result;
  }

  Future<dynamic> updateGeometryById({context, cardName, id, dataEdit}) async {
    var adminToken = await getToken(context);
    var encodedBody = jsonEncode(dataEdit);
    http.Response response = await http.put(
        Uri.parse('$cmdbuildBaseURL/classes/$cardName/cards/$id/geovalues/Geometry'),
        headers: {'Cmdbuild-authorization': adminToken},
        body: encodedBody);
    var data = jsonDecode(response.body);

    return data;
  }

  Future<dynamic> readGeometryById({context, cardName, id}) async {
    var adminToken = await getToken(context);
    http.Response response = await http.get(
        Uri.parse('$cmdbuildBaseURL/classes/$cardName/cards/$id/geovalues/Geometry'),
        headers: {'Cmdbuild-authorization': adminToken});
    var data = jsonDecode(response.body);

    return data;
  }

  Future<dynamic> readGeometryPolygonById({context, cardName, id}) async {
    var adminToken = await getToken(context);
    if(cardName == "mtr_village"){
      http.Response response = await http.get(
          Uri.parse('$cmdbuildBaseURL/classes/$cardName/cards/$id/geovalues/geometrypolygon'),
          headers: {'Cmdbuild-authorization': adminToken});
      var data = jsonDecode(response.body);

      return data;
    }else{
      http.Response response = await http.get(
          Uri.parse('$cmdbuildBaseURL/classes/$cardName/cards/$id/geovalues/GeometryPolygon'),
          headers: {'Cmdbuild-authorization': adminToken});
      var data = jsonDecode(response.body);

      return data;
    }

  }

  Future<dynamic> addGeometryById(
      {cardname, id, dataEdit, context}) async {

    var adminToken = await getToken(context);
    var encodedBody = jsonEncode(dataEdit);
    http.Response response = await http.put(
        Uri.parse('$cmdbuildBaseURL/classes/$cardname/cards/$id/geovalues/Geometry'),
        headers: {'Cmdbuild-authorization': adminToken},
        body: encodedBody);
    var data = jsonDecode(response.body);

    return data;
  }

  Future<dynamic> addGeometryPolygonById(
      {cardname, id, dataEdit, context}) async {

    var adminToken = await getToken(context);
    var encodedBody = jsonEncode(dataEdit);
    if(cardname == 'mtr_village'){
      http.Response response = await http.put(
          Uri.parse('$cmdbuildBaseURL/classes/$cardname/cards/$id/geovalues/geometrypolygon'),
          headers: {'Cmdbuild-authorization': adminToken},
          body: encodedBody);
      var data = jsonDecode(response.body);
      return data;
    }else{
      http.Response response = await http.put(
          Uri.parse('$cmdbuildBaseURL/classes/$cardname/cards/$id/geovalues/GeometryPolygon'),
          headers: {'Cmdbuild-authorization': adminToken},
          body: encodedBody);
      var data = jsonDecode(response.body);
      return data;
    }

  }

  Future<dynamic> addNewCard({cardName, data, context}) async {

    var adminToken = await getToken(context);
    var encodedBody = jsonEncode(data);
    http.Response response = await http.post(
        Uri.parse('$cmdbuildBaseURL/classes/$cardName/cards'),
        headers: {'Cmdbuild-authorization': adminToken},
        body: encodedBody);
    var result = jsonDecode(response.body);

    return result;
  }

  Future<dynamic> editCardById({cardName, data, id, context}) async {

    var adminToken = await getToken(context);
    var encodedBody = jsonEncode(data);
    http.Response response = await http.put(
        Uri.parse('$cmdbuildBaseURL/classes/$cardName/cards/$id'),
        headers: {'Cmdbuild-authorization': adminToken},
        body: encodedBody);
    var result = jsonDecode(response.body);

    return result;
  }

  Future<dynamic> readCardList({cardName, context}) async {
    var adminToken = await getToken(context);
    http.Response publicInfoResponse = await http.get(
      Uri.parse('$cmdbuildBaseURL/classes/$cardName/cards'),
      headers: {'Cmdbuild-authorization': adminToken},
    );
    var publicInfo = jsonDecode(publicInfoResponse.body);

    return publicInfo;
  }

  Future<dynamic> updateCardsById({
    context,
    cardName,
    dataEdit,
    id,
  }) async {
    var adminToken = await getToken(context);
    var encodedBody = jsonEncode(dataEdit);
    http.Response response = await http.put(
        Uri.parse('$cmdbuildBaseURL/classes/$cardName/cards/$id'),
        headers: {'Cmdbuild-authorization': adminToken},
        body: encodedBody);
    var data = jsonDecode(response.body);

    return data;
  }

  Future<dynamic> addNewNeighborLocation({data, geomData, context}) async {
    var adminToken = await getToken(context);
    var encodedBody = jsonEncode(data);
    http.Response response = await http.post(
        Uri.parse('$cmdbuildBaseURL/classes/app_neighborhood/cards'),
        headers: {'Cmdbuild-authorization': adminToken},
        body: encodedBody);

    var result = jsonDecode(response.body);
    if (result['success'] == true) {
      var encodedBody = jsonEncode(geomData);
      http.Response response = await http.put(
          Uri.parse('$cmdbuildBaseURL/classes/app_neighborhood/cards/${result['data']['_id']}/geovalues/Geometry'),
          headers: {'Cmdbuild-authorization': adminToken},
          body: encodedBody);
      var data = jsonDecode(response.body);
      return data;
    }
  }

  Future<dynamic> addNewOthersArea({data, geomData, context, imageData,cardName}) async {
    var adminToken = await getToken(context);
    var encodedBody = jsonEncode(data);
    http.Response response = await http.post(
        Uri.parse('$cmdbuildBaseURL/classes/app_otherarea/cards'),
        headers: {'Cmdbuild-authorization': adminToken},
        body: encodedBody);

    var result = jsonDecode(response.body);

    if (result['success'] == true) {

      await this.addImages(result['data']['_id'],imageData,'app_otherarea',context);

      var encodedBody = jsonEncode(geomData);
      http.Response response = await http.put(
          Uri.parse('$cmdbuildBaseURL/classes/app_otherarea/cards/${result['data']['_id']}/geovalues/Geometry'),
          headers: {'Cmdbuild-authorization': adminToken},
          body: encodedBody);
      var data = jsonDecode(response.body);
      return data;
    }
  }

  Future<dynamic> deleteCardById({id, cardName, context}) async {
    var adminToken = await getToken(context);
    http.Response response = await http.delete(
        Uri.parse('$cmdbuildBaseURL/classes/$cardName/cards/$id'),
        headers: {'Cmdbuild-authorization': adminToken});
    var result = jsonDecode(response.body);

    return result;
  }

  Future<dynamic> getImageName({id, cardName, context}) async {
    var adminToken = await getToken(context);
    try {
      http.Response response = await http.get(
          Uri.parse('$cmdbuildBaseURL/classes/$cardName/cards/$id/attachments'),
          headers: {'Cmdbuild-authorization': adminToken});
        var data = jsonDecode(response.body);

        return data;

    } catch (e) {
      // return null;
    }
  }

  Future<dynamic> readImages({id, context,cardName}) async {
    var adminToken = await getToken(context);
    try {
      http.Response response = await http.get(
          Uri.parse('$cmdbuildBaseURL/classes/$cardName/cards/$id/attachments'),
          headers: {'Cmdbuild-authorization': adminToken});
      var data = jsonDecode(response.body);

      List attachments = [];
      for (var i = 0; i < data['data'].length; i++) {
        http.Response response2 = await http.get(
            Uri.parse('$cmdbuildBaseURL/classes/$cardName/cards/$id/attachments/${data['data'][i]['_id']}'),
            headers: {'Cmdbuild-authorization': adminToken});
        var decodedData = jsonDecode(response2.body);
        attachments.add(decodedData);
      }

      return attachments;
    } catch (e) {
      return null;
    }
  }

  Future<dynamic> deleteImage({id, attachmentId, memberStatus, context}) async {
    var adminToken = await getToken(context);
    try {
      if (memberStatus == 'member') {
        http.Response response = await http.delete(
            Uri.parse('$cmdbuildBaseURL/classes/app_localcitizen/cards/$id/attachments/$attachmentId'),
            headers: {'Cmdbuild-authorization': adminToken});

        return jsonDecode(response.body);
      }
      if (memberStatus == 'nonMember') {
        http.Response response = await http.delete(
            Uri.parse('$cmdbuildBaseURL/classes/app_nonlocalcitizen/cards/$id/attachments/$attachmentId'),
            headers: {'Cmdbuild-authorization': adminToken});

        return jsonDecode(response.body);
      }
    } catch (e) {
      return null;
    }
  }

  Future<dynamic> sendImage({id, filePath, name, cardName, context}) async {
    var adminToken = await getToken(context);
    var uri =
        Uri.parse('$cmdbuildBaseURL/classes/$cardName/cards/$id/attachments');
    var request = http.MultipartRequest('POST', uri);
    request.headers['Cmdbuild-authorization'] = adminToken;
    request.files.add(await http.MultipartFile.fromPath('file', filePath));
    request.send().then((value) {
      return value.statusCode;
    });
  }

  Future<dynamic> readComodityPoints({idData, context}) async {
    var adminToken = await getToken(context);
    http.Response response = await http.get(
        Uri.parse('$cmdbuildBaseURL/classes/app_comodity/cards/$idData/geovalues/Geometry'),
        headers: {'Cmdbuild-authorization': adminToken});
    var data = jsonDecode(response.body);

    http.Response response2 = await http.get(
        Uri.parse('$cmdbuildBaseURL/classes/app_comodity/cards/$idData/geovalues/GeometryPolygon'),
        headers: {'Cmdbuild-authorization': adminToken});
    var data2 = jsonDecode(response2.body);
    return {"dataPoints": data, "dataPolygon": data2};
  }

  Future<dynamic> addNewComodity({data, geomData, geomPolygon, context}) async {
    var adminToken = await getToken(context);
    var encodedBody = jsonEncode(data);
    http.Response response = await http.post(
        Uri.parse('$cmdbuildBaseURL/classes/app_comodity/cards'),
        headers: {'Cmdbuild-authorization': adminToken},
        body: encodedBody);

    var result = jsonDecode(response.body);

    if (result['success'] == true) {
      var data = await this.editComodityPolygon(
          id: result['data']['_id'],
          dataPoint: geomData,
          dataPolygon: geomPolygon);
      if (data['success'] == true) {
        return data;
      }
    }
  }

  Future<dynamic> editComodityPolygon(
      {id, dataPoint, dataPolygon, context}) async {
    var adminToken = await getToken(context);
    var encodedBody = jsonEncode(dataPoint);
    http.Response response = await http.put(
        Uri.parse('$cmdbuildBaseURL/classes/app_comodity/cards/$id/geovalues/Geometry'),
        headers: {'Cmdbuild-authorization': adminToken},
        body: encodedBody);
    var data = jsonDecode(response.body);
    if (data['success']) {
      var encodedBody = jsonEncode(dataPolygon);
      http.Response response = await http.put(
          Uri.parse('$cmdbuildBaseURL/classes/app_comodity/cards/$id/geovalues/GeometryPolygon'),
          headers: {'Cmdbuild-authorization': adminToken},
          body: encodedBody);
      var data = jsonDecode(response.body);
      return data;
    }
  }

  Future<dynamic> editGeometryPoint(
      {id, card,dataPoint,context}) async {
    var adminToken = await getToken(context);
    var encodedBody = jsonEncode(dataPoint);
    http.Response response = await http.put(
        Uri.parse('$cmdbuildBaseURL/classes/$card/cards/$id/geovalues/Geometry'),
        headers: {'Cmdbuild-authorization': adminToken},
        body: encodedBody);
    var data = jsonDecode(response.body);
      return data;
  }

  Future<dynamic> editComodityData(
      {id, data, geomValue, geomPolygon, context}) async {
    var adminToken = await getToken(context);
    var encodedBody = jsonEncode(data);
    http.Response response = await http.put(
        Uri.parse('$cmdbuildBaseURL/classes/app_comodity/cards/$id'),
        headers: {'Cmdbuild-authorization': adminToken},
        body: encodedBody);

    var result = jsonDecode(response.body);

    if (result['success'] == true) {
      var data = this.editComodityPolygon(
          id: id, dataPoint: geomValue, dataPolygon: geomPolygon);
      return data;
    }
  }

  Future<dynamic> addImages(id, body, cardName,context) async {
    var adminToken = await getToken(context);
    for (var i = 0; i < body.length; i++) {
      List<http.MultipartFile> newList = [];
      var uri = Uri.parse(
          '$cmdbuildBaseURL/classes/$cardName/cards/$id/attachments');
      var request = http.MultipartRequest('POST', uri);
      request.fields['Code'] = 'Code';
      request.headers['Cmdbuild-authorization'] = adminToken;
      var file = await FlutterAbsolutePath.getAbsolutePath(body[i].identifier);
      newList.add(await http.MultipartFile.fromPath('file', file,
          filename: body[i].name));
      request.files.addAll(newList);

      request.send().then((value) {}).catchError((e) {
        print('====error= $e');
      });
    }
    return true;
  }

  Future<dynamic> downloadImages(className, cardId, imageId, context) async {
    var adminToken = await getToken(context);
    var download = await ImageDownloader.downloadImage(
        '$cmdbuildBaseURL/classes/$className/cards/$cardId/attachments/$imageId/download',
        headers: {'Cmdbuild-authorization': adminToken}).catchError((e) {});
    return download;
  }

  Future<dynamic> deleteAttach(className, cardId, imageId, context) async {
    var adminToken = await getToken(context);
    http.Response response = await http.delete(
        Uri.parse('$cmdbuildBaseURL/classes/$className/cards/$cardId/attachments/$imageId'),
        headers: {'Cmdbuild-authorization': adminToken});

    return jsonDecode(response.body);
  }

  Future<Map<String, List>> readAreaList(context) async {
    var adminToken = await getToken(context);
    http.Response responseProv = await http.get(
        Uri.parse('$cmdbuildBaseURL/classes/mtr_province/cards'),
        headers: {'Cmdbuild-authorization': adminToken});
    http.Response response = await http.get(
        Uri.parse('$cmdbuildBaseURL/classes/mtr_district/cards'),
        headers: {'Cmdbuild-authorization': adminToken});
    http.Response response1 = await http.get(
        Uri.parse('$cmdbuildBaseURL/classes/mtr_subdistrict/cards'),
        headers: {'Cmdbuild-authorization': adminToken});
    http.Response response2 = await http.get(
        Uri.parse('$cmdbuildBaseURL/classes/mtr_village/cards'),
        headers: {'Cmdbuild-authorization': adminToken});
    var regency = jsonDecode(response.body);
    var district = jsonDecode(response1.body);
    var village = jsonDecode(response2.body);
    var province = jsonDecode(responseProv.body);

    Map<String, List> result = {
      'Provinsi': province['data'],
      'Kabupaten': regency['data'],
      'Kecamatan': district['data'],
      'Desa': village['data'],
    };

    return result;
  }

  Future<dynamic> readAreaForGettingAllFamilyLocation(context) async {
    var adminToken = await getToken(context);
    var resultId = await this.readAttributeArea(context);

    http.Response response = await http.get(
        Uri.parse('$cmdbuildBaseURL/classes/_ANY/cards/_ANY/geovalues/area?attribute=${resultId['data'][0]['_id']}'),
        headers: {'Cmdbuild-authorization': adminToken});

    var result = jsonDecode(response.body);

    if (result['success'] == true) {
      return result;
    }
  }

  Future<dynamic> readAttributeArea(context) async {
    var adminToken = await getToken(context);
    http.Response attributeId = await http.get(
        Uri.parse('$cmdbuildBaseURL/classes/app_address/geoattributes'),
        headers: {'Cmdbuild-authorization': adminToken});

    var result = jsonDecode(attributeId.body);

    if (result['success'] == true) {
      return result;
    }
  }

  Future<dynamic> readAllFamilyLocation(context, area, attribute) async {
    var adminToken = await getToken(context);
    http.Response response = await http.get(
        Uri.parse('$cmdbuildBaseURL/classes/_ANY/cards/_ANY/geovalues?attribute=$attribute&area=$area'),
        headers: {'Cmdbuild-authorization': adminToken});
    var result = jsonDecode(response.body);
    if (result['success'] == true) {
      return result;
    }
  }

  Future<dynamic> deleteGeovalue(context, cardName, id) async {
    var adminToken = await getToken(context);
    if(cardName == "mtr_village"){
      http.Response response = await http.delete(
          Uri.parse('$cmdbuildBaseURL/classes/$cardName/cards/$id/geovalues/geometrypolygon'),
          headers: {'Cmdbuild-authorization': adminToken});
      var result = jsonDecode(response.body);

      if (result['success'] == true) {
        return result;
      }
    }else{
      http.Response response = await http.delete(
          Uri.parse('$cmdbuildBaseURL/classes/$cardName/cards/$id/geovalues/GeometryPolygon'),
          headers: {'Cmdbuild-authorization': adminToken});
      var result = jsonDecode(response.body);

      if (result['success'] == true) {
        return result;
      }
    }

  }

  Future<dynamic> readCardWithFilter(
      context, cardName, filter, key, value) async {
    var myToken = await getToken(context);
    var returnThis;

    String paramValue =
        '{"attribute":{"simple":{"attribute":"$key","operator":"$filter","value":["$value"]}}}';

    http.Response response = await http.get(
        Uri.parse('$cmdbuildBaseURL/classes/$cardName/cards?filter=$paramValue'),
        headers: {'Cmdbuild-authorization': myToken});

    var result = jsonDecode(response.body);


    if (result['success'] == true) {
      returnThis = result;
    }

    return returnThis;
  }

  Future<dynamic> readCardWithSomeFilter(
      context, cardName, filter, key, value) async {
    var returnThis;
    await getToken(context).then((token) async {
      String paramValue =
          '{"attribute":{"and":[{"simple":{"attribute":"${key[0]}","operator":"$filter","value":["${value[0]}"]}}, {"simple":{"attribute":"${key[1]}","operator":"equal","value":["${value[1]}"]}},{"simple":{"attribute":"${key[2]}","operator":"equal","value":["${value[2]}"]}}]}}';
      http.Response response = await http.get(
          Uri.parse('$cmdbuildBaseURL/classes/$cardName/cards?filter=$paramValue'),
          headers: {'Cmdbuild-authorization': token});

      var result = jsonDecode(response.body);
      print(paramValue);
      print(cardName);
      if (result['success'] == true) {
        returnThis = result;
      }
    });

    return returnThis;
  }

  Future<dynamic> readCardWith2Filter(
      context, cardName, filter, key, value) async {

    var returnThis;
    await getToken(context).then((token) async {
      String paramValue =
          '{"attribute":{"and":[{"simple":{"attribute":"${key[0]}","operator":"$filter","value":["${value[0]}"]}}, {"simple":{"attribute":"${key[1]}","operator":"$filter","value":["${value[1]}"]}}]}}';
      http.Response response = await http.get(
          Uri.parse('$cmdbuildBaseURL/classes/$cardName/cards?filter=$paramValue'),
          headers: {'Cmdbuild-authorization': token});
      print(paramValue);
      print(cardName);
      var result = jsonDecode(response.body);
      if (result['success'] == true) {
        returnThis = result;
      }
    });

    return returnThis;
  }

  Future<dynamic> readCardWithManyFilter(
      context, cardName, filter, key, value) async {
    var returnThis;
    await getToken(context).then((token) async {
      String paramValue =
          '{"attribute":{"and":[{"simple":{"attribute":"${key[0]}","operator":"$filter","value":["${value[0]}"]}}, {"simple":{"attribute":"${key[1]}","operator":"equal","value":["${value[1]}"]}},{"simple":{"attribute":"${key[2]}","operator":"equal","value":["${value[2]}"]}},{"simple":{"attribute":"${key[3]}","operator":"equal","value":["${value[3]}"]}}]}}';

      http.Response response = await http.get(
          Uri.parse('$cmdbuildBaseURL/classes/$cardName/cards?filter=$paramValue'),
          headers: {'Cmdbuild-authorization': token});

      var result = jsonDecode(response.body);

      if (result['success'] == true) {
        returnThis = result;
      }
    });

    return returnThis;
  }
}
