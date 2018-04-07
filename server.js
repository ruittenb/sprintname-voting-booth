/**
 * http://blog.pixelastic.com/2017/10/28/authenticating-to-firebase-from-a-server/
 * http://blog.pixelastic.com/2017/11/01/firebase-authentication-with-auth0/
 *
 * https://github.com/auth0/node-jsonwebtoken
 */

let jwt = require('jsonwebtoken');
let firebase = require('firebase');
let firebaseAdmin = require('firebase-admin');
let lock = require('auth0-lock');

/**
 * Validate the JWT token.
 * Also validate that this is an @proforto.nl account.
 */

// TODO get token from POST request

let publicKey = fs.readFileSync('./dist/public-auth0.key');
let userData;
try {
    userData = jwt.verify(token, publicKey);
    if (!userData)
        throw new Error('Not allowed: JWT token could not be validated');
    }
    if (!userData.email_verified) {
        throw new Error('Not allowed: email address not verified');
    }
    if (!userData.email.match(/@proforto\.nl$/)) {
        throw new Error('Not allowed: email address does not end in @proforto.nl');
    }
}
catch (e) {
    // TODO return 403 with Error message
}

/**
 * use the service account key to authenticate with the firebase server
 */
let serviceAccountKey = require('./dist/serviceAccountKey.json');

firebaseAdmin.initializeApp({
  credential: firebaseAdmin.credential.cert(serviceAccountKey),
  databaseURL: 'https://sprintname-voting-booth.firebaseio.com'
});

firebaseAdmin.auth().createCustomToken(userData.email).then(function (firebaseToken) {
    console.log(firebaseToken);
    // TODO return 200 with firebaseToken
});


//
//    "gmailUsers": {
//      "$uid": {
//        ".write": "auth.profile.email_verified == true && auth.profile.email.matches(/.*@proforto.nl$/)"
//      }
//    }
//
//
