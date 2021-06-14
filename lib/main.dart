// <----- Importing Necessary Modules ----->
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show DeviceOrientation, SystemChrome, SystemUiOverlayStyle;
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:permission_handler/permission_handler.dart';

// <----- Importing UserDefined Modules ----->
import 'Alerts.dart';
import 'Audioservices.dart';

// <---- File Constants ---->
final serverServices = ServerServices();
enum AudioState { fresh_record, recording, uploadDownload, stop, play }
const kFrontColor = Color(0xFF26A69A);
const kBackgroundColor = Color(0xFF00695C);
String hindiText = 'मुझे मुझे आशा है कि यह ऐप अच्छा काम करता है';

// <---- Main Function ---->
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown])
      .then((_) => runApp(VTransify()));
}

// <---- Stateless Base Platform ---->
class VTransify extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VTransify',
      home: SafeArea(
        child: Scaffold(
          backgroundColor: kFrontColor,
          appBar: AppBar(
            title: Text('VTransify'),
            centerTitle: true,
            backgroundColor: kBackgroundColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(12.0), bottomRight: Radius.circular(12.0))),
          ),
          body: HomeScreen(),
        ),
      ),
    );
  }
}

// <---- Stateful App HomeScreen ---->
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _playBackReady = false, _mRecorderInit = false, _mPlayerInit = false;
  late String? _audioFilePath, _translatedText;
  AudioState audioState = AudioState.fresh_record;
  FlutterSoundPlayer _mPlayer = FlutterSoundPlayer();
  FlutterSoundRecorder _mRecorder = FlutterSoundRecorder();

  // <---- Overriding Init State ---->
  @override
  void initState() {
    openAudioSources().then((value) {
      setState(() {
        _mRecorderInit = true;
        _mPlayerInit = true;
      });
    });
    super.initState();
  }

  // <---- Overriding Dispose State ---->
  @override
  void dispose() {
    _mPlayer.closeAudioSession();
    _mPlayerInit = false;

    _mRecorder.closeAudioSession();
    _mRecorderInit = false;
    print('Screen Disposed');
    super.dispose();
  }

  // <---- Open Audio Sources for Playing and Recording ---->
  Future openAudioSources() async {
    var status = await Permission.microphone.request();
    print(status.isGranted);
    if (status != PermissionStatus.granted) {
      print('Permission Granted');
    }

    print(_mRecorderInit);
    print(_mPlayerInit);

    if (!_mPlayerInit) {
      await _mPlayer.openAudioSession();
    }

    if (!_mRecorderInit) {
      await _mRecorder.openAudioSession();
    }
  }

  // <---------------- RECORDER FUNCTIONS ---------------->

  // <---- Start Recording Function ---->
  void startRecording() async {
    await _mRecorder.startRecorder(toFile: 'sample_voice.mp3', numChannels: 1, bitRate: 320000, sampleRate: 17000);
    setState(() {
      _playBackReady = true;
      audioState = AudioState.recording;
    });
  }

  // <---- Stop Recording Function ---->
  void stopRecording() async {
    String? filepath = await _mRecorder.stopRecorder();
    print('Recording Path : ' + filepath.toString());

    // Update State for UploadDownload
    setState(() {
      _audioFilePath = filepath;
      audioState = AudioState.uploadDownload;
    });

    dynamic serverResponse = await serverServices.uploadDownload(_audioFilePath!);
    if (serverResponse != 'Error') {
      setState(() {
        _audioFilePath = serverResponse['audioPath'];
        _translatedText = serverResponse['translatedText'];
        audioState = AudioState.play;
      });
    } else {
      setState(() {
        audioState = AudioState.fresh_record;
        _playBackReady = false;
        _audioFilePath = '';
        Alerts.showAlertDialog(context);
      });
    }
  }

  // <---- Determine Recording State Function ---->
  void getRecordFunction() async {
    if (!_mRecorderInit) return;
    return _mRecorder.isStopped ? startRecording() : stopRecording();
  }

  // <---------------- PLAYER FUNCTIONS ---------------->

  // <---- Start Player Function ---->
  void startPlayer() async {
    if (_mPlayerInit && (_mPlayer.isStopped || _mPlayer.isPaused) && _playBackReady) {
      if (_mPlayer.isPaused)
        _mPlayer.resumePlayer();
      else {
        await _mPlayer.startPlayer(
            fromURI: _audioFilePath,
            sampleRate: 320000,
            whenFinished: () {
              setState(() {
                audioState = AudioState.stop;
              });
            });
      }
      setState(() {
        audioState = AudioState.play;
      });
    }
  }

  // <---- Stop/Pause Player Function ---->
  void stopPlayer() async {
    await _mPlayer.pausePlayer();
    setState(() {
      audioState = AudioState.stop;
    });
  }

  // <---- Determine Player Function ---->
  void getPlayerFunction() {
    if (!_mPlayerInit || !_playBackReady || !_mRecorder.isStopped) return;
    (_mPlayer.isStopped || _mPlayer.isPaused) ? startPlayer() : stopPlayer();
  }

  // <---------------- MAIN-APP Function ---------------->
  // <---- Determine Recorder-Player Functions ---->
  getPlayRecordFunction() {
    (_playBackReady && _mRecorder.isStopped) ? getPlayerFunction() : getRecordFunction();
  }

  // <---- Build Function ---->
  @override
  Widget build(BuildContext context) {
    return audioState == AudioState.uploadDownload
        ? SpinKitWave(color: Colors.white)
        : Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      padding: EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: handleAudioColour(),
                      ),
                      child: RawMaterialButton(
                        fillColor: Colors.white,
                        shape: CircleBorder(),
                        padding: EdgeInsets.all(30),
                        onPressed: () => getPlayRecordFunction(),
                        child: getIcon(audioState),
                      ),
                    ),
                    SizedBox(width: 20),
                    if (audioState == AudioState.play || audioState == AudioState.stop)
                      Container(
                        padding: EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: kBackgroundColor,
                        ),
                        child: RawMaterialButton(
                          fillColor: Colors.white,
                          shape: CircleBorder(),
                          padding: EdgeInsets.all(30),
                          onPressed: () => setState(() {
                            audioState = AudioState.fresh_record;
                            if (!_mPlayer.isStopped) _mPlayer.stopPlayer();
                            _playBackReady = false;
                          }),
                          child: Icon(Icons.replay, size: 50),
                        ),
                      ),
                  ],
                ),
                if (audioState == AudioState.play || audioState == AudioState.stop)
                  Container(
                    margin: EdgeInsets.all(25.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: Colors.orange,
                    ),
                    width: 400.0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          child: Text(
                            'TRANSLATION',
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'NotoSerif',
                              color: Colors.white,
                            ),
                          ),
                          padding: EdgeInsets.all(10.0),
                        ),
                        Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Text(
                            _translatedText!,
                            style: TextStyle(
                              fontSize: 19,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
              ],
            ),
          );
  }

  Color handleAudioColour() {
    if (audioState == AudioState.recording) {
      return Colors.red.shade800;
    } else if (audioState == AudioState.stop) {
      return Colors.green.shade600;
    } else {
      return kBackgroundColor;
    }
  }

  Icon getIcon(AudioState state) {
    switch (state) {
      case AudioState.play:
        return Icon(Icons.play_arrow, size: 50);
      case AudioState.stop:
        return Icon(Icons.stop, size: 50);
      case AudioState.recording:
        return Icon(Icons.mic, color: Colors.redAccent, size: 50);
      default:
        return Icon(Icons.mic, size: 50);
    }
  }
}
