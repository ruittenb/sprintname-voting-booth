var jsonServer = require('json-server');

var server = jsonServer.create();
server.use(jsonServer.defaults());

var router = jsonServer.router('data/ratings.json');
server.use(router);

var serverPort = 4202;
console.log('Listening at ', serverPort);
server.listen(serverPort);

