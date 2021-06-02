import 'dart:js';

import 'package:fido2_client/authenticator_attestation_response.dart';
import 'package:js/js.dart';

@JS()
@anonymous
class PublicKeyCredential {
  List<int> id;
  // // PublicKeyCredential({this.id, this.response});
  // PublicKeyCredential({this.id});

  // static fromJSObject(dynamic jsObject) {
  //   return new PublicKeyCredential(id: jsObject['id']);
  // }

  // // TODO: should this be an arraybuffer?
  // String id;
  // AuthenticatorAttestationResponse response;

  // @override
  // factory PublicKeyCredential.fromJson(Map<String, dynamic> json) =>
  //     _$PublicKeyCredentialFromJson(json);

  // @override
  // Map<String, dynamic> toJson() => _$PublicKeyCredentialToJson(this);
}
