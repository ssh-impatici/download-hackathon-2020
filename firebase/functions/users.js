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





    let topicIndex2 = topics[topicIndex1][Object.keys(topics[topicIndex1])].findIndex(r => r.name == data.role)

    console.log("XXXXXXXXX" + JSON.stringify(topics))
    console.log("XXXXXXXXX" + JSON.stringify(topics[topicIndex1]))
    console.log("XXXXXXXXX" + JSON.stringify(topics[topicIndex1][Object.keys(topics[topicIndex1])]))
    console.log("XXXXXXXXX" + topicIndex2)


    // IF TECH VUOTO (JOINA)






    if (topicIndex1 < 0 || topicIndex2 < 0) {
      return res.status(404).send("Topic/Role not available");
    }

    const previous_reviews = topics[topicIndex1][Object.keys(topics[topicIndex1])][topicIndex2].reviews
    const previous_stars = topics[topicIndex1][Object.keys(topics[topicIndex1])][topicIndex2].stars

    topics[topicIndex1][Object.keys(topics[topicIndex1])][topicIndex2].reviews++;
    topics[topicIndex1][Object.keys(topics[topicIndex1])][topicIndex2].stars = (previous_stars * previous_reviews + data.stars) / (previous_reviews + 1);
    await db.doc(data.userRef).update({
      topics: topics
    });

    // TODO Valutare solo sui topic relativi all'ambito svolto nell'alveare, non potrebbe modificarli tutti i possibili topic?

    return res.status(201).send("Stars modified!");
  });
}