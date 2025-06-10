import 'package:flutter/material.dart';

class NotificationHelper {
  static void success(
    BuildContext context,
    String message, {
    Duration? duration,
  }) {
    _showSnackBar(
      context,
      message,
      backgroundColor: const Color(0xFF4CAF50),
      duration: duration ?? const Duration(seconds: 3),
    );
  }

  static void error(
    BuildContext context,
    String message, {
    Duration? duration,
  }) {
    _showSnackBar(
      context,
      message,
      backgroundColor: const Color(0xFFEF5350),
      duration: duration ?? const Duration(seconds: 4),
    );
  }

  static void pending(
    BuildContext context,
    String message, {
    Duration? duration,
  }) {
    _showSnackBar(
      context,
      message,
      backgroundColor: const Color(0xFFFFA726),
      duration: duration ?? const Duration(seconds: 10),
    );
  }

  static void _showSnackBar(
    BuildContext context,
    String message, {
    required Color backgroundColor,
    required Duration duration,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: backgroundColor,
        duration: duration,
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(message, style: const TextStyle(color: Colors.white, fontSize: 15)),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
