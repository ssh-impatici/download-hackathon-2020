const functions = require('firebase-functions');
const admin = require('firebase-admin');
const {
  user
} = require('firebase-functions/lib/providers/auth');

const db = admin.firestore();
const Fields = admin.firestore.FieldValue;

module.exports = function(e) {
  e.joinHive = functions.https.onRequest(async (req, res) => {
    if (req.method !== 'POST' || !req.body)
      return res.status(400).send("Please send a POST request");

    const data = req.body;

    const hive = await db.doc(data.hiveRef).get();
    if (!hive.exists) return res.status(404).send("Hive not found");

    // Check that user is not already joined
    const takenRoles = hive.get("takenRoles");
    if (takenRoles.find(role => role.userRef === data.userRef && role.name === data.roleRef))
      return res.status(401).send("User already joined");

    // ##### Remove from open roles
    // Get role id and check if quantity is enough
    const roles = hive.get("openRoles");
    const roleIndex = roles.findIndex(r => r.name == data.roleRef);
    if (roleIndex < 0) return res.status(404).send("Role not available");
    if (roles[roleIndex].quantity == 1) {
      // If quantity is 0 remove role from list
      roles.splice(roleIndex, 1);
    } else {
      // If quantity is enough subtract it
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
          name: data.roleRef,
          userRef: data.userRef
        }
      ]
    });

    // ##### Add hive to user's hives
    const user = await db.doc(data.userRef).get();
    let userHives = user.get("hives");
    if (!userHives) userHives = [];
    const hiveIndex = userHives.findIndex(hive => hive.hiveRef === data.hiveRef);
    if (hiveIndex > 0)
      userHives[hiveIndex].roles.push(data.roleRef);
    else
      userHives.push({
        hiveRef: data.hiveRef,
        roles: [data.roleRef]
      });
    await db.doc(data.userRef).update({
      hives: userHives
    });

    var hiveRef_plain = data.hiveRef.replace("hives/", "");

    db.collection("hives").doc(hiveRef_plain).get()
      .then(snap => {
        return res.status(201).send({
          hiveId: hiveRef_plain,
          hiveData: snap.data()
        });
      })
  });

  e.leaveHive = functions.https.onRequest(async (req, res) => {
    if (req.method !== 'POST' || !req.body)
      return res.status(400).send("Please send a POST request");

    const data = req.body;

    const hive = await db.doc(data.hiveRef).get();
    if (!hive.exists) return res.status(404).send("Hive not found");

    const user = await db.doc(data.userRef).get();
    if (!user.exists) return res.status(404).send("User not found");

    // ##### Remove from taken roles
    let roles = hive.get("takenRoles");
    console.log(roles);
    let roleIndex = roles.findIndex(r => r.name == data.roleRef);
    if (roleIndex < 0) return res.status(404).send("Role not available");
    roles.splice(roleIndex, 1)
    await db.doc(data.hiveRef).update({
      takenRoles: roles
    });

    // ##### Add to open roles
    // Get role id and get his quantity
    roles = hive.get("openRoles");
    console.log(roles);
    roleIndex = roles.findIndex(r => r.name == data.roleRef);
    // If there is not in openRoles, quantity is set to 1
    if (roleIndex < 0) {
      await db.doc(data.hiveRef).update({
        openRoles: [
          ...hive.get("openRoles"),
          {
            name: data.roleRef,
            quantity: 1
          }
        ]
      });
      // If there is in openRoles, quantity is increased by 1
    } else {
      roles[roleIndex].quantity++;
      await db.doc(data.hiveRef).update({
        openRoles: roles
      });
    }

    // ##### Remove hive from user's hives
    let userHives = user.get("hives");
    let userIndex = userHives.findIndex(r => (r.hiveRef == data.hiveRef));
    if (userIndex < 0) {
      return res.status(404).send("Hive not available");
    } else {
      userHives[userIndex].roles.pop(data.roleRef)
      await db.doc(data.userRef).update({
        hives: userHives
      });
    }

    var hiveRef_plain = data.hiveRef.replace("hives/", "");

    db.collection("hives").doc(hiveRef_plain).get()
      .then(snap => {
        return res.status(201).send({
          hiveId: hiveRef_plain,
          hiveData: snap.data()
        });
      })
  });

  e.createHive = functions.https.onRequest(async (req, res) => {
    // Check for POST request
    if (req.method !== "POST")
      return res.status(400).send("Please send a POST request");

    const data = {
      ...req.body
    };

    let lat = null;
    let lon = null;
    let addr = null;
    if (data.latitude != null && data.longitude != null) {
      lat = data.latitude
      lon = data.longitude
      addr = data.address
    }

    let docId = null
    await db.collection('hives').add({
      active: true,
      creator: data.creator,
      description: data.description,
      address: addr,
      latitude: lat,
      longitude: lon,
      name: data.name,
      openRoles: data.openRoles,
      takenRoles: [],
      topics: data.topics
    }).then(function(docRef) {
      docId = docRef.id;
      db.collection("hives").doc(docRef.id).get()
        .then(snap => {
          return res.status(201).send({
            hiveId: docId,
            hiveData: snap.data()
          });
        })
    });
  });
}