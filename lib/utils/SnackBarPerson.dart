import 'package:flutter/material.dart';

class SnackBarUtils {
  static void showSnackBar(BuildContext context, String mensagem, {Color? color}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: color ?? Colors.lightGreenAccent[600],
        duration: Duration(seconds: 1),

      ),
    );
  }
}