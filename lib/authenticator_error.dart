class AuthenticatorError implements Exception {
  String errorName;
  String errMsg;
  AuthenticatorError(this.errorName, this.errMsg);
}