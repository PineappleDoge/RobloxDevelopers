var net = require("net");
var io = require("@pm2/io");
var port = 4864;

require('dotenv').config();

var metrics = {};

var server = net.createServer(function (socket) {
  socket.on('data', function (buffer) {
    let str = buffer.toString()

    str = str.substr(0, str.length-1)

    str.split('|').forEach(chunk => {
        var data = JSON.parse(chunk);
        if (!data.auth || data.auth !== process.env.METRICS_AUTH) return

        switch (data.method) {
        case 'set':
          if (metrics[data.id]) {
            metrics[data.id].set(data.value);
          } else {
            metrics[data.id] = io.metric({
              name: data.name || data.id
            });
            metrics[data.id].set(data.value);
          }

          break
        case 'log':
          console.log(data.value)
          break
        }
    })
  });
});

server.listen({ port: port }, function () {
  console.log('Server online');
});
