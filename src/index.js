'use strict';

require('ace-css/css/ace.css');
require('font-awesome/css/font-awesome.css');
require('./index.html'); // ensure index.html gets copied during build
require('../dist/utils.js'); // ensure utils.js gets copied during build

const Authentication = require('../dist/Authentication.js');
const Database       = require('../dist/Database.js');
const VotingApp      = require('../dist/VotingApp.js');

/** **********************************************************************
 * main
 */

const auth = new Authentication();
const credentials = auth.retrieveCredentials();

const votingApp = new VotingApp();
votingApp.run(credentials);
auth.register(votingApp.elmClient);

const database = new Database(votingApp.elmClient);

window.votingApp = votingApp;

