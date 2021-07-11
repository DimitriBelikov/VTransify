import 'dart:convert';
import 'dart:io';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:vtransify/DropDownList.dart';

class ServerServices {
  String _redirectPath = '';
  static const String _errorResponse = 'Error';

  // <---- Upload Audio Function ---->
  Future<Map> _uploadAudio(String audioFilePath) async {
    late int responseCode; // Response Code
    String translatedText = '';

    // Url's and Requests
    var url = Uri.http('192.168.29.175:5000', '/translate-voice');
    int uploadTryCount = 3;

    while(uploadTryCount-- > 0){
      var request = http.MultipartRequest('POST', url);
      //Getting Audio Length
      var audioLength = await File(audioFilePath).length();
      print(audioLength);

      // Creating Multipart file and Adding to Requests
      var multiPartFile = await http.MultipartFile.fromPath(
        'audio_file',
        audioFilePath,
        contentType: MediaType('audio', 'mp3'),
      );

      // Creating Request Components
      request.files.add(multiPartFile);
      Map languageList = Languages.getLanguageMap();
      request.fields['from_lang'] = languageList[DropDownList.getVariable('From Language')];
      request.fields['to_lang'] = languageList[DropDownList.getVariable('To Language')];

      // Sending Request and Handling Errors
      try {
        var response = await request.send();
        if (response.statusCode == 200) {
          responseCode = response.statusCode;
          String serverResponse = await response.stream.bytesToString();
          print('Server Response = ' + serverResponse);

          var decodedServerResponse = jsonDecode(serverResponse);
          if (decodedServerResponse['Response'] == 200) {
            _redirectPath = decodedServerResponse['redirect_path'];
            translatedText = decodedServerResponse['translated_text'];
            break;
          } else
            _redirectPath = '';
        } else {
          responseCode = response.statusCode;
          _redirectPath = '';
        }
      } catch (Exception) {
        responseCode = 404;
        print(Exception.toString());
      }
    }
    DropDownList.resetVariables();

    var result = {'responseCode': responseCode, 'redirectPath': _redirectPath};
    if (translatedText.isNotEmpty) result['translatedText'] = translatedText;
    return result;
  }

  // <---- Download Audio Function ---->
  Future<String> _downloadAudio(String audioPath) async {
    // Declaring Upload Path
    Uri downloadUrl = Uri.http('192.168.29.175:5000', '/output-audio/$audioPath');

    // Downloading File from Upload Path
    try {
      var audioFile = await DefaultCacheManager().downloadFile(downloadUrl.toString());
      return audioFile.file.path;
    } catch (Exception) {
      return 'DownloadError';
    }
  }

  // <---- Upload-Download Function ---->
  Future<dynamic> uploadDownload(String filePath) async {
    Map uploadResponse = await _uploadAudio(filePath);
    if (uploadResponse['redirectPath'] != '' && uploadResponse['responseCode'] == 200) {
      try {
        var downloadAudioPath = await _downloadAudio(uploadResponse['redirectPath']);
        print('Download Response = ' + downloadAudioPath);
        if (downloadAudioPath.substring(downloadAudioPath.lastIndexOf('.')) != '.wav' || downloadAudioPath == 'DownloadError') {
          return _errorResponse;
        } else
          return {'audioPath': downloadAudioPath, 'translatedText': uploadResponse['translatedText']};
      } catch (Exception) {
        print(Exception);
        return _errorResponse;
      }
    } else {
      return _errorResponse;
    }
  }
}

class Languages {
  static String toLang = 'Select Language';
  static Map<String, String> _availableLanguages = {
    'Hindi': 'hi-IN',
    'English': 'en-US',
    'Malayalam': 'ml-IN',
    'Telugu': 'te-IN',
    'Tamil': 'ta-IN'
  };

  static List<String> getLanguageList() {
    return _availableLanguages.keys.toList();
  }

  static Map<String, String> getLanguageMap() {
    return _availableLanguages;
  }
}
