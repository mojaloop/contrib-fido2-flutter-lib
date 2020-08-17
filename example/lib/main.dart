import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:fido2_client/fido2_client.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: RaisedButton(child: Text('Press here'), onPressed: () {
            var fidoClient = Fido2Client();
            fidoClient.addRegistrationResultListener(() {
              print('Received result of registration');
            });
            fidoClient.initiateRegistrationProcess("randomchallenge1231321", "kkzeng@edu.uwaterloo.ca", "kkzeng");
          },)
        ),
      ),
    );
  }
}
