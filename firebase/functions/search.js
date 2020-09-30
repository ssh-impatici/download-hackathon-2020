const functions = require('firebase-functions');
const admin = require('firebase-admin');

const db = admin.firestore();

const getDistance = (x1, x2, y1, y2) => {
  const a = x1 - x2;
  const b = y1 - y2;
  return Math.sqrt(a * a + b * b);
}

module.exports = function(e) {
  e.getHivesList = functions.https.onRequest(async (req, res) => {
    const data = {
      ...req.query
    };

    let userTopics = await db.doc(data.userRef).get();
    userTopics = userTopics.get("topics").map(topic => topic.id);

    let virtualHives = await db.collection("hives").where('latitude', '==', null).get();
    virtualHives = virtualHives.docs.map(doc => doc.data());

    let physicalHives = await db.collection("hives").where('latitude', '>', 0).get();
    physicalHives = physicalHives.docs.map(doc => doc.data());

    virtualHives = virtualHives.sort((a, b) => {
      let scoreA = a.topics.filter(item => userTopics.includes(item)).length;
      let scoreB = b.topics.filter(item => userTopics.includes(item)).length;
      return scoreB - scoreA
    });

    physicalHives = physicalHives
      // .filter(hive => hive.topics.filter(topic => userTopics.includes(topic)).length > 0)
      .sort((a, b) => {
        let distA = getDistance(a.latitude, data.latitude, a.longitude, data.longitude);
        let distB = getDistance(b.latitude, data.latitude, b.longitude, data.longitude);
        return distA - distB;
      });

    let resultHives = [];
    let iVirtual = 0;
    let iPhysical = 0;
    for (let i = 0; i < physicalHives.length + virtualHives.length; i++) {
      if (iVirtual < virtualHives.length) {
        resultHives.push(virtualHives.shift());
        iVirtual++;
      }
      if (iPhysical < physicalHives.length) {
        resultHives.push(physicalHives.shift());
        iPhysical++;
      }
    }

    return res.status(200).send(resultHives);
  });

  e.getHivesMap = functions.https.onRequest(async (req, res) => {
    // TODO Zoom
    let zoom = Number(req.query.zoom);
    let lat = Number(req.query.latitude);
    let long = Number(req.query.longitude);
    let topic = String(req.query.topic);

    console.log(lat + zoom);

    let hives = null;

    if (topic != "undefined") {
      hives = await db.collection('hives')
        .where('latitude', '<=', lat + zoom)
        .where('latitude', '>=', lat - zoom)
        .where('topics', 'array-contains', topic) // Filter by topic
        .limit(100)
        .get()
    } else {
      hives = await db.collection('hives')
        .where('latitude', '<=', lat + zoom)
        .where('latitude', '>=', lat - zoom)
        .limit(100)
        .get()
    }

    hives = hives.docs.map(doc => {
      return {
        ...doc.data(),
        hiveId: doc.id
      }
    })

    res.status(200).send(hives.filter(
      a => (a.longitude <= (long + zoom)) && (a.longitude >= (long - zoom))
    ));
  });
}