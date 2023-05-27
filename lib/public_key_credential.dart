import 'package:fido2_client/authenticator_response.dart';
import 'package:js/js.dart';

/// External PublicKeyCredential in JS Land
///
@JS()
@anonymous
class PublicKeyCredentialJS {
  late String id;
  late List<int> rawId;
  late AuthenticatorResponseJS response;
}

/// Native PublicKeyCredential in Dart Land
class PublicKeyCredential {
  final String id;
  final List<int> rawId;
  final AuthenticatorResponse response;

  PublicKeyCredential(
      {required this.id, required this.rawId, required this.response});

  static fromJs(PublicKeyCredentialJS credential) {
    return new PublicKeyCredential(
        id: credential.id,
        rawId: credential.rawId,
        response: AuthenticatorResponse.fromJs(credential.response));
  }

  static PublicKeyCredential fromJson(Map<String, dynamic> json) {
    return PublicKeyCredential(
        id: (json['id'] as String),
        rawId: (json['rawId'] as List).map((i) => i as int).toList(),
        response: AuthenticatorResponse.fromJson(
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
