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
        height: 200,
        child: Column(
          children: [
            Text('Há $countPlayers jogadores na lista.'),
            const Text('Defina a quantidade de jogadores por time'),
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
                  hintText: '...',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira um número';
                  }
                  int playersPerTeam = int.parse(value);
                  if (playersPerTeam <= 0) {
                    return 'A quantidade de jogadores por time\ndeve ser maior que zero';
                  }
                  if (playersPerTeam >= countPlayers) {
                    return 'A quantidade de jogadores por time\ndeve ser menor que a quantidade\ntotal de jogadores';
                  }
                    return null;
                },
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
            if (formKey.currentState?.validate() ?? false) {
              Navigator.of(context).pop();
              onDrawTeams(controllerPlayersPerTeam.text);
            }
            },
          child: const Text('Sortear'),
        ),
      ],
    );
  }
}
