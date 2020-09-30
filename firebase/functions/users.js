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

    const topics = user.get("topics");
    const topicIndex = topics.findIndex(r => r.id == data.topic);

    const previous_reviews = topics[topicIndex].reviews
    const previous_stars = topics[topicIndex].stars

    if (topicIndex < 0) {
      return res.status(404).send("Topic not available");
    } else {
      topics[topicIndex].reviews = topics[topicIndex].reviews + 1;
      topics[topicIndex].stars = (previous_stars * previous_reviews + data.stars) / (previous_reviews + 1);
      await db.doc(data.userRef).update({
        topics: topics
      });
    }

    // TODO Valutare solo sui topic relativi all'ambito svolto nell'alveare, non potrebbe modificarli tutti

    return res.status(201).send("Stars modified!");
  });
}