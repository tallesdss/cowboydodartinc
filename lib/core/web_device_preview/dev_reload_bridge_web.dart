import 'dart:convert';
import 'dart:js_interop';

import 'package:cowboydodartinc/core/web_device_preview/dev_bridge_status.dart';
import 'package:web/web.dart' as web;

/// Outcome of a hot reload / restart request via the local `kasy run` bridge.
class DevReloadResult {
  const DevReloadResult({
    required this.ok,
    required this.message,
    this.available = true,
    this.needsRestart = false,
    this.compileError = false,
  });

  final bool ok;
  final String message;

  /// False when the bridge server is not reachable (e.g. not started via kasy).
  final bool available;

  /// True when Flutter rejected hot reload and a full restart (R) is required.
  final bool needsRestart;

  /// True when the project has a compile/analysis error that must be fixed first.
  final bool compileError;
}

/// Convention: `kasy run --web` serves the app on [appPort] and the dev bridge
/// on the next port.
int devBridgePortForAppPort(int appPort) => appPort + 1;

/// Hosts to try when probing the local dev bridge (page host first).
List<String> _bridgeHosts() {
  final pageHost = Uri.base.host;
  final hosts = <String>[
    if (pageHost.isNotEmpty) pageHost,
    'localhost',
    '127.0.0.1',
  ];
  return hosts.toSet().toList();
}

String _bridgeUrl(String host, int bridgePort, String path) =>
    'http://$host:$bridgePort$path';

Future<bool> probeDevBridge(int bridgePort) async {
  final status = await fetchDevBridgeStatus(bridgePort);
  return status.available;
}

Future<DevBridgeStatus> fetchDevBridgeStatus(int bridgePort) async {
  for (final host in _bridgeHosts()) {
    try {
      final response = await web.window
          .fetch(_bridgeUrl(host, bridgePort, '/dev/health').toJS)
          .toDart;
      if (!response.ok) continue;
      final text = (await response.text().toDart).toDart;
      final json = jsonDecode(text) as Map<String, dynamic>;
      if (json['ok'] != true) continue;
      return DevBridgeStatus(
        available: true,
        ready: json['ready'] == true,
        hasError: json['hasError'] == true,
      );
    } catch (_) {
      continue;
    }
  }
  return const DevBridgeStatus.offline();
}

Future<DevReloadResult> requestDevReload(int bridgePort) =>
    _post(bridgePort, 'reload');

Future<DevReloadResult> requestDevRestart(int bridgePort) =>
    _post(bridgePort, 'restart');

Future<DevReloadResult> _post(int bridgePort, String action) async {
  Object? lastError;
  for (final host in _bridgeHosts()) {
    try {
      final response = await web.window
          .fetch(
            _bridgeUrl(host, bridgePort, '/dev/$action').toJS,
            web.RequestInit(method: 'POST'),
          )
          .toDart;
      final text = (await response.text().toDart).toDart;
      if (text.isEmpty) {
        return DevReloadResult(
          ok: false,
          message: 'Empty response (${response.status})',
        );
      }
      final json = jsonDecode(text) as Map<String, dynamic>;
      return DevReloadResult(
        ok: json['ok'] == true,
        message: (json['message'] as String?) ?? '',
        needsRestart: json['needsRestart'] == true,
        compileError: json['compileError'] == true,
      );
    } catch (e) {
      lastError = e;
      continue;
    }
  }
  return DevReloadResult(
    ok: false,
    message: lastError?.toString() ?? '',
    available: false,
  );
}
