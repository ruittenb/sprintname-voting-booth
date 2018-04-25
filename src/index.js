'use strict';

require('ace-css/css/ace.css');
require('font-awesome/css/font-awesome.css');
require('./index.html'); // ensure index.html gets copied during build

const EventHub    = require('../dist/EventHub.js');
const AuthWrapper = require('../dist/AuthWrapper.js');
const VotingDb    = require('../dist/VotingDb.js');
const VotingApp   = require('../dist/VotingApp.js');

/** **********************************************************************
 * main
 */

const eventHub  = new EventHub();
const auth      = new AuthWrapper(eventHub);
const votingDb  = new VotingDb(eventHub);
const votingApp = new VotingApp(eventHub);

votingApp.start();
