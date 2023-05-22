const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.sendTaskNotification = functions.firestore
  .document('tasks/{taskId}')
  .onCreate(async (snap, context) => {
    const task = snap.data();
    const userId = task.createdBy;

    const userRef = admin.firestore().collection('users').doc(userId);
    const userDoc = await userRef.get();
    const user = userDoc.data();

    const tokensRef = userRef.collection('tokens');
    const tokensSnapshot = await tokensRef.get();

    const tokens = [];
    tokensSnapshot.forEach((tokenDoc) => {
      tokens.push(tokenDoc.id);
    });

    if (tokens.length > 0) {
      const payload = {
        notification: {
          title: `Nouvelle tâche : ${task.titre}`,
          body: `Description: ${task.description}`,
        },
      };

      const response = await admin.messaging().sendToDevice(tokens, payload);
      console.log('Notification envoyée', response);
    }
  });
