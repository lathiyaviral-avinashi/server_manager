import 'dart:io';

class myClient {
      WebSocket _socket;

     myClient(WebSocket ws){
            _socket = ws;
            _socket.listen(messageHandler,
                           onError: errorHandler,
                           onDone: finishedHandler);
     }

     void write(dynamic message){ _socket.add(message); }

    void messageHandler(dynamic msg){  
    if (msg == 'Connected to server')write('Connected to server');   // send msg to the new socket only
    else distributeMessage(msg, _socket);  // send msg to all opened sockets
  }

    void errorHandler(error){
         print('one socket got error: $error');
         removeClient(this);
        _socket.close();
    }

    void finishedHandler() {
         print('one socket had been closed');
         distributeMessage('one socket had been closed', _socket);
         removeClient(this);
         _socket.close();
    }
}

removeClient(myClient client) {
  if(clients.length > 0) {
    for(int i = 0; i < clients.length; i++){
      if(clients[i] == client) {
        clients.removeAt(i);
        print('one socket had been removed successfully');
      }
    }
  }
}


List<myClient> clients = new List();

//  void main() { 
//   startServer();
//  }

 void startServer() {
  HttpServer.bind(InternetAddress.anyIPv4, 8080).then((HttpServer server) {
        print("HttpServer listening...");
        server.listen((HttpRequest request) {
          if (WebSocketTransformer.isUpgradeRequest(request)){
              WebSocketTransformer.upgrade(request).then(handleWebSocket);
           }
      else {
            print("Regular ${request.method} request for: ${request.uri.path}");
            serveRequest(request);
            }
        });
     });
 }

void handleWebSocket(WebSocket socket){
  print('Client connected!');
  myClient client = new myClient(socket);
  addClient(client);
}

void serveRequest(HttpRequest request){
  request.response.statusCode = HttpStatus.forbidden;
  request.response.reasonPhrase = "WebSocket connections only";
  request.response.close();
}

void distributeMessage(String msg, WebSocket socket){
  // print('Message --> ' + msg);
  for(int i = 0; i < clients.length; i ++) {
    if(clients[i]._socket != socket)  {
      clients[i].write('$msg');
    }
  }
  //  for (myClient c in clients)c.write('$msg ');
 }

class DateFormat {
}

 void addClient(myClient c){
     clients.add(c);
 }
