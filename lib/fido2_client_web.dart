import 'dart:async';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html show window;

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
    // final MethodChannel channel = const MethodChannel('fido2_client');

    final MethodChannel channel = MethodChannel(
      'fido2_client',
      const StandardMethodCodec(),
      registrar,
    );

    final pluginInstance = Fido2ClientWeb();
    channel.setMethodCallHandler(pluginInstance.handleMethodCall);
  }

  Future<dynamic> handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'consoleLog':
        final String message = call.arguments['message'];
        _initiateRegistration(message);
        break;
      case 'initiateRegistration':
        final String message = call.arguments['message'];
        _initiateRegistration(message);
        break;
      case 'initiateSigning':
        final String message = call.arguments['message'];
        _initiateSigning(message);
        break;
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

  void consoleLog(String message) {
    html.window.console.log('[TEST] _consoleLog' + message);
  }

  void initiateRegistration(String message) {
    html.window.console.log('[TEST] _initiateRegistration' + message);
  }

  void initiateSigning(String message) {
    html.window.console.log('[TEST] _initiateSigning' + message);
  }
}
