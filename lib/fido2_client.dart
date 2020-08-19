
import 'dart:async';
import 'package:flutter/services.dart';

typedef RegistrationResultListener = Function(String keyHandle, String clientData, String attestationObj);
typedef SigningResultListener = Function(String keyHandle, String clientData, String authData, String signature, String userHandle);

class AuthenticatorError implements Exception {
  String errorName;
  String errMsg;
  AuthenticatorError(this.errorName, this.errMsg);
}

class Fido2Client {

  MethodChannel _channel = const MethodChannel('fido2_client');
  List<RegistrationResultListener> _savedRegistrationListeners = [];
  List<Function> _savedSigningListeners = [];

  Fido2Client() {
    _channel.setMethodCallHandler(_handleMethod);
  }

  void addRegistrationResultListener(RegistrationResultListener l) {
    _savedRegistrationListeners.add(l);
  }

  void addSigningResultListener(SigningResultListener l) {
    _savedSigningListeners.add(l);
  }

  Future<dynamic> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case 'onRegistrationComplete':
        // WARNING: Do not add generics like Map<String, dynamic> - this causes breaking changes
        Map args = call.arguments;
        String keyHandleBase64 = args['keyHandle'];
        String clientDataJson = args['clientDataJson'];
        String attestationObj = args['attestationObject'];
        for (var listener in _savedRegistrationListeners) listener(keyHandleBase64, clientDataJson, attestationObj);
        break;
      case 'onSigningComplete':
        // WARNING: Do not add generics like Map<String, dynamic> - this causes breaking changes
        Map args = call.arguments;
        String keyHandleBase64 = args['keyHandle'];
        String clientDataJson = args['clientDataJson'];
        String authenticatorDataBase64 = args['authData'];
        String signatureBase64 = args['signature'];
        String userHandle = args['userHandle'];
        for (var listener in _savedSigningListeners) listener(keyHandleBase64, clientDataJson, authenticatorDataBase64, signatureBase64, userHandle);
        break;
      case 'onAuthError':
        Map args = call.arguments;
        String errorName = args['errorName'];
        String errorMsg = args['errorMsg'];
        throw AuthenticatorError(errorName, errorMsg);
        break;
      default:
        throw ('Method not defined');
    }
  }

  Future<void> initiateRegistrationProcess(String challenge, String userId, String username, String rpDomain, String rpName) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('challenge', () => challenge);
    args.putIfAbsent('userId', () => userId);
    args.putIfAbsent('username', () => username);
    args.putIfAbsent('rpDomain', () => rpDomain);
    args.putIfAbsent('rpName', () => rpName);
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
