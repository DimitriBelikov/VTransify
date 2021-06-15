import 'package:flutter/material.dart';

import 'Services.dart' show Languages;

class DropDownList extends StatefulWidget {
  final String displayText;
  DropDownList(this.displayText);

  static String _fromLang = 'Select Language', _toLang = 'Select Language';
  void _updateVariable(String language) {
    if (displayText == 'From Language')
      _fromLang = language;
    else
      _toLang = language;
  }

  static String getVariable(String dropDownType) {
    if (dropDownType == 'From Language')
      return _fromLang;
    else
      return _toLang;
  }

  static void resetVariables() {
    _fromLang = _toLang = 'Select Language';
  }

  @override
  _DropDownListState createState() => _DropDownListState();
}

class _DropDownListState extends State<DropDownList> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text(
            widget.displayText,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, fontFamily: 'NotoSerif', fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 10,
          ),
          DropdownButton(
            items: (Languages.getLanguageList()).map((String language) {
              return DropdownMenuItem(
                value: language,
                child: Text(
                  language,
                  style: TextStyle(fontSize: 14, fontFamily: 'NotoSerif'),
                ),
              );
            }).toList(),
            onChanged: (selectVal) {
              setState(() {
                widget._updateVariable(selectVal.toString());
              });
            },
            hint: Text(
              DropDownList.getVariable(widget.displayText),
              style: TextStyle(color: Colors.black, fontSize: 14, fontFamily: 'NotoSerif'),
            ),
            icon: Icon(Icons.arrow_drop_down_circle_outlined, color: Colors.black),
            iconSize: 20.0,
            dropdownColor: Colors.amber,
            underline: Container(
              height: 1,
              color: Colors.grey.shade900,
            ),
          ),
        ],
      ),
      decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(14.0)),
    );
  }
}
