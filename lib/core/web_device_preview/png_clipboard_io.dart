import 'dart:typed_data';

import 'package:cowboydodartinc/core/web_device_preview/png_export_result.dart';

/// Non-web stub. The device preview is web-only, so this never runs at runtime —
/// it exists only so the VM / native build (and `flutter test`) compile without
/// the web interop.
Future<PngExportResult> copyOrDownloadPng(Uint8List bytes) async =>
    PngExportResult.unavailable;
