import 'package:flutter/material.dart';
// ignore: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;

//Estados del servidor:
enum ServerStatus { online, offline, connecting }

class SocketService with ChangeNotifier { 
  //Propiedad:
  ServerStatus _serverStatus = ServerStatus.connecting;
  late IO.Socket _socket; //ver si dejar o no el late

  //Getter:
  ServerStatus get serverStatus => _serverStatus;
  IO.Socket get socket => _socket;
  Function get emit => _socket.emit;

  //Constructor
  SocketService() {
    _initConfig();
  }

  //Método privado:
  void _initConfig() {
    // Dart client
    //_socket = IO.io('http://localhost:3000/', {
      _socket = IO.io('http://192.168.1.119:3000/', {
      //si no funciona localhost se pone el IP del pc
      'transports': ['websocket'],
      'autoConnect': true
    });

    _socket.onConnect((_) {
      _serverStatus = ServerStatus.online;
      notifyListeners();
    });

    _socket.onDisconnect((_) {
      _serverStatus = ServerStatus.offline;
      notifyListeners();
    });

  }
}
