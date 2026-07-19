/// Live status from the local `kasy run` dev bridge (terminal error indicator).
class DevBridgeStatus {
  const DevBridgeStatus({
    required this.available,
    required this.ready,
    required this.hasError,
  });

  const DevBridgeStatus.offline()
      : available = false,
        ready = false,
        hasError = false;

  final bool available;
  final bool ready;
  final bool hasError;
}
