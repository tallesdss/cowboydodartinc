import 'package:cowboydodartinc/components/components.dart';
import 'package:flutter/material.dart';

/// Legacy entry point — delegates to [showKasyConfirmDialog] ([KasyDialog]).
@Deprecated('Use showKasyConfirmDialog from package:cowboydodartinc/components/components.dart')
Future<void> showAppDialog(
  BuildContext context, {
  required String title,
  String? message,
  required String cancelLabel,
  required String confirmLabel,
  VoidCallback? onCancel,
  VoidCallback? onConfirm,
  bool destructive = false,
}) {
  return showKasyConfirmDialog(
    context,
    title: title,
    message: message,
    cancelLabel: cancelLabel,
    confirmLabel: confirmLabel,
    onCancel: onCancel,
    onConfirm: onConfirm,
    destructive: destructive,
  );
}
