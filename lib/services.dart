import 'dart:convert';
import 'dart:io';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart' as http;

class ServerServices {
  String _redirectPath = '';
  static const String _errorResponse = 'Error';

  // <---- Upload Audio Function ---->
  Future<Map> _uploadAudio(String audioFilePath) async {
    int responseCode; // Response Code

    // Url's and Requests
    var url = Uri.http('192.168.225.60:5000', '/translate-voice');
    var request = http.MultipartRequest('POST', url);

    //Getting Audio Length
    var audioLength = await File(audioFilePath).length();
    print(audioLength);

    // Creating Multipart file and Adding to Requests
    var multiPartFile = await http.MultipartFile.fromPath(
      'audio_file',
      audioFilePath,
    );
    request.files.add(multiPartFile);

    try {
      var response = await request.send();

      if (response.statusCode == 200) {
        responseCode = response.statusCode;
        String serverResponse = await response.stream.bytesToString();
        print('Server Response = ' + serverResponse);

        var decodedServerResponse = jsonDecode(serverResponse);
        if (decodedServerResponse['Response'] == 200)
          _redirectPath = jsonDecode(serverResponse)['redirect_path'];
        else
          _redirectPath = '';
      } else {
        responseCode = response.statusCode;
        _redirectPath = '';
      }
    } catch (Exception) {
      responseCode = 404;
      print(Exception.toString());
    }

    var result = {'responseCode': responseCode, 'redirectPath': _redirectPath};
    return result;
  }

  Future<String> _downloadAudio(String audioPath) async {
    // Declaring Upload Path
    Uri downloadUrl = Uri.http('192.168.225.60:5000', '/output-audio/$audioPath');

    // Downloading File from Upload Path
    try {
      var audioFile = await DefaultCacheManager().downloadFile(downloadUrl.toString());
      return audioFile.file.path;
    } catch (Exception) {
      return 'DownloadError';
    }
  }

  Future<String> uploadDownload(String filePath) async {
    Map uploadResponse = await _uploadAudio(filePath);
    if (uploadResponse['redirectPath'] != '' && uploadResponse['responseCode'] == 200) {
      try {
        var downloadResponse = await _downloadAudio(uploadResponse['redirectPath']);
        print('Download Response = ' + downloadResponse);
        if (downloadResponse.substring(downloadResponse.lastIndexOf('.')) != '.mp3' || downloadResponse == 'DownloadError') {
          return _errorResponse;
        } else
          return downloadResponse;
      } catch (Exception) {
        print(Exception);
        return _errorResponse;
      }
    } else {
      return _errorResponse;
    }
  }
}
