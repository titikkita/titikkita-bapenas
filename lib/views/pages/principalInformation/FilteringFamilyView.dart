import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:titikkita/controller/cmdbuild_controller.dart';
import 'package:titikkita/state/local_provider.dart';
import 'package:titikkita/state/principal_provider.dart';
import 'package:titikkita/util/navigation.dart';
import 'package:titikkita/views/forms/familyMemberAction.dart';
import 'package:titikkita/views/pages/family_member/MemberDetails.dart';
import 'package:titikkita/views/pages/principalInformation/CitizenList.dart';
import 'package:titikkita/views/pages/principalInformation/FamilyList.dart';
import 'package:titikkita/views/widgets/const.dart';
import 'package:titikkita/views/widgets/containerBuilder.dart';
import 'package:titikkita/views/widgets/inputDropdownFullWidth.dart';
import 'package:titikkita/views/widgets/loadingIndicator.dart';
import 'package:provider/provider.dart' as provider;

class FilteringFamilyView extends StatefulWidget {
  FilteringFamilyView({this.type});

  final String type;

  @override
  _FilteringFamilyViewState createState() => _FilteringFamilyViewState();
}

class _FilteringFamilyViewState extends State<FilteringFamilyView> {
  Map<String, List> membersData = {};
  bool _isLoading = false;
  bool isSubmitLoading = false;
  dynamic user;
  String filteringCardName;
  int filteringId;
  String filteringKey;
  List<DropdownMenuItem> listRT = [];
  List<DropdownMenuItem> listRW = [];
  List<DropdownMenuItem> listDusun = [];
  List<DropdownMenuItem> listDesa = [];
  dynamic initialValue = {
    'RT': 'Pilih salah satu',
    'RW': 'Pilih salah satu',
    'Dusun': 'Pilih salah satu',
    'Desa': ''
  };

  dynamic initialValueId = {
    'RT': 0,
    'RW': 0,
    'Dusun': 0,
    'Desa': 0,
  };

  @override
  void initState() {
    super.initState();
    getDefaultData();
  }

  void getDefaultData() async {
    setState(() {
      _isLoading = true;
    });

    user = provider.Provider.of<LocalProvider>(context, listen: false)
        .principalConstraint['data'][0];
    initialValue['Desa'] = user['_Desa_description'];
    initialValue['Dusun'] = user['_Dusun_description'];
    initialValue['RW'] = user['_RW_description'];
    initialValueId['Desa'] = user['Desa'];
    initialValueId['Dusun'] = user['Dusun'];
    initialValueId['RW'] = user['RW'];
    initialValueId['RT'] = user['RT'];

    if (user['_Jabatan_description'] == 'Ketua Dusun') {
      filteringCardName = 'pti_upperneighbor';
      filteringId = user['Dusun'];
      filteringKey = 'Dusun';
      findList(filteringCardName, filteringKey, filteringId, 'RW');
    }
    if (user['_Jabatan_description'] == 'Kepala Desa') {
      filteringCardName = 'pti_hamlet';
      filteringId = user['Desa'];
      filteringKey = 'Desa';
      findList(filteringCardName, filteringKey, filteringId, 'Dusun');
    }
    setState(() {
      _isLoading = false;
    });
  }

  void findList(cardName, key, id, type) async {
    List<DropdownMenuItem> list = [];
    await CmdbuildController.findCardWithFilter(
            context: context,
            cardName: cardName,
            filter: 'equal',
            key: key,
            value: id)
        .then((value) {
          print(value);
      value['data'].forEach((e) {
        list.add(DropdownMenuItem(
          child: Text('${e['Description']}'),
          value: e,
        ));
      });
    });
    setState(() {
      if (type == 'RW') {
        listRW = list;
      }
      if (type == 'Dusun') {
        listDusun = list;
        print(listDusun);
      }
      if (type == 'RT') {
        listRT = list;
      }
    });
  }

  void onChanged(param, value) {
    if(param == 'RW'){
      findList('pti_neighborhood', 'RW', value['_id'], 'RT');
    }
    if(param == 'Dusun'){
      findList('pti_upperneighbor', 'Dusun', value['_id'], 'RW');
    }
    setState(() {
      initialValue[param] = value['Description'];
      initialValueId[param] = value['_id'];
    });
  }

  void onSubmitFamily() async {
    setState(() {
      isSubmitLoading = true;
    });
      //
      // await CmdbuildController.findCardWith4Filter(
      //     context: context,
      //     cardName: 'app_family',
      //     filter: 'equal',
      //     key: ['Desa','Dusun','RW','RT'],
      //     value: [initialValue['Desa'],initialValue['Dusun'],initialValue['RW'],initialValue['RT']]).then((value){
      //       print(value);
      // });

      await CmdbuildController.findCardWith3Filter(
          context: context,
          cardName: 'app_family',
          filter: 'equal',
          key: [
            '_tenant',
            'RW',
            'RT'
          ],
          value: [
            initialValueId['Desa'],
            initialValueId['RW'],
            initialValueId['RT']
          ]).then((value) {
        setState(() {
          isSubmitLoading = false;
        });
        goToPage(context, FamilyListView(data: value['data'],));
      });
  }

  void onSubmitPeople() async {
    setState(() {
      isSubmitLoading = true;
    });
    //
    // await CmdbuildController.findCardWith4Filter(
    //     context: context,
    //     cardName: 'app_family',
    //     filter: 'equal',
    //     key: ['Desa','Dusun','RW','RT'],
    //     value: [initialValue['Desa'],initialValue['Dusun'],initialValue['RW'],initialValue['RT']]).then((value){
    //       print(value);
    // });

    await CmdbuildController.findCardWith3Filter(
        context: context,
        cardName: 'app_citizen',
        filter: 'equal',
        key: [
          '_tenant',
          'RW',
          'RT'
        ],
        value: [
          initialValueId['Desa'],
          initialValueId['RW'],
          initialValueId['RT']
        ]).then((value) {
          print(value);

      setState(() {
        isSubmitLoading = false;
      });
      goToPage(context, CitizenListView(data: value['data'],));
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff084A9A),
        title: Text(
          widget.type == 'family' ?
          'Cari Anggota Keluarga' : 'Cari Warga',
          style: kAppBarTextTitleStyle,
        ),
      ),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: ListView(
          children: [
            InputDropdownFullWidth(
              title: 'Desa',
              lookupData: listDesa,
              onChangedDropdownList: onChanged,
              param: 'Desa',
              initialValue: initialValue['Desa'],
            ),
            InputDropdownFullWidth(
              title: 'Dusun',
              lookupData: listDusun,
              onChangedDropdownList: onChanged,
              param: 'Dusun',
              initialValue: initialValue['Dusun'],
            ),
            InputDropdownFullWidth(
              title: 'RW',
              lookupData: listRW,
              onChangedDropdownList: onChanged,
              param: 'RW',
              initialValue: initialValue['RW'],
            ),
            InputDropdownFullWidth(
              title: 'RT',
              lookupData: listRT,
              onChangedDropdownList: onChanged,
              param: 'RT',
              initialValue: initialValue['RT'],
            ),
            SizedBox(
              height: 60,
            ),
            Container(
              decoration: BoxDecoration(
                color: Color(0xff084A9A),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextButton(
                  onPressed: widget.type == 'family' ? onSubmitFamily : onSubmitPeople,
                  child: isSubmitLoading ? Container(child: CircularProgressIndicator()) :
                  Text(
                    'OK',
                    style: TextStyle(color: Colors.white),
                  )),
            )
          ],
        ),
      ),
    );
  }
}
