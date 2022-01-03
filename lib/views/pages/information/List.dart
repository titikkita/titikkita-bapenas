import 'package:flutter/material.dart';
import 'package:titikkita/controller/cmdbuild_controller.dart';
import 'package:titikkita/state/local_provider.dart';
import 'package:titikkita/util/navigation.dart';
import 'package:titikkita/views/pages/information/Details.dart';
import 'package:titikkita/views/widgets/appBar.dart';
import 'package:titikkita/views/widgets/const.dart';
import 'package:provider/provider.dart' as provider;
import 'package:titikkita/views/widgets/loadingIndicator.dart';
import 'package:titikkita/views/widgets/popupNotif.dart';

class InformationListView extends StatefulWidget {
  InformationListView({this.title});
  final String title;

  @override
  _InformationListViewState createState() => _InformationListViewState();
}

class _InformationListViewState extends State<InformationListView>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    getDefaultInformation();
    _tabController = TabController(length: 2, vsync: this);
  }

  void getDefaultInformation() async {
    var informationData = provider.Provider.of<LocalProvider>(context,listen: false).information;
      try{
        // await generateToken(context);
        // await getInformation(context);
        if(widget.title == 'Publik'){
          if(informationData['publicInformationList'] == null ){
            await CmdbuildController.getPublicInformation(context);
          }
        }
        if(widget.title == 'Pribadi'){

          if(informationData['privateInformationList'] == null ){
            var id= provider.Provider.of<LocalProvider>(context,listen: false).principalConstraint['data'][0]['_id'];
            await CmdbuildController.getPersonalInformation(id,context);
          }

        }

        setState(() {
          _isLoading = false;
        });
      }catch(e){
        setState(() {
          _isLoading = false;
        });
        ShowPopupNotification.errorNotification(
            context: context,
            content: 'Terjadi error. Coba lagi nanti!',
            action: () {
              Navigator.pop(context);
            });
      }
      setState(() {
        _isLoading = false;
      });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
            appBar: AppBarCustom.buildAppBarCustom(
                title: widget.title, context: context),
            body: _isLoading == true
                ? Center(
              child: LoadingIndicator.containerSquareLoadingIndicator(),
            )
                :
            provider.Consumer<LocalProvider>(
              builder: (context, localProvider, child) {
                  var data = widget.title == 'Publik'? localProvider.information['publicInformationList'] : localProvider.information['privateInformationList'];

                  return data.length == 0
                      ? Center(child: Text('Belum ada informasi'))
                      : Center(
                    child: buildInformationTabBarview(
                        data),
                  );


              },
            ),
          );
  }

  buildInformationTabBarview(localProvider) {
    return ListView.builder(
      itemCount: localProvider.length,
      itemBuilder: (context, index) {
        var information = localProvider[index];
        return Container(
          child: Column(
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  goToPage(
                      context,
                      InformationDetailView(
                          details: information));
                },
                child: Container(
                  margin: EdgeInsets.only(top: 25),
                  height: 100,
                  padding: EdgeInsets.only(left: 25, right: 25),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        blurRadius: 1,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          margin: EdgeInsets.only(top: 10),
                          child: Text(
                            information['Time'] == null
                                ? '-'
                                : information['Time'],
                            style: kTextValueBlack,
                          ),
                        ),
                      ),
                      Divider(
                        color: Colors.black,
                      ),
                      Container(
                        child: Text(
                          information['Description'] == null
                              ? '-'
                              : information['Description'],
                          style: kTextValueBlack,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
