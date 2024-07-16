import 'package:band_names_v2/pages/home.dart';
import 'package:band_names_v2/pages/status.dart';
import 'package:band_names_v2/services/socket_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

//"socket.io": "^4.7.5" 

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create:(_) => SocketService() )
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Material App',
        initialRoute: 'home', 
        routes: {
          'home': (_) => const HomePage(),
          'status': (_) => const StatusPage(),
        },  
      ),
    );
  }
}
