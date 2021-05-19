import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';

enum AudioState { fresh_record, recording, stop, play }

const veryDarkBlue = Color(0xff172133);
const kindaDarkBlue = Color(0xff202641);

void main() {
  runApp(VTransify());
}

class VTransify extends StatefulWidget {
  @override
  _VTransifyState createState() => _VTransifyState();
}

class _VTransifyState extends State<VTransify> {
  FlutterSoundPlayer _mPlayer = FlutterSoundPlayer();
  FlutterSoundRecorder _mRecorder = FlutterSoundRecorder();
  bool _mRecorderInit = false, _mPlayerInit = false, _playbackready = false;

  AudioState audioState = AudioState.fresh_record;

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

  Future openAudioSources() async {
    var status = await Permission.microphone.request();
    if (status == PermissionStatus.granted) {
      print('Permission Granted');
    }
    await _mPlayer.openAudioSession();
    _mPlayerInit = true;

    await _mRecorder.openAudioSession();
    _mRecorderInit = true;
  }

  @override
  void dispose() {
    _mPlayer.closeAudioSession();
    _mPlayerInit = false;

    _mRecorder.closeAudioSession();
    _mRecorderInit = false;
    print('Screen Disposed');
    super.dispose();
  }

  void startRecording() async {
    await _mRecorder.startRecorder(toFile: 'sample_voice.aac');
    setState(() {
      _playbackready = true;
      audioState = AudioState.recording;
    });
  }

  void stopRecording() async {
    await _mRecorder.stopRecorder();
    setState(() {
      audioState = AudioState.play;
    });
  }

  void getRecordFunction() {
    if (!_mRecorderInit) return;
    print(_mRecorder.isStopped);
    return _mRecorder.isStopped ? startRecording() : stopRecording();
  }

  void startPlayer() async {
    if (_mPlayerInit &&
        (_mPlayer.isStopped || _mPlayer.isPaused) &&
        _playbackready) {
      if (_mPlayer.isPaused)
        _mPlayer.resumePlayer();
      else {
        await _mPlayer.startPlayer(
            fromURI: 'sample_voice.aac',
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

  void stopPlayer() async {
    await _mPlayer.pausePlayer();
    setState(() {
      audioState = AudioState.stop;
    });
  }

  void getPlayerFunction() {
    if (!_mPlayerInit || !_playbackready || !_mRecorder.isStopped) return;
    (_mPlayer.isStopped || _mPlayer.isPaused) ? startPlayer() : stopPlayer();
  }

  // void handleAudioState(AudioState state) {
  //   setState(() {
  //     if (audioState == AudioState.fresh_record) {
  //       // Starts recording
  //       audioState = AudioState.recording;
  //       // Finished recording
  //     } else if (audioState == AudioState.recording) {
  //       audioState = AudioState.play;
  //       // Play recorded audio
  //     } else if (audioState == AudioState.play) {
  //       audioState = AudioState.stop;
  //       // Stop recorded audio
  //     } else if (audioState == AudioState.stop) {
  //       audioState = AudioState.play;
  //     }
  //   });
  // }

  getPlayRecordFunction() {
    (_playbackready && _mRecorder.isStopped)
        ? getPlayerFunction()
        : getRecordFunction();
  }

  Color handleAudioColour() {
    if (audioState == AudioState.recording) {
      return Colors.deepOrangeAccent.shade700.withOpacity(0.5);
    } else if (audioState == AudioState.stop) {
      return Colors.green.shade900;
    } else {
      return kindaDarkBlue;
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vtransify',
      home: Scaffold(
        backgroundColor: veryDarkBlue,
        body: Center(
          child: Row(
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
              if (audioState == AudioState.play ||
                  audioState == AudioState.stop)
                Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: kindaDarkBlue,
                  ),
                  child: RawMaterialButton(
                    fillColor: Colors.white,
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(30),
                    onPressed: () => setState(() {
                      audioState = AudioState.fresh_record;
                      if (!_mPlayer.isStopped) _mPlayer.stopPlayer();
                      _playbackready = false;
                    }),
                    child: Icon(Icons.replay, size: 50),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
