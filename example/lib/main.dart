import 'package:flutter/material.dart';
import 'package:fido2_client/fido2_client.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String keyHandle; // Should be saved in shared pref
  static const String regChallenge = "randomchallenge1231321"; // Should come from server
  static const String signChallenge = "transaction12356678"; // Should come from server

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
    return RaisedButton(child: Text('FIDO Register'), onPressed: () {
      RegistrationResultListener regListener = (String keyHandle, String clientData, String attestationObj) {
        setState(() {
          this.keyHandle = keyHandle;
          displayText = 'Challenge: \n$regChallenge\n\nKey handle: \n$keyHandle\n\nClient data: \n$clientData\n\nAttestation obj: \n$attestationObj';
        });
        print(displayText);
      };
      fidoClient.addRegistrationResultListener(regListener);
      fidoClient.initiateRegistrationProcess(regChallenge, "kenkaizeng@gmail.com", "kkzeng", rpDomain, rpName);
    },);
  }

  Widget buildSignButton() {
    return RaisedButton(child: Text('FIDO Sign'), onPressed:  keyHandle == null ? null : () {
      SigningResultListener signingListener = (String keyHandle, String clientData, String authData, String signature, String userHandle) {
        setState(() {
          displayText = 'Challenge: \n$signChallenge\n\nKey handle: \n$keyHandle\n\nClient data: \n$clientData\n\nauthData: \n$authData\n\nSignature: \n$signature';
        });
        print(displayText);
      };
      fidoClient.addSigningResultListener(signingListener);
      fidoClient.initiateSigningProcess(keyHandle, signChallenge, rpDomain);
    },);
  }
}
