// ignore_for_file: use_build_context_synchronously

import 'package:cowboydodartinc/core/data/models/user.dart';
import 'package:cowboydodartinc/core/shared_preferences/shared_preferences.dart';
import 'package:cowboydodartinc/core/states/components/maybeshow_component.dart';
import 'package:cowboydodartinc/core/states/models/event_model.dart';
import 'package:cowboydodartinc/core/states/user_state_notifier.dart';
import 'package:cowboydodartinc/router.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _lastAskKey = 'subscription_last_asking_date';

const _kDaysToAsk = 2;

class MaybeShowPremiumPage implements MaybeShowWithRef {
  @override
  Future<bool> handle(WidgetRef ref, AppEvent event) async {
    if (event is! OnAppStartEvent) {
      return false;
    }
    debugPrint("🧐 MaybeShowPremiumPage");
    final userState = ref.watch(userStateNotifierProvider);
    if (userState.subscription?.isActive == true) {
      return false;
    }
    final userCreationDate = switch(userState.user) {
      AuthenticatedUserData(:final creationDate) => creationDate,
      AnonymousUserData(:final creationDate) => creationDate,
      _ => null,
    };

    if (userCreationDate == null) {
      return false;
    }
    
    final now = DateTime.now();
    final prefs = ref.watch(sharedPreferencesProvider).prefs;
    
    // await prefs.remove(_lastAskKey);
    // await prefs.remove(_lastShowPromoKey);

    final lastAskingDate = prefs.getInt(_lastAskKey);


    /// 🧐 🧐 🧐 if we have a promo - we only show the promo once or customize it
    /// ----
    // final lastShowPromoInMS = prefs.getInt(_lastShowPromoKey);
    // final lastShowPromoDate = lastShowPromoInMS == null ? null : DateTime.fromMillisecondsSinceEpoch(lastShowPromoInMS);
    // if (now.isAfter(userCreationDate.add(const Duration(days: 3))) && lastShowPromoDate == null && ref.context.mounted) {
    //   await prefs.setInt(_lastShowPromoKey, now.millisecondsSinceEpoch);
    //   await prefs.setInt(_lastAskKey, DateTime.now().millisecondsSinceEpoch);
    //   PromoBottomSheet.show(ref.context);
    //   return true;
    // }

    if (now.isBefore(userCreationDate.add(const Duration(days: 1)))) {
      return false;
    }
    
    if (lastAskingDate == null) {
      await prefs.setInt(_lastAskKey, DateTime.now().millisecondsSinceEpoch);
      showPremiumPage(ref);
      return true;
    }

    final lastDate = DateTime.fromMillisecondsSinceEpoch(lastAskingDate);
    
    final difference = now.difference(lastDate);

    if (difference.inDays >= _kDaysToAsk) {
      await prefs.setInt(_lastAskKey, now.millisecondsSinceEpoch);
      showPremiumPage(ref);
      return true;
    }
    
    return false;
  }

  void showPremiumPage(WidgetRef ref) {
    ref.read(goRouterProvider).push("/premium");
  }
}
