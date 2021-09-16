/**
 * @function ab2str
 * @description Converts an ArrayBuffer of UTF-16 chars to a string
 * @param {*} buf 
 */
function ab2str(buf) {
  return String.fromCharCode.apply(null, new Uint16Array(buf));
}

/**
 * @function str2ab
 * @description Converts an string to an ArrayBuffer with UTF-16
 * @param {String} str
 */
function str2ab(str) {
  var buf = new ArrayBuffer(str.length * 2); // 2 bytes for each char
  var bufView = new Uint16Array(buf);
  for (var i = 0, strLen = str.length; i < strLen; i++) {
    bufView[i] = str.charCodeAt(i);
  }
  return buf;
}

/**
 * @function initiateRegistration
 * @param challenge - the challenge string
 * @param userId - the userId string
 * @param options - optional parameters, for example:
 *   {
 *     rp: {
 *       id: string,
 *       name: string,
 *     }
 *     user: {
 *       name: string
 *       displayName: string
 *     },
 *     pubKeyCredParams: [
 *       {alg: -7, type: 'public-key'}
 *     ],
 *     authenticatorSelection: {
 *       authenticatorAttachment: 'cross-platform'
 *     },
 *     timeout: 60000,
 *     attestation: 'direct'
 *   }
 *
 * @returns {Promise<PublicKeyCredential>}
 */
async function initiateRegistration(challenge, userId, options) {
  if (!challenge || !userId) {
    throw new Error('Challenge and userId must be defined')
  }

  if (!options) {
    options = {}
  }

  const credentialCreationOptions = {
    // challenge: str2ab(challenge),
    challenge: Uint8Array.from(challenge, c => c.charCodeAt(0)),
    rp: options.rp || {
      id: 'pineapplepay.moja-lab.live',
      name: 'Pineapple Pay'
    },
    user: {
      id: str2ab(userId),
      name: options.user && options.user.name || 'test@example.com',
      displayName: options.user && options.user.displayName || 'Example User',
    },
    pubKeyCredParams: options.pubKeyCredParams || [
      { alg: -7, type: 'public-key' }
    ],
    timeout: options.timeout || 60000,
    attestation: options.attestation || 'direct'
  }

  // add other values that default to empty:
  if (options.authenticatorSelection) {
    credentialCreationOptions.authenticatorSelection = options.authenticatorSelection
  }

  console.log(`calling window.navigator.credentials.create with options:\n ${JSON.stringify(credentialCreationOptions)}`)

  const credential = await window.navigator.credentials.create(
    {publicKey: credentialCreationOptions}
  )
  
  // convert from ArrayBuffers here since Dart's JS interop has problems with
  // marshalling a NativeByteBuffer
  const rawId = new Uint8Array(credential.rawId)
  const attestationObject = new Uint8Array(credential.response.attestationObject)
  const clientDataJSON = new Uint8Array(credential.response.clientDataJSON)

  return {
    
    id: credential.id,
    rawId,
    response: {
      // we add type here to help Dart to convert to the right type
      type: 'AuthenticatorAttestationResponse',
      attestationObject,
      clientDataJSON,
    }
  }
}


/**
 * @function initiateSigning
 * @param {Int16Array} keyHandleId  - the id of the key created in `window.navigator.credentials.create(...)`
 * @param challenge - the challenge provided by the Relying Party
 * @param rpId - _Optional_ the domain string of the Relying Party
 * 
 * @returns {Promise<PublicKeyCredential>} - promise returned from navigator.crentials.create
 */
async function initiateSigning(keyHandleId, challenge, rpId) {
  if (!keyHandleId || !challenge) {
    throw new Error('keyHandle and challenge must be defined')
  }

  const localKeyHandleId = atob('vwWPva1iiTJIk/c7n9a49spEtJZBqrn4SECerci0b+Ue+6Jv9/DZo3rNX02Lq5PU4N5kGlkEPAkIoZ3499AzWQ==');
  const id = Uint8Array.from(localKeyHandleId, c => c.charCodeAt(0));

  const publicKeyCredentialRequestOptions = {
    challenge: Uint8Array.from(challenge, c => c.charCodeAt(0)),
    allowCredentials: [{
      // id: Uint8Array.from(keyHandleId, c => c),
      // Tmp test out a different approach here...
      id,
      type: 'public-key',
      // TODO: expose this to the client library.
      // transports: ['usb', 'ble', 'nfc'],
    }],
    timeout: 60000,
  }

  if (rpId) {
    publicKeyCredentialRequestOptions.rpId = rpId
  }

  console.log(`calling window.navigator.credentials.get with options:\n ${JSON.stringify(publicKeyCredentialRequestOptions)}`)

  const assertion = await window.navigator.credentials.get({
    publicKey: publicKeyCredentialRequestOptions
  });
  

  console.log('assertion is', JSON.stringify(assertion))

  // convert from ArrayBuffers here since Dart's JS interop has problems with
  // marshalling a NativeByteBuffer
  const rawId = new Uint8Array(assertion.rawId)
  const authenticatorData = new Uint8Array(assertion.response.authenticatorData)
  const clientDataJSON = new Uint8Array(assertion.response.clientDataJSON)
  const signature = new Uint8Array(assertion.response.signature)
  const userHandle = new Uint8Array(assertion.response.userHandle)

  return {
    id: assertion.id,
    rawId,
    response: {
      // we add type here to help Dart to convert to the right type
      type: 'AuthenticatorAssertionResponse',
      authenticatorData,
      clientDataJSON,
      signature,
      userHandle,
    }
  }
 }