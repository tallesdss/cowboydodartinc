import 'package:cowboydodartinc/components/kasy_separator.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:flutter/material.dart';

/// The "or sign in with" rule between the social buttons and the email form —
/// a labelled [KasySeparator], the design-system divider.
class SocialSeparator extends StatelessWidget {
  const SocialSeparator({super.key});

  @override
  Widget build(BuildContext context) {
    return KasySeparator(label: t.auth.signin.or_sign_in_with);
  }
}
