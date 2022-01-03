import 'package:flutter/material.dart';
import 'package:titikkita/controller/cmdbuild_controller.dart';
import 'package:titikkita/state/principal_provider.dart';
import 'package:titikkita/util/navigation.dart';
import 'package:titikkita/views/forms/familyMemberAction.dart';
import 'package:titikkita/views/pages/family_member/MemberDetails.dart';
import 'package:titikkita/views/widgets/const.dart';
import 'package:titikkita/views/widgets/containerBuilder.dart';
import 'package:titikkita/views/widgets/loadingIndicator.dart';
import 'package:provider/provider.dart' as provider;

class FamilyMembersListView extends StatefulWidget {
  FamilyMembersListView({this.memberId});

  final int memberId;

  @override
  _FamilyMembersListViewState createState() => _FamilyMembersListViewState();
}

class _FamilyMembersListViewState extends State<FamilyMembersListView>
    with TickerProviderStateMixin {
  TabController _tabController;
  Map<String, List> membersData = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    getDefaultData();
    _tabController = TabController(length: 2, vsync: this);
  }

  void getDefaultData() async {
    setState(() {
      _isLoading = true;
    });
    await CmdbuildController.getAllFamilyMembersData(
            membersFilterValue: widget.memberId,
            buildContext: context)
        .then((value) {
      provider.Provider.of<PrincipalProvider>(context, listen: false)
          .updateMembers('memberList', value['data']);
      setState(() {
        membersData['membersList'] = value['data'];
      });
    }).catchError((e) {
      setState(() {
        _isLoading = false;
      });
      print(e);
    });
    await CmdbuildController.getAllFamilyNonMembersData(
            membersFilterValue: widget.memberId,
            buildContext: context)
        .then((value) {
      provider.Provider.of<PrincipalProvider>(context, listen: false)
          .updateMembers('memberList', value['data']);
      setState(() {
        membersData['nonMembersList'] = value['data'];
      });
    }).catchError((e) {
      setState(() {
        _isLoading = false;
      });
      print(e);
    });

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff084A9A),
        title: Text(
          'Daftar Anggota',
          style: kAppBarTextTitleStyle,
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const <Widget>[
            Tab(
              text: 'Anggota Keluarga',
            ),
            Tab(
              text: 'Anggota Non Keluarga',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          var index = _tabController.index.toInt();
          var category =
              index == 0 ? 'app_localcitizen' : 'app_nonlocalcitizen';

          goToPage(
              context,
              FamilyMembersForm(
                stepName: 'Data Diri',
                formMode: 'add',
                data: null,
                cardName: category,
                isPrincipal: true,
                familyId: widget.memberId,
              ));
        },
        child: Icon(Icons.person_add),
        // backgroundColor: Colors.green,
      ),
      body: _isLoading
          ? Center(child: LoadingIndicator.containerSquareLoadingIndicator())
          : TabBarView(
              controller: _tabController,
              children: <Widget>[
                membersData['membersList'].length == 0
                    ? Center(
                        child:
                            Text('Tidak ada anggota keluarga yang terdaftar.'),
                      )
                    : ListView.builder(
                        controller: ScrollController(),
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return ContainerBuilder.buildContainerPersonDetail(
                            context: context,
                            fullName: membersData['membersList'][index]
                                ['Description'],
                            gender: membersData['membersList'][index]
                                ['_JenisKelamin_code'],
                            personalId: membersData['membersList'][index]
                                ['Code'],
                            placeOfBirth: membersData['membersList'][index]
                                ['TempatLahir'],
                            action: () {
                              goToPage(
                                  context,
                                  PersonDetailsView(
                                    dataPerson: membersData['membersList']
                                        [index],
                                    memberIndex: index,
                                    cardName: 'app_localcitizen',
                                    isPrincipal: true,
                                  ));
                            },
                          );
                        },
                        itemCount: membersData['membersList'].length,
                      ),
                membersData['nonMembersList'].length == 0
                    ? Center(
                        child: Text(
                            'Tidak ada anggota non keluarga yang terdaftar.'),
                      )
                    : ListView.builder(
                        controller: ScrollController(),
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return ContainerBuilder.buildContainerPersonDetail(
                            context: context,
                            fullName: membersData['nonMembersList'][index]
                                ['Description'],
                            gender: membersData['nonMembersList'][index]
                                ['_JenisKelamin_code'],
                            personalId: membersData['nonMembersList'][index]
                                ['Code'],
                            placeOfBirth: membersData['nonMembersList'][index]
                                ['TempatLahir'],
                            action: () {
                              goToPage(
                                  context,
                                  PersonDetailsView(
                                    dataPerson: membersData['nonMembersList']
                                        [index],
                                    memberIndex: index,
                                    cardName: 'app_nonlocalcitizen',
                                    isPrincipal: true,
                                  ));
                            },
                          );
                        },
                        itemCount: membersData['nonMembersList'].length,
                      ),
              ],
            ),
    );
  }
}
