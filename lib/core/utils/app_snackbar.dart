import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppSnack {
  AppSnack._();

  static const _padding = EdgeInsets.symmetric(horizontal: 16, vertical: 12);
  static const _margin = EdgeInsets.all(12);
  static const _borderRadius = 10.0;

  static void success(String title, String message) =>
      _show(title, message, backgroundColor: Colors.green);

  static void error(String title, String message) => _show(
    title,
    message,
    backgroundColor: const Color.fromARGB(211, 229, 62, 62),
  );

  static void info(String title, String message) => _show(
    title,
    message,
    backgroundColor: const Color.fromARGB(223, 30, 59, 138),
  );

  static void _show(
    String title,
    String message, {
    required Color backgroundColor,
  }) {
    Get.snackbar(
      title,
      message,
      backgroundColor: backgroundColor,
      colorText: Colors.black,
      snackPosition: SnackPosition.TOP,
      margin: _margin,
      padding: _padding,
      borderRadius: _borderRadius,
    );
  }
}
