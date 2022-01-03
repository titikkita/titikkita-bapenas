import 'package:flutter/material.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';

class InputDropdownHalfWidth extends StatelessWidget {
  const InputDropdownHalfWidth(
      {this.title,
      this.lookupData,
      this.onChangedDropdownList,
      this.param,
      this.initialValue});

  final title;
  final lookupData;
  final onChangedDropdownList;
  final param;
  final initialValue;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.only(top: 10),
          width: MediaQuery.of(context).size.width / 2.8,
          child: Text(
            '$title',
            style: TextStyle(
                color: Color(0xff084A9A),
                fontFamily: "roboto",
                fontSize: 11,
                fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          height: 80,
          width: MediaQuery.of(context).size.width / 1.7,
          // padding: EdgeInsets.symmetric(horizontal: 0),
          decoration: BoxDecoration(
              border: Border.all(
                color: Colors.black45,
              ),
              borderRadius: BorderRadius.circular(5.0)),
          child: SearchableDropdown.single(
            items: lookupData,
            onChanged: (value) {
              onChangedDropdownList(param, value);
            },
            hint: initialValue != null ? '$initialValue' : 'Pilih salah satu:',
            value: lookupData[0],
            isExpanded: true,
            style: TextStyle(fontSize: 11, color: Colors.black),
          ),
        ),
      ],
    );
  }
}
