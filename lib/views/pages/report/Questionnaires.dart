import 'package:flutter/material.dart';
import 'package:titikkita/views/widgets/appBar.dart';


class QuestionnairesView extends StatefulWidget {
  @override
  _QuestionnairesViewState createState() => _QuestionnairesViewState();
}

class _QuestionnairesViewState extends State<QuestionnairesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarCustom.buildAppBarCustom(title: "Kuisioner", context: context),
      body: Container(),
    );
  }
}
