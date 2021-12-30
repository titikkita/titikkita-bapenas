import 'package:flutter/material.dart';

import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:titikkita/state/local_provider.dart';
import 'package:titikkita/util/downloadImage.dart';
import 'package:titikkita/views/widgets/const.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart' as provider;

class InputTextForm {
  static Container buildContainerInputVertical({
    context,
    title,
    validate,
    isPasswordVerified,
    controllerInput,
    controllerInputText,
    obscureText,
    action,
    isDropDownList,
    lookupName,
    initialLookup,
    key,
    keyboardType,
    textController,
  }) {

    return Container(
      margin: EdgeInsets.only(bottom: 10.0),
      padding: EdgeInsets.only(right: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 130,
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
          isDropDownList == true
              ? Container(
                  height: 60,
                  padding: EdgeInsets.only(left: 7, top: 7),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.black38)),
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration.collapsed(hintText: ''),
                    value: initialLookup != null
                        ? initialLookup
                        : provider.Provider.of<LocalProvider>(context)
                            .lookupData['$lookupName'][0],
                    isExpanded: true,
                    style: TextStyle(
                        fontFamily: 'roboto',
                        fontSize: 12,
                        color: Colors.black54),
                    items: provider.Provider.of<LocalProvider>(context)
                        .lookupData['$lookupName']
                        .map<DropdownMenuItem<String>>((value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      action(value);
                    },
                  ),
                )
              : Container(
                  width: 160,
                  height: 60,
                  child: Stack(
                    children: <Widget>[
                      Theme(
                        data: ThemeData(
                            primaryColor: isPasswordVerified == false
                                ? Colors.red[200]
                                : Colors.black26),
                        child: TextFormField(
                          initialValue:
                              title != 'Nama Tetangga (Kepala Keluarga)'
                                  ? controllerInputText != null
                                      ? controllerInputText.toString()
                                      : ''
                                  : null,
                          // enableInteractiveSelection: true,
                          // autofocus: true,
                          // enabled: true,
                          keyboardType: keyboardType != null
                              ? keyboardType
                              : TextInputType.text,
                          controller: title == 'Nama Tetangga (Kepala Keluarga)'
                              ? TextEditingController.fromValue(
                                  TextEditingValue(
                                    text: controllerInputText == null
                                        ? '-'
                                        : '$controllerInputText',
                                    selection: TextSelection.collapsed(
                                        offset: '$controllerInputText'.length),
                                  ),
                                )
                              : null,

                          // controller: textController,
                          // TextEditingController.fromValue(
                          //     controllerInputText != null
                          //         ? TextEditingValue(
                          //             text: '$controllerInputText',
                          //             selection:
                          //             TextSelection.fromPosition(
                          //                 TextPosition(offset:
                          //                     '$controllerInputText'.length)
                          //             ),
                          //       // TextSelection.fromPosition(
                          //       //     TextPosition(offset: controllerInputText.length )
                          //       //         // '$controllerInputText'.length
                          //       // ),
                          //           )
                          //         : TextEditingValue()),
                          obscureText: obscureText,
                          onChanged: (value) {
                            action(key, value);
                          },
                          style: TextStyle(
                              fontFamily: 'roboto',
                              fontSize: 13,
                              color: Colors.black54),
                          decoration: InputDecoration(
                            errorText:
                                validate ? '$title tidak boleh kosong' : null,
                            fillColor: Colors.red,
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  static Container textInputFieldWithBorderAndBGColor(
      {initialValue, keyboardType, hintText, action, attributeName,obscureText}) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white)),
      child: TextFormField(
        initialValue: initialValue == null ? "" : '$initialValue',
        keyboardType: keyboardType == null ? TextInputType.text : keyboardType,
        obscureText: obscureText != null? obscureText : true,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white, width: 2.0),
            borderRadius: BorderRadius.circular(10.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white, width: 2.0),
            borderRadius: BorderRadius.circular(10.0),
          ),
          hintText: hintText != null ? hintText : '',
          border: OutlineInputBorder(),
        ),
        onChanged: (val) {
          action(attributeName, val);
        },
        style: TextStyle(
            fontFamily: 'roboto', fontSize: 12, color: Colors.black54),
      ),
    );
  }

  static Container dropdownInputFieldWithBorderAndBGColor({
    itemList,
    actionDropdown,
    actionValueChange,
    attributeName,
    initialValue,
    keyboardType,
    hintText,
  }) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 60.0,
            height: 55,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white)),
            child: Align(
              alignment: Alignment.center,
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                decoration: InputDecoration.collapsed(hintText: ''),
                value: 'NIK',
                style: TextStyle(
                    fontFamily: 'roboto', fontSize: 12, color: Colors.black54),
                items: itemList.map<DropdownMenuItem<String>>((value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Center(
                      child: Text(
                        value,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  actionDropdown(val);
                },
              ),
            ),
          ),
          SizedBox(
            width: 5.0,
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
              ),
              padding: EdgeInsets.only(left: 10.0),
              child: TextFormField(
                initialValue: initialValue == null ? "" : '$initialValue',
                keyboardType:
                    keyboardType == null ? TextInputType.text : keyboardType,
                obscureText: false,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white, width: 2.0),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white, width: 2.0),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  hintText: hintText != null ? hintText : '',
                  border: OutlineInputBorder(),
                ),
                onChanged: (val) {
                  actionValueChange(attributeName, val);
                },
                style: TextStyle(
                    fontFamily: 'roboto', fontSize: 12, color: Colors.black54),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Column dropdownInputFieldWithBorder(
      {attributeName,
      lookupName,
      title,
      itemList,
      initialValue,
      action}) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          child: Text(
            "$title",
            style: TextStyle(
                color: Color(0xff084A9A),
                fontFamily: "roboto",
                fontSize: 13,
                fontWeight: FontWeight.bold),
          ),
        ),
        Container(
            margin: EdgeInsets.only(top: 5.0),
            padding: EdgeInsets.only(left: 10.0),
            width: 250.0,
            height: 58,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.black38)),
            child: itemList.length != 0
                ? Center(
                    child: DropdownButtonFormField<String>(
                      hint: Text('Pilih salah satu:'),
                      decoration: InputDecoration.collapsed(hintText: ''),
                      value: initialValue,
                      // initialValue == null &&
                      //         itemList[lookupName].length != 0
                      //     ? itemList[lookupName][0]
                      //     : initialValue['_$attributeName$attributeNote'] !=
                      //             null
                      //         ? initialValue['_$attributeName$attributeNote']
                      //         : null,
                      isExpanded: true,
                      style: TextStyle(
                          fontFamily: 'roboto',
                          fontSize: 12,
                          color: Colors.black54),
                      items: itemList[lookupName] != null
                          ? itemList[lookupName]
                              .map<DropdownMenuItem<String>>((item) {
                              return DropdownMenuItem<String>(
                                value: item,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    item,
                                  ),
                                ),
                              );
                            }).toList()
                          : null,
                      onChanged: (val) {
                        action(attributeName, val, lookupName);
                      },
                    ),
                  )
                : Container()),
        SizedBox(
          height: 20,
        ),
      ],
    );
  }

  static Column textWithDrowdownFieldWithBorder(
      {title,
      initialValue,
      key,
      itemList,
      actionDropdown,
      actionValueChange,
      textFieldController,
      validation,
      validationException,
      isValidate,
      context,
      hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        title != null
            ? Container(
                child: Text(
                  "$title",
                  style: TextStyle(
                      color: Color(0xff084A9A),
                      fontFamily: "roboto",
                      fontSize: 15,
                      fontWeight: FontWeight.bold),
                ),
              )
            : Container(),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.only(top: 5.0),
              width: 60.0,
              height: 58,
              decoration: key == 'idLogin'
                  ? BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.white))
                  : BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.black38)),
              child: Align(
                alignment: Alignment.center,
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration.collapsed(hintText: ''),
                  value: itemList != null ? itemList[0] : '',
                  isExpanded: true,
                  style: TextStyle(
                      fontFamily: 'roboto',
                      fontSize: 12,
                      color: Colors.black54),
                  items: itemList != null
                      ? itemList.map<DropdownMenuItem<String>>((value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Center(
                              child: Text(
                                value,
                              ),
                            ),
                          );
                        }).toList()
                      : null,
                  onChanged: (val) {
                    actionDropdown(key, val);
                  },
                ),
              ),
            ),
            SizedBox(width: 10.0),
            Expanded(
              child: Container(
                decoration: key == 'idLogin'
                    ? BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.white),
                      )
                    : BoxDecoration(),
                margin: EdgeInsets.only(top: 5.0),
                child: TextField(
                  keyboardType: TextInputType.number,
                  controller: textFieldController,
                  obscureText: false,
                  decoration: InputDecoration(
                      enabledBorder: key == 'idLogin'
                          ? OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white))
                          : OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.black38, width: 1.0)),
                      focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.blue, width: 2.0)),
                      hintText: '$hint',
                      errorText: isValidate ? validation : validationException,
                      errorStyle: TextStyle(fontSize: 11),
                      fillColor: Colors.red,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: BorderSide(color: Colors.white))),
                  onChanged: (val) {
                    actionValueChange(key, val);
                  },
                  style: TextStyle(
                      fontFamily: 'roboto',
                      fontSize: 15,
                      color: Colors.black54),
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 20,
        ),
      ],
    );
  }

  static Column textInputFieldWithBorder({
    title,
    attributeName,
    keyboardType,
    initialValue,
    action,
    controller,
    validation,
    isValidate = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
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
          child: controller != null
              ? TextFormField(
                  controller: controller,
                  keyboardType:
                      keyboardType == null ? TextInputType.text : keyboardType,
                  obscureText: false,
                  decoration: InputDecoration(
                    errorText: isValidate ? validation : null,
                    errorStyle: TextStyle(fontSize: 11),
                    fillColor: Colors.red,
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (val) {
                    action(attributeName, val);
                  },
                  style: TextStyle(
                      fontFamily: 'roboto',
                      fontSize: 12,
                      color: Colors.black54),
                )
              : TextFormField(
                  initialValue: initialValue == null ? "" : '$initialValue',
                  keyboardType:
                      keyboardType == null ? TextInputType.text : keyboardType,
                  obscureText: false,
                  decoration: InputDecoration(
                    errorText: isValidate ? validation : null,
                    errorStyle: TextStyle(fontSize: 11),
                    fillColor: Colors.red,
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (val) {
                    action(attributeName, val);
                  },
                  style: TextStyle(
                      fontFamily: 'roboto',
                      fontSize: 12,
                      color: Colors.black54),
                ),
        ),
        SizedBox(
          height: 20.0,
        )
      ],
    );
  }

  static Column imageInputField(
      {title,
      initialValue,
      action,
      isImageShow,
      imageData,
      onEditImage,
      imageName,
      context}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
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
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                imageName == null && initialValue == null
                    ? Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: OutlinedButton(
                          onPressed: action,
                          child: Text("  Pilih foto "),
                        ),
                      )
                    : Column(
                        children: [
                          initialValue != null
                              ? Container(
                                  height: 100,
                                  child: Align(
                                      alignment: Alignment.topLeft,
                                      child: Image.file(initialValue)),
                                )
                              : Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    imageName,
                                    style: kTextValueBlack,
                                  )),
                          SizedBox(height: 5.0),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Row(
                              children: [
                                initialValue == null
                                    ? GestureDetector(
                                        onTap: () async {
                                          await downloadImage(
                                              imageData['data'][0]['_id'],
                                              context);
                                        },
                                        child: Text(
                                          '(download)',
                                          style: TextStyle(
                                              color: Colors.blue,
                                              fontSize: 13.0),
                                        ),
                                      )
                                    : Container(),
                                SizedBox(
                                  width: 5.0,
                                ),
                                GestureDetector(
                                  onTap: action,
                                  child: Text(
                                    '(edit)',
                                    style: TextStyle(
                                        color: Colors.blue, fontSize: 13.0),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 20.0,
        )
      ],
    );
  }

  static Column dateTimeInputFieldWithBorder({
    title,
    action,
    initialDateValue,
    key,
    dateFormat,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
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
          child: DateTimeField(
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            format: dateFormat,
            initialValue: initialDateValue != null
                ? DateTime.tryParse(initialDateValue)
                : DateTime.now(),
            onShowPicker: (context, currentValue) {
              return showDatePicker(
                  context: context,
                  firstDate: DateTime(1900),
                  initialDate: currentValue ?? DateTime.now(),
                  lastDate: DateTime(2100));
            },
            onChanged: (value) {
              action(dateFormat.format(value));
            },
            obscureText: false,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),
        ),
        SizedBox(
          height: 20.0,
        )
      ],
    );
  }

  static Container buildContainerInputHorizontal(
      {title,
      lookupName,
      isDropdownList,
      List<String> optionList,
      initialValue,
      onChangedAction,
      key,
      buildContext,
      keyboardType,
      keyboardTypeDate = false}) {
    return Container(
      // padding: EdgeInsets.only(left: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.only(top: 10),
            width: MediaQuery.of(buildContext).size.width / 3,
            child: Text(
              '$title',
              style: TextStyle(
                  color: Color(0xff084A9A),
                  fontFamily: "roboto",
                  fontSize: 11,
                  fontWeight: FontWeight.bold),
            ),
          ),
          keyboardTypeDate
              ? Expanded(
                  child: Container(
                    height: 30,
                    padding: EdgeInsets.all(10),
                    child: DateTimeField(
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      format: DateFormat("yyyy-MM-dd"),
                      initialValue: initialValue != null
                          ? DateTime.tryParse(initialValue)
                          : DateTime.now(),
                      onShowPicker: (context, currentValue) {
                        return showDatePicker(
                            context: context,
                            firstDate: DateTime(1900),
                            initialDate: currentValue ?? DateTime.now(),
                            lastDate: DateTime(2100));
                      },
                      onChanged: (value) {
                        var data = DateFormat("yyyy-MM-dd").format(value);

                        onChangedAction(key, data, lookupName);
                      },
                      obscureText: false,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                )
              : isDropdownList == false
                  ? Expanded(
                      child: Container(
                        padding: EdgeInsets.all(10),
                        child: TextFormField(
                          initialValue:
                              initialValue == null ? '' : '$initialValue',
                          keyboardType: keyboardType != null
                              ? keyboardType
                              : TextInputType.text,
                          // controller: TextEditingController.fromValue(
                          //   TextEditingValue(
                          //     text: initialValue == null ? '' : '$initialValue',
                          //     selection: TextSelection.collapsed(
                          //         offset: '$initialValue'.length),
                          //   ),
                          // ),
                          obscureText: false,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            onChangedAction(key, value, lookupName);
                          },
                          style: kTextValueBlack,
                        ),
                      ),
                    )
                  : provider.Provider.of<LocalProvider>(buildContext)
                              .lookupData['$lookupName'] !=
                          null
                      ? Expanded(
                          child: Container(
                            padding: EdgeInsets.all(10),
                            child: ButtonTheme(
                              // alignedDropdown: true,
                              child: Container(
                                height: 40,
                                padding: EdgeInsets.only(left: 7, top: 7),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: Colors.black38)),
                                child: DropdownButtonFormField(
                                  hint: Text('Pilih salah satu', style: kTextValueBlack,),
                                  decoration:
                                      InputDecoration.collapsed(hintText: ''),
                                  value: initialValue,
                                  items: provider.Provider.of<LocalProvider>(
                                          buildContext)
                                      .lookupData['$lookupName']
                                      .map((item) {
                                    return DropdownMenuItem(
                                      child: Text(
                                        item,
                                        style: kTextValueBlack,
                                      ),
                                      value: item,
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    onChangedAction(key, value, lookupName);
                                  },
                                ),
                              ),
                            ),
                          ),
                        )
                      : Expanded(child: Container()),
        ],
      ),
    );
  }
}
