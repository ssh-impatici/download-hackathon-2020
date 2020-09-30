
const admin = require('firebase-admin');
admin.initializeApp();

require('./hive.js')(exports);
require('./map.js')(exports);