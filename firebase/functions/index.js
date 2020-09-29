const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();
const db = admin.firestore();

exports.addHiveTakenRole = functions.https.onRequest(async (req, res) => {
  // ## Remove from open roles
  if (req.method !== 'POST' || !req.body)
    return res.status(401).send("must be POST and have a body");

  const data = JSON.parse(req.body);
  const hive = await db.doc(data.hiveRef).get();
  if (!hive.exists) return res.status(404).send("Hive not found");
  // Get role id and check if quantity is enough
  const roles = hive.get("openRoles");
  const roleIndex = roles.findIndex(r => r.roleId == data.roleRef);
  let quantity = roles[roleIndex].quantity;
  if (quantity <= 0) return res.status(500).send("Quantity <= 0");
  else if (quantity == 1) {
    // if quantity is 0 remove role from list
    roles.splice(roleIndex, 1);
  } else {
    // if quantity is enough subtract it
    roles[roleIndex].quantity = quantity - 1;
  }
  await db.doc(data.hiveRef).update({
    openRoles: roles
  });

  // ## Add to taken roles
  await db.doc(data.hiveRef).update({
    takenRoles: [
      ...hive.get("takenRoles"),
      {
        roleId: data.roleRef,
        userId: data.userRef
      }
    ]
  });

  return res.status(201).send("Taken role created");
});


exports.createHive = functions.https.onRequest(async (request, response) => {
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
    description: data.description,
    location: loc,
    name: data.name,
    openRoles: data.openRoles,
    takenRoles: [],
    topics: data.topics
  });

  return response.status(200).send("Hive created!");
});