import 'package:cowboydodartinc/core/app_update/app_update_status.dart';
import 'package:cowboydodartinc/core/data/api/remote_config_api.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';

final appUpdateRepositoryProvider = Provider<AppUpdateRepository>(
  (ref) => AppUpdateRepository(
    remoteConfig: ref.read(remoteConfigApiProvider),
  ),
);

/// Decides whether the user should be prompted to update, by comparing the
/// installed version ([PackageInfo]) against the remote `app_latest_version` /
/// `app_min_version` keys.
///
/// Backend-agnostic: the config is read from Firebase Remote Config, which is
/// available on every backend (Firebase / Supabase / API all initialize
/// Firebase Core for push). It is also native-only — the web build is never
/// considered "behind a store".
class AppUpdateRepository {
  final RemoteConfigApi _remoteConfig;

  AppUpdateRepository({required RemoteConfigApi remoteConfig})
      : _remoteConfig = remoteConfig;

  Future<AppUpdateStatus> check() async {
    if (kIsWeb) return AppUpdateStatus.upToDate;
    try {
      final info = await PackageInfo.fromPlatform();
      final Version installed = Version.parse(info.version);
      final Version? latest = _tryParse(_remoteConfig.appUpdate.latestVersion.value);
      final Version? min = _tryParse(_remoteConfig.appUpdate.minVersion.value);

      if (min != null && installed < min) return AppUpdateStatus.forced;
      if (latest != null && installed < latest) return AppUpdateStatus.optional;
      return AppUpdateStatus.upToDate;
    } catch (e) {
      // Never block the app because of a missing/bad config or a parse error.
      Logger().e('AppUpdateRepository.check failed: $e');
      return AppUpdateStatus.upToDate;
    }
  }

  Version? _tryParse(String raw) {
    try {
      return Version.parse(raw.trim());
    } catch (_) {
      return null;
    }
  }
}
