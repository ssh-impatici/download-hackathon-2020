const functions = require('firebase-functions');
const admin = require('firebase-admin');

const db = admin.firestore();

const getDistance = (x1, x2, y1, y2) => {
  const a = x1 - x2;
  const b = y1 - y2;
  return Math.sqrt(a * a + b * b);
}

module.exports = function (e) {
  e.getHivesList = functions.https.onRequest(async (req, res) => {
    const data = JSON.parse(req.body);
    if (!data) return res.status(400).send("Bad request: no body found");

    let userTopics = await db.doc(data.userRef).get();
    userTopics = userTopics.get("topics");
    userTopics = userTopics.map(topic => Object.keys(topic)[0]);
    let virtualHives = await db.collection("hives").where('latitude', '==', null).get();
    virtualHives = virtualHives.docs.map(doc => doc.data());

    let physicalHives = await db.collection("hives").where('latitude', '>', 0).get();
    physicalHives = physicalHives.docs.map(doc => doc.data());

    virtualHives = virtualHives.sort((a, b) => {
      let scoreA = a.topics.filter(item => userTopics.includes(item)).length;
      let scoreB = b.topics.filter(item => userTopics.includes(item)).length;
      return scoreB - scoreA
    });

    console.log(virtualHives.length);

    physicalHives = physicalHives
      .filter(hive => hive.topics.filter(item => {
        // userTopics.includes(item).length > 0)
        console.log(userTopics, item);
      }))
      .sort((a, b) => {
        let distA = getDistance(a.latitude, data.userPosition.latitude, a.longitude, data.userPosition.longitude)
        let distB = getDistance(b.latitude, data.userPosition.latitude, b.longitude, data.userPosition.longitude);
        return distA - distB;
      });

    return res.status(200).send();
  });

  e.getHivesMap = functions.https.onRequest(async (req, res) => {
    // TODO Zoom
    let zoom = Number(req.query.zoom);
    let lat = Number(req.query.latitude);
    let long = Number(req.query.longitude);

    console.log(lat + zoom);
    let hives = await db.collection('hives')
      .where('latitude', '<=', lat + zoom)
      .where('latitude', '>=', lat - zoom)
      .limit(100)
      .get()

    hives = hives.docs.map(doc => doc.data())
    res.status(200).send(hives.filter(
      a => (a.longitude <= (long + zoom)) && (a.longitude >= (long - zoom))
    ));
  });
}