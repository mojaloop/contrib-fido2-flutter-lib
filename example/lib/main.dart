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
  String keyHandle;
  String clientData;
  String attestationObj;
  String signature;
  static final String rpDomain = "webauthn-server-demo.herokuapp.com";
  static final String rpName = "Fido2ClientDemo";
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
      SigningResultListener signingListener = (String keyHandle, String clientData, String authData, String signature, String userHandle) {
        this.signature = signature;
        print('Signature: $signature');
        print('Key Handle: $keyHandle');
        print('User handle: $userHandle');
      };
      fidoClient.addSigningResultListener(signingListener);
      fidoClient.initiateSigningProcess(keyHandle, "transaction12356678", rpDomain);
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
      fidoClient.initiateRegistrationProcess("randomchallenge1231321", "kenkaizeng@gmail.com", "kkzeng", rpDomain, rpName);
    },);
  }
}
