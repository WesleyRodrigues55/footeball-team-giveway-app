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

      return RegExp(r'^\d+\s*-\s*').hasMatch(trimmed);
    }).map((line) {
      var name = line.replaceFirst(RegExp(r'^\d+\s*-\s*'), '').trim();
      String typePlayer = 'normal';

      return Player(name: name, typePlayer: typePlayer);
    }).toList();
    
    setState(() {
      listPlayers.addAll(names);
      quantityPlayers = listPlayers.length;
    });

    controllerData.value = TextEditingValue.empty;
    Navigator.of(context).pop();
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
              child: Text('Close'),
            ),
            TextButton(
              onPressed: () {
                _getData(context, controllerData.text);
              },
              child: Text('Import'),
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
              child: Text('Close'),
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

    int playerIndex = 0;
    for (var i = 0; i < teams.length && playerIndex < players.length; i++) {
      while (teams[i].length < playersPerTeam && playerIndex < players.length) {
        teams[i].add(players[playerIndex]);
        playerIndex++;
      }
    }

    // for (var i = 0; i < teams.length; i++) {
    //   print('Time ${i + 1}:');
    //   for (var player in teams[i]) {
    //     print(player.name); 
    //   }
    //   print('');
    // }

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
              child: Text('Close'),
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

  @override
  Widget build(BuildContext context) {
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
                          color: Colors.grey,
                          onPressed: () => _setPlayerType(player, 'especial'),
                        ),
                        IconButton(
                          tooltip: 'Goleiro',
                          icon: Icon(Icons.sports_mma),
                          color: Colors.grey,
                          onPressed: () => _setPlayerType(player, 'goleiro'),
                        ),
                      ]
                    ),
                  );
                },
              ),
            ),
          ),
           ButtonBar(
            alignment: MainAxisAlignment.center,
            children: [
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