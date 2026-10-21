import 'package:flutter/material.dart';

/// Shows the single snackbar shape used across the app.
///
/// Background, text colour and shape come from `snackBarTheme`
/// (`inverseSurface` in Material 3), so a dynamic or high-contrast scheme is
/// never repainted by hand; only the leading icon marks a failure.
void showAppSnackBar(
  ScaffoldMessengerState messenger,
  String message, {
  bool isError = false,
}) {
  final scheme = Theme.of(messenger.context).colorScheme;
  messenger.showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            size: 20,
            color: scheme.inversePrimary,
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(message)),
        ],
      ),
    ),
  );
}
