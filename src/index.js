'use strict';

require('ace-css/css/ace.css');
require('font-awesome/css/font-awesome.css');
require('./index.html'); // ensure index.html gets copied during build
const firebase = require('firebase');
require('firebase/auth');
require('firebase/database');

require('../dist/Observable.js');
require('../dist/EventHub.js');
require('../dist/AuthWrapper.js');
require('../dist/VotingDb.js');
require('../dist/VotingApp.js');

/** **********************************************************************
 * main
 */

const eventHub  = new EventHub();
const auth      = new AuthWrapper(eventHub);
const votingDb  = new VotingDb(eventHub);
const votingApp = new VotingApp(eventHub);

window.eventHub = eventHub;

