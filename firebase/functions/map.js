const functions = require('firebase-functions');
const admin = require('firebase-admin');

const db = admin.firestore();

module.exports = function (e) {
  e.searchMap = functions.https.onRequest(async (req, res) => {

  });
}
