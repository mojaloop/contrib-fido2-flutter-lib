import 'dart:typed_data';

import 'package:fido2_client/authenticator_response.dart';
import 'package:js/js.dart';

@JS()
@anonymous
class AuthenticatorAssertionResponseJS {
  late Uint8List authenticatorData;
  late Uint8List clientDataJSON;
  late Uint8List signature;
  late Uint8List userHandle;
}

class AuthenticatorAssertionResponse extends AuthenticatorResponse {
  final List<int> authenticatorData;
  final List<int> clientDataJSON;
  final List<int> signature;
  final List<int> userHandle;

  AuthenticatorAssertionResponse({
    required this.authenticatorData,
    required this.clientDataJSON,
    required this.signature,
    required this.userHandle,
  });

  static AuthenticatorAssertionResponse fromJs(
      AuthenticatorAssertionResponseJS js) {
    return new AuthenticatorAssertionResponse(
      authenticatorData: js.authenticatorData,
      clientDataJSON: js.clientDataJSON,
      signature: js.signature,
      userHandle: js.userHandle,
    );
  }

  static AuthenticatorAssertionResponse fromJson(Map<String, dynamic> json) {
    return AuthenticatorAssertionResponse(
      authenticatorData:
          (json['authenticatorData'] as List).map((i) => i as int).toList(),
      clientDataJSON:
          (json['clientDataJSON'] as List).map((i) => i as int).toList(),
      signature: (json['signature'] as List).map((i) => i as int).toList(),
      userHandle: (json['userHandle'] as List).map((i) => i as int).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    final val = <String, dynamic>{};

    void writeNotNull(String key, dynamic value) {
      if (value != null) {
        val[key] = value;
      }
    }

    writeNotNull('authenticatorData', this.authenticatorData);
    writeNotNull('clientDataJSON', this.clientDataJSON);
    writeNotNull('signature', this.signature);
    writeNotNull('userHandle', this.userHandle);
    return val;
  }

  @override
  String toString() {
    return toJson().toString();
  }
}
