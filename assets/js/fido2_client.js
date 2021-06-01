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
 * @returns {Promise<Array<int>>} - the credentialId
 */
async function initiateRegistration(challenge, userId, options) {
  if (!challenge || !userId) {
    throw new Error('Challenge and userId must be defined')
  }

  if (!options) {
    options = {}
  }

  const credentialCreationOptions = {
    challenge: str2ab(challenge),
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

  // Note:
  // The following would ideally be done inside of the Dart code
  // but I'm not good enough at dart and navigating the Dart/JS
  // interop tools to do this well. 
  //
  // For now, we'll just work on returning the credentialId and 
  // attestation object so we can get the demos working.
  // A more complete library would be much smarter about this
  const credential = await window.navigator.credentials.create(
    {publicKey: credentialCreationOptions}
  )

  console.log(`credential is:\n ${JSON.stringify(credential)}`)

  const utf8Decoder = new TextDecoder('utf-8');
  const decodedClientData = utf8Decoder.decode(
    credential.response.clientDataJSON)

  // parse the string as an object
  const clientDataObj = JSON.parse(decodedClientData);
  console.log(clientDataObj)

  const decodedAttestationObj = CBOR.decode(
    credential.response.attestationObject)

  console.log('decoded Object: ' + decodedAttestationObj)

  const { authData } = decodedAttestationObj
  // get the length of the credential ID
  const dataView = new DataView(
    new ArrayBuffer(2));
  const idLenBytes = authData.slice(53, 55);
  idLenBytes.forEach(
    (value, index) => dataView.setUint8(
      index, value));
  const credentialIdLength = dataView.getUint16();

  // get the credential ID
  const credentialId = authData.slice(
    55, 55 + credentialIdLength);

  return {
    id: credentialId,
      // TODO: also return the attestation object 
    response: null
  }
}


/**
 * @function initiateSigning
 * @param {Int16Array} keyHandleId  - the id of the key created in `window.navigator.credentials.create(...)`
 * @param challenge - the challenge provided by the Relying Party
 * @param rpId - _Optional_ the domain string of the Relying Party
 * 
 * @returns {Promise<unknown>} - promise returned from navigator.crentials.create
 */
function initiateSigning(keyHandleId, challenge, rpId) {
  if (!keyHandleId || !challenge) {
    throw new Error('keyHandle and challenge must be defined')
  }

  const publicKeyCredentialRequestOptions = {
    challenge: Uint8Array.from(challenge, c => c.charCodeAt(0)),
    allowCredentials: [{
      id: Uint8Array.from(keyHandleId, c => c),
      // id: keyHandleId,
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

  return navigator.credentials.get({
    publicKey: publicKeyCredentialRequestOptions
  });
 }