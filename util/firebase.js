const firebase = require('firebase');
// Your web app's Firebase configuration
// For Firebase JS SDK v7.20.0 and later, measurementId is optional
const firebaseConfig = {
  apiKey: "AIzaSyB4DRQB_VhHAcHRBBix3HdHZdjZpeVXjJY",
  authDomain: "tache-cd41d.firebaseapp.com",
  projectId: "tache-cd41d",
  storageBucket: "tache-cd41d.appspot.com",
  messagingSenderId: "1082257014599",
  appId: "1:1082257014599:web:c0d70ef1a3cda0d2651662",
  measurementId: "G-6MPQ0Y4938"
};
firebase.initializeApp(firebaseConfig); //initialize firebase app
module.exports = { firebase }; //export the app