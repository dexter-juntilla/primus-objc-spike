var express = require('express')
, app = express();

var Primus = require('primus')
, http = require('http');

var server = http.createServer(app)
, primus = new Primus(server, { transformer: 'websockets', parser: 'JSON' });

app.use(express.static(__dirname + '/public'));
app.get('/', function(req, res, next){
  res.sendfile('index.html');
});

primus.on('connection', function(socket) {

  socket.write('connected');
  console.log('connected')

  socket.on('data', function(data) {
    console.log('MESSAGE: ', data)
    socket.write('pong');
  })

  socket.on('message', function(v) {
    console.log('MESSAGE: ', v)
    socket.write('pong');
  });

  socket.on('tttt', function(v) {
    console.log('MESSAGE: ', v)
    socket.write('pong');
  });
});

var port = process.env.PORT || 3000;
server.listen(port, function(){
  console.log('\033[96mlistening on localhost:' + port + ' \033[39m');
});
