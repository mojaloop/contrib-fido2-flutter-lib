import 'dart:typed_data';

import 'package:fido2_client/authenticator_response.dart';
import 'package:js/js.dart';

@JS()
@anonymous
class AuthenticatorAttestationResponseJS {
  late Uint8List attestationObject;
  late Uint8List clientDataJSON;
}

class AuthenticatorAttestationResponse extends AuthenticatorResponse {
  final List<int> attestationObject;
  final List<int> clientDataJSON;

  AuthenticatorAttestationResponse({
    required this.clientDataJSON,
    required this.attestationObject,
  });

  static AuthenticatorAttestationResponse fromJs(
      AuthenticatorAttestationResponseJS js) {
    return new AuthenticatorAttestationResponse(
        attestationObject: js.attestationObject,
        clientDataJSON: js.clientDataJSON);
  }

  static AuthenticatorAttestationResponse fromJson(Map<String, dynamic> json) {
    return AuthenticatorAttestationResponse(
      attestationObject:
          (json['attestationObject'] as List).map((i) => i as int).toList(),
      clientDataJSON:
          (json['clientDataJSON'] as List).map((i) => i as int).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    final val = <String, dynamic>{};

    void writeNotNull(String key, dynamic value) {
      if (value != null) {
        val[key] = value;
      }
    }

    writeNotNull('attestationObject', this.attestationObject);
    writeNotNull('clientDataJSON', this.clientDataJSON);
    return val;
  }

  @override
  String toString() {
    return toJson().toString();
  }
}
