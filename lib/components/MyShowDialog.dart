import 'package:flutter/material.dart';

class MyShowDialog extends StatefulWidget {
  const MyShowDialog({
    Key? key,
    required this.title,
    required this.content,
    required this.actions,
  }) : super(key: key);

  final String title;
  final Widget content;
  final List<Widget> actions;

  @override
  State<MyShowDialog> createState() => _MyShowDialogState();
}

class _MyShowDialogState extends State<MyShowDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: widget.content,
      actions: widget.actions,
    );
  }
}