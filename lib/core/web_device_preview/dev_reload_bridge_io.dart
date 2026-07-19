import 'package:cowboydodartinc/core/web_device_preview/dev_bridge_status.dart';

/// Stub — the dev bridge only runs in the browser during `kasy run --web`.
class DevReloadResult {
  const DevReloadResult({
    required this.ok,
    required this.message,
    this.available = false,
    this.needsRestart = false,
    this.compileError = false,
  });

  final bool ok;
  final String message;
  final bool available;
  final bool needsRestart;
  final bool compileError;
}

int devBridgePortForAppPort(int appPort) => appPort + 1;

Future<bool> probeDevBridge(int bridgePort) async => false;

Future<DevBridgeStatus> fetchDevBridgeStatus(int bridgePort) async =>
    const DevBridgeStatus.offline();

Future<DevReloadResult> requestDevReload(int bridgePort) async {
  return const DevReloadResult(ok: false, message: '');
}

Future<DevReloadResult> requestDevRestart(int bridgePort) async {
  return const DevReloadResult(ok: false, message: '');
}
