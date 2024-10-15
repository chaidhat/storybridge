import 'package:flutter/material.dart';
import 'package:mooc/services/translation_service.dart' as translation_service;

void showSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(translation_service.translate(message)),
  ));
}
