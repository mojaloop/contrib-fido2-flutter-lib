
import 'dart:async';

import 'package:flutter/services.dart';

class Fido2Client {
  MethodChannel _channel = const MethodChannel('fido2_client');
  List<Function> _savedRegistrationListeners = [];
  List<Function> _savedSigningListeners = [];

  Fido2Client() {
    _channel.setMethodCallHandler(_handleMethod);
  }

  void addRegistrationResultListener(Function listener) {
    _savedRegistrationListeners.add(listener);
  }

  void addSigningResultListener(Function listener) {
    _savedSigningListeners.add(listener);
  }

  Future<dynamic> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case 'onRegistrationComplete':
        print('Reached');
        // WARNING: Do not add generics like Map<String, dynamic> - this causes breaking changes
        Map m = call.arguments; // how to get this back
        String keyHandleBase64 = m['keyHandleBase64'];
        String clientDataJson = m['clientDataJson'];
        String attestationObject = m['attestationObject'];
        print('Results: $keyHandleBase64, $clientDataJson, $attestationObject');
        for (var callback in _savedRegistrationListeners) callback();
        break;
      case 'onSigningComplete':
        for (var callback in _savedSigningListeners) callback();
        break;
      default:
        throw ('Method not defined');
    }
  }

  Future<void> initiateRegistrationProcess(String challenge, String userId, String username) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('challenge', () => challenge);
    args.putIfAbsent('userId', () => userId);
    args.putIfAbsent('username', () => username);
    await _channel.invokeMethod('initiateRegistrationProcess', args);
  }

  Future<void> initiateSigningProcess(String challenge) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('challenge', () => challenge);
    await _channel.invokeMethod('initiateSigningProcess', args);
  }
}
