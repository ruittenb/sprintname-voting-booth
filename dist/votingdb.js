
const votingDb = (function (firebase) {

    //    var serviceAccount = require('serviceAccountKey.json');

    var firebaseConfig = {
        //        credential        : firebase.credential.cert(serviceAccount),
        apiKey            : "AIzaSyAm4--Q2MjVWGZYW-IC8LPZARXJq-XyHXA",
        databaseURL       : "https://sprintname-voting-booth.firebaseio.com",
        authDomain        : "sprintname-voting-booth.firebaseapp.com",
        storageBucket     : "sprintname-voting-booth.appspot.com",
        messagingSenderId : "90828432994"
    };

    firebase.initializeApp(firebaseConfig);

    return {
        pokedex : firebase.database().ref('pokedex'),
        users   : firebase.database().ref('users')
    };

})(firebase);

