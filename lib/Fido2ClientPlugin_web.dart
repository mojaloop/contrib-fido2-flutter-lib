@JS()
library fido2_client_plugin_web;

import 'package:js/js.dart';
import 'package:js/js_util.dart';

import 'dart:async';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html show window;

import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'package:fido2_client/registration_result.dart';
import 'package:fido2_client/signing_result.dart';
import 'authenticator_error.dart';

class AuthenticatorResponse {
  List<ByteData> clientDataJSON;
}

@JS()
@anonymous
class PublicKeyCredential {
  String id;
  // todo: guessing how the types will be marshalled here...
  List<ByteData> rawId;

  // todo: guessing how the types will be marshalled here...
  AuthenticatorResponse response;
}

@JS('initiateRegistration')
// ignore: non_constant_identifier_names
external web_initiateRegistration(
    String challenge, String userId, Object options);
@JS('initiateSigning')
// ignore: non_constant_identifier_names
external web_initiateSigning(String keyHandleId, String challenge, String rpId);

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

  Future<dynamic> initiateRegistration(
      {String challenge, String userId, Map<String, dynamic> options}) async {
    html.window.console.log('Fido2ClientWeb initiateRegistration with ' +
        challenge +
        ' ' +
        userId +
        ' and options: ' +
        options.toString());

    return promiseToFuture(
        web_initiateRegistration(challenge, userId, jsify(options)));
  }

  Future<dynamic> initiateSigning(
      String keyHandleId, String challenge, String rpId) async {
    html.window.console.log('Fido2ClientWeb initiateSigning with ' +
        keyHandleId +
        ' ' +
        challenge +
        ' and rpId: ' +
        rpId);

    return promiseToFuture(web_initiateSigning(keyHandleId, challenge, rpId));
  }
}
