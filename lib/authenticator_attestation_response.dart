import 'package:js/js.dart';

@JS()
@anonymous
class AuthenticatorAttestationResponseJS {
  List<dynamic> attestationObject;
  List<dynamic> clientDataJSON;
}

class AuthenticatorAttestationResponse {
  List<dynamic> attestationObject;
  List<dynamic> clientDataJSON;

  AuthenticatorAttestationResponse({
    this.clientDataJSON,
    this.attestationObject,
  });

  static fromJs(AuthenticatorAttestationResponseJS js) {
    return new AuthenticatorAttestationResponse(
        attestationObject: js.attestationObject,
        clientDataJSON: js.clientDataJSON);
  }

  static AuthenticatorAttestationResponse fromJson(Map<String, dynamic> json) {
    return AuthenticatorAttestationResponse(
        attestationObject: (json['attestationObject'] as List),
        clientDataJSON: (json['clientDataJSON'] as List));
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
