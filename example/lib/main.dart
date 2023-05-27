import 'dart:convert';
import 'dart:typed_data';

import 'package:fido2_client/fido2_client.dart';
import 'package:fido2_client/registration_result.dart';
import 'package:fido2_client/signing_result.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String keyHandle; // Should be saved in shared pref
  static const String regChallenge =
      "randomchallenge1231321"; // Should come from server
  static const String signChallenge =
      "transaction12356678"; // Should come from server

  String displayText = "Please sign or register to display auth results";
  static final String rpDomain = "webauthn-server-demo.herokuapp.com";
  static final String rpName = "Fido2Client Demo";
  Fido2Client fidoClient = Fido2Client();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(displayText),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  buildRegButton(),
                  buildSignButton(),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDisplayText() {
    return Text(displayText);
  }

  Widget buildRegButton() {
    return ElevatedButton(
      child: Text('FIDO Register'),
      onPressed: () async {
        Map<String, dynamic> options = {
          'username': 'kkzeng',
          'rpDomain': rpDomain,
          'rpName': rpName,
          'coseAlgoValue': "-7"
        };
        RegistrationResult res = await fidoClient.initiateRegistration(
            regChallenge, "kenkaizeng@gmail.com", options);
        setState(() {
          this.keyHandle = res.keyHandle;

          // Decoding the clientData to be JSON so that it is human readable
          Uint8List decodedClientData = base64Url.decode(res.clientData);
          String jsonFormat = utf8.decode(decodedClientData);

          displayText =
              'Challenge: \n$regChallenge\n\nKey handle: \n$keyHandle\n\nClient data: \n$jsonFormat\n\nAttestation obj: \n${res.attestationObj}';
        });
        print(displayText);
      },
    );
  }

  Widget buildSignButton() {
    return ElevatedButton(
      child: Text('FIDO Sign'),
      onPressed: keyHandle == null
          ? null
          : () async {
              SigningResult res = await fidoClient.initiateSigning(
                  keyHandle, signChallenge,
                  rpDomain: rpDomain);
              setState(() {
                // Decoding the clientData to be JSON so that it is human readable
                Uint8List decodedClientData = base64Url.decode(res.clientData);
                String jsonFormat = utf8.decode(decodedClientData);

                displayText =
                    'Challenge: \n$signChallenge\n\nKey handle: \n$keyHandle\n\nClient data: \n$jsonFormat\n\nauthData: \n${res.authData}\n\nSignature: \n${res.signature}';
              });
              print(displayText);
            },
    );
  }
}
