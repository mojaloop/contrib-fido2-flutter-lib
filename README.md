# Fido2 client

## Introduction

Fido2Client is a Flutter plugin that allows you to use your Flutter app as an authenticator in the Fido2 process. with this plugin, your Flutter app can create and use public key based credentials to authenticate users.

The Fido2Client supports 2 main operations:

(1) Registration

Registration is done once per authenticator per account. It is performed when linking a credential to a user.

(2) Signing

Signing is performed to verify a user's identity.

For more information, refer to section: [insert link to section]()

## Warning

Note: The Fido2 client only supports Android currently!

Since Apple has only joined the FIDO alliance in Feb 2020, it is not expected that an iOS Fido2 client will be ready like the ones available for Android.

However, we are open to contributors interested in working on the iOS side.

## Dependencies

The plugin uses the native Android library: Fido2ApiClient, specifically `com.google.android.gms:play-services-fido:18.1.0`.

## How does FIDO2 verify a user's identity? (Brief overview)

The whole FIDO2 process of authenticating a user is based on public key cryptography. When the user is in the registration phase, the Fido2 client generates a key pair (1 public key and 1 private key) under the hood. The private key pair is stored somewhere secure on device while the public key pair is sent to the server and is associated to a particular user.

The next time that the server wants to authenticate a user, they send a challenge - usually a randomly generated string with a fixed, predetermined length. The FIDO2 client uses the private key it previously stored to sign this string. From this process, a signature is produced. Using the previously registered public key, the server can check whether or not the signature produced was a result of using the associated private key to sign the particular challenge. The identity of the user is assumed from their ownership of the private key.

For more information: [insert link to external resource]()

## Quick Start Guide

There are 2 functions that are exposed to the user, each corresponding to a phase of the FIDO2 process:

(1) `initiateRegistration`

(2) `initiateSigning`

It is fairly straightforward to understand the purpose of these functions - you call each of these functions whenever you want to register a new credential or you want to authenticate a user via signing.

What is not so straightforward are the parameters.

For registration:

String challenge - the
String userId - The identifier of the user you are trying to register a credential for.
String username - The username of the user you are trying to register a credential for.
String rpDomain - The domain of the Relying Party
String rpName - The name of the Relying Party.
int coseAlgoValue - The COSE identifier for the algorithm that you are trying to use.

List of possible coseAlgoValues:

For signing:

String keyHandle - The identifier for the credential you generated previously. Should be the same 
String challenge
String rpDomain

## Hosting assetlinks.json file

## Example code from my repo