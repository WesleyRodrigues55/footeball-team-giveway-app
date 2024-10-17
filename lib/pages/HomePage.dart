import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:footeball_team_giveway_app/model/Player.dart';

class HomePage extends StatefulWidget {

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final formKey = GlobalKey<FormState>();
  final controllerData = TextEditingController();
  final controllerPlayersPerTeam = TextEditingController();
  
  final List<Player> listPlayers = [];
  int quantityPlayers = 0;

  // importa e padroniza os dados
  void _getData(context, String data) {
    final names = data.split('\n').where((line) {
    final trimmed = line.trim();

      // return RegExp(r'^\d+\s*-\s*').hasMatch(trimmed);
      return RegExp(r'^(\d+\s*-\s*|\d+\s*|\-\s*)?.+', caseSensitive: false).hasMatch(trimmed);
    }).map((line) {
      // var name = line.replaceFirst(RegExp(r'^\d+\s*-\s*'), '').trim();
      var name = line.replaceFirst(RegExp(r'^(\d+\s*-\s*|\d+\s*|\-\s*)', caseSensitive: false), '').trim();
      String typePlayer = 'normal';

      return Player(name: name, typePlayer: typePlayer);
    }).toList();
    
    setState(() {
      listPlayers.addAll(names);
      quantityPlayers = listPlayers.length;
    });

    controllerData.value = TextEditingValue.empty;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Jogador(es) adicionado na lista!'))
    );
  }

  // Abre o diálogo, e executa a importação da lista de jogadores
  void _showDialogModalImportData(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Importar lista de jogadores'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controllerData,
              maxLines: 10,
              decoration: InputDecoration(
                hintText: 'Estilo aceitável:\n1- Player 1\n2- Player 2\n3- Player 3\n4- ...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                _getData(context, controllerData.text);
              },
              child: Text('Importar Lista'),
            ),
          ],
        );
      },
    );
  }

  // Abre o diálogo, e executa o sorteio dos times
  void _showDialogModalDrawTeams(BuildContext context, countPlayers) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Sortear Times'),
          content: Container(
            height: 100,
            child: Column(
              children: [
                Text('Há $countPlayers jogadores na lista.'),
                SizedBox(height: 16),
                Form(
                  key: formKey,
                  child: TextFormField(
                    controller: controllerPlayersPerTeam,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    decoration: InputDecoration(
                      hintText: 'Quantidade de jogadores por time',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _drawTeams(controllerPlayersPerTeam.text);
              },
              child: Text('Sortear'),
            ),
          ],
        );
      },
    );
  }

  // Sorteia os times
  void _drawTeams(quantityPlayersPerTeam) {
    final teams = <List<Player>>[];

    final players = listPlayers.toList();
    players.shuffle();

    final playersPerTeam = int.parse(quantityPlayersPerTeam);
    final teamsCount = (players.length / playersPerTeam).ceil();
 
    for (var i = 0; i < teamsCount; i++) {
      teams.add([]);
    }

    // Separe os jogadores especiais e os goleiros do restante dos jogadores
    final specialPlayers = players.where((player) => player.typePlayer == 'especial').toList();
    final goalkeepers = players.where((player) => player.typePlayer == 'goleiro').toList();
    final remainingPlayers = players
        .where((player) => player.typePlayer != 'especial' && player.typePlayer != 'goleiro')
        .toList();

    // Embaralhe as listas para garantir aleatoriedade
    specialPlayers.shuffle();
    goalkeepers.shuffle();
    remainingPlayers.shuffle();

    // Distribua um jogador especial (se houver) e um goleiro (se houver) para cada time
    for (var i = 0; i < teams.length; i++) {
      if (specialPlayers.isNotEmpty) {
        teams[i].add(specialPlayers.removeLast());
      }
      if (goalkeepers.isNotEmpty) {
        teams[i].add(goalkeepers.removeLast());
      }
    }

    // Distribua os jogadores restantes nos times, garantindo que cada time tenha no máximo `playersPerTeam` jogadores
    int playerIndex = 0;
    for (var i = 0; i < teams.length && playerIndex < remainingPlayers.length; i++) {
      while (teams[i].length < playersPerTeam && playerIndex < remainingPlayers.length) {
        teams[i].add(remainingPlayers[playerIndex]);
        playerIndex++;
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Times Sorteados'),
        content: Container(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: teams.length,
            itemBuilder: (context, index) {
            final team = teams[index];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Text('Time ${index + 1}:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...team.map((player) => Text(player.name)).toList(),
              SizedBox(height: 16),
              ],
            );
            },
          ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
              Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => _copyToClipboard(teams),
              child: Text('Copiar'),
            ),
          ],
        );
      },
    );
  }

  // Copia a lista de jogadores para a área de transferência
  void _copyToClipboard(teams) {
    Clipboard.setData(ClipboardData(
      text: teams.map((team) => 'Time ${teams.indexOf(team) + 1}:\n' + team.map((player) => player.name).join('\n')).join('\n\n')
    ));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Lista de jogadores copiada!'))
    );
    Navigator.of(context).pop();
  }

  // Define o tipo de jogador
  void _setPlayerType(Player player, String type) {
    setState(() {
      if (player.typePlayer == type) {
        player.typePlayer = 'normal';
      } else {
        player.typePlayer = type;
      }
    });
  }

  // Remove o jogador selecionado
  void _delPlayerSelected(Player player) {
    setState(() {
      listPlayers.remove(player);
      quantityPlayers = listPlayers.length;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Jogador removido da lista!'))
    );
  }

  void _clearListPlayer(BuildContext context, countPlayers) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Limpar lista de jogadores'),
          content: Text('Deseja realmente limpar a lista de $countPlayers jogadores?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  listPlayers.clear();
                  quantityPlayers = 0;
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Lista de jogadores limpa!'))
                );
              },
              child: Text('Limpar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    if (listPlayers.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black12,
          title: Text('Footeball Team Giveaway'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Nenhum jogador na lista'),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _showDialogModalImportData(context),
                child: Text('Importar lista de jogadores'),
              ),
            ],
          ),
        ),
        // bottomNavigationBar: BottomNavigationBar(
        //   items: const <BottomNavigationBarItem>[
        //     BottomNavigationBarItem(
        //       icon: Icon(Icons.home),
        //       label: 'Home',
        //     ),
        //     BottomNavigationBarItem(
        //       icon: Icon(Icons.list),
        //       label: 'Players',
        //     ),
        //     BottomNavigationBarItem(
        //       icon: Icon(Icons.settings),
        //       label: 'Settings',
        //     ),
        //   ],
        //   currentIndex: 0,
        //   selectedItemColor: Colors.black,
        //   onTap: (index) {
        //   },
        // ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showDialogModalImportData(context),
          child: Icon(Icons.add),
        ),
      );
    }


    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black12,
        title: Text('Footeball Team Giveaway'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: listPlayers.length,
                itemBuilder: (context, index) {
                  final player = listPlayers[index];
                  return ListTile(
                    title: Text(listPlayers[index].name),
                    subtitle: Text(player.typePlayer),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Jogador especial',
                          icon: Icon(Icons.star),
                          color: player.typePlayer == 'especial' ? Colors.red : Colors.grey,
                          onPressed: () => _setPlayerType(player, 'especial'),
                        ),
                        IconButton(
                          tooltip: 'Goleiro',
                          icon: Icon(Icons.sports_mma),
                          color: player.typePlayer == 'goleiro' ? Colors.blue : Colors.grey,
                          onPressed: () => _setPlayerType(player, 'goleiro'),
                        ),
                        IconButton(
                          tooltip: 'Remover',
                          icon: Icon(Icons.remove),
                          color: Colors.grey,
                          onPressed: () => _delPlayerSelected(player),
                        ),
                      ]
                    ),
                    leading: Text('${index+1}'),
                  );
                },
              ),
            ),
          ),
           ButtonBar(
            alignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => _clearListPlayer(context, quantityPlayers),
                child: Icon(Icons.clear_all),
              ),
              ElevatedButton(
                onPressed: () => _showDialogModalDrawTeams(context, quantityPlayers),
                child: Text('Sortear Times'),
              ),
            ],
          ),
        ],
      ),
      
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Players',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: 0,
        selectedItemColor: Colors.black,
        onTap: (index) {
          // Handle navigation to different pages here
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showDialogModalImportData(context),
        child: Icon(Icons.add),
      ),
    );
  }
}