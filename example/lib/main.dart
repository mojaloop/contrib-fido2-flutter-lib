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
  String signature;
  Fido2Client fidoClient = Fido2Client();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child:
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
            buildRegButton(),
            buildSignButton(),
          ],)
        ),
      ),
    );
  }

  Widget buildSignButton() {
    return RaisedButton(child: Text('FIDO Sign'), onPressed: () {
      SigningResultListener signingListener = (String keyHandle, String clientData, String authData, String signature) {
        this.signature = signature;
        print('Signature: $signature');
        print('Keyhandle: $keyHandle');
      };
      fidoClient.addSigningResultListener(signingListener);
      fidoClient.initiateSigningProcess(keyHandle, "transaction12356678");
    },);
  }

  Widget buildRegButton() {
    return RaisedButton(child: Text('FIDO Register'), onPressed: () {
      RegistrationResultListener regListener = (String keyHandle, String clientData, String attestationObj) {
        this.keyHandle = keyHandle;
        this.clientData = clientData;
        this.attestationObj = attestationObj;
        print('Key handle: $keyHandle');
        print('Client data: $clientData');
        print('Attestation obj: $attestationObj');
      };
      fidoClient.addRegistrationResultListener(regListener);
      fidoClient.initiateRegistrationProcess("randomchallenge1231321", "kkzeng@edu.uwaterloo.ca", "kkzeng");

    },);
  }
}
