import 'dart:io';

import 'package:band_names_v2/models/band.dart';
import 'package:band_names_v2/services/socket_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //Me creo mi lista de bandas:
  List<Band> bands = []; //Se leerán desde el backend

  @override
  void initState() {
    final socketService = Provider.of<SocketService>(context,
        listen:
            false); //No necesito redibujar nada (x eso false), xq estoy en el initState
    //Listener:
    socketService.socket.on('active-bands',
        _handleActiveBands //Para escuchar el evento 'active-bands'. Payload es la data
        );

    super.initState();
  }

  //Método que no devuelve nada
  _handleActiveBands(dynamic payload) {
    bands = (payload as List).map((band) => Band.fromMap(band)).toList();
    setState(() {});
  }

  //Para cuando se destruya el home (aunque aquí no sucederá):
  @override
  void dispose() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.off(
        'active-bands'); //Hacemos la limpieza. Ya dejo de escuchar ese evento.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'BandNames',
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            child: (socketService.serverStatus == ServerStatus.online)
                ? Icon(Icons.check_circle, color: Colors.blue.shade300)
                : const Icon(
                    Icons.offline_bolt,
                    color: Colors.red,
                  ),
          ),
        ],
      ),
      body: Column(
        children: [
          _showGraph(),
          Expanded(
            //toma todo el espacio disponible
            child: ListView.builder(
              itemCount: bands.length,
              itemBuilder: (context, i) => _bandTile(bands[i]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addNewBand,
        elevation: 1,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _bandTile(Band band) {
    final socketService = Provider.of<SocketService>(context, listen: false);

    return Dismissible(
      //para poder eliminar de la lista moviendo hacia el lado
      //key: Key(band.id), //sale error al agregar nueva banda
      key: UniqueKey(),
      direction: DismissDirection.startToEnd, //no funciona
      onDismissed: (_) {
        //Emitir evento "delete-band"
        socketService.emit('delete-band', {'id': band.id});
      },
      background: Container(
        padding: const EdgeInsets.only(left: 8.0),
        color: Colors.red,
        child: const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Delete band',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: Text(band.name.substring(0, 2)),
        ),
        title: Text(band.name),
        trailing: Text(
          '${band.votes}',
          style: const TextStyle(fontSize: 15),
        ),
        onTap: () {
          socketService.socket.emit('vote-band', {'id': band.id});
        },
      ),
    );
  }

  //Método para crear una nueva banda
  addNewBand() {
    final textController = TextEditingController();

    if (Platform.isAndroid) {
      return showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: const Text('New band name:'),
            content: TextField(
              controller: textController,
            ),
            actions: [
              MaterialButton(
                  elevation: 5,
                  textColor: Colors.blue,
                  onPressed: () {
                    return addBandToList(textController.text);
                  },
                  child: const Text('Add'))
            ],
          );
        },
      );
    }

    //En caso que no sea android:
    showCupertinoDialog(
      context: context,
      builder: (_) {
        return CupertinoAlertDialog(
          title: const Text('New band name'),
          content: CupertinoTextField(
            controller: textController,
          ),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text('Add'),
              onPressed: () => addBandToList(textController.text),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: const Text(
                  'Dismiss'), //necesito este botón para que se cierre, ya que si me paro afuera no lo hace
              onPressed: () => Navigator.pop(context),
            )
          ],
        );
      },
    );
  }

  //Para agregar una banda a la lista
  void addBandToList(String name) {
    if (name.length > 1) {
      //Podemos agregar
      //Mando una comunicación al servidor de socket
      //emitir evento "add-band"
      final socketService = Provider.of<SocketService>(context, listen: false);
      socketService.emit('add-band', {
        'name': name
      }); //emito el evento "add-band" y entrego como información el name
    }
    Navigator.pop(context);
  }

  //Gráfico
  Widget _showGraph() {
    Map<String, double> dataMap = {};
    // = {"Flutter": 5, "React": 3, "Xamarin": 2, "Ionic": 2,  };
    for (var band in bands) {
      dataMap.addAll({band.name: band.votes.toDouble()});
      //dataMap = {band.name: band.votes.toDouble()};
    }

    final List<Color> colorList = [
      Colors.blue.shade50,
      Colors.blue.shade200,
      Colors.pink.shade50,
      Colors.pink.shade200,
      Colors.yellow.shade50,
      Colors.yellow.shade200
    ];

    return  Container(
      padding: const EdgeInsets.only(top: 10),   
        width: double.infinity, //todo el ancho
        height: 200,
        child: PieChart(
          dataMap: dataMap,
          animationDuration: const Duration(milliseconds: 800),
          //chartRadius: MediaQuery.of(context).size.width / 3.2,
          colorList: colorList,
          initialAngleInDegree: 0,
          chartType: ChartType.ring,
          //ringStrokeWidth: 32,
          //centerText: "HYBRID",
          legendOptions: const LegendOptions(
            showLegendsInRow: false,
            legendPosition: LegendPosition.right,
            showLegends: true,
            //legendShape: _BoxShape.circle,
            legendTextStyle: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          chartValuesOptions: const ChartValuesOptions(
            showChartValueBackground: false,
            showChartValues: true,
            showChartValuesInPercentage: true,
            showChartValuesOutside: false,
            decimalPlaces: 0,
          ),
          // gradientList: ---To add gradient colors---
          // emptyColorGradient: ---Empty Color gradient---
        ));
  }
}
