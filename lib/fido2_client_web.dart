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
external Future<List<int>> web_initiateRegistration(
    String challenge, String userId, Object options);
@JS('initiateSigning')
// ignore: non_constant_identifier_names
external web_initiateSigning(
    List<dynamic> keyHandleId, String challenge, String rpId);

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

  // TODO (LD): does the web version need these?
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
      default:
        throw PlatformException(
          code: 'Unimplemented',
          details: 'hello for web doesn\'t implement \'${call.method}\'',
        );
    }
  }

  /// Begins the FIDO registration process.
  ///
  /// This launches the FIDO client which authenticates the user associated with [userId]
  /// and [username] via lock screen (which may have biometric or PIN methods) or
  /// even external authenticators.
  ///
  /// The [rpDomain] and [rpName] describe the Relying Party's
  /// domain and name.
  /// See: https://www.w3.org/TR/webauthn/#webauthn-relying-party
  ///
  /// e.g.
  /// rpDomain: webauthn-demo-server.com
  /// rpName: Webauthn Demo Server
  ///
  /// Note that the RP domain must be hosting an assetlinks.json file.
  /// See: https://developers.google.com/identity/fido/android/native-apps#interoperability_with_your_website
  ///
  /// The [challenge] is used validation purposes by the WebAuthn server.
  ///
  /// [coseAlgoValue] is the COSE identifier for the cryptographic algorithm that will be
  /// used by the authenticator for keypair generation.
  /// See: https://www.iana.org/assignments/cose/cose.xhtml
  ///
  /// The method returns a [RegistrationResult] future that is completed after the
  /// user completes the authentication process.
  Future<List<int>> initiateRegistration(
      String challenge, String userId, Map<String, dynamic> options) async {
    // TODO: remove
    // html.window.console.log('Fido2ClientWeb initiateRegistration with ' +
    //     challenge +
    //     ' ' +
    //     userId +
    //     ' and options: ' +
    //     options.toString());

    return promiseToFuture(
        web_initiateRegistration(challenge, userId, jsify(options)));
  }

  /// Begins the FIDO signing process.
  ///
  /// This launches the FIDO client which authenticates the user whose credentials
  /// were previously registered and are associated with the credential identifier
  /// [keyHandle]. This [keyHandle] should match the one produced in the registration
  /// phase for the same user ([RegistrationResult.keyHandle]).
  ///
  ///
  /// The [challenge] is signed by the private key that the FIDO client created
  /// during registration. The [SigningResult.signature] produced will be used
  /// for user verification purposes.
  ///
  /// The [rpDomain] describes the Relying Party's domain.
  /// e.g. rpDomain: webauthn-demo-server.com
  /// See: https://www.w3.org/TR/webauthn/#webauthn-relying-party
  ///
  /// Note that the RP domain must be hosting an assetlinks.json file.
  /// See: https://developers.google.com/identity/fido/android/native-apps#interoperability_with_your_website
  ///
  /// The method returns a [SigningResult] future that is completed after the
  /// user completes the authentication process.
  Future<dynamic> initiateSigning(
      List<dynamic> keyHandle, String challenge, String rpDomain) async {
    return promiseToFuture(web_initiateSigning(keyHandle, challenge, rpDomain));
  }
}
