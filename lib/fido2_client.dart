
import 'dart:async';
import 'package:fido2_client/registration_result.dart';
import 'package:fido2_client/signing_result.dart';
import 'package:flutter/services.dart';

import 'authenticator_error.dart';

class Fido2Client {

  MethodChannel _channel = const MethodChannel('fido2_client');
  Function(RegistrationResult) _regCompletionCallback;
  Function(SigningResult) _signingCompletionCallback;

  Fido2Client() {
    _channel.setMethodCallHandler(_handleMethod);
  }

  void registerRegistrationCompletionCallback(Function(RegistrationResult) callback) => _regCompletionCallback = callback;

  void registerSigningCompletionHandler(Function(SigningResult) callback) => _signingCompletionCallback = callback;

  Future<dynamic> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case 'onRegistrationComplete':
        // WARNING: Do not add generics like Map<String, dynamic> - this causes breaking changes
        Map args = call.arguments;
        String keyHandleBase64 = args['keyHandle'];
        String clientDataJson = args['clientDataJson'];
        String attestationObj = args['attestationObject'];
        RegistrationResult res = RegistrationResult(keyHandleBase64, clientDataJson, attestationObj)
        _regCompletionCallback(res);
        break;
      case 'onSigningComplete':
        // WARNING: Do not add generics like Map<String, dynamic> - this causes breaking changes
        Map args = call.arguments;
        String keyHandleBase64 = args['keyHandle'];
        String clientDataJson = args['clientDataJson'];
        String authenticatorDataBase64 = args['authData'];
        String signatureBase64 = args['signature'];
        String userHandle = args['userHandle'];
        SigningResult res = SigningResult(keyHandleBase64, clientDataJson, authenticatorDataBase64, signatureBase64, userHandle);
        _signingCompletionCallback(res);
        break;
      case 'onRegAuthError':
        Map args = call.arguments;
        String errorName = args['errorName'];
        String errorMsg = args['errorMsg'];
        throw(AuthenticatorError(errorName, errorMsg));
        break;
      case 'onSignAuthError':
        Map args = call.arguments;
        String errorName = args['errorName'];
        String errorMsg = args['errorMsg'];
        throw(AuthenticatorError(errorName, errorMsg));
        break;
      default:
        throw ('Method not defined');
    }
  }

  Future<void> initiateRegistrationProcess(String challenge, String userId, String username, String rpDomain, String rpName, int coseAlgoValue) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('challenge', () => challenge);
    args.putIfAbsent('userId', () => userId);
    args.putIfAbsent('username', () => username);
    args.putIfAbsent('rpDomain', () => rpDomain);
    args.putIfAbsent('rpName', () => rpName);
    args.putIfAbsent('coseAlgoValue', () => coseAlgoValue);
    await _channel.invokeMethod('initiateRegistrationProcess', args);
  }

  Future<void> initiateSigningProcess(String keyHandle, String challenge, String rpDomain) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('challenge', () => challenge);
    args.putIfAbsent('keyHandle', () => keyHandle);
    args.putIfAbsent('rpDomain', () => rpDomain);
    await _channel.invokeMethod('initiateSigningProcess', args);
  }
}
