
import 'package:flutter/material.dart';

class MapLabel extends PreferredSize {
  final Function toggle;
  final bool isOn;

  MapLabel({this.toggle, this.isOn});

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: SwitchListTile(
        title: Text('Aktifkan label peta', style: TextStyle(fontSize:12,),),
        value: isOn,
        onChanged: (value) {
          toggle(value);
        },
        secondary: Icon(Icons.layers, size: 35),
      ),
    );
  }
}