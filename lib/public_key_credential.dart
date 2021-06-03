import 'dart:js';

import 'package:fido2_client/authenticator_assertion_response.dart';
import 'package:fido2_client/authenticator_attestation_response.dart';
import 'package:js/js.dart';

/// Can either be a AuthenticatorAssertionResponse, or
/// a AuthenticatorAttestationResponse
abstract class AuthenticatorResponse {
  static AuthenticatorResponse fromJs(dynamic someResponseJs) {
    if (someResponseJs.hasProperty('attestationObject')) {
      // This must be a AuthenticatorAttestationResponse
      return AuthenticatorAttestationResponse.fromJs(
          someResponseJs as AuthenticatorAttestationResponseJS);
    }

    if (someResponseJs.hasProperty('authenticatorData')) {
      // This must be a AuthenticatorAssertionResponse
      return AuthenticatorAssertionResponse.fromJs(
          someResponseJs as AuthenticatorAssertionResponseJS);
    }

    throw new Exception(
        'Neither attestationObject nor authenticatorData found on jsobject. Failed to decode AuthenticatorResponse');
  }

  static AuthenticatorResponse fromJson(Map<String, dynamic> json) {
    if (json['attestationObject']) {
      // This must be a AuthenticatorAttestationResponse
      return AuthenticatorAttestationResponse.fromJson(json);
    }
    if (json['authenticatorData']) {
      // This must be a AuthenticatorAssertionResponse
      return AuthenticatorAssertionResponse.fromJson(json);
    }

    throw new Exception(
        'Neither attestationObject nor authenticatorData found on json. Failed to decode JSON');
  }

  Map<String, dynamic> toJson();
}

/// External PublicKeyCredential in JS Land
///
@JS()
@anonymous
class PublicKeyCredentialJS<T> {
  String id;
  List<int> rawId;
  T response;
}

/// Native PublicKeyCredential in Dart Land
class PublicKeyCredential {
  String id;
  List<int> rawId;
  AuthenticatorResponse response;

  PublicKeyCredential({this.id, this.rawId, this.response});

  static fromJs(PublicKeyCredentialJS credential) {
    return new PublicKeyCredential(
        id: credential.id,
        rawId: credential.rawId,
        response: AuthenticatorResponse.fromJs(credential.response));
  }

  static PublicKeyCredential fromJson(Map<String, dynamic> json) {
    return PublicKeyCredential(
        id: (json['id'] as String),
        rawId: (json['rawId'] as List)?.map((i) => i as int)?.toList(),
        response: json['response'] == null
            ? null
            : AuthenticatorResponse.fromJson(
                json['response'] as Map<String, dynamic>));
  }

  Map<String, dynamic> toJson() {
    final val = <String, dynamic>{};

    void writeNotNull(String key, dynamic value) {
      if (value != null) {
        val[key] = value;
      }
    }

    writeNotNull('id', this.id);
    writeNotNull('rawId', this.rawId);
    writeNotNull('response', this.response.toJson());
    return val;
  }

  @override
  String toString() {
    return toJson().toString();
  }
}
