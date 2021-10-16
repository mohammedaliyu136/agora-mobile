import 'package:flutter/material.dart';

import 'calling/calling.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: startcall(),
    );
  }
}

class startcall extends StatelessWidget {
  startcall({Key? key}) : super(key: key);
  String channel = 'doctor';
  String token = '006da2e58ec2ef84ca29aa5d23c7523fb82IAA9KDYhoS1T1fy+GkOO1nNLENkokWz6El7FzP2ywj0nu2rzwB8AAAAAEACIv8JrdKZsYQEAAQAEY2th';


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(),
      body: Column(children: [
        TextButton(
            onPressed: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CallingScreen(channel: channel, token: token, remoteUID: '',)),
              );
            },
            child: Text('CALL'))
      ],),
    );
  }
}
