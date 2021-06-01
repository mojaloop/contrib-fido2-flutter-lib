class AuthenticatorAttestationResponse {
  AuthenticatorAttestationResponse({
    this.clientDataJSON,
    this.attestationObject,
    this.publicKey,
    this.publicKeyAlgorithm,
  });

  dynamic clientDataJSON;
  String attestationObject;
  String publicKey;
  String publicKeyAlgorithm;

  // @override
  // factory AuthenticatorAttestationResponse.fromJson(
  //         Map<String, dynamic> json) =>
  //     _$AuthenticatorAttestationResponseFromJson(json);

  // @override
  // Map<String, dynamic> toJson() =>
  //     _$AuthenticatorAttestationResponseToJson(this);
}
