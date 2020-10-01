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
      userRef: req.query.userRef,
      latitude: Number(req.query.latitude),
      longitude: Number(req.query.longitude),
      topic: req.query.topic
    };

    let userTopics = await db.doc(data.userRef).get();
    userTopics = userTopics.get("topics").map(topic => topic.id);

    let virtualHives = await db.collection("hives").where('latitude', '==', null).get();
    virtualHives = virtualHives.docs.map(doc => {
      return {
        ...doc.data(),
        hiveId: doc.id
      }
    });

    let physicalHives = await db.collection("hives").where('latitude', '>', 0).get();
    physicalHives = physicalHives.docs.map(doc => {
      return {
        ...doc.data(),
        hiveId: doc.id
      }
    });

    let userHives = await db.doc(data.userRef).get();
    userHives = userHives.get("hives");
    if (!userHives) userHives = [];
    userHives = userHives.map(hive => hive.hiveRef);

    // filter out already joined hives or created by you
    virtualHives = virtualHives.filter(hive => hive.creator !== data.userRef && !userHives.includes("hives/" + hive.hiveId));
    physicalHives = physicalHives.filter(hive => hive.creator !== data.userRef && !userHives.includes("hives/" + hive.hiveId));

    if (data.topic) {
      virtualHives = virtualHives.filter(hive => hive.topics.includes(data.topic));
      physicalHives = physicalHives.filter(hive => hive.topics.includes(data.topic));
    }

    // Sort virtual hives by common topics
    virtualHives = virtualHives.sort((a, b) => {
      let scoreA = a.topics.filter(item => userTopics.includes(item)).length;
      let scoreB = b.topics.filter(item => userTopics.includes(item)).length;
      return scoreB - scoreA
    });

    // Sort physical hives by distance
    if (data.latitude && data.longitude) {
      physicalHives = physicalHives
        .sort((a, b) => {
          let distA = getDistance(a.latitude, data.latitude, a.longitude, data.longitude);
          let distB = getDistance(b.latitude, data.latitude, b.longitude, data.longitude);
          return distA - distB;
        });
    }

    // Construct final result
    let resultHives = [];
    let iVirtual = virtualHives.length;
    let iPhysical = physicalHives.length;
    while (iVirtual > 0 || iPhysical > 0) {
      if (iVirtual > 0) {
        resultHives.push(virtualHives.shift());
        iVirtual--;
      }
      if (iPhysical > 0) {
        resultHives.push(physicalHives.shift());
        iPhysical--;
      }
    }

    return res.status(200).send(resultHives);
  });

  e.getHivesMap = functions.https.onRequest(async (req, res) => {
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
    });

    res.status(200).send(hives.filter(
      a => (a.longitude <= (long + zoom)) && (a.longitude >= (long - zoom))
    ));
  });
}