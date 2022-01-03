import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider;
import 'package:titikkita/util/navigation.dart';
import 'package:titikkita/views/forms/familyMemberAction.dart';
import 'package:titikkita/views/pages/family_member/MemberDetails.dart';
import 'package:titikkita/views/widgets/containerBuilder.dart';
import 'package:titikkita/views/widgets/const.dart';
import 'package:titikkita/state/local_provider.dart';
import 'package:titikkita/views/widgets/appBar.dart';

class FamilyMembersDetailsView extends StatefulWidget {
  FamilyMembersDetailsView({this.category});

  final String category;

  @override
  _FamilyMembersDetailsViewState createState() =>
      _FamilyMembersDetailsViewState();
}

class _FamilyMembersDetailsViewState extends State<FamilyMembersDetailsView> {
  void pageAddMembersForm() {
    goToPage(
        context,
        FamilyMembersForm(
          stepName: 'Data Diri',
          formMode: 'add',
          data: null,
          cardName: widget.category,
          isPrincipal: false,
          familyId: null,
        ));
  }

  void detailInfo(familyMembersDetail, index) {
    goToPage(
        context,
        PersonDetailsView(
          dataPerson: familyMembersDetail,
          memberIndex: index,
          cardName: widget.category,
          isPrincipal: false,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarCustom.buildAppBarCustom(
        context: context,
        title: widget.category == 'app_localcitizen'
            ? 'Anggota Keluarga'
            : 'Anggota Non Keluarga',
        iconAction: true,
        icon: IconButton(
          alignment: Alignment.centerRight,
          icon: Container(
            width: MediaQuery.of(context).size.width / 3,
            child: Icon(
              Icons.person_add,
              color: Colors.white,
              size: 25,
            ),
          ),
          onPressed: pageAddMembersForm,
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          margin: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              widget.category == 'app_localcitizen'
                  ? Column(
                      children: [
                        AnimatedContainer(
                          height: 200,
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
                          child: Stack(
                            children: <Widget>[
                              Container(
                                child: provider.Consumer<LocalProvider>(
                                    builder: (context, cmdbuild, child) {
                                  return ContainerBuilder.buildContainerFamilyInfo(
                                    data: cmdbuild,
                                  );
                                }),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 10, top: 10),
                          child:
                              Text("Anggota Keluarga", style: ktextTitleBlue),
                        ),
                      ],
                    )
                  : Container(),
              provider.Consumer<LocalProvider>(
                  builder: (context, localProvider, child) {
                final membersData = widget.category == 'app_localcitizen'
                    ? localProvider.members['familyMembers']
                    : localProvider.members['familyNonMembers'];
                return membersData.length == 0
                    ? Center(
                        child: Container(
                          margin: EdgeInsets.only(
                            top: 30.0,
                          ),
                          child: Text(
                            widget.category == 'app_localcitizen'
                                ? 'Tidak ada anggota keluarga yang terdaftar.'
                                : 'Tidak ada anggota non keluarga yang terdaftar.',
                            style: ktextTitleBlue,
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: ScrollController(),
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return ContainerBuilder.buildContainerPersonDetail(
                            context: context,
                            fullName: membersData[index]['Description'],
                            gender: membersData[index]['_JenisKelamin_code'],
                            personalId: membersData[index]['Code'],
                            placeOfBirth: membersData[index]['TempatLahir'],
                            action: () {
                              detailInfo(membersData[index], index);
                            },
                          );
                        },
                        itemCount: membersData.length,
                      );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
