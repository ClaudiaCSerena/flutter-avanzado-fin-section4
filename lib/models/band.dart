class Band {
  String id; //Lo genera el backend
  String name; //nombre de la banda
  int votes; //cantidad de votos de la banda

  //Constructor tradicional:
  Band({required this.id, required this.name, required this.votes});

  //Factory constructor, es un constructor que recibe ciertos argumentos y crea una nueva instancia de band
  //el constructor se llama "fromMap" y recibe un mapa como argumento
  factory Band.fromMap(Map<String, dynamic> obj) {
    return Band(
      id: obj.containsKey('id')?  obj['id'] : 'no-id',
      name: obj.containsKey('name')?  obj['name'] : 'no-name',
      votes: obj.containsKey('votes')?  obj['votes'] : 'no-votes',
    );
  }
}