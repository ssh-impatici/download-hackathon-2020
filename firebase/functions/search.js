const functions = require('firebase-functions');
const admin = require('firebase-admin');

const db = admin.firestore();

module.exports = function (e) {
  e.getHivesList = functions.https.onRequest(async (req, res) => {
    const data = JSON.parse(req.body);
    if (!data) return res.status(400).send("Bad request: no body found");
    // num. of topics in common
    const userTopics = await db.doc(data.userRef).get("topics");
    const virtualHives = await db.collection("hives").where("latitude")
  });
}
