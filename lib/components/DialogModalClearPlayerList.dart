import 'package:flutter/material.dart';
import 'package:footeball_team_giveway_app/model/Player.dart';

class DialogModalClearPlayerList extends StatefulWidget {
  int quantityPlayers;
  final void Function() clearListPlayer;

  DialogModalClearPlayerList({
    required this.quantityPlayers,
    required this.clearListPlayer,
  });

  @override
  State<DialogModalClearPlayerList> createState() => _DialogModalClearPlayerListState();
}

class _DialogModalClearPlayerListState extends State<DialogModalClearPlayerList> {
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Limpar lista de jogadores'),
          content: Text('Deseja realmente limpar a lista de ${widget.quantityPlayers} jogadores?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => widget.clearListPlayer(),
              child: const Text('Limpar'),
            ),
          ],
      );
  }
}
