class SigningResult {
  SigningResult(this.keyHandle, this.clientData, this.authData, this.signature, this.userHandle);

  final String keyHandle;
  final String clientData;
  final String authData;
  final String signature;
  final String userHandle;
}