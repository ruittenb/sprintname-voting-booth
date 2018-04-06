/**
 * http://blog.pixelastic.com/2017/10/28/authenticating-to-firebase-from-a-server/
 * http://blog.pixelastic.com/2017/11/01/firebase-authentication-with-auth0/
 */

let firebase = require('firebase');
let firebaseAdmin = require('firebase-admin');

/**
 * use the service account key to authenticate with the firebase server
 */
let serviceAccountConfig = require('./dist/serviceAccountKey.json');

firebaseAdmin.initializeApp({
  credential: firebaseAdmin.credential.cert(serviceAccountConfig),
  databaseURL: 'https://sprintname-voting-booth.firebaseio.com'
});

// valideer jwt token
// valideer '@proforto.nl'

firebaseAdmin.auth().createCustomToken('ruittenb').then(function (firebaseToken) {
    // return firebaseToken;
});

//
//
//firebase.initializeApp(firebaseConfig);
//
//firebase.auth().signInWithCustomToken(customToken);
//
//
//
//    "gmailUsers": {
//      "$uid": {
//        ".write": "auth.profile.email_verified == true && auth.profile.email.matches(/.*@proforto.nl$/)"
//      }
//    }
//
//
