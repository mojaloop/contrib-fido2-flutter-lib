import 'package:fido2_client/authenticator_assertion_response.dart';
import 'package:fido2_client/authenticator_attestation_response.dart';
import 'package:js/js.dart';

// TODO: this feels a little hacky to me.
@JS()
@anonymous
class AuthenticatorResponseJS {
  late String type;
}

/// Can either be a AuthenticatorAssertionResponse, or
/// a AuthenticatorAttestationResponse
abstract class AuthenticatorResponse {
  static AuthenticatorResponse fromJs(AuthenticatorResponseJS someResponseJs) {
    if (someResponseJs.type == "AuthenticatorAttestationResponse") {
      // This must be a AuthenticatorAttestationResponse
      return AuthenticatorAttestationResponse.fromJs(
          someResponseJs as AuthenticatorAttestationResponseJS);
    }

    if (someResponseJs.type == "AuthenticatorAssertionResponse") {
      // This must be a AuthenticatorAssertionResponse
      return AuthenticatorAssertionResponse.fromJs(
          someResponseJs as AuthenticatorAssertionResponseJS);
    }

    throw new Exception(
        'Neither attestationObject nor authenticatorData found on jsobject. Failed to decode AuthenticatorResponse');
  }

  static AuthenticatorResponse fromJson(Map<String, dynamic> json) {
    if (json['attestationObject'] != null) {
      // This must be a AuthenticatorAttestationResponse
      return AuthenticatorAttestationResponse.fromJson(json);
    }
    if (json['authenticatorData'] != null) {
      // This must be a AuthenticatorAssertionResponse
      return AuthenticatorAssertionResponse.fromJson(json);
    }

    throw new Exception(
        'Neither attestationObject nor authenticatorData found on json. Failed to decode JSON');
  }

  Map<String, dynamic> toJson();
}
