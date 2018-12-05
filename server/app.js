const app = require('express')();
const server = require('http').createServer(app);
const io = require('socket.io')(server);

console.log("waiting for socket users to come in.......");
io.on('connection', () => {
  console.log("a user come in!!!");
});
server.listen(8998);
