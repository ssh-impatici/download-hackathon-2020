const functions = require('firebase-functions');
const admin = require('firebase-admin');

const db = admin.firestore();
const Fields = admin.firestore.FieldValue;

module.exports = function(e) {
  e.modifyStars = functions.https.onRequest(async (req, res) => {

    if (req.method !== 'POST' || !req.body)
      return res.status(400).send("Please send a POST request");

    const data = req.body;

    const user = await db.doc(data.userRef).get();
    if (!user.exists) return res.status(404).send("User not found");

    let topics = user.get("topics");

    let topicIndex1 = topics.findIndex(r => Object.keys(r) == data.topic);

    // Topic not in database, so add it
    if (topicIndex1 < 0) {
      let obj = {
        [data.topic]: [{
          "name": data.role,
          "stars": data.stars,
          "reviews": 1
        }]
      }

      topics.push(obj)

      await db.doc(data.userRef).update({
        topics: topics
      });

      return res.status(201).send("Stars modified!");
    }

    let topicIndex2 = topics[topicIndex1][Object.keys(topics[topicIndex1])].findIndex(r => r.name == data.role)

    // Role not in database inside topic, so add it
    if (topicIndex2 < 0) {
      let obj = {
        "name": data.role,
        "stars": data.stars,
        "reviews": 1
      }

      topics[topicIndex1][Object.keys(topics[topicIndex1])].push(obj)

      await db.doc(data.userRef).update({
        topics: topics
      });

      return res.status(201).send("Stars modified!");
    }

    console.log("Log " + JSON.stringify(topics))
    console.log("Log " + JSON.stringify(topics[topicIndex1]))
    console.log("Log " + JSON.stringify(topics[topicIndex1][Object.keys(topics[topicIndex1])]))
    console.log("Log " + topicIndex2)

    const previous_reviews = topics[topicIndex1][Object.keys(topics[topicIndex1])][topicIndex2].reviews
    const previous_stars = topics[topicIndex1][Object.keys(topics[topicIndex1])][topicIndex2].stars

    topics[topicIndex1][Object.keys(topics[topicIndex1])][topicIndex2].reviews++;
    topics[topicIndex1][Object.keys(topics[topicIndex1])][topicIndex2].stars = (previous_stars * previous_reviews + data.stars) / (previous_reviews + 1);
    await db.doc(data.userRef).update({
      topics: topics
    });

    return res.status(201).send("Stars modified!");
  });
}