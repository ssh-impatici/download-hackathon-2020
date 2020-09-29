const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();
const db = admin.firestore();

exports.addHiveTakenRole = functions.https.onRequest(async (req, res) => {
  // ## Remove from open roles
  if (!req.body) return res.status(401).send("req body not found");
  const data = JSON.parse(req.body);
  const hive = await db.collection('hives').doc(data.hiveId).get();
  if (!hive.exists) return res.status(404).send("Hive not found");
  // Get role id and check if quantity is enough
  const roles = hive.openRoles;
  const roleIndex = roles.findIndex(r => r.roleId == roleId);
  let quantity = roles[roleIndex].quantity;
  if (quantity <= 0) return res.status(500).send("Quantity <= 0");
  else if (quantity == 0) {
    // if quantity is 0 remove role from list
    roles.splice(roleIndex, 1);
  } else {
    // if quantity is enough subtract it
    roles[roleIndex].quantity = quantity - 1;
  }
  await hive.update({ roles: roles });

  // ## Add to taken roles
  await hive.takenRoles.update({
    takenRoles: hive.takenRoles.push({
      roleId: data.roleId,
      userId: data.userId
    })
  });
  return res.status(201).send("Taken role created");
});


exports.createHive = functions.https.onRequest(async (request, response) => {
  // Check for POST request
  if (request.method !== "POST") {
    response.status(400).send('Please send a POST request');
    return;
  }

  const obj = JSON.parse(request.body);
  let loc = null;
  if (obj.location != null) {
    loc = new firebase.firestore.GeoPoint(obj.location.latitude, obj.location.longitude)
  }
  // GeoPoint
  await db.collection('hives').add({
    active: true,
    description: obj.description,
    location: loc,
    name: obj.name,
    openRoles: obj.openRoles,
    takenRoles: null,
    topics: obj.topics
  });

  return response.status(200).send("Hive created!");
});