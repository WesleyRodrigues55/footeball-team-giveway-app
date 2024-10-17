import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DialogModalDrawTeam extends StatelessWidget {
  final int countPlayers;
  final TextEditingController controllerPlayersPerTeam;
  final GlobalKey<FormState> formKey;
  final Function(String) onDrawTeams;

  DialogModalDrawTeam({
    required this.countPlayers,
    required this.controllerPlayersPerTeam,
    required this.formKey,
    required this.onDrawTeams,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Sortear Times'),
      content: Container(
        height: 100,
        child: Column(
          children: [
            Text('Há $countPlayers jogadores na lista.'),
            const SizedBox(height: 16),
            Form(
              key: formKey,
              child: TextFormField(
                controller: controllerPlayersPerTeam,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: const InputDecoration(
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
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onDrawTeams(controllerPlayersPerTeam.text);
          },
          child: const Text('Sortear'),
        ),
      ],
    );
  }
}
