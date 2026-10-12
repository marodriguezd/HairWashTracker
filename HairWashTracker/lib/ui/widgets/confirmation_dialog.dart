import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback onConfirm;
  final String confirmText;
  final String cancelText;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.content,
    required this.onConfirm,
    this.confirmText = 'Delete',
    this.cancelText = 'Cancel',
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).pop();
          },
          child: Text(cancelText),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Theme.of(context).colorScheme.onError,
          ),
          onPressed: () {
            HapticFeedback.mediumImpact();
            Navigator.of(context).pop();
            onConfirm();
          },
          child: Text(confirmText),
        ),
      ],
    );
  }
}

// Compatibility shim: legacy NeumorphicButton call sites now render as M3 FilledButton.
class NeumorphicButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final bool isDestructive;

  const NeumorphicButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (isDestructive) {
      return FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.error,
          foregroundColor: colorScheme.onError,
        ),
        onPressed: () {
          HapticFeedback.mediumImpact();
          onPressed();
        },
        child: child,
      );
    }
    return FilledButton(
      onPressed: () {
        HapticFeedback.lightImpact();
        onPressed();
      },
      child: child,
    );
  }
}
