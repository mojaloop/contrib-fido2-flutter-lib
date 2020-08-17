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
  String keyHandle;
  String clientData;
  String attestationObj;
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
            RegistrationResultListener listener = (String keyHandle, String clientData, String attestationObj) {
              this.keyHandle = keyHandle;
              this.clientData = clientData;
              this.attestationObj = attestationObj;
            };
            fidoClient.addRegistrationResultListener(listener);
            fidoClient.initiateRegistrationProcess("randomchallenge1231321", "kkzeng@edu.uwaterloo.ca", "kkzeng");
            print('Key handle: $keyHandle');
            print('Client data: $clientData');
            print('Attestation obj: $attestationObj');
          },)
        ),
      ),
    );
  }
}
