import 'dart:core';

import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

const String serverError =
    'An Error occurred while communicating with the Server. Please check your internet connection and Try Again or there was a problem with the Audio File.'
    ' If still not resolved, please contact the Owner';
const String chooseLanguageError = 'Please Select to and from Languages.';

class Alerts {
  static void showAlertDialog(BuildContext context, String alertType) {
    Alert(
        title: 'Error Occurred !!!',
        context: context,
        content: Text(
          alertType,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
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
              style: TextStyle(fontSize: 19),
            ),
          ),
        ]).show();
  }
}
