const functions = require('firebase-functions');
const admin = require('firebase-admin');

const db = admin.firestore();
const Fields = admin.firestore.FieldValue;

module.exports = function (e) {
  e.joinHive = functions.https.onRequest(async (req, res) => {
    // ##### Remove from open roles
    if (req.method !== 'POST' || !req.body)
      return res.status(400).send("must be POST and have a body");

    const data = JSON.parse(req.body);
    const hive = await db.doc(data.hiveRef).get();
    if (!hive.exists) return res.status(404).send("Hive not found");
    // Get role id and check if quantity is enough
    const roles = hive.get("openRoles");
    const roleIndex = roles.findIndex(r => r.roleId == data.roleRef);
    if (roleIndex < 0) return res.status(404).send("Role not available");
    if (roles[roleIndex].quantity == 1) {
      // if quantity is 0 remove role from list
      roles.splice(roleIndex, 1);
    } else {
      // if quantity is enough subtract it
      roles[roleIndex].quantity -= 1;
    }
    await db.doc(data.hiveRef).update({
      openRoles: roles
    });

    // ##### Add to taken roles
    await db.doc(data.hiveRef).update({
      takenRoles: [
        ...hive.get("takenRoles"),
        {
          roleId: data.roleRef,
          userId: data.userRef
        }
      ]
    });

    // ##### Add hive to user's hives
    await db.doc(data.userRef).update({
      hives: Fields.arrayUnion(data.hiveRef)
    })

    return res.status(201).send("Taken role created");
  });

  e.createHive = functions.https.onRequest(async (request, response) => {
    // Check for POST request
    if (request.method !== "POST")
      return response.status(400).send('Please send a POST request');

    const data = JSON.parse(request.body);

    let loc = null;
    if (data.location != null) {
      // GeoPoint
      loc = new admin.firestore.GeoPoint(data.location.latitude, data.location.longitude)
    }

    await db.collection('hives').add({
      active: true,
      creator: data.creator,
      description: data.description,
      location: loc,
      name: data.name,
      openRoles: data.openRoles,
      takenRoles: [],
      topics: data.topics
    });

    return response.status(200).send("Hive created!");
  });
}
