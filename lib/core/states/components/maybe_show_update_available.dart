import 'package:cowboydodartinc/core/app_update/app_update_repository.dart';
import 'package:cowboydodartinc/core/app_update/app_update_status.dart';
import 'package:cowboydodartinc/core/app_update/update_available_sheet.dart';
import 'package:cowboydodartinc/core/states/components/maybeshow_component.dart';
import 'package:cowboydodartinc/core/states/models/event_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// On app start, checks whether a newer version is available (remote config vs
/// installed version) and, if so, prompts the user to update via the store.
///
/// Native-only. Distinct from `MaybeShowUpdateBottomSheet` (the "what's new"
/// sheet, which runs *after* the user already updated): this runs *before*,
/// when the user is behind. It is registered first so a required update
/// pre-empts every other start-up prompt.
class MaybeShowUpdateAvailable extends MaybeShowWithRef {
  @override
  Future<bool> handle(WidgetRef ref, AppEvent event) async {
    if (event is! OnAppStartEvent) return false;
    if (kIsWeb) return false;

    final status = await ref.read(appUpdateRepositoryProvider).check();
    if (status == AppUpdateStatus.upToDate) return false;
    if (!ref.context.mounted) return false;

    await showUpdateAvailableSheet(
      ref.context,
      forced: status == AppUpdateStatus.forced,
    );
    return true;
  }
}
