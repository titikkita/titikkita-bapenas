import 'package:flutter/material.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';

class InputDropdownFullWidth extends StatelessWidget {
  const InputDropdownFullWidth({this.title,this.lookupData,this.onChangedDropdownList,this.param,this.initialValue});

  final title;
  final lookupData;
  final onChangedDropdownList;
  final param;
  final initialValue;

  @override
  Widget build(BuildContext context) {

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.only(bottom: 5),
          width: MediaQuery.of(context)
              .size
              .width,
          child: Text(
            '$title',
            style: TextStyle(
                color: Color(0xff084A9A),
                fontFamily: "roboto",
                fontSize: 13,
                fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          height: 70,
          width: MediaQuery.of(context)
              .size
              .width,
          padding: EdgeInsets.symmetric(
              horizontal: 0),
          margin: EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
              border: Border.all(
                color: Colors.black45,
              ),
              borderRadius:
              BorderRadius.circular(5.0)),
          child: SearchableDropdown.single(
            items: lookupData,
            onChanged: (value){
              onChangedDropdownList(param,value);
            },
            hint: initialValue != null ? initialValue : 'Pilih salah satu:',
            // value:  lookupData[0],
            isExpanded: true,
            style: TextStyle(
                fontSize: 13,
                color: Colors.black),
          ),
        ),
      ],
    );
  }
}
