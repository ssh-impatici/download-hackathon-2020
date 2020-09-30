
const admin = require('firebase-admin');
admin.initializeApp();

require('./hive.js')(exports);
require('./search.js')(exports);