const functions = require('firebase-functions');
const admin = require('firebase-admin');
const {
  user
} = require('firebase-functions/lib/providers/auth');

const db = admin.firestore();

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
    if (hiveIndex >= 0)
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

    const fcm = admin.messaging();

    const topic = hiveRef_plain;
    const payload = {
      notification: {
        title: 'Beelder',
        body: `Someone joined your hive ${hive.get("name")}!`,
      },
      data: {
        sound: 'default',
        click_action: 'FLUTTER_NOTIFICATION_CLICK'
      }
    };

    fcm.sendToTopic(topic, payload);
    
    db.collection("hives").doc(hiveRef_plain).get()
    .then(snap => {
      return res.status(201).send({
        ...snap.data(),
        hiveId: hiveRef_plain
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
    let roleIndex = roles.findIndex(r => r.name == data.roleRef);
    if (roleIndex < 0) return res.status(404).send("Role not available");
    roles.splice(roleIndex, 1)
    await db.doc(data.hiveRef).update({
      takenRoles: roles
    });

    // ##### Add to open roles
    // Get role id and get his quantity
    roles = hive.get("openRoles");
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
    let hiveIndex = userHives.findIndex(r => r.hiveRef == data.hiveRef);
    let creator = await db.doc(data.hiveRef).get();
    if (hiveIndex < 0) return res.status(404).send("Hive not found");

    userHives[hiveIndex].roles = userHives[hiveIndex].roles.filter(role => role != data.roleRef);
    if ((userHives[hiveIndex].roles.length > 0) || (data.userRef == creator.get("creator"))) {
      // Creator, so roles is empty but hiveRef keept
      // or
      // There is some roles, so roles is not empty
      await db.doc(data.userRef).update({
        hives: userHives
      });
    } else {
      // Remove hives arrray
      userHives.splice(hiveIndex, 1);
      await db.doc(data.userRef).update({
        hives: userHives
      });
    }

    var hiveRef_plain = data.hiveRef.replace("hives/", "");

    db.collection("hives").doc(hiveRef_plain).get()
      .then(snap => {
        return res.status(201).send({
          hiveId: hiveRef_plain,
          ...snap.data()
        });
      })
  });

  e.createHive = functions.https.onRequest(async (req, res) => {
    // Check for POST request
    if (req.method !== "POST")
      return res.status(400).send("Please send a POST request");

    const data = req.body

    let lat = null;
    let lon = null;
    let addr = null;
    if (data.latitude != null && data.longitude != null) {
      lat = data.latitude
      lon = data.longitude
      addr = data.address
    }

    const docRef = await db.collection('hives').add({
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
    });
    const docId = docRef.id;

    let user = await db.doc(data.creator).get();
    let userHives = [];
    if (user.get("hives")) {
      userHives = user.get("hives");
    }

    userHives.push({
      hiveRef: "hives/" + docId,
      roles: []
    });

    await db.doc(data.creator).update({
      hives: userHives
    });

    db.collection("hives").doc(docRef.id).get()
      .then(snap => {
        return res.status(201).send({
          hiveId: docId,
          ...snap.data()
        });
      })
  });
}