'use strict';

require('ace-css/css/ace.css');
require('font-awesome/css/font-awesome.css');
require('./index.html'); // ensure index.html gets copied during build

const AuthWrapper = require('../dist/AuthWrapper.js');
const VotingDb    = require('../dist/VotingDb.js');
const VotingApp   = require('../dist/VotingApp.js');

/** **********************************************************************
 * main
 */

const auth      = new AuthWrapper();

const votingApp = new VotingApp();
votingApp.run(auth.retrieveCredentials());
auth.register(votingApp.elmClient);

const votingDb  = new VotingDb(votingApp.elmClient);


