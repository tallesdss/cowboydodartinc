import 'package:cowboydodartinc/core/data/models/user.dart';
import 'package:cowboydodartinc/core/extensions/date.ext.dart';
import 'package:cowboydodartinc/core/shared_preferences/shared_preferences.dart';
import 'package:cowboydodartinc/core/states/components/maybeshow_component.dart';
import 'package:cowboydodartinc/core/states/models/event_model.dart';
import 'package:cowboydodartinc/core/states/user_state_notifier.dart';
import 'package:cowboydodartinc/core/widgets/update_bottom_sheet.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';

/// MaybeShow implementation that shows update bottom sheet when app version changes
class MaybeShowUpdateBottomSheet extends MaybeShowWithRef {
  @override
  Future<bool> handle(WidgetRef ref, AppEvent event) async {
    if (event is! OnAppStartEvent) {
      return false;
    }
    if (kIsWeb) return false;

    final sharedPrefs = ref.read(sharedPreferencesProvider);

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentAppVersion = Version.parse(packageInfo.version);

      final lastSeenVersionStr = sharedPrefs.getLastSeenUpdateVersion();
      final lastSeenVersion = lastSeenVersionStr != null
          ? Version.parse(lastSeenVersionStr)
          : null;
      Logger().d(
        "👉 currentAppVersion: $currentAppVersion (last seen version: $lastSeenVersion)",
      );

      // First run on this device (fresh install or reinstall) — just record the
      // current version as baseline. Never show the sheet without a reference point.
      if (lastSeenVersion == null) {
        sharedPrefs.setLastSeenUpdateVersion(currentAppVersion.toString());
        return false;
      }

      // Version hasn't changed since last run — nothing to show.
      if (lastSeenVersion >= currentAppVersion) {
        return false;
      }

      // Version increased. Skip for new users (account created today) to avoid
      // showing "what's new" right after sign-up.
      final userState = ref.watch(userStateNotifierProvider);
      final userCreationDate = switch (userState.user) {
        AuthenticatedUserData(:final creationDate) => creationDate,
        AnonymousUserData(:final creationDate) => creationDate,
        _ => null,
      };

      if (userCreationDate == null ||
          userCreationDate.isSameDay(DateTime.now())) {
        return false;
      }

      if (ref.context.mounted) {
        sharedPrefs.setLastSeenUpdateVersion(currentAppVersion.toString());
        // ignore: use_build_context_synchronously
        await _showUpdateSheet(ref.context, currentAppVersion.toString());
        return true;
      }

      return false;
    } catch (e) {
      // If there's an error getting version info, don't show the sheet
      return false;
    }
  }

  Future<void> _showUpdateSheet(BuildContext context, String version) async {
    // Small delay to ensure the home page is fully loaded
    await Future.delayed(const Duration(milliseconds: 500));

    if (!context.mounted) return;

    await showUpdateBottomSheet(context: context, version: version);
  }
}
