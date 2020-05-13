import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';

import "package:angel_framework/angel_framework.dart";
import "package:angel_websocket/server.dart";

import 'package:angel_websocket/io.dart' as ws1;
import "package:angel_framework/http.dart" as srv;

Future main() async {
  connectWithAngel();
  // var handler = webSocketHandler((webSocket) {
  //   webSocket.stream.asBroadcastStream().listen((message) {
  //     print("Server Listner -->>  " + message);
  //     handleClientResponse(message, webSocket);
  //   });
  // });

  // shelf_io.serve(handler, InternetAddress.anyIPv4, 8080, shared: true).then((server) {
  //   print('Serving at ws://${server.address.host}:${server.port}');
  // });

}

void handleClientResponse(dynamic message, dynamic webSocket) {
  if(message.contains('error')) {
    return ;
  }
  var json = jsonDecode(message);
  
  if(json == null) {
    return;
  }

  if(json.containsKey('cmd')) {
    switch (json['cmd']) {

      case 'success':
        var json = '{"id":"all","cmd":"success"}';
        webSocket.sink.add(json);
    }
  }

  print(json);
} 

Future<void> connectWithAngel() async {
  
}

void startServer() {
  ServerSocket.bind(InternetAddress.anyIPv4, 8080).then(
    (ServerSocket server) {
      server.listen(handleClient);
    }
  );
}

void handleClient(Socket client){
 print('Connection from '
    '${client.remoteAddress.address}:${client.remotePort}');

  clients.add(new ChatClient(client));

  client.write("Welcome to dart-chat! "
    "There are ${clients.length - 1} other clients\n");
}
List<HandleClient> clientsHan = [];

class HandleClient{
  dynamic webSocket;
  String message;
  HandleClient(dynamic websocket, dynamic message){
    this.webSocket = websocket;
    this.message = message;
    clientsHan.forEach((element) {
      handleClientResponse(element.webSocket, element.message);
      
    });
  }

}

class ChatClient {
  Socket _socket;
  String _address;
  int _port;
  
  ChatClient(Socket s){
    _socket = s;
    _address = _socket.remoteAddress.address;
    _port = _socket.remotePort;

    _socket.listen(messageHandler,
        onError: errorHandler,
        onDone: finishedHandler);
  }

  void messageHandler(dynamic data){
    String message = new String.fromCharCodes(data).trim();
    distributeMessage(this, '${_address}:${_port} Message: $message');
  }

  void errorHandler(error){
    print('${_address}:${_port} Error: $error');
    // removeClient(this);
    _socket.close();
  }

  void finishedHandler() {
    print('${_address}:${_port} Disconnected');
    // removeClient(this);
    _socket.close();
  }

  void write(String message){
    _socket.write(message);
  }
}

List<ChatClient> clients = [];

void distributeMessage(ChatClient client, String message){
  for (ChatClient c in clients) {
    if (c != client){
      c.write(message + "\n");
    }
  }
}