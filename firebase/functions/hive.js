const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();
const db = admin.firestore();

exports.addHiveTakenRole = functions.https.onRequest(async (req, res) => {
  // ## Remove from open roles
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