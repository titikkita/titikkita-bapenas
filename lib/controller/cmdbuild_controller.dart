import 'package:titikkita/model/cmdbuild_model.dart';
import 'package:provider/provider.dart' as provider;
import 'package:titikkita/state/local_provider.dart';

var newNetworkHelper = CmdbuildModel();

class CmdbuildController {
  static Future<String> getAdminToken() async {
    var isSuccess = await newNetworkHelper.readAdminToken();

    return isSuccess;
  }

  static Future<dynamic> findCard(value, context) async {
    var isSuccess = await newNetworkHelper.readCard(value, context);
    return isSuccess;
  }

  static Future<dynamic> findOneCard(cardName,value, context) async {
    var isSuccess = await newNetworkHelper.readOneCard(cardName,value, context);
    return isSuccess;
  }

  static Future<dynamic> getFilterCard(value, context,card) async {
    var isSuccess = await newNetworkHelper.readFilterCard(value, context,card);
    return isSuccess;
  }

  static Future<dynamic> getLookupData(lookupList, context) async {
    var data = await newNetworkHelper.readLookupData(lookupList, context);
    return data;
  }
  static Future getOneLookup(lookupName, context) async {
    var data = await newNetworkHelper.readOneLookup(lookupName, context);
    return data;
  }


  static Future<dynamic> commitNewRegister(dataMember, buildContext) async {
    var data = await newNetworkHelper.newRegister(
        data: dataMember, context: buildContext);

    return data;
  }

  static Future<dynamic> getFamilyData(familyId, buildContext) async {
    var familyData = await newNetworkHelper.readCardWithFilter(
        buildContext, 'app_family', 'equal', 'Code', familyId);
    return familyData;
  }

  static Future<dynamic> getDataIdForRegister(
      cardName, familyId, buildContext) async {
    var familyData = await newNetworkHelper.readCardWithFilter(
        buildContext, cardName, 'equal', 'Code', familyId);
    return familyData;
  }

  static Future<dynamic> getNonResidentData(id, buildContext) async {
    var personData = await newNetworkHelper.readCardWithFilter(
        buildContext, 'app_nonlocalcitizen', 'equal', 'Code', id);
    return personData;
  }

  static Future<dynamic> getAllFamilyMembersData(
      {membersFilterValue, buildContext}) async {
    var familyMembersData = await newNetworkHelper.readCardWithFilter(
        buildContext,
        'app_localcitizen',
        'equal',
        'Keluarga',
        membersFilterValue);

    return familyMembersData;
  }

  static Future<dynamic> getAllFamilyNonMembersData(
      {membersFilterValue, buildContext}) async {
    var familyMembersData = await newNetworkHelper.readCardWithFilter(
        buildContext,
        'app_nonlocalcitizen',
        'equal',
        'Keluarga',
        membersFilterValue);

    return familyMembersData;
  }

  static Future<dynamic> getFamilyAddress({filterValue, buildContext}) async {
    var data = await newNetworkHelper.readCardWithFilter(
        buildContext, 'app_address', 'equal', '_id', filterValue);

    return data;
  }

  static Future<dynamic> commitUpdateMemberData(
      dataMember, familyId, status, buildContext) async {
    var data = await newNetworkHelper.updateCardsById(
        id: familyId,
        dataEdit: dataMember,
        cardName: status,
        context: buildContext);

    return data;
  }

  static Future<dynamic> commitDeleteMember(familyId, buildContext) async {
    var data = await newNetworkHelper.deleteCardById(
        id: familyId, cardName: 'app_citizen', context: buildContext);
    return data;
  }

  static Future<dynamic> commitAddNewMember(
      dataMember, status, buildContext) async {
    var data = await newNetworkHelper.addNewCard(
        data: dataMember, cardName: status, context: buildContext);
    return data;
  }

  static Future<dynamic> commitAddNewCard(
      newData, card, buildContext) async {
    var data = await newNetworkHelper.addNewCard(
        data: newData, cardName: card, context: buildContext);
    return data;
  }

  static Future<dynamic> getFamilyLocationPoint(idData, buildContext) async {
    var data = await newNetworkHelper.readGeometryById(
        cardName: 'app_address', id: idData, context: buildContext);
    return data;
  }

  static Future<dynamic> commitUpdateFamilyLocationPoint(
      idData, dataToUpdate, buildContext) async {
    var data = await newNetworkHelper.updateGeometryById(
        id: idData,
        dataEdit: dataToUpdate,
        context: buildContext,
        cardName: 'app_address');
    return data;
  }

  static Future<dynamic> commitUpdateIndividualLocationPoint(
      idData,card, dataToUpdate, buildContext) async {
    var data = await newNetworkHelper.updateGeometryById(
        id: idData,
        dataEdit: dataToUpdate,
        context: buildContext,
        cardName: card);
    return data;
  }

  static Future<dynamic> commitAddFamilyLocationPointByPrincipal(
      dataToAdd, geomData, buildContext) async {
    var result;
    await newNetworkHelper
        .addNewCard(
            data: dataToAdd,
            context: buildContext,
            cardName: 'app_neighborhood')
        .then((value) async {
      await newNetworkHelper
          .updateGeometryById(
              context: buildContext,
              cardName: 'app_neighborhood',
              id: value['data']['_id'],
              dataEdit: geomData)
          .then((val) {
        result = val;
      });
    });
    return result;
  }

  static Future<dynamic> commitAddFamilyPolygonePoints(
      idData, dataToAdd, buildContext) async {
    var data = await newNetworkHelper.addGeometryById(
        cardname: 'app_lot',
        id: idData,
        dataEdit: dataToAdd,
        context: buildContext);
    return data;
  }

  static Future<dynamic> commitAddPrincipalMap(
      dataToAdd, buildContext, nameCard,key, value,value2) async {
    var result;
    await newNetworkHelper
        .readCardWith2Filter(buildContext, nameCard, 'equal', ['Description',key], [value2,value])
        .then((val) async {
      var data = await newNetworkHelper.addGeometryPolygonById(
          cardname: nameCard,
          id: val['data'][0]['_id'],
          dataEdit: dataToAdd,
          context: buildContext);
      result = data;

    }).catchError((e){
      print(e);
    });
    return result;
  }

  static Future<dynamic> commitAddNewPersilCard(cardData, buildContext) async {
    var data = await newNetworkHelper.addNewCard(
        cardName: 'app_lot', data: cardData, context: buildContext);
    return data;
  }

  static Future<dynamic> commitEditPersilCard(
      cardData, cardId, buildContext) async {
    var data = await newNetworkHelper.editCardById(
        cardName: 'app_lot', data: cardData, id: cardId, context: buildContext);
    return data;
  }

  static Future<dynamic> getFamilyLotId(idData, buildContext) async {
    var data = await newNetworkHelper.readCardWithFilter(
        buildContext, 'app_lot', 'equal', 'UserID', idData);
    return data;
  }

  static Future<dynamic> getFamilyPolylinePoints(familyId, buildContext) async {
    var data = await newNetworkHelper.readGeometryById(
        cardName: 'app_lot', id: familyId, context: buildContext);
    return data;
  }

  static Future<dynamic> getPrincipalPolyline(id, nameCard ,buildContext) async {
    var data = await newNetworkHelper.readGeometryPolygonById(
        cardName: nameCard, id: id, context: buildContext);
    return data;
  }

  static Future<dynamic> getReportData(context, cardName, id) async {
    var data = await newNetworkHelper.readCardWithFilter(
        context, cardName, 'equal', 'UserID', id);
    return data;
  }

  static Future<dynamic> commitAddReport(
      reportData, card, images, buildContext) async {
    var data = await newNetworkHelper.addNewCard(
        cardName: card, data: reportData, context: buildContext);
    if (data['success']) {
      await newNetworkHelper.addImages(
          data['data']['_id'], images, card, buildContext);
    }
    return data;
  }

  static Future<dynamic> getPublicInformation(buildContext) async {
    var data = await newNetworkHelper.readCardList(
        cardName: 'app_publicinformatio', context: buildContext);

    await provider.Provider.of<LocalProvider>(buildContext, listen: false)
        .updatePublicInformationData(data);

    return data;
  }

  static Future<dynamic> getPersonalInformation(id, buildContext) async {
    var data = await newNetworkHelper.readCardWithFilter(
        buildContext, 'app_personalinformat', 'equal', 'UserID', id);
    await provider.Provider.of<LocalProvider>(buildContext, listen: false)
        .updatePersonalInformationData(data);
    return data;
  }

  static Future<dynamic> commitUpdateFamilyInternalData(
      dataFamily, idEdit, buildContext) async {
    var data = await newNetworkHelper.updateCardsById(
        cardName: 'app_address',
        dataEdit: dataFamily,
        id: idEdit,
        context: buildContext);
    return data;
  }

  static Future<dynamic> commitUpdateData(
      dataToEdit, idEdit, card,buildContext) async {
    var data = await newNetworkHelper.updateCardsById(
        cardName: card,
        dataEdit: dataToEdit,
        id: idEdit,
        context: buildContext);
    return data;
  }

  static Future<dynamic> getNeighborLocation(cardId, buildContext) async {
    var data = await newNetworkHelper.readGeometryById(
        context: buildContext, cardName: 'app_neighborhood', id: cardId);
    return data;
  }

  static Future<dynamic> getNeighborList(code, buildContext) async {
    var neighboarList = await newNetworkHelper.readCardWithFilter(
        buildContext, 'app_neighborhood', 'equal', 'UserID', code);
    return neighboarList;
  }

  static Future<dynamic> commitAddNewNeighborLocation(
      newNeighbor, geomValue, buildContext) async {
    var newData = await newNetworkHelper.addNewNeighborLocation(
        data: newNeighbor, geomData: geomValue, context: buildContext);

    return newData;
  }

  static Future<dynamic> commitAddNewOthersArea(
      newNeighbor, geomValue, dataImages, buildContext) async {
    var newData = await newNetworkHelper.addNewOthersArea(
        data: newNeighbor,
        geomData: geomValue,
        context: buildContext,
        imageData: dataImages,
        cardName: 'app_otherarea');

    return newData;
  }

  static Future<dynamic> commitAddReportLocationGeomValue(
      dataToAdd, cardId, name, buildContext) async {
    var newData = await newNetworkHelper.updateGeometryById(
        cardName: name, id: cardId, dataEdit: dataToAdd, context: buildContext);

    return newData;
  }

  static Future<dynamic> commitDeleteGeovalue(
   cardId, name, buildContext) async {
    var newData = await newNetworkHelper.deleteGeovalue(buildContext,name,cardId);
    return newData;
  }

  static Future<dynamic> getInfoGeomValue(cardId, buildContext) async {
    var data = await newNetworkHelper.readGeometryById(
        cardName: 'app_publicinformatio', id: cardId, context: buildContext);
    return data;
  }

  static Future<dynamic> getGeometryPoint(card, cardId, buildContext) async {
    var data = await newNetworkHelper.readGeometryById(
        cardName: card, id: cardId, context: buildContext);
    return data;
  }

  static Future<dynamic> getReportLocation(cardId, buildContext) async {
    var data = await newNetworkHelper.readGeometryById(
        cardName: 'app_report', id: cardId, context: buildContext);
    return data;
  }

  static Future<dynamic> commitEditReportDetail(
      cardId, dataToAdd, name, buildContext) async {
    var data = await newNetworkHelper.editCardById(
        cardName: name, data: dataToAdd, id: cardId, context: buildContext);

    return data;
  }

  static Future<dynamic> commitEditCardById(
      cardId, dataToAdd, name, buildContext) async {
    var data = await newNetworkHelper.editCardById(
        cardName: name, data: dataToAdd, id: cardId, context: buildContext);

    return data;
  }

  static Future<dynamic> commitEditNeighborData(
      cardId, newNeighbor, buildContext) async {
    var newData = await newNetworkHelper.updateCardsById(
        context: buildContext,
        cardName: 'app_neighborhood',
        dataEdit: newNeighbor,
        id: cardId);

    return newData;
  }

  static Future<dynamic> commitDeleteNeighborLocation(
      cardId, buildContext) async {
    var data = await newNetworkHelper.deleteCardById(
        id: cardId, context: buildContext, cardName: 'app_neighborhood');
    return data;
  }

  static Future<dynamic> commitDeleteOneOthersArea(cardId, buildContext) async {
    var data = await newNetworkHelper.deleteCardById(
        id: cardId, cardName: 'app_otherarea', context: buildContext);
    return data;
  }

  static Future<dynamic> deleteOneCard({cardName, id, context}) async {
    var data = await newNetworkHelper.deleteCardById(
        id: '$id', cardName: '$cardName', context: context);
    return data;
  }

  static Future<dynamic> getOtherAreaList(code, buildContext) async {
    var neighboarList = await newNetworkHelper.readCardWithFilter(
        buildContext, 'app_otherarea', 'equal', 'UserID', code);
    return neighboarList;
  }

  static Future<dynamic> getOtherAreaGeom(cardId, buildContext) async {
    var data = await newNetworkHelper.readGeometryById(
        cardName: 'app_otherarea', context: buildContext, id: cardId);
    return data;
  }

  static Future<dynamic> commitEditOtherArea(
      cardId, newNeighbor, images, buildContext) async {
    if (images.length != 0) {
      await newNetworkHelper.addImages(
          cardId, images, 'app_otherarea', buildContext);
    }

    var newData = await newNetworkHelper.updateCardsById(
        context: buildContext,
        cardName: 'app_otherarea',
        dataEdit: newNeighbor,
        id: cardId);
    return newData;
  }

  static Future<dynamic> getImage(memberId, status, buildContext) async {
    var newData = await newNetworkHelper.getImageName(
        id: memberId, cardName: status, context: buildContext);
    return newData;
  }

  static Future<dynamic> getImageFromAddress(memberId, buildContext) async {
    var newData = await newNetworkHelper.readImages(
        id: memberId, context: buildContext, cardName: 'app_address');
    return newData;
  }

  static Future<dynamic> getImageFromCitizen(memberId,card, buildContext) async {
    var newData = await newNetworkHelper.readImages(
        id: memberId, context: buildContext, cardName: card);
    return newData;
  }

  static Future<dynamic> getImageFromOtherArea(memberId, buildContext) async {
    var newData = await newNetworkHelper.readImages(
        id: memberId, context: buildContext, cardName: 'app_otherarea');
    return newData;
  }

  static Future<dynamic> getImageFromReport(
      memberId, buildContext, cardName) async {
    var newData = await newNetworkHelper.readImages(
        id: memberId, context: buildContext, cardName: '$cardName');
    return newData;
  }

  static Future<dynamic> deleteImage(memberId, id, status, buildContext) async {
    var newData = await newNetworkHelper.deleteImage(
        id: memberId,
        attachmentId: id,
        memberStatus: status,
        context: buildContext);
    return newData;
  }

  static Future<dynamic> commitSendImage(
      memberId, path, author, status, buildContext) async {
    var sendImage = await newNetworkHelper.sendImage(
        id: memberId,
        filePath: path,
        name: author,
        cardName: status,
        context: buildContext);

    return sendImage;
  }

  static Future<dynamic> getCountryCode(buildContext) async {
    var countryCode = await newNetworkHelper.readCardList(
        context: buildContext, cardName: 'mtr_country');

    return countryCode;
  }

  static Future<dynamic> getComodityData(context, id) async {
    var countryCode = await newNetworkHelper.readCardWithFilter(
        context, 'app_comodity', 'equal', 'UserID', id);

    return countryCode;
  }

  static Future<dynamic> getComodityPoints(id) async {
    var data = await newNetworkHelper.readComodityPoints(idData: id);
    return data;
  }

  static Future<dynamic> commitAddNewComodity(
      newComodity, geomValue, geomPolygonValue) async {
    var newData = await newNetworkHelper.addNewComodity(
        data: newComodity, geomData: geomValue, geomPolygon: geomPolygonValue);

    return newData;
  }

  static Future<dynamic> commitDeleteComodity(buildContext, cardId) async {
    var data = await newNetworkHelper.deleteCardById(
        id: cardId, context: buildContext, cardName: 'app_comodity');
    return data;
  }

  static Future<dynamic> commitDeletePersilCard(cardId, buildContext) async {
    var data = await newNetworkHelper.deleteCardById(
        id: cardId, cardName: 'app_lot', context: buildContext);
    return data;
  }

  static Future<dynamic> commitEditComodityData(
      cardId, newNeighbor, points, polygon) async {
    var newData = await newNetworkHelper.editComodityData(
        id: cardId, data: newNeighbor, geomValue: points, geomPolygon: polygon);

    return newData;
  }

  static Future<dynamic> commitEditGeometryPoint(
      cardId, cardName, points,context) async {
    var newData = await newNetworkHelper.editGeometryPoint(
        id: cardId, card: cardName, dataPoint: points,context: context);

    return newData;
  }

  static Future<dynamic> getAllFamilyList(buildContext) async {
    var data = await newNetworkHelper.readCardList(
        context: buildContext, cardName: 'app_family');

    return data;
  }

  static Future<dynamic> getFAQList(buildContext) async {
    var data = await newNetworkHelper.readCardList(
        context: buildContext, cardName: 'app_faq');

    return data;
  }

  static Future<dynamic> commitAddHomeImages({familyId, body, context}) async {
    var data = await newNetworkHelper.addImages(
        familyId, body, 'app_address', context);

    return data;
  }

  static Future<dynamic> commitAddIndividualHomeImages({id, cardName, body, context}) async {
    var data = await newNetworkHelper.addImages(
        id, body, cardName, context);

    return data;
  }

  static Future<dynamic> commitDownloadImage(
      className, cardId, imageId, context) async {
    var data = await newNetworkHelper.downloadImages(
        className, cardId, imageId, context);

    return data;
  }

  static Future<dynamic> commitDeleteAttach(
      className, cardId, imageId, context) async {
    var data = await newNetworkHelper.deleteAttach(
        className, cardId, imageId, context);

    return data;
  }

  static Future<Map<String, List>> getAreaList(context) async {
    Map<String, List> data = await newNetworkHelper.readAreaList(context);

    return data;
  }

  static Future<dynamic> getFamilyList(buildContext) async {
    var data = await newNetworkHelper.readCardList(
        context: buildContext, cardName: 'app_family');

    return data;
  }

  static Future<dynamic> getCitizenList(context, cardName, key, value) async {
    var data = await newNetworkHelper.readCardWithFilter(
        context, cardName, 'contain', key, value);

    return data;
  }

  static Future<dynamic> getCitizenListWithConstraintFilter(
      context, cardName, key, value) async {
    var data = await newNetworkHelper.readCardWithSomeFilter(
        context, cardName, 'equal', key, value);

    return data;
  }

  static Future<dynamic> getAreaForGettingAllFamilyLocation(context) async {
    var data =
        await newNetworkHelper.readAreaForGettingAllFamilyLocation(context);

    return data;
  }

  static Future<dynamic> getAllFamilyLocation(context, area) async {
    var attribute = await newNetworkHelper.readAttributeArea(context);
    var data = await newNetworkHelper.readAllFamilyLocation(
        context, area, attribute['data'][0]['_id']);

    return data;
  }

  static Future<dynamic> findCardWithFilter(
      {context, cardName, filter, key, value}) async {

    var data = await newNetworkHelper.readCardWithFilter(
        context, cardName, filter, key, value);

    return data;
  }

  static Future<dynamic> findCardWith4Filter(
      {context, cardName, filter, key, value}) async {
    var data = await newNetworkHelper.readCardWithManyFilter(
        context, cardName, filter, key, value);
    return data;
  }

  static Future<dynamic> findCardWith3Filter(
      {context, cardName, filter, key, value}) async {
    var data = await newNetworkHelper.readCardWithSomeFilter(
        context, cardName, filter, key, value);
    return data;
  }

  static Future<dynamic> getUserAuthenticationData({context, value}) async {
    var data = await newNetworkHelper.readCardWithFilter(
        context, 'mtr_authentification', 'equal', 'Code', value);
    return data;
  }

  static Future<dynamic> findCardWithSomeFilter(
      {context, cardName, filter, key, value}) async {
    var data = await newNetworkHelper.readCardWithSomeFilter(
        context, cardName, filter, key, value);

    return data;
  }

  static Future<dynamic> findCardWith2Filter(

      {context, cardName, filter, key, value}) async {
    var data = await newNetworkHelper.readCardWith2Filter(
        context, cardName, filter, key, value);

    return data;
  }
}
