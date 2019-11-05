import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SettingItem extends StatelessWidget {

  SettingItem({Key key, this.label, this.labelText, this.keyType=TextInputType.text, this.onChange, this.inputText=''}):super(key: key);
  
  final String label;
  final String labelText;
  final TextInputType keyType;
  final Function onChange;
  final String inputText;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 30),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Text(
              label,
              style: TextStyle(fontSize: 20),
            ),
          ),
          Expanded(
            flex: 5,
            child: TextField(
              style: TextStyle(fontSize: 20),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(10.0),
                labelText: labelText,
                labelStyle: TextStyle(fontSize: 20),
              ),
              onChanged: (value) => onChange(value),
              autofocus: false,
              controller: TextEditingController.fromValue(TextEditingValue(text: inputText)),
            ),
          )
        ],
      ),
    );
  }
}
