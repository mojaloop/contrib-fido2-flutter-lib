import 'dart:async';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html show window;
import 'dart:js' as js;

import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'package:fido2_client/registration_result.dart';
import 'package:fido2_client/signing_result.dart';
import 'authenticator_error.dart';

/// A web implementation of the Fido2Client plugin.
class Fido2ClientWeb {
  // Used to produce and complete Futures for each process
  Completer<RegistrationResult> _regCompleter = Completer();
  Completer<SigningResult> _signCompleter = Completer();

  static void registerWith(Registrar registrar) {
    final MethodChannel channel = MethodChannel(
      'Fido2ClientWeb',
      const StandardMethodCodec(),
      registrar,
    );

    final pluginInstance = Fido2ClientWeb();
    channel.setMethodCallHandler(pluginInstance.handleMethodCall);
  }

  // Hmm I don't think we need these now
  Future<dynamic> handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onRegistrationComplete':
        // WARNING: Do not add generics like Map<String, dynamic> - this causes breaking changes
        Map args = call.arguments;
        String keyHandleBase64 = args['keyHandle'];
        String clientDataJson = args['clientDataJson'];
        String attestationObj = args['attestationObject'];
        RegistrationResult res =
            RegistrationResult(keyHandleBase64, clientDataJson, attestationObj);
        _regCompleter.complete(res);
        break;
      case 'onSigningComplete':
        // WARNING: Do not add generics like Map<String, dynamic> - this causes breaking changes
        Map args = call.arguments;
        String keyHandleBase64 = args['keyHandle'];
        String clientDataJson = args['clientDataJson'];
        String authenticatorDataBase64 = args['authData'];
        String signatureBase64 = args['signature'];
        String userHandle = args['userHandle'];
        SigningResult res = SigningResult(keyHandleBase64, clientDataJson,
            authenticatorDataBase64, signatureBase64, userHandle);
        _signCompleter.complete(res);
        break;
      case 'onRegAuthError':
        Map args = call.arguments;
        String errorName = args['errorName'];
        String errorMsg = args['errorMsg'];
        _signCompleter.completeError(AuthenticatorError(errorName, errorMsg));
        break;
      case 'onSignAuthError':
        Map args = call.arguments;
        String errorName = args['errorName'];
        String errorMsg = args['errorMsg'];
        _signCompleter.completeError(AuthenticatorError(errorName, errorMsg));
        break;
      case 'getPlatformVersion':
        return getPlatformVersion();
        break;
      default:
        throw PlatformException(
          code: 'Unimplemented',
          details: 'hello for web doesn\'t implement \'${call.method}\'',
        );
    }
  }

  /// Implement the methods below:

  /// Returns a [String] containing the version of the platform.
  Future<String> getPlatformVersion() {
    final version = html.window.navigator.userAgent;
    return Future.value(version);
  }

  Future<dynamic> initiateRegistration({String challenge, String userId}) {
    final credentialCreationOptions = {
      'publicKey': {
        // TODO - make an array buffer!
        'challenge': challenge,
        "rp": {
          "name": "Test Mojapay",
          // "id": "pineapplepay.moja-lab.live",
        },
        'user': {
          'id': userId,
          'name': 'test@example.com',
          'displayName': 'PineapplePay user'
        },
        'pubKeyCredParams': [
          // {'alg': -7, 'type': 'public-key'}
          {'alg': -7, 'type': 'public-key'}
        ],
        'authenticatorSelection': {'authenticatorAttachment': 'cross-platform'},
        'timeout': 60000,
        'attestation': 'direct'
      }
    };
    print(credentialCreationOptions);
    html.window.console.log(
        'Fido2ClientWeb initiateRegistration with ' + challenge + ' ' + userId);
    // html.window.console.log(credentialCreationOptions);
    final jsCredentialCreationOptions =
        new js.JsObject.jsify(credentialCreationOptions);
    // final credential = js.context['navigator.credentials']
    //     .callMethod('create', [jsCredentialCreationOptions]);
    // html.window.console.log(jsCredentialCreationOptions);
    js.context['console'].callMethod('log', [jsCredentialCreationOptions]);

    final credential =
        html.window.navigator.credentials.create(credentialCreationOptions);
    return Future.value(credential);
  }

  void initiateSigning(String message) {
    html.window.console.log('[TEST] _initiateSigning ' + message);
  }
}
