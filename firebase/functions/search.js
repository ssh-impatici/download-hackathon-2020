const functions = require('firebase-functions');
const admin = require('firebase-admin');

const db = admin.firestore();

module.exports = function(e) {
  e.getHivesList = functions.https.onRequest(async (req, res) => {
    const data = JSON.parse(req.body);
    if (!data) return res.status(400).send("Bad request: no body found");
    // num. of topics in common
    const userTopics = await db.doc(data.userRef).get("topics");
    const virtualHives = await db.collection("hives").where("latitude")
  });
}


module.exports = function(e) {
  e.getHivesMap = functions.https.onRequest(async (req, res) => {
    // Check for POST request
    if (req.method !== "POST")
      return res.status(400).send('Please send a POST request');

    const data = JSON.parse(req.body);
    let zoom = data.zoom

    const hives_filtered_1 = await db.collection('hives')
      .where('latitude', '<=', data.latitude + zoom)
      .where('latitude', '>=', data.latitude - zoom)
      //.where('longitude', '<=', data.longitude + zoom)
      //.where('longitude', '>=', data.longitude - zoom)
      .limit(100)
      .get()

    hives_filtered_2 = hives_filtered_1.docs.map(doc => doc.data())

    res.status(200).send(hives_filtered_2.filter(
      function(a) {
        return (a.longitude <= (data.longitude + zoom)) && (a.longitude >= (data.longitude - zoom));
      }
    ));
  });
}