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

  if (!options) {
    options = {}
  }
  
  const credentialCreationOptions = {
    challenge: str2ab(challenge),
    rp: options.rp || {
      name: 'Example Corp'
    },
    user: {
      id: str2ab(userId),
      name: options.user && options.user.name || 'test@example.com',
      displayName: options.user && options.user.displayName || 'Example User',
    },
    pubKeyCredParams: options.pubKeyCredParams || [
      { alg: -7, type: 'public-key' }
    ],
    authenticatorSelection: options.authenticatorSelection || {
      authenticatorAttachment: 'cross-platform'
    },
    timeout: options.timeout || 60000,
    attestation: options.attestation || 'direct'
  }

  return window.navigator.credentials.create({publicKey: credentialCreationOptions})
}