import 'dart:js';

import 'package:fido2_client/authenticator_attestation_response.dart';
import 'package:js/js.dart';

/// External PublicKeyCredential in JS Land
///
@JS()
@anonymous
class PublicKeyCredentialJS {
  List<int> id;
}

/// Native PublicKeyCredential in Dart Land
class PublicKeyCredential {
  List<int> id;

  PublicKeyCredential({this.id});

  static fromJs(PublicKeyCredentialJS credential) {
    return new PublicKeyCredential(id: credential.id);
  }

  static fromJson(Map<String, dynamic> json) {
    return PublicKeyCredential(
      id: json['id'] as List<int>,
    );
  }

  Map<String, dynamic> toJson() => {
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
