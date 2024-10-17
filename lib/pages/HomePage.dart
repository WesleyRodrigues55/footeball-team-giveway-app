import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:footeball_team_giveway_app/components/DIalogModalImportData.dart';
import 'package:footeball_team_giveway_app/components/DialogModalClearPlayerList.dart';
import 'package:footeball_team_giveway_app/components/DialogModalDrawTeams.dart';
import 'package:footeball_team_giveway_app/components/DialogModalDrawnTeams.dart';
import 'package:footeball_team_giveway_app/model/Player.dart';
import 'package:footeball_team_giveway_app/utils/SnackBarPerson.dart';

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
    
      return RegExp(r'^(\d+\s*-\s*|\d+\s*|\-\s*)?.+', caseSensitive: false).hasMatch(trimmed);
    }).map((line) {
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
    SnackBarUtils.showSnackBar(context, 'Jogador(es) adicionado na lista!');
  }

  // Abre o diálogo, e executa a importação da lista de jogadores
  void _showDialogModalImportData(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DialogModalImportData(
          controllerData: controllerData,
          formKey: formKey,
          getData: (BuildContext context, String data) {
            _getData(context, controllerData.text);
          },
        );
      },
    );
  }

  // Abre o diálogo, e executa o sorteio dos times
  void _showDialogModalDrawTeams(BuildContext context, countPlayers) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DialogModalDrawTeam(
          countPlayers: countPlayers,
          controllerPlayersPerTeam: controllerPlayersPerTeam,
          formKey: formKey,
          onDrawTeams: (String playersPerTeam) {
            _drawTeams(playersPerTeam);
          },
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

    specialPlayers.shuffle();
    goalkeepers.shuffle();
    remainingPlayers.shuffle();

    // Distribui um jogador especial (se houver) e um goleiro (se houver) para cada time
    for (var i = 0; i < teams.length; i++) {
      if (specialPlayers.isNotEmpty) {
        teams[i].add(specialPlayers.removeLast());
      }
      if (goalkeepers.isNotEmpty) {
        teams[i].add(goalkeepers.removeLast());
      }
    }

    // Distribui os jogadores restantes nos times, garantindo que cada time tenha no máximo `playersPerTeam` jogadores
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
        return DialogModalDrawnTeams(
          teams: teams,
          copyToClipboard: (List<List<Player>> teams) {
            _copyToClipboard(teams);
          },
        );
      },
    );
  }

  // Copia a lista de jogadores para a área de transferência
  void _copyToClipboard(teams) {
    Clipboard.setData(ClipboardData(
      text: teams.map((team) => 'Time ${teams.indexOf(team) + 1}:\n' + team.map((player) => player.name).join('\n')).join('\n\n')
    ));
    SnackBarUtils.showSnackBar(context, 'Lista de jogadores copiada!');
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

    SnackBarUtils.showSnackBar(context, 'Jogador removido da lista!');
  }

  // Limpa a lista de jogadores
  void _clearListPlayer() {
    setState(() {
      listPlayers.clear();
      quantityPlayers = 0;
    });
    Navigator.of(context).pop();
    SnackBarUtils.showSnackBar(context, 'Lista de jogadores limpa!');
  }

  // Abre o diálogo, e executa a função que limpa a lista de jogadores
  void _showDialogModalClearListPlayer(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return  DialogModalClearPlayerList(
          quantityPlayers: quantityPlayers,
          clearListPlayer:  _clearListPlayer
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.lightGreenAccent,
          title: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Icon(Icons.sports_soccer),
              Center(
                child: Text('Sorteio de times de futebol')
              ),
            ],
          ),
        ),
        body: listPlayers.isEmpty ? HomeListWithEmpty(context) : HomeListWithPlayers(context),

        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.lightGreenAccent,
          onPressed: () => _showDialogModalImportData(context),
          child: Icon(Icons.add),
        ),
      );
  }

  Column HomeListWithPlayers(BuildContext context) {
    return Column(
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
              onPressed: () => _showDialogModalClearListPlayer(context),
              child: Icon(Icons.clear_all),
            ),
            ElevatedButton(
              onPressed: () => _showDialogModalDrawTeams(context, quantityPlayers),
              child: Text('Sortear Times'),
            ),
          ],
        ),
      ],
    );
  }

  Container HomeListWithEmpty(BuildContext context) {
    return Container(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Nenhum jogador na lista'),
                SizedBox(height: 16),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.lightGreenAccent),
                  ),
                  onPressed: () => _showDialogModalImportData(context),
                  child: Container(
                    width: 240,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.import_export),
                        Text('Importar lista de jogadores'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  }
}