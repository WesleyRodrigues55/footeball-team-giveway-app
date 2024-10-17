import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:footeball_team_giveway_app/model/Player.dart';

class DialogModalDrawnTeams extends StatelessWidget {
  final List<List<Player>> teams;
  final void Function(List<List<Player>>) copyToClipboard;

  DialogModalDrawnTeams({
    required this.teams,
    required this.copyToClipboard,
  });

  @override
  Widget build(BuildContext context) {
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
            onPressed: () => copyToClipboard(teams),
            child: Text('Copiar'),
          ),
        ],
      );
  }
}
