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

  static PublicKeyCredential fromJson(Map<String, dynamic> json) {
    return PublicKeyCredential(
      id: json['id'] as List<int>,
      // TODO
    );
  }

  Map<String, dynamic> toJson() {
    final val = <String, dynamic>{};

    void writeNotNull(String key, dynamic value) {
      if (value != null) {
        val[key] = value;
      }
    }

    writeNotNull('id', this.id);
    return val;
  }

  //   'id': id,
  //   // 'name': name,
  //   // 'email': email,
  //   // 'token': token
  // };

  @override
  String toString() {
    return toJson().toString();
  }
}
