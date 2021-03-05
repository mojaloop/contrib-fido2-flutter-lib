# Fido2Client Plugin for Flutter

## Introduction

Fido2Client is a Flutter plugin that allows you to use your Flutter app as an authenticator in the Fido2 process. With this plugin, your Flutter app can create and use public key based credentials to authenticate users.

The Fido2Client supports 2 main operations:

(1) **Registration**

Registration is done once per authenticator per account. It is performed when linking a credential to a user.

(2) **Signing**

Signing is performed to verify a user's identity.

For more information, refer to this [section](#how-does-fido2-verify-a-users-identity-brief-overview)

## Warning

Note: The Fido2 client only supports Android currently!

Since Apple has only joined the FIDO alliance in Feb 2020, it is not expected that an iOS Fido2 client will be ready like the ones available for Android.

However, we are open to contributors interested in working on the iOS side.

## Dependencies

The plugin uses the native Android library: Fido2ApiClient, specifically `com.google.android.gms:play-services-fido:18.1.0`.

## How does FIDO2 verify a user's identity? (Brief overview)

The whole FIDO2 process of authenticating a user is based on public key cryptography. When the user is in the registration phase, the Fido2 client generates a key pair (1 public key and 1 private key) under the hood. The private key pair is stored somewhere secure on device while the public key pair is sent to the server and is associated to a particular user.

The next time that the server wants to authenticate a user, they send a challenge - usually a randomly generated string with a fixed, predetermined length. The FIDO2 client uses the private key it previously stored to sign this string. From this process, a signature is produced. Using the previously registered public key, the server can check whether or not the signature produced was a result of using the associated private key to sign the particular challenge. The identity of the user is assumed from their ownership of the private key.

For more information, refer to these [external resources](#external-resources-for-fido)

## How to use

There are 2 functions that are exposed to the user, each corresponding to a phase of the FIDO2 process:

(1) `initiateRegistration`

(2) `initiateSigning`

It is fairly straightforward to understand the purpose of these functions. Calling these functions brings up a flow that guides the user through the processes of FIDO credential registration and signing respectively and the functions return futures of generated authenticator results which can be sent to the server for registration and authentication purposes.

However, the inputs and outputs of these functions may be confusing. 

Here is an explanation of the inputs and outputs of the above functions:

### `initiateRegistration`

Inputs:

| variable        | type   | description                                                                  |
|-----------------|--------|------------------------------------------------------------------------------|
| challenge       | String | The string given by the server                                               |
| userId          | String | The identifier of the user you are registering a credential for              |
| username        | String | The name of the user you are registering a credential for                    |
| rpDomain        | String | The domain of the Relying Party*                                             |
| rpName          | String | The name of the Relying Party                                                |
| coseAlgoValue** | int    | The unique COSE identifier for the algorithm to be used by the authenticator |

\* A Relying Party refers to the party on whose behalf the authentication ceremony is being performed. 
You can view the formal definition [here](https://www.w3.org/TR/webauthn/#webauthn-relying-party)
For example, if you were using this for a mobile app with a web server backend, then the web server would be the Relying Party.

\*\* See the supported algorithms: [EC2 algorithms](https://developers.google.com/android/reference/com/google/android/gms/fido/fido2/api/common/EC2Algorithm) and [RSA algorithms](https://developers.google.com/android/reference/com/google/android/gms/fido/fido2/api/common/RSAAlgorithm)

These 2 links will give you the supported descriptions of the supported algorithms e.g. 'ECDSA w/ SHA-256'.

You can search for the algorithm identifier using the following links: [COSE registry](https://www.iana.org/assignments/cose/cose.xhtml#algorithms) and [WebAuthn registry](https://www.w3.org/TR/webauthn/#sctn-cose-alg-reg).

You will find that 'ECDSA w/ SHA-256' has a COSE identifier of -7.

Outputs:

The output will be in the form of a `RegistrationResult` model object with the following fields:

| variable       | type   | encoding                | description                                                                                             |
|----------------|--------|-------------------------|---------------------------------------------------------------------------------------------------------|
| keyHandle      | String | Base64URL               | A string identifier for the credential generated.                                                       |
| clientData     | String | Base64URL               | [WebAuthn spec](https://www.w3.org/TR/webauthn/#dom-authenticatorresponse-clientdatajson)               |
| attestationObj | String | CBOR and then Base64URL | [WebAuthn spec](https://www.w3.org/TR/webauthn/#dom-authenticatorattestationresponse-attestationobject) |

This corresponds to the `AuthenticatorAttestationResponse` in the WebAuthn spec.

### `initiateSigning`

Inputs:

| variable  | type   | description                                                                                                                                   |
|-----------|--------|-----------------------------------------------------------------------------------------------------------------------------------------------|
| keyHandle | String | The string identifier for the credential you are authenticating.  This should be the same as the output of the initial `initiateRegistration` |
| challenge | String | The challenge string from the server to be signed by the FIDO client.                                                                         |
| rpDomain  | String | The domain of the Relying Party. Same as the variable in `initiateRegistration`                                                               |

Outputs:

The output will be in the form of a `SigningResult` model object with the following fields:

| variable   | type   | encoding  | description                                                                                                                                                                                            |
|------------|--------|-----------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| keyHandle  | String | Base64URL | The string identifier for the credential                                                                                                                                                               |
| clientData | String | Base64URL | [WebAuthn spec](https://www.w3.org/TR/webauthn/#dom-authenticatorresponse-clientdatajson)                                                                                                              |
| authData   | String | Base64URL | [WebAuthn spec](https://www.w3.org/TR/webauthn/#authenticator-data)                                                                                                                                    |
| signature  | String | Base64URL | The signature is to be sent to the server for verification of identity. <br/> It provides proof that the authenticator possesses the private key associated with the public key previously registered. |
| userHandle | String | Base64URL | An opaque identifier for the user being authenticated.                                                                                                                                                 |

This corresponds to the `AuthenticatorAssertionResponse` in the WebAuthn spec.

### Hosting assetlinks.json (VERY IMPORTANT!)

This step is very important! Without this, the plugin will not work. By hosting the file that these instructions will teach you, your server is making a public statement about sharing credentials with your Flutter app.

1. Generate your app's SHA256 fingerprint by following the steps [here](https://developers.google.com/android/guides/client-auth)
2. In the JSON file below, replace "app sha256 fingerprint" with your app's SHA256 fingerprint.

`assetlinks.json`

```
[
  {
    "relation" : [
      "delegate_permission/common.handle_all_urls",
      "delegate_permission/common.get_login_creds"
    ],
    "target" : {
      "namespace" : "android_app",
      "package_name" : "com.example.android",
      "sha256_cert_fingerprints" : [
         "app sha256 fingerprint"
      ]
    }
  }
]
```

3. Host the JSON file at https://example.com/.well-known/assetlinks.json, replacing example with your domain.

### Getting everything to work

1. While the user is logged in via traditional login processes, when the user needs to register a FIDO credential, request registration options from the server - these will be provided as inputs to `initiateRegistration`.
2. Prompt the user to begin the registration phase by calling `initiateRegistration` with the registration options retrieved in the previous step.
3. Format the `RegistrationResult` into something that your web server understands and send the results - the server will save the keyHandle(credential identifier) and public key and associate it to the user.
4. The next time the user needs to verify their identity (e.g. for login), request signing options from the server - these will be provided as inputs to `initiateSigning`.
5. Prompt the user to authenticate themselves by calling `initiateSigning` with the signing options retrieved in the previous step.
5. Once again, format the `SigningResult` into something that your web server understands and send the results for verification. If the server deems that this is indeed a valid signature produced using the private key of the key pair previously registered, then the user has been authenticated.

If you want to see a working example, feel free to reference the [example fido flow](#example-fido-flow).
If there are any issues, you may refer to the section on [common issues](#common-issues).

## Example FIDO Flow

If you wish to see a working example, you can take a look at this [repo](https://github.com/kkzeng/fido2-client-example-flutter)

## Common Issues

Issue: I am getting a white screen when I call `initiateRegistration` or `initiateSigning`. How do I fix this?

Solution: Please check that you have hosted the assetlinks file correctly. Make sure you follow the steps for that correctly.

## External resources for FIDO

[W3 WebAuthn Spec](https://www.w3.org/TR/webauthn/#webauthn-relying-party)

[Mozilla Web Authentication Docs](https://developer.mozilla.org/en-US/docs/Web/API/Web_Authentication_API)

[Fido2ApiClient API Reference](https://developers.google.com/android/reference/com/google/android/gms/fido/fido2/Fido2ApiClient)

[Introduction to WebAuthn API](https://medium.com/@herrjemand/introduction-to-webauthn-api-5fd1fb46c285)



## Notes - Web Fido Tests:

```js
function ab2str(buf) {
  return String.fromCharCode.apply(null, new Uint16Array(buf));
}
function str2ab(str) {
  var buf = new ArrayBuffer(str.length*2); // 2 bytes for each char
  var bufView = new Uint16Array(buf);
  for (var i=0, strLen=str.length; i < strLen; i++) {
    bufView[i] = str.charCodeAt(i);
  }
  return buf;
}

/**
 * @function initiateRegistration
 * @param challenge - the challenge string
 * @param userId - the userId string
 * @param options - optional parameters, for example:

    {
      rp: {
        id: string,
        name: string,
      }
      user: {
        name: string
        displayName: string
      },
      pubKeyCredParams: [
        {alg: -7, type: 'public-key'}
      ],
      authenticatorSelection: {
        authenticatorAttachment: 'cross-platform'
      },
      timeout: 60000,
      attestation: 'direct'
    }
 *
 * @returns {Promise<unknown>} - promise returned from navigator.crentials.create
 */
function initiateRegistration(challenge, userId, options) {
  if (!challenge || !userId) {
    throw new Error('Challenge and userId must be defined')
  }
  const credentialCreationOptions = {
    rp: options.rp || {
      name: 'Example Corp'
    },
    user: {
      id: str2ab(userId),
      name: options.user && options.user.name || 'test@example.com'
      displayName: options.user && options.user.displayName || 'test@example.com' 
    },
    pubKeyCredParams: options.pubKeyCredParams || [
      {alg: -7, type: 'public-key'}
    ],
    authenticatorSelection: options.authenticatorSelection || {
      authenticatorAttachment: 'cross-platform'
    },
    timeout: options.timeout || 60000,
    attestation: options.attestation || 'direct'
  }

  return window.navigator.credentials.create(credentialCreationOptions)
}


const challenge = str2ab('random challenge string')
const credentialCreationOptions = {
  publicKey: {
    challenge: challenge,
    rp: {
      // todo: we NEED to set this to the domain of the PISP
      // id: "login.example.com",
      name: "Example Corp",
    },
    user: {
      id: str2ab('some user id'),
      name: 'test@example.com',
      displayName: 'PineapplePay user'
    },
    pubKeyCredParams: [
      {alg: -7, type: 'public-key'}
    ],
    authenticatorSelection: {
      authenticatorAttachment: 'cross-platform'
    },
    timeout: 60000,
    attestation: 'direct'
  }
};

window.navigator.credentials.create(credentialCreationOptions)

```