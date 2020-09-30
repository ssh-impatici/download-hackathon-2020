const functions = require('firebase-functions');
const admin = require('firebase-admin');

const db = admin.firestore();
const Fields = admin.firestore.FieldValue;

module.exports = function(e) {
  e.modifyStars = functions.https.onRequest(async (req, res) => {

    if (req.method !== 'POST' || !req.body)
      return res.status(400).send("Please send a POST request");

    const data = JSON.parse(req.body);

    const user = await db.doc(data.userRef).get();
    if (!user.exists) return res.status(404).send("User not found");

    const topics = user.get("topics");
    const index = topics.findIndex(r => r.id == data.topic);

    const previous_reviews = topics[index].reviews
    const previous_stars = topics[index].stars

    // TODO Valutare solo sui topic relativi all'ambito svolto nell'alveare, non potrebbe modificarli tutti

    const obj = {
      "topics": [{
        "id": data.topic,
        "reviews": previous_reviews + 1,
        "stars": (previous_stars * previous_reviews + data.stars) / (previous_reviews + 1)
      }]
    }

    // Update, need an existing users with fields!
    await db.doc(data.userRef).update(obj);

    return res.status(201).send("Stars modified!");
  });
}