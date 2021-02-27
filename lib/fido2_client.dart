import 'dart:async';
import 'package:fido2_client/registration_result.dart';
import 'package:fido2_client/signing_result.dart';
import 'package:flutter/services.dart';

import 'authenticator_error.dart';

class Fido2Client {
  MethodChannel _channel = const MethodChannel('fido2_client');

  // Used to produce and complete Futures for each process
  Completer<RegistrationResult> _regCompleter = Completer();
  Completer<SigningResult> _signCompleter = Completer();

  Fido2Client() {
    _channel.setMethodCallHandler(_handleMethod);
  }

  Future<dynamic> _handleMethod(MethodCall call) async {
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
        throw ('Method not defined');
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
  Future<RegistrationResult> initiateRegistration(
      String challenge,
      String userId,
      String username,
      String rpDomain,
      String rpName,
      int coseAlgoValue) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('challenge', () => challenge);
    args.putIfAbsent('userId', () => userId);
    args.putIfAbsent('username', () => username);
    args.putIfAbsent('rpDomain', () => rpDomain);
    args.putIfAbsent('rpName', () => rpName);
    args.putIfAbsent('coseAlgoValue', () => coseAlgoValue);
    _channel.invokeMethod('initiateRegistration', args);
    return _regCompleter.future;
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
  Future<SigningResult> initiateSigning(
      String keyHandle, String challenge, String rpDomain) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('challenge', () => challenge);
    args.putIfAbsent('keyHandle', () => keyHandle);
    args.putIfAbsent('rpDomain', () => rpDomain);
    _channel.invokeMethod('initiateSigning', args);
    return _signCompleter.future;
  }

  void _consoleLog(String message) {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('message', () => message);
    _channel.invokeMethod('consoleLog', args);
  }
}
