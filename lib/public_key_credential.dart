import 'package:fido2_client/authenticator_attestation_response.dart';

class PublicKeyCredential {
  PublicKeyCredential({this.id, this.response});

  static fromJSObject(dynamic jsObject) {
    return new PublicKeyCredential(
        id: jsObject['id'], response: jsObject['response']);
  }

  // TODO: should this be an arraybuffer?
  String id;
  AuthenticatorAttestationResponse response;

  // @override
  // factory PublicKeyCredential.fromJson(Map<String, dynamic> json) =>
  //     _$PublicKeyCredentialFromJson(json);

  // @override
  // Map<String, dynamic> toJson() => _$PublicKeyCredentialToJson(this);
}
