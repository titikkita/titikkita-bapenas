import 'package:flutter/material.dart';
import 'package:titikkita/controller/cmdbuild_controller.dart';
import 'package:titikkita/state/local_provider.dart';
import 'package:titikkita/views/widgets/appBar.dart';
import 'package:titikkita/views/widgets/const.dart';
import 'package:provider/provider.dart' as provider;
import 'package:titikkita/views/widgets/popupNotif.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpDeskView extends StatefulWidget {
  @override
  _HelpDeskViewState createState() => _HelpDeskViewState();
}

class _HelpDeskViewState extends State<HelpDeskView> {
  List<dynamic> faqList = [];
  List<bool> isShowAnswer = [];

  @override
  void initState() {
    getFAQ();
    super.initState();
  }

  void getFAQ() async {
    if (provider.Provider.of<LocalProvider>(context, listen: false)
            .faqList
            .length ==
        0) {
      try {
        var data = await CmdbuildController.getFAQList(context);
        if (data['success'] == true) {
          setState(() {
            faqList = data['data'];
          });

          provider.Provider.of<LocalProvider>(context, listen: false)
              .updateFAQ(faqList);
        }
      } catch (e) {}
    } else {
      setState(() {
        faqList = provider.Provider.of<LocalProvider>(context, listen: false)
            .faqList;
      });
    }
    for (var i = 0; i < faqList.length; i++) {
      setState(() {
        isShowAnswer.add(false);
      });
    }

    print(isShowAnswer);
  }

  subMenu({title, container}) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.only(left: 20.0, bottom: 10.0,top:10.0),
          child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                '$title',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.start,
              )),
        ),
        container,
        Container(
          height: 5.0,
          color: Colors.grey[200],
          margin: EdgeInsets.only(top: 10.0, bottom: 10.0),
        ),

      ],
    );
  }

  void urlLauncher(url) async {
    try {
      await canLaunch(url)
          ? launch(url)
          : ShowPopupNotification.errorNotification(
              context: context,
              content: 'Anda belum menginstall aplikasi surel',
              action: () {
                // Navigator.pop(context);
              });
    } catch (e) {
      ShowPopupNotification.errorNotification(
          context: context,
          content: 'Terjadi error. Coba lagi nanti!',
          action: () {
            Navigator.pop(context);
          });
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarCustom.buildAppBarNoNavigation(
        title: 'Pusat Bantuan',
        context: context,
        iconAction: true,
        icon: IconButton(
            icon: kIconCloseAppBar,
            onPressed: () {
              Navigator.pop(context);
            }),
      ),
      body: Container(
        child: SafeArea(
          child: Container(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  subMenu(
                      title: 'TUTORIAL APLIKASI',
                      container: Container(
                        padding: EdgeInsets.only(left:20.0),
                        child: GestureDetector(
                          onTap: () {
                            var wordpress =
                                'http://www.padasuka-sumedang.online/?page_id=1038';
                            urlLauncher(wordpress);
                          },
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(left:8.0),
                              child: Text(
                                'cara penggunaan aplikasi',
                                style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                                textAlign: TextAlign.start,
                              ),
                            ),
                          ),
                        ),
                      )),
                  subMenu(
                    title: 'FAQ',
                    container: Container(
                      height: MediaQuery.of(context).size.height / 3,
                      child: ListView.builder(
                        itemCount: faqList.length != 0 ? faqList.length : 0,
                        itemBuilder: (context, index) {
                          return Column(children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  isShowAnswer[index] = !isShowAnswer[index];
                                });
                              },
                              child: Row(
                                children: [
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width / 1.1,
                                    padding: EdgeInsets.only(
                                        left: 20.0, right: 20.0),
                                    child: Align(
                                        alignment: Alignment.topLeft,
                                        child: Text(
                                          '${faqList[index]['Pertanyaan']}',
                                          style: kListTileTextStyle,
                                          textAlign: TextAlign.start,
                                        )),
                                  ),
                                  Icon(
                                    Icons.keyboard_arrow_right,
                                    color: Colors.black45,
                                    size: 17,
                                  ),
                                ],
                              ),
                            ),
                            isShowAnswer[index]
                                ? Container(
                                    width:
                                        MediaQuery.of(context).size.width / 1.1,
                                    padding: EdgeInsets.only(
                                        top: 5.0, left: 25.0, right: 20.0),
                                    child: Align(
                                        alignment: Alignment.topLeft,
                                        child: Text(
                                          '${faqList[index]['Jawaban']}',
                                          style: kListTileTextStyleSmaller,
                                          textAlign: TextAlign.start,
                                        )),
                                  )
                                : Container(),
                            Divider(
                              color: Colors.black26,
                            ),
                          ]);
                        },
                      ),
                    ),
                  ),
                  subMenu(
                      title: 'HUBUNGI KAMI',
                      container: Column(
                        children: [
                          ListTile(
                            title: Text('Chat Whatsapp',
                                style: kListTileTextStyle),
                            leading: Icon(Icons.chat_bubble_outline_rounded),
                            onTap: () {
                              var whatsappUrl =
                                  'whatsapp://send?phone=+6281809405408';
                              urlLauncher(whatsappUrl);
                            },
                          ),
                          ListTile(
                            title: Text('Email', style: kListTileTextStyle),
                            leading: Icon(Icons.email_rounded),
                            onTap: () {
                              var emailUrl = Uri(
                                  scheme: 'mailto',
                                  path: 'sapadiridantetangga@gmail.com',
                                  queryParameters: {'subject': ' '});
                              urlLauncher(emailUrl.toString());
                            },
                          ),
                          ListTile(
                            title: Text('Telepon', style: kListTileTextStyle),
                            leading: Icon(Icons.phone),
                            onTap: () {
                              var url = 'tel://+6281809405408';
                              urlLauncher(url);
                            },
                          ),
                        ],
                      ))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
