var io = require('socket.io')();
io.on('connection', function(client){
    console.log('socket connected!');

    client.on('new_message', function(data){
        console.log("coming message!");
        console.log(data);
        client.emit("user_" + data.receiver_user_id, data);
    });

    client.on('disconnect', function(){
        console.log("user disconnected!");
    });
});
console.log("Server starts to listening!!!.....");
io.listen(8998);