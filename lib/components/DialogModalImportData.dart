import 'package:flutter/material.dart';

class DialogModalImportData extends StatelessWidget {
  final TextEditingController controllerData;
  final GlobalKey<FormState> formKey;
  final Function(BuildContext, String) getData;

  DialogModalImportData({ 
    required this.controllerData,
    required this.formKey,
    required this.getData,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Importar lista de jogadores'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controllerData,
            maxLines: 10,
            decoration: const InputDecoration(
              hintText: 'Entradas aceitáveis:\n1- Player 1\n- Player 2\nPlayer 3\n4 Player\n Player',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, insira os dados';
              }
              return null;

            },
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
                getData(context, controllerData.text);
              }
            },
            child: const Text('Importar Lista'),
          ),
        ],
    );
  }
}
