import 'dart:js';

import 'package:fido2_client/authenticator_attestation_response.dart';
import 'package:js/js.dart';

/// External PublicKeyCredential in JS Land
///
@JS()
@anonymous
class PublicKeyCredentialJS {
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

  // dynamic toJson() => {
  //       'id': id,
  //       // 'name': name,
  //       // 'email': email,
  //       // 'token': token
  //     };

  // @override
  // String toString() {
  //   return toJson().toString();
  // }
}

/// Native PublicKeyCredential in Dart Land
class PublicKeyCredential {
  List<int> id;

  PublicKeyCredential({this.id});

  static fromPublicKeyCredentialJS(PublicKeyCredentialJS credential) {
    return new PublicKeyCredential(id: credential.id);
  }

  dynamic toJson() => {
        'id': id,
        // 'name': name,
        // 'email': email,
        // 'token': token
      };

  @override
  String toString() {
    return toJson().toString();
  }
}
