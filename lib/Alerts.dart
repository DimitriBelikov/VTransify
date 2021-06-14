import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class Alerts {
  static void showAlertDialog(BuildContext context) {
    Alert(
        title: 'Error Occurred !!!',
        context: context,
        content: Text(
          'An Error occurred while communicating with the Server. Please check your internet connection and Try Again or there was a problem with the Audio File.'
          ' If still not resolved, please contact the Owner',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
          textAlign: TextAlign.center,
        ),
        type: AlertType.error,
        style: AlertStyle(
          titleStyle: TextStyle(fontSize: 24.0),
          alertBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
        ),
        buttons: [
          DialogButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'Try Again',
              style: TextStyle(fontSize: 22),
            ),
          ),
        ]).show();
  }
}
