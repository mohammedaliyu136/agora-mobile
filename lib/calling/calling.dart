import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
class CallingScreen extends StatefulWidget {
  String token = '';
  String remoteUID = '';
  String channel = '';
  CallingScreen({Key? key, required String this.token, required String this.remoteUID, required String this.channel}) : super(key: key);

  @override
  _CallingScreenState createState() {
    return _CallingScreenState();
  }
}

class _CallingScreenState extends State<CallingScreen> {
  bool _localUserJoined = false;
  bool _showStats = false;
  int? _remoteUid;
  late RtcEngine engine;
  //RtcStats _stats = RtcStats();
  bool activeVideo = true;
  bool activeAudio = true;


  static const Color COLOR_PURPLE_MID = Color(0xFFA800A8);
  static const Color COLOR_PURPLE_DEEP = Color(0xFF4E0076);

  @override
  void initState() {
    super.initState();
    initForAgora();
  }

  Future<void> initForAgora() async {
    // retrieve permissions
    await [Permission.microphone, Permission.camera].request();

    // create the engine for communicating with agora
    engine = await RtcEngine.create('da2e58ec2ef84ca29aa5d23c7523fb82');

    // set up event handling for the engine
    engine.setEventHandler(RtcEngineEventHandler(
      joinChannelSuccess: (String channel, int uid, int elapsed) {
        print('$uid successfully joined channel: $channel ');
        setState(() {
          _localUserJoined = true;
        });
      },
      userJoined: (int uid, int elapsed) {
        print('remote user $uid joined channel');
        setState(() {
          _remoteUid = uid;
        });
      },
      userOffline: (int uid, UserOfflineReason reason) {
        print('remote user $uid left channel');
        setState(() {
          _remoteUid = null;
        });
      },
    ));
    // enable video
    await engine.enableVideo();

    await engine.joinChannel(widget.token, widget.channel, null, 0);
    //await engine.joinChannel(
      //  '006da2e58ec2ef84ca29aa5d23c7523fb82IAA9KDYhoS1T1fy+GkOO1nNLENkokWz6El7FzP2ywj0nu2rzwB8AAAAAEACIv8JrdKZsYQEAAQAEY2th',
      //  'doctor',
      //  null,
      //  0);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      home: Scaffold(
        body: Stack(
          children: [
            Center(
              child: _renderRemoteVideo(),
            ),
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 28.0, top: 60),
                child: activeVideo?Container(
                  width: 130,
                  height: 170,
                  child: Center(
                    child: _renderLocalPreview(),
                  ),
                ):Container(
                  width: 130,
                  height: 170,
                  color: Colors.white,
                  child: Icon(activeVideo?Icons.videocam:Icons.videocam_off, color: Colors.purple, size: 30,),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 38.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                        onTap: (){
                          engine.destroy();
                          Navigator.pop(context);
                          },
                        child: circleButton(icon: Icon(Icons.call_end, color: Colors.white, size: 30,), backgroundColor: Colors.red)),
                    SizedBox(height: 40,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                            onTap: (){engine.switchCamera();},
                            child: circleButton(icon: Icon(Icons.camera_alt, color: Colors.white, size: 30,), backgroundColor: COLOR_PURPLE_DEEP)),
                        SizedBox(width: 50,),
                        GestureDetector(
                            onTap: (){
                              setState(() {
                                activeVideo=!activeVideo;
                              });
                              if(activeVideo){
                                engine.enableVideo();
                              }else{
                                engine.disableVideo();
                              }
                              },
                            child: circleButton(icon: Icon(activeVideo?Icons.videocam:Icons.videocam_off, color: Colors.white, size: 30,), backgroundColor: COLOR_PURPLE_DEEP)),
                        SizedBox(width: 50,),
                        GestureDetector(
                            onTap: (){
                              setState(() {
                                activeAudio=!activeAudio;
                              });
                              if(activeAudio){
                                engine.enableAudio();
                              }else{
                                engine.disableAudio();
                              }
                            },
                            child: circleButton(icon: Icon(activeAudio?Icons.mic:Icons.mic_off, color: Colors.white, size: 30,), backgroundColor: COLOR_PURPLE_DEEP))
                      ],),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // current user video
  Widget _renderLocalPreview() {
    if (_localUserJoined) {
      return RtcLocalView.SurfaceView();
    } else {
      return Text(
        'Joining Chat',
        textAlign: TextAlign.center,
      );
    }
  }

  // remote user video
  Widget _renderRemoteVideo() {
    if (_remoteUid != null) {
      return RtcRemoteView.SurfaceView(uid: _remoteUid??0);
    } else {
      return Text(
        'Please wait for patient to join',
        textAlign: TextAlign.center,
      );
    }
  }
}

class circleButton extends StatelessWidget {
  circleButton({required this.icon, required this.backgroundColor});
  Icon icon = Icon(Icons.ac_unit);
  Color backgroundColor = Colors.blue;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor, // border color
        shape: BoxShape.circle,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: icon,
      ),
    );
  }
}
