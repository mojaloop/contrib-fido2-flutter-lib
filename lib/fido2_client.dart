
import 'dart:async';

import 'package:flutter/services.dart';

class Fido2Client {
  static const MethodChannel _channel =
      const MethodChannel('fido2_client');

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
        for (var callback in _savedRegistrationListeners) callback();
        break;
      case 'onSigningComplete':
        for (var callback in _savedSigningListeners) callback();
        break;
      default:
        throw ('Method not defined');
    }
  }

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<void> showToast(String msg) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('msg', () => msg);
    await _channel.invokeMethod('showToast', args);
  }

  static Future<void> initiateRegistrationProcess(String challenge, String userId, String username) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('challenge', () => challenge);
    args.putIfAbsent('userId', () => userId);
    args.putIfAbsent('username', () => username);
    await _channel.invokeMethod('initiateRegistrationProcess', args);
  }

  static Future<void> initiateSigningProcess(String challenge) async {
    Map<String, dynamic> args = <String, dynamic>{};
    args.putIfAbsent('challenge', () => challenge);
    await _channel.invokeMethod('initiateSigningProcess', args);
  }
}
