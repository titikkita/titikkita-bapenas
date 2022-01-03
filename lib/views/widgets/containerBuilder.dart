import 'package:flutter/material.dart';
import 'package:titikkita/state/local_provider.dart';
import 'package:titikkita/util/navigation.dart';
import 'package:titikkita/views/pages/principalInformation/FamilyMap.dart';
import 'package:titikkita/views/pages/principalInformation/MemberList.dart';
import 'package:titikkita/views/widgets/const.dart';
import 'package:provider/provider.dart' as provider;

class ContainerBuilder {
  static Container buildContainerFamilyInternalData(
      {title, value, crossAxis, isShowImageFile}) {
    return Container(
      // margin: EdgeInsets.only(bottom: 10.0),
      height: 100.0,
      child: Column(
        crossAxisAlignment: crossAxis,
        children: <Widget>[
          Container(
            child: Text(title, style: ktextTitleBlue),
          ),
          Container(
              child:
                  Text(value == null ? '-' : '$value', style: kTextValueBlack)
              // isShowImageFile == true && value != null
              //     ? Container(
              //         height: 50.0,
              //         width: 100.0,
              //         child: Image.file(value),
              //       )
              //     : Text(value == null ? '-' : value, style: kTextValueBlack),
              ),
        ],
      ),
    );
  }

  static Widget buildContainerPersonDetail(
      {context, fullName, gender, personalId, placeOfBirth, action}) {
    return GestureDetector(
      onTap: action,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              blurRadius: 1,
            ),
          ],
        ),
        margin: EdgeInsets.only(top: 20, bottom: 10),
        padding: EdgeInsets.only(left: 20, right: 45),
        child: Stack(
          children: <Widget>[
            Container(
              child: Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(top: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          child: Text("Nama Lengkap", style: ktextTitleBlue),
                        ),
                        Container(
                          child: Text("Jenis Kelamin", style: ktextTitleBlue),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          child: Text('$fullName', style: kTextValueBlack),
                        ),
                        Container(
                          child: Text(gender == null ? '-' : gender,
                              style: kTextValueBlack),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          child: Text("NIK", style: ktextTitleBlue),
                        ),
                        Container(
                          child: Text("Tempat Lahir", style: ktextTitleBlue),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 5, bottom: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          child: Text(personalId == null ? '-' : personalId,
                              style: kTextValueBlack),
                        ),
                        Container(
                          child: Text(placeOfBirth == null ? '-' : placeOfBirth,
                              style: kTextValueBlack),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Column buildContainerFamilyInfo({data, isPrincipal}) {
    final familyInfo = data.familyData;
    final addressInfo = data.address;
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(top: 15),
          child: Text('No.KK ${familyInfo['Code']}', style: ktextTitleBlue),
        ),
        Container(
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(top: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      child:
                          Text("Nama Kepala Keluarga", style: ktextTitleBlue),
                    ),
                    Container(
                      child: Text("Kabupaten/kota", style: ktextTitleBlue),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      child: Text("${familyInfo['Description']}",
                          style: kTextValueBlack),
                    ),
                    Container(
                      child: Text(
                          "${addressInfo['data'][0]['_Kabupaten_description']}",
                          style: kTextValueBlack),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      child: Text("Desa", style: ktextTitleBlue),
                    ),
                    Container(
                      child: Text("Kecamatan", style: ktextTitleBlue),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 10, bottom: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      child: Text(
                          "${addressInfo['data'][0]['_Desa_description']}",
                          style: kTextValueBlack),
                    ),
                    Container(
                      child: Text(
                          "${addressInfo['data'][0]['_Kecamatan_description']}",
                          style: kTextValueBlack),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static GestureDetector buildContainerListFamily({data, context}) {
    // print(data);
    return GestureDetector(
      onTap: () {
        goToPage(
            context,
            FamilyMembersListView(
              memberId: data['_id'],
            ));
      },
      child: AnimatedContainer(
        height: 150.0,
        duration: Duration(milliseconds: 1),
        margin: EdgeInsets.only(top: 20, bottom: 10),
        padding: EdgeInsets.only(left: 20, right: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              blurRadius: 1,
            ),
          ],
        ),
        child: Container(
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(top: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      child:
                          Text("Nama Kepala Keluarga", style: ktextTitleBlue),
                    ),
                    Container(
                      child: Text("Nomor KK", style: ktextTitleBlue),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: Text("${data['Description']}",
                          style: kTextValueBlack),
                    ),
                    Container(
                      child: Text("${data['Code']}", style: kTextValueBlack),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      child: Text("Alamat", style: ktextTitleBlue),
                    ),
                    Container(
                      width: 30,
                      height:30,
                      child: IconButton(
                        icon: Icon(Icons.map_outlined),
                        color: Colors.blueAccent,
                        iconSize: 19,
                        onPressed: () {
                          print('I got pressed');
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){
                            return PrincipalMapView(data);
                          }));
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 10, bottom: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: Text("${data['_AlamatTinggal_description']}",
                          style: kTextValueBlack),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
