import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:titikkita/views/widgets/modal.dart';

class MultiSelectBuilder {
  static Column modalCheckBoxList(
      {buildContext, onChangedValue, data, lookupName, attributeName, title}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          child: Text(
            title,
            style: TextStyle(
                color: Color(0xff084A9A),
                fontFamily: "roboto",
                fontSize: 13,
                fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 5,
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black38,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: ListTile(
            onTap: () {
              Modal.showMultiSelect(
                context: buildContext,
                lookupName: lookupName,
                attributeName: attributeName,
                action: onChangedValue,
              );
            },
            title: Text( data[attributeName] == null
                      ? 'Pilih jika ada:'
                      : data[attributeName],
              maxLines: 1,
              style: TextStyle(
                  fontFamily: 'roboto', fontSize: 11, color: Colors.black54),
            ),
            trailing: Icon(
              Icons.arrow_drop_down,
              color: Colors.black54,
            ),
          ),
        ),
        SizedBox(
          height: 20.0,
        ),
      ],
    );
  }
}
