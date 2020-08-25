import 'package:flutter/material.dart';
import 'package:fido2_client/fido2_client.dart';
import 'package:fido2_client/registration_result.dart';
import 'package:fido2_client/signing_result.dart';

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
    return RaisedButton(child: Text('FIDO Register'), onPressed: () async {
      print("before await");
      RegistrationResult res = await fidoClient.initiateRegistrationProcess(regChallenge, "kenkaizeng@gmail.com", "kkzeng", rpDomain, rpName, -7);
      print("after await");
      setState(() {
        this.keyHandle = res.keyHandle;
        displayText = 'Challenge: \n$regChallenge\n\nKey handle: \n$keyHandle\n\nClient data: \n${res.clientData}\n\nAttestation obj: \n${res.attestationObj}';
      });
      print(displayText);
    },);
  }

  Widget buildSignButton() {
    return RaisedButton(child: Text('FIDO Sign'), onPressed:  keyHandle == null ? null : () async {
      SigningResult res = await fidoClient.initiateSigningProcess(keyHandle, signChallenge, rpDomain);
      setState(() {
        displayText = 'Challenge: \n$signChallenge\n\nKey handle: \n$keyHandle\n\nClient data: \n${res.clientData}\n\nauthData: \n${res.authData}\n\nSignature: \n${res.signature}';
      });
      print(displayText);
    },);
  }
}
