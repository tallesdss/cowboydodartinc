///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

part of 'translations.g.dart';

// Path: <root>
typedef TranslationsEn = Translations; // ignore: unused_element
class Translations with BaseTranslations<AppLocale, Translations> {
	/// Returns the current translations of the given [context].
	///
	/// Usage:
	/// final t = Translations.of(context);
	static Translations of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context).translations;

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	Translations({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.en,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <en>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	dynamic operator[](String key) => $meta.getTranslation(key);

	late final Translations _root = this; // ignore: unused_field

	Translations $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => Translations(meta: meta ?? this.$meta);

	// Translations
	late final TranslationsCommonEn common = TranslationsCommonEn.internal(_root);
	late final TranslationsAdminConsoleEn admin_console = TranslationsAdminConsoleEn.internal(_root);
	late final TranslationsHomeEn home = TranslationsHomeEn.internal(_root);
	late final TranslationsAuthEn auth = TranslationsAuthEn.internal(_root);
	late final TranslationsRatePopupEn rate_popup = TranslationsRatePopupEn.internal(_root);
	late final TranslationsPremiumEn premium = TranslationsPremiumEn.internal(_root);
	late final TranslationsActivePremiumEn activePremium = TranslationsActivePremiumEn.internal(_root);
	late final TranslationsOnboardingEn onboarding = TranslationsOnboardingEn.internal(_root);
	late final TranslationsFeatureRequestsEn feature_requests = TranslationsFeatureRequestsEn.internal(_root);
	late final TranslationsUpdateBottomSheetEn update_bottom_sheet = TranslationsUpdateBottomSheetEn.internal(_root);
	late final TranslationsUpdateAvailableEn update_available = TranslationsUpdateAvailableEn.internal(_root);
	late final TranslationsRequestNotificationPermissionEn request_notification_permission = TranslationsRequestNotificationPermissionEn.internal(_root);
	late final TranslationsNotificationPermissionDeniedEn notification_permission_denied = TranslationsNotificationPermissionDeniedEn.internal(_root);
	late final TranslationsReviewPopupEn review_popup = TranslationsReviewPopupEn.internal(_root);
	late final TranslationsNavigationEn navigation = TranslationsNavigationEn.internal(_root);
	late final TranslationsReminderPageEn reminderPage = TranslationsReminderPageEn.internal(_root);
	late final TranslationsTimePickerEn time_picker = TranslationsTimePickerEn.internal(_root);
	late final TranslationsDailyReminderEn dailyReminder = TranslationsDailyReminderEn.internal(_root);
	late final TranslationsSettingsEn settings = TranslationsSettingsEn.internal(_root);
	late final TranslationsRateBannerEn rate_banner = TranslationsRateBannerEn.internal(_root);
	late final TranslationsNotificationsEn notifications = TranslationsNotificationsEn.internal(_root);
	late final TranslationsBottomRouterEn bottom_router = TranslationsBottomRouterEn.internal(_root);
	late final TranslationsAiChatEn ai_chat = TranslationsAiChatEn.internal(_root);
	late final TranslationsPhoneAuthEn phone_auth = TranslationsPhoneAuthEn.internal(_root);
	late final TranslationsRecoverPasswordResultEn recover_password_result = TranslationsRecoverPasswordResultEn.internal(_root);
	late final TranslationsPageNotFoundEn page_not_found = TranslationsPageNotFoundEn.internal(_root);
	late final TranslationsDevInspectorEn devInspector = TranslationsDevInspectorEn.internal(_root);
	late final TranslationsWebDevicePreviewEn webDevicePreview = TranslationsWebDevicePreviewEn.internal(_root);
	late final TranslationsBiometricPromptEn biometric_prompt = TranslationsBiometricPromptEn.internal(_root);
	late final TranslationsHomeWidgetEn home_widget = TranslationsHomeWidgetEn.internal(_root);
	late final TranslationsKanbanEn kanban = TranslationsKanbanEn.internal(_root);
	late final TranslationsLibraryEn library = TranslationsLibraryEn.internal(_root);
	late final TranslationsSearchEn search = TranslationsSearchEn.internal(_root);
}

// Path: common
class TranslationsCommonEn {
	TranslationsCommonEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Close'
	String get close => 'Close';

	/// en: 'Copied'
	String get copied => 'Copied';

	/// en: 'Saved'
	String get saved => 'Saved';

	/// en: 'Error'
	String get error => 'Error';

	/// en: 'Unavailable'
	String get unavailable => 'Unavailable';

	/// en: 'Native app only'
	String get native_only_title => 'Native app only';
}

// Path: admin_console
class TranslationsAdminConsoleEn {
	TranslationsAdminConsoleEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final TranslationsAdminConsoleTabsEn tabs = TranslationsAdminConsoleTabsEn.internal(_root);

	/// en: 'Back to app'
	String get back_to_app => 'Back to app';

	late final TranslationsAdminConsoleOverviewEn overview = TranslationsAdminConsoleOverviewEn.internal(_root);
	late final TranslationsAdminConsoleUsersEn users = TranslationsAdminConsoleUsersEn.internal(_root);
	late final TranslationsAdminConsoleRequestsEn requests = TranslationsAdminConsoleRequestsEn.internal(_root);
	late final TranslationsAdminConsoleCategoriesEn categories = TranslationsAdminConsoleCategoriesEn.internal(_root);
	late final TranslationsAdminConsoleGroupsEn groups = TranslationsAdminConsoleGroupsEn.internal(_root);
	late final TranslationsAdminConsolePaywallsEn paywalls = TranslationsAdminConsolePaywallsEn.internal(_root);
	late final TranslationsAdminConsoleSettingsEntryEn settings_entry = TranslationsAdminConsoleSettingsEntryEn.internal(_root);

	/// en: 'You need to be an admin to view this. Set role: admin on your user record in the backend. The app cannot change this field; validation runs on the server.'
	String get requires_admin => 'You need to be an admin to view this. Set role: admin on your user record in the backend. The app cannot change this field; validation runs on the server.';
}

// Path: home
class TranslationsHomeEn {
	TranslationsHomeEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Kasy example'
	String get title => 'Kasy example';

	/// en: 'Welcome to the Kasy demo'
	String get welcome => 'Welcome to the Kasy demo';

	late final TranslationsHomeCardsEn cards = TranslationsHomeCardsEn.internal(_root);
	late final TranslationsHomeFeaturesPageEn features_page = TranslationsHomeFeaturesPageEn.internal(_root);
	late final TranslationsHomeDashboardEn dashboard = TranslationsHomeDashboardEn.internal(_root);
	late final TranslationsHomeComponentsPreviewEn components_preview = TranslationsHomeComponentsPreviewEn.internal(_root);
}

// Path: auth
class TranslationsAuthEn {
	TranslationsAuthEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final TranslationsAuthSigninEn signin = TranslationsAuthSigninEn.internal(_root);
	late final TranslationsAuthSignupEn signup = TranslationsAuthSignupEn.internal(_root);
	late final TranslationsAuthRecoverEn recover = TranslationsAuthRecoverEn.internal(_root);
}

// Path: rate_popup
class TranslationsRatePopupEn {
	TranslationsRatePopupEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Would you have 15s to rate us?'
	String get title => 'Would you have 15s to rate us?';

	/// en: 'It's fast and very helpful! Thanks a lot!'
	String get description => 'It\'s fast and very helpful! Thanks a lot!';

	/// en: 'Maybe later'
	String get cancel_button => 'Maybe later';

	/// en: 'Yes, with pleasure!'
	String get rate_button => 'Yes, with pleasure!';
}

// Path: premium
class TranslationsPremiumEn {
	TranslationsPremiumEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Unlock full access'
	String get title_1 => 'Unlock full access';

	/// en: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.'
	String get description => 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.';

	/// en: 'Feature 1 lorem ipsum '
	String get feature_1 => 'Feature 1 lorem ipsum ';

	/// en: 'Feature 2 mop issum '
	String get feature_2 => 'Feature 2 mop issum ';

	/// en: 'Feature 3 lorem '
	String get feature_3 => 'Feature 3 lorem ';

	/// en: 'Week'
	String get duration_weekly => 'Week';

	/// en: 'Year'
	String get duration_annual => 'Year';

	/// en: 'Month'
	String get duration_monthly => 'Month';

	/// en: 'Cancel anytime'
	String get duration_monthly_description => 'Cancel anytime';

	/// en: 'Lifetime'
	String get duration_lifetime => 'Lifetime';

	/// en: 'One time payment'
	String get duration_lifetime_description => 'One time payment';

	/// en: 'Restore'
	String get restore_action => 'Restore';

	/// en: 'Preview'
	String get preview_disabled_title => 'Preview';

	/// en: 'This is an admin preview. Purchase actions are disabled.'
	String get preview_disabled_text => 'This is an admin preview. Purchase actions are disabled.';

	/// en: 'Have a coupon?'
	String get coupon_title => 'Have a coupon?';

	/// en: 'Easy 1-click cancel, always'
	String get payment_cancel_reassurance => 'Easy 1-click cancel, always';

	/// en: 'No payment now, cancel anytime'
	String get payment_cancel_reassurance_free_trial => 'No payment now, cancel anytime';

	/// en: 'Start free trial'
	String get payment_action => 'Start free trial';

	/// en: '7-day free trial, then $money'
	String payment_action_trial({required Object money}) => '7-day free trial, then ${money}';

	/// en: 'Try free for $days days'
	String try_free_btn_action({required Object days}) => 'Try free for ${days} days';

	/// en: 'Annual'
	String get duration_recuring_label_annual => 'Annual';

	/// en: 'Monthly'
	String get duration_recuring_label_monthly => 'Monthly';

	/// en: 'Weekly'
	String get duration_recuring_label_weekly => 'Weekly';

	/// en: '/week'
	String get price_per_week => '/week';

	/// en: '/month'
	String get price_per_month => '/month';

	/// en: '/3 months'
	String get price_per_three_month => '/3 months';

	/// en: '/6 months'
	String get price_per_six_month => '/6 months';

	/// en: '/year'
	String get price_per_year => '/year';

	/// en: ''
	String get price_one_time => '';

	/// en: 'Continue'
	String get action_button => 'Continue';

	/// en: 'Terms'
	String get terms => 'Terms';

	/// en: 'Privacy'
	String get privacy => 'Privacy';

	/// en: 'Terms of Use'
	String get terms_of_use => 'Terms of Use';

	/// en: 'Privacy Policy'
	String get privacy_policy => 'Privacy Policy';

	/// en: 'Error while loading the offers'
	String get error_loading => 'Error while loading the offers';

	/// en: 'Subscription options are not available yet'
	String get no_products_title => 'Subscription options are not available yet';

	/// en: 'Please try again in a moment. If this keeps happening, the store products may still be finishing setup.'
	String get no_products_description => 'Please try again in a moment. If this keeps happening, the store products may still be finishing setup.';

	/// en: 'Subscription restored'
	String get restore_success_title => 'Subscription restored';

	/// en: 'Thank you for your trust'
	String get restore_success_text => 'Thank you for your trust';

	/// en: 'Subscription successful'
	String get purchase_success_title => 'Subscription successful';

	/// en: 'Thank you for your trust'
	String get purchase_success_text => 'Thank you for your trust';

	/// en: 'Error'
	String get error_title => 'Error';

	/// en: 'An error occurred. Please try again'
	String get error_text => 'An error occurred. Please try again';

	/// en: 'Payment not confirmed'
	String get web_checkout_timeout_title => 'Payment not confirmed';

	/// en: 'We did not receive payment confirmation. If you already paid, tap Restore.'
	String get web_checkout_timeout_text => 'We did not receive payment confirmation. If you already paid, tap Restore.';

	/// en: 'No subscription found'
	String get restore_none_title => 'No subscription found';

	/// en: 'We could not find an active subscription to restore.'
	String get restore_none_text => 'We could not find an active subscription to restore.';

	late final TranslationsPremiumSoloEn solo = TranslationsPremiumSoloEn.internal(_root);
	late final TranslationsPremiumComparePlanEn comparePlan = TranslationsPremiumComparePlanEn.internal(_root);
	late final TranslationsPremiumTrialPlanEn trialPlan = TranslationsPremiumTrialPlanEn.internal(_root);
	late final TranslationsPremiumUnlockPlanEn unlockPlan = TranslationsPremiumUnlockPlanEn.internal(_root);
	late final TranslationsPremiumComparisonEn comparison = TranslationsPremiumComparisonEn.internal(_root);
}

// Path: activePremium
class TranslationsActivePremiumEn {
	TranslationsActivePremiumEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'You are a premium user'
	String get title => 'You are a premium user';

	/// en: 'Enjoy all the features'
	String get description => 'Enjoy all the features';

	/// en: 'Unsubscribe'
	String get unsubscribe_button => 'Unsubscribe';

	/// en: 'You used a coupon that provided you access to the premium features for free without any subscription. Enjoy!'
	String get early_bird_description => 'You used a coupon that provided you access to the premium features for free without any subscription. Enjoy!';

	/// en: 'Help us improve'
	String get unsubscribe_feedback_title => 'Help us improve';

	/// en: 'We're sorry to see you go. Could you briefly tell us why you're unsubscribing?'
	String get unsubscribe_feedback_description => 'We\'re sorry to see you go. Could you briefly tell us why you\'re unsubscribing?';

	/// en: 'Tell us your reason...'
	String get unsubscribe_feedback_hint => 'Tell us your reason...';

	/// en: 'Minimum 6 characters required'
	String get unsubscribe_feedback_min_chars => 'Minimum 6 characters required';

	/// en: 'Continue'
	String get unsubscribe_confirm_button => 'Continue';

	/// en: 'You are a lifetime user'
	String get lifetime_user_description => 'You are a lifetime user';

	/// en: 'Subscription on another platform'
	String get managed_elsewhere_title => 'Subscription on another platform';

	/// en: 'This subscription was made on another platform and can't be managed or cancelled here. Sign in to your account on the platform where you purchased it.'
	String get managed_elsewhere_description => 'This subscription was made on another platform and can\'t be managed or cancelled here. Sign in to your account on the platform where you purchased it.';

	/// en: 'Restore purchases'
	String get restore_button => 'Restore purchases';

	/// en: 'Close'
	String get cancel_button => 'Close';

	/// en: 'Billing'
	String get billing_title => 'Billing';

	/// en: 'Account plan'
	String get plan_label => 'Account plan';

	/// en: 'Premium'
	String get plan_fallback => 'Premium';

	/// en: 'Manage subscription'
	String get manage_subscription => 'Manage subscription';

	/// en: 'Restore purchases'
	String get restore_purchases => 'Restore purchases';

	/// en: 'Renews on $date'
	String renews_on({required Object date}) => 'Renews on ${date}';

	/// en: 'Expires on $date'
	String expires_on({required Object date}) => 'Expires on ${date}';

	/// en: 'Free trial'
	String get trial_label => 'Free trial';

	/// en: 'Free trial until $date'
	String trial_until({required Object date}) => 'Free trial until ${date}';

	/// en: '$price starting $date'
	String charges_from({required Object price, required Object date}) => '${price} starting ${date}';
}

// Path: onboarding
class TranslationsOnboardingEn {
	TranslationsOnboardingEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final TranslationsOnboardingFeature1En feature_1 = TranslationsOnboardingFeature1En.internal(_root);
	late final TranslationsOnboardingFeature2En feature_2 = TranslationsOnboardingFeature2En.internal(_root);
	late final TranslationsOnboardingFeature3En feature_3 = TranslationsOnboardingFeature3En.internal(_root);
	late final TranslationsOnboardingMockupsEn mockups = TranslationsOnboardingMockupsEn.internal(_root);
	late final TranslationsOnboardingAgeQuestionEn ageQuestion = TranslationsOnboardingAgeQuestionEn.internal(_root);
	late final TranslationsOnboardingGenderQuestionEn genderQuestion = TranslationsOnboardingGenderQuestionEn.internal(_root);
	late final TranslationsOnboardingNotificationsEn notifications = TranslationsOnboardingNotificationsEn.internal(_root);
	late final TranslationsOnboardingAttEn att = TranslationsOnboardingAttEn.internal(_root);
	late final TranslationsOnboardingLoadingEn loading = TranslationsOnboardingLoadingEn.internal(_root);
}

// Path: feature_requests
class TranslationsFeatureRequestsEn {
	TranslationsFeatureRequestsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Ideas'
	String get title => 'Ideas';

	/// en: 'Vote on ideas or share your own. Every voice shapes the roadmap.'
	String get description => 'Vote on ideas or share your own. Every voice shapes the roadmap.';

	/// en: 'Community ideas'
	String get community_ideas => 'Community ideas';

	/// en: 'No ideas yet'
	String get no_requests => 'No ideas yet';

	/// en: 'Be the first to suggest a feature or improvement.'
	String get no_requests_hint => 'Be the first to suggest a feature or improvement.';

	late final TranslationsFeatureRequestsVoteSuccessEn vote_success = TranslationsFeatureRequestsVoteSuccessEn.internal(_root);
	late final TranslationsFeatureRequestsVoteErrorEn vote_error = TranslationsFeatureRequestsVoteErrorEn.internal(_root);
	late final TranslationsFeatureRequestsAddFeatureEn add_feature = TranslationsFeatureRequestsAddFeatureEn.internal(_root);
}

// Path: update_bottom_sheet
class TranslationsUpdateBottomSheetEn {
	TranslationsUpdateBottomSheetEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'What's new?'
	String get title => 'What\'s new?';

	/// en: 'We made some improvements'
	String get description => 'We made some improvements';

	List<String> get highlights => [
		'- Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
		'- Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
		'- Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
	];

	/// en: 'Got it'
	String get continue_button => 'Got it';
}

// Path: update_available
class TranslationsUpdateAvailableEn {
	TranslationsUpdateAvailableEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Update available'
	String get title => 'Update available';

	/// en: 'A newer version of the app is available. Update to get the latest improvements and fixes.'
	String get description => 'A newer version of the app is available. Update to get the latest improvements and fixes.';

	/// en: 'Update required'
	String get forced_title => 'Update required';

	/// en: 'This version is no longer supported. Please update to keep using the app.'
	String get forced_description => 'This version is no longer supported. Please update to keep using the app.';

	/// en: 'Update now'
	String get update_button => 'Update now';

	/// en: 'Not now'
	String get later_button => 'Not now';
}

// Path: request_notification_permission
class TranslationsRequestNotificationPermissionEn {
	TranslationsRequestNotificationPermissionEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Enable notifications?'
	String get title => 'Enable notifications?';

	/// en: 'Get real-time updates and stay on top of what matters.'
	String get description => 'Get real-time updates and stay on top of what matters.';

	/// en: 'Enable'
	String get continue_button => 'Enable';

	/// en: 'Not now'
	String get skip_button => 'Not now';
}

// Path: notification_permission_denied
class TranslationsNotificationPermissionDeniedEn {
	TranslationsNotificationPermissionDeniedEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Permission Required'
	String get title => 'Permission Required';

	/// en: 'To receive notifications, please enable notification permissions in your device settings.'
	String get description => 'To receive notifications, please enable notification permissions in your device settings.';

	/// en: 'Allow notifications'
	String get allow_button => 'Allow notifications';

	/// en: 'Open Settings'
	String get open_settings_button => 'Open Settings';

	/// en: 'Cancel'
	String get cancel_button => 'Cancel';
}

// Path: review_popup
class TranslationsReviewPopupEn {
	TranslationsReviewPopupEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Enjoying the app?'
	String get question_title => 'Enjoying the app?';

	/// en: 'Your answer helps us improve.'
	String get question_description => 'Your answer helps us improve.';

	/// en: 'Yes, I am'
	String get question_positive => 'Yes, I am';

	/// en: 'Could be better'
	String get question_negative => 'Could be better';

	/// en: 'Glad you like it!'
	String get title => 'Glad you like it!';

	/// en: 'A store review makes all the difference. It takes a few seconds and really helps us grow.'
	String get description => 'A store review makes all the difference. It takes a few seconds and really helps us grow.';

	/// en: 'Write a review'
	String get rate_button => 'Write a review';
}

// Path: navigation
class TranslationsNavigationEn {
	TranslationsNavigationEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Home'
	String get home => 'Home';

	/// en: 'Help'
	String get support => 'Help';

	/// en: 'Notifications'
	String get notifications => 'Notifications';

	/// en: 'Config.'
	String get settings => 'Config.';

	/// en: 'Sign out'
	String get logout => 'Sign out';

	/// en: 'Skip to content'
	String get skip_to_content => 'Skip to content';
}

// Path: reminderPage
class TranslationsReminderPageEn {
	TranslationsReminderPageEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Reminders'
	String get title => 'Reminders';

	/// en: 'Enable reminder'
	String get toggleLabel => 'Enable reminder';

	/// en: 'Repeat'
	String get typeLabel => 'Repeat';

	/// en: 'Every day'
	String get daily => 'Every day';

	/// en: 'Every week'
	String get weekly => 'Every week';

	/// en: 'Once'
	String get specificDate => 'Once';

	/// en: 'Time'
	String get timeLabel => 'Time';

	/// en: 'Day of week'
	String get dayLabel => 'Day of week';

	/// en: 'Date'
	String get dateLabel => 'Date';

	/// en: 'Select date'
	String get selectDate => 'Select date';

	/// en: 'Get reminded to come back to the app'
	String get hint => 'Get reminded to come back to the app';

	/// en: 'Every day at $time'
	String summaryDaily({required Object time}) => 'Every day at ${time}';

	/// en: 'Every $day at $time'
	String summaryWeekly({required Object day, required Object time}) => 'Every ${day} at ${time}';

	/// en: 'On $date at $time'
	String summaryDate({required Object date, required Object time}) => 'On ${date} at ${time}';
}

// Path: time_picker
class TranslationsTimePickerEn {
	TranslationsTimePickerEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Select time'
	String get title => 'Select time';

	/// en: 'Select a time'
	String get placeholder => 'Select a time';

	/// en: 'Hour'
	String get hour => 'Hour';

	/// en: 'Minute'
	String get minute => 'Minute';

	/// en: 'AM'
	String get am => 'AM';

	/// en: 'PM'
	String get pm => 'PM';

	/// en: 'OK'
	String get confirm => 'OK';

	/// en: 'Cancel'
	String get cancel => 'Cancel';
}

// Path: dailyReminder
class TranslationsDailyReminderEn {
	TranslationsDailyReminderEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Reminder'
	String get title => 'Reminder';

	/// en: 'Time to drink a glass of water.'
	String get body => 'Time to drink a glass of water.';
}

// Path: settings
class TranslationsSettingsEn {
	TranslationsSettingsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Settings'
	String get title => 'Settings';

	late final TranslationsSettingsAvatarEn avatar = TranslationsSettingsAvatarEn.internal(_root);

	/// en: 'Languages'
	String get language_title => 'Languages';

	/// en: 'Theme'
	String get theme_title => 'Theme';

	/// en: 'System'
	String get theme_option_system => 'System';

	/// en: 'Light'
	String get theme_option_light => 'Light';

	/// en: 'Dark'
	String get theme_option_dark => 'Dark';

	/// en: 'Haptic feedback'
	String get haptic_feedback_title => 'Haptic feedback';

	/// en: 'Hide bars when scrolling'
	String get hide_chrome_on_scroll_title => 'Hide bars when scrolling';

	/// en: 'PREFERENCES'
	String get section_preferences_label => 'PREFERENCES';

	/// en: 'SECURITY'
	String get section_security_label => 'SECURITY';

	/// en: 'HELP'
	String get section_support_label => 'HELP';

	/// en: 'App lock'
	String get biometric_title => 'App lock';

	/// en: 'Require Face ID or Touch ID each time you open the app while signed in.'
	String get biometric_subtitle_ios => 'Require Face ID or Touch ID each time you open the app while signed in.';

	/// en: 'Require Face ID each time you open the app while signed in.'
	String get biometric_subtitle_ios_face => 'Require Face ID each time you open the app while signed in.';

	/// en: 'Require Touch ID each time you open the app while signed in.'
	String get biometric_subtitle_ios_touch => 'Require Touch ID each time you open the app while signed in.';

	/// en: 'We ask you to verify on this device when you open the app while signed in.'
	String get biometric_subtitle_android => 'We ask you to verify on this device when you open the app while signed in.';

	/// en: 'Require face unlock when you open the app while signed in.'
	String get biometric_subtitle_android_face => 'Require face unlock when you open the app while signed in.';

	/// en: 'Require fingerprint unlock when you open the app while signed in.'
	String get biometric_subtitle_android_fingerprint => 'Require fingerprint unlock when you open the app while signed in.';

	/// en: 'Require fingerprint or face unlock when you open while signed in.'
	String get biometric_subtitle_android_face_and_fingerprint => 'Require fingerprint or face unlock when you open while signed in.';

	/// en: 'Turn off lock?'
	String get biometric_disable_title => 'Turn off lock?';

	/// en: 'Anyone with your unlocked phone can open the app until you sign out.'
	String get biometric_disable_message => 'Anyone with your unlocked phone can open the app until you sign out.';

	/// en: 'Turn off'
	String get biometric_disable_confirm => 'Turn off';

	/// en: 'Cancel'
	String get biometric_disable_cancel => 'Cancel';

	/// en: 'Confirm with Face ID or Touch ID to turn on App Lock'
	String get biometric_enable_reason_ios => 'Confirm with Face ID or Touch ID to turn on App Lock';

	/// en: 'Confirm with Face ID to turn on App Lock'
	String get biometric_enable_reason_ios_face => 'Confirm with Face ID to turn on App Lock';

	/// en: 'Confirm with Touch ID to turn on App Lock'
	String get biometric_enable_reason_ios_touch => 'Confirm with Touch ID to turn on App Lock';

	/// en: 'Confirm on this phone to turn on App Lock'
	String get biometric_enable_reason_android => 'Confirm on this phone to turn on App Lock';

	/// en: 'Confirm with face unlock to turn on App Lock'
	String get biometric_enable_reason_android_face => 'Confirm with face unlock to turn on App Lock';

	/// en: 'Confirm with fingerprint to turn on App Lock'
	String get biometric_enable_reason_android_fingerprint => 'Confirm with fingerprint to turn on App Lock';

	/// en: 'Confirm with fingerprint or face unlock to turn on App Lock'
	String get biometric_enable_reason_android_face_and_fingerprint => 'Confirm with fingerprint or face unlock to turn on App Lock';

	/// en: 'Unlock with Face ID or Touch ID'
	String get biometric_login_reason_ios => 'Unlock with Face ID or Touch ID';

	/// en: 'Unlock with Face ID'
	String get biometric_login_reason_ios_face => 'Unlock with Face ID';

	/// en: 'Unlock with Touch ID'
	String get biometric_login_reason_ios_touch => 'Unlock with Touch ID';

	/// en: 'Verify it's you'
	String get biometric_login_reason_android => 'Verify it\'s you';

	/// en: 'Unlock using face unlock'
	String get biometric_login_reason_android_face => 'Unlock using face unlock';

	/// en: 'Unlock using fingerprint'
	String get biometric_login_reason_android_fingerprint => 'Unlock using fingerprint';

	/// en: 'Unlock with fingerprint or face'
	String get biometric_login_reason_android_face_and_fingerprint => 'Unlock with fingerprint or face';

	/// en: 'Enable Face ID, Touch ID, or a device passcode in Settings.'
	String get biometric_unavailable_message_ios => 'Enable Face ID, Touch ID, or a device passcode in Settings.';

	/// en: 'Turn on Face ID or a device passcode in Settings.'
	String get biometric_unavailable_message_ios_face => 'Turn on Face ID or a device passcode in Settings.';

	/// en: 'Turn on Touch ID or a device passcode in Settings.'
	String get biometric_unavailable_message_ios_touch => 'Turn on Touch ID or a device passcode in Settings.';

	/// en: 'Turn on biometric unlock or a screen lock in Settings.'
	String get biometric_unavailable_message_android => 'Turn on biometric unlock or a screen lock in Settings.';

	/// en: 'Add face unlock or a secure screen lock in system settings.'
	String get biometric_unavailable_message_android_face => 'Add face unlock or a secure screen lock in system settings.';

	/// en: 'Add a fingerprint or a secure screen lock in system settings.'
	String get biometric_unavailable_message_android_fingerprint => 'Add a fingerprint or a secure screen lock in system settings.';

	/// en: 'Add a fingerprint or face unlock in Settings.'
	String get biometric_unavailable_message_android_face_and_fingerprint => 'Add a fingerprint or face unlock in Settings.';

	/// en: 'App Lock wasn't enabled.'
	String get biometric_not_enabled_message => 'App Lock wasn\'t enabled.';

	/// en: 'Send feedback'
	String get feedback => 'Send feedback';

	/// en: 'Premium'
	String get premium => 'Premium';

	/// en: 'Billing'
	String get billing => 'Billing';

	/// en: 'Privacy policy'
	String get privacy => 'Privacy policy';

	/// en: 'Help center'
	String get support => 'Help center';

	/// en: 'Yes, sign out'
	String get disconnect => 'Yes, sign out';

	/// en: 'Sign out of your account?'
	String get disconnect_confirm_title => 'Sign out of your account?';

	/// en: 'Are you sure you want to sign out?'
	String get disconnect_confirm_message => 'Are you sure you want to sign out?';

	/// en: 'Cancel'
	String get disconnect_cancel => 'Cancel';

	/// en: 'Sign out'
	String get logout => 'Sign out';

	/// en: 'My account'
	String get my_account => 'My account';

	/// en: 'Not signed in'
	String get not_signed_in => 'Not signed in';

	/// en: 'Register'
	String get register => 'Register';

	/// en: 'Name'
	String get name_label => 'Name';

	/// en: 'Edit'
	String get edit => 'Edit';

	/// en: 'Email'
	String get email_label => 'Email';

	/// en: 'Connected with'
	String get connected_with_label => 'Connected with';

	/// en: 'Email & password'
	String get provider_email => 'Email & password';

	/// en: 'Phone'
	String get provider_phone => 'Phone';

	/// en: 'Create password'
	String get create_password_title => 'Create password';

	/// en: 'Set a password so you can also sign in with email and password, on top of social login.'
	String get create_password_subtitle => 'Set a password so you can also sign in with email and password, on top of social login.';

	/// en: 'New password'
	String get create_password_field => 'New password';

	/// en: 'Confirm password'
	String get create_password_confirm_label => 'Confirm password';

	/// en: 'Password created'
	String get create_password_success => 'Password created';

	/// en: 'Couldn't create the password. Please try again.'
	String get create_password_error => 'Couldn\'t create the password. Please try again.';

	/// en: 'Password must be at least 6 characters'
	String get create_password_too_short => 'Password must be at least 6 characters';

	/// en: 'Passwords don't match'
	String get create_password_mismatch => 'Passwords don\'t match';

	/// en: 'Link $provider'
	String link_social({required Object provider}) => 'Link ${provider}';

	/// en: '$provider linked'
	String link_social_success({required Object provider}) => '${provider} linked';

	/// en: 'Couldn't link the account. Please try again.'
	String get link_social_error => 'Couldn\'t link the account. Please try again.';

	/// en: 'Edit name'
	String get edit_name_title => 'Edit name';

	/// en: 'Your name'
	String get edit_name_hint => 'Your name';

	/// en: 'Save'
	String get edit_name_save => 'Save';

	/// en: 'Cancel'
	String get edit_name_cancel => 'Cancel';

	/// en: 'Name updated'
	String get edit_name_success => 'Name updated';

	/// en: 'Couldn't update your name. Please try again.'
	String get edit_name_error => 'Couldn\'t update your name. Please try again.';

	/// en: 'Bio'
	String get bio_label => 'Bio';

	/// en: 'Write something about yourself...'
	String get bio_hint => 'Write something about yourself...';

	/// en: 'Edit profile'
	String get edit_profile_title => 'Edit profile';

	/// en: 'Save'
	String get edit_profile_save => 'Save';

	/// en: 'Profile updated'
	String get edit_profile_success => 'Profile updated';

	/// en: 'Couldn't update your profile. Please try again.'
	String get edit_profile_error => 'Couldn\'t update your profile. Please try again.';

	/// en: 'Reminders'
	String get reminders => 'Reminders';

	/// en: 'Admin Panel'
	String get admin_panel => 'Admin Panel';

	/// en: 'ADMIN (DEBUG ONLY)'
	String get admin_debug_section_label => 'ADMIN (DEBUG ONLY)';

	/// en: 'This entire Admin section (header, panel, and all options below) only exists in debug builds. It is not included in release; people who install from the store or a production APK never see any of it.'
	String get admin_panel_debug_notice => 'This entire Admin section (header, panel, and all options below) only exists in debug builds. It is not included in release; people who install from the store or a production APK never see any of it.';

	late final TranslationsSettingsDeleteAccountEn delete_account = TranslationsSettingsDeleteAccountEn.internal(_root);
	late final TranslationsSettingsAdminEn admin = TranslationsSettingsAdminEn.internal(_root);
}

// Path: rate_banner
class TranslationsRateBannerEn {
	TranslationsRateBannerEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Do you like our app?'
	String get title => 'Do you like our app?';

	/// en: 'Do you have a minute to leave us a review on the store?'
	String get text => 'Do you have a minute to leave us a review on the store?';

	/// en: 'Yes sure!'
	String get rate_button => 'Yes sure!';

	/// en: 'Later...'
	String get later_button => 'Later...';
}

// Path: notifications
class TranslationsNotificationsEn {
	TranslationsNotificationsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Notifications'
	String get title => 'Notifications';

	/// en: 'No notifications yet'
	String get empty_title => 'No notifications yet';

	/// en: 'Stay tuned for updates'
	String get empty_subtitle => 'Stay tuned for updates';

	/// en: 'Error fetching notifications'
	String get error_fetching => 'Error fetching notifications';

	/// en: 'Push notifications'
	String get push_title => 'Push notifications';

	/// en: 'You are receiving alerts'
	String get push_subtitle_enabled => 'You are receiving alerts';

	/// en: 'Tap to enable in Settings'
	String get push_subtitle_disabled => 'Tap to enable in Settings';

	/// en: 'Enable to stay in the loop'
	String get push_subtitle_waiting => 'Enable to stay in the loop';

	/// en: 'Mark as read'
	String get mark_all_read => 'Mark as read';

	/// en: 'See all'
	String get see_all => 'See all';

	/// en: 'Today'
	String get group_today => 'Today';

	/// en: 'Yesterday'
	String get group_yesterday => 'Yesterday';

	/// en: 'Older'
	String get group_older => 'Older';

	/// en: 'Enable notifications'
	String get empty_cta => 'Enable notifications';

	/// en: 'Open settings'
	String get empty_cta_open_settings => 'Open settings';

	/// en: 'Delete all'
	String get delete_all => 'Delete all';

	/// en: 'Options'
	String get options => 'Options';

	/// en: 'Delete all notifications?'
	String get delete_all_confirm_title => 'Delete all notifications?';

	/// en: 'This will permanently remove every notification from your account. This cannot be undone.'
	String get delete_all_confirm_message => 'This will permanently remove every notification from your account. This cannot be undone.';

	/// en: 'Yes, delete'
	String get delete_action => 'Yes, delete';

	/// en: 'Cancel'
	String get cancel_action => 'Cancel';

	/// en: 'Notification deleted'
	String get deleted_one => 'Notification deleted';

	/// en: 'All notifications deleted'
	String get deleted_all => 'All notifications deleted';

	/// en: 'New Comment'
	String get new_comment_title => 'New Comment';

	/// en: 'A new comment was added to your PDF: "{pdfTitle}"'
	String get new_comment_body => 'A new comment was added to your PDF: "{pdfTitle}"';
}

// Path: bottom_router
class TranslationsBottomRouterEn {
	TranslationsBottomRouterEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'This is a fake page'
	String get fake_page_text => 'This is a fake page';
}

// Path: ai_chat
class TranslationsAiChatEn {
	TranslationsAiChatEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'AI Assistant'
	String get title => 'AI Assistant';

	/// en: 'Start a conversation with your assistant.'
	String get empty_state => 'Start a conversation with your assistant.';

	/// en: 'Ask something...'
	String get hint => 'Ask something...';

	/// en: 'The assistant isn't available yet. Please try again later.'
	String get error_not_configured => 'The assistant isn\'t available yet. Please try again later.';

	/// en: 'We couldn't get a reply. Please try again.'
	String get error_no_reply => 'We couldn\'t get a reply. Please try again.';

	/// en: 'Could not reach the AI assistant.'
	String get error_network => 'Could not reach the AI assistant.';

	/// en: 'New conversation'
	String get new_conversation => 'New conversation';

	/// en: 'No conversations yet'
	String get conversations_empty => 'No conversations yet';

	/// en: 'Tap New conversation to get started.'
	String get conversations_empty_hint => 'Tap New conversation to get started.';

	/// en: 'Pick a conversation, or start a new one.'
	String get no_conversation_selected => 'Pick a conversation, or start a new one.';

	/// en: 'Delete conversation?'
	String get delete_title => 'Delete conversation?';

	/// en: 'This conversation and all its messages will be permanently deleted.'
	String get delete_message => 'This conversation and all its messages will be permanently deleted.';

	/// en: 'Cancel'
	String get delete_cancel => 'Cancel';

	/// en: 'Yes, delete'
	String get delete_confirm => 'Yes, delete';
}

// Path: phone_auth
class TranslationsPhoneAuthEn {
	TranslationsPhoneAuthEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Phone Authentication'
	String get title_input => 'Phone Authentication';

	/// en: 'Enter your phone number'
	String get subtitle_input => 'Enter your phone number';

	/// en: 'We will send you a verification code to confirm your identity'
	String get description_input => 'We will send you a verification code to confirm your identity';

	/// en: 'Phone Number'
	String get phone_label => 'Phone Number';

	/// en: '+1 (555) 123-4567'
	String get phone_hint => '+1 (555) 123-4567';

	/// en: 'Please enter a phone number'
	String get error_empty => 'Please enter a phone number';

	/// en: 'Please enter a valid phone number'
	String get error_invalid => 'Please enter a valid phone number';

	/// en: 'Continue'
	String get continue_btn => 'Continue';

	/// en: 'Verify code'
	String get title_verify => 'Verify code';

	/// en: 'Verification Code'
	String get verification_code => 'Verification Code';

	/// en: 'We have sent a verification code to $phone'
	String code_sent({required Object phone}) => 'We have sent a verification code to ${phone}';

	/// en: 'All set'
	String get signin_success_title => 'All set';

	/// en: 'You're now signed in with your phone number'
	String get signin_success_text => 'You\'re now signed in with your phone number';

	/// en: 'Verify Code'
	String get verify_code => 'Verify Code';

	/// en: 'Resend Code'
	String get resend_code => 'Resend Code';

	/// en: 'Please enter all 6 digits'
	String get enter_all_digits => 'Please enter all 6 digits';
}

// Path: recover_password_result
class TranslationsRecoverPasswordResultEn {
	TranslationsRecoverPasswordResultEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Email sent'
	String get title => 'Email sent';

	/// en: 'We sent you an email with a link to reset your password'
	String get description => 'We sent you an email with a link to reset your password';

	/// en: 'Get back to Sign in'
	String get back_to_signin => 'Get back to Sign in';

	/// en: 'Note: If you don't receive an email, please check your spam folder'
	String get note => 'Note: If you don\'t receive an email, please check your spam folder';
}

// Path: page_not_found
class TranslationsPageNotFoundEn {
	TranslationsPageNotFoundEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: '404 - Page not found'
	String get title => '404 - Page not found';
}

// Path: devInspector
class TranslationsDevInspectorEn {
	TranslationsDevInspectorEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Context copied. Paste into your AI chat.'
	String get copied => 'Context copied. Paste into your AI chat.';

	/// en: 'Activate widget inspector'
	String get activate => 'Activate widget inspector';

	/// en: 'Deactivate widget inspector'
	String get deactivate => 'Deactivate widget inspector';

	/// en: 'Copy for AI'
	String get copyForAi => 'Copy for AI';

	/// en: 'Select a widget on screen first.'
	String get selectWidgetFirst => 'Select a widget on screen first.';

	/// en: 'Tap a widget to select. Context copies automatically. Press C to copy again.'
	String get inspectorHint => 'Tap a widget to select. Context copies automatically. Press C to copy again.';

	/// en: 'Inspecting'
	String get statusActive => 'Inspecting';
}

// Path: webDevicePreview
class TranslationsWebDevicePreviewEn {
	TranslationsWebDevicePreviewEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Frame'
	String get frame => 'Frame';

	/// en: 'Dark background'
	String get darkBackground => 'Dark background';

	/// en: 'Dark theme'
	String get darkTheme => 'Dark theme';

	/// en: 'Landscape'
	String get landscape => 'Landscape';

	/// en: 'Text scale'
	String get textScale => 'Text scale';

	/// en: 'Screenshot'
	String get screenshot => 'Screenshot';

	/// en: 'Image copied — paste it in chat'
	String get imageCopied => 'Image copied — paste it in chat';

	/// en: 'Image downloaded'
	String get imageDownloaded => 'Image downloaded';

	/// en: 'Hot reload'
	String get hotReload => 'Hot reload';

	/// en: 'Hot restart'
	String get hotRestart => 'Hot restart';

	/// en: 'Reloading…'
	String get hotReloading => 'Reloading…';

	/// en: 'Restarting…'
	String get hotRestarting => 'Restarting…';

	/// en: 'Reload complete'
	String get hotReloadDone => 'Reload complete';

	/// en: 'Restart complete'
	String get hotRestartDone => 'Restart complete';

	/// en: 'Reload failed'
	String get hotReloadFailed => 'Reload failed';

	/// en: 'That change needs a full restart — tap R'
	String get hotReloadNeedsRestart => 'That change needs a full restart — tap R';

	/// en: 'Code error — fix it in the editor, then reload'
	String get hotReloadCompileError => 'Code error — fix it in the editor, then reload';

	/// en: 'Restart failed'
	String get hotRestartFailed => 'Restart failed';

	/// en: 'Code error — fix it in the editor, then restart'
	String get hotRestartCompileError => 'Code error — fix it in the editor, then restart';

	/// en: 'Terminal clear — r is good to go'
	String get terminalStatusOk => 'Terminal clear — r is good to go';

	/// en: 'Terminal has an error — fix it or tap R'
	String get terminalStatusError => 'Terminal has an error — fix it or tap R';

	/// en: 'Terminal bridge offline — run kasy run --web'
	String get terminalStatusOffline => 'Terminal bridge offline — run kasy run --web';

	/// en: 'Dev server offline — run kasy run --web, keep the terminal open, and open the URL it prints'
	String get devBridgeUnavailable => 'Dev server offline — run kasy run --web, keep the terminal open, and open the URL it prints';
}

// Path: biometric_prompt
class TranslationsBiometricPromptEn {
	TranslationsBiometricPromptEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Turn on Face ID for App Lock?'
	String get title_ios_face => 'Turn on Face ID for App Lock?';

	/// en: 'Turn on Touch ID for App Lock?'
	String get title_ios_touch => 'Turn on Touch ID for App Lock?';

	/// en: 'Turn on Face ID/Touch ID for App Lock?'
	String get title_ios_mixed => 'Turn on Face ID/Touch ID for App Lock?';

	/// en: 'Turn on App Lock with face unlock?'
	String get title_android_face => 'Turn on App Lock with face unlock?';

	/// en: 'Turn on App Lock with fingerprint?'
	String get title_android_fingerprint => 'Turn on App Lock with fingerprint?';

	/// en: 'Protect the app with your phone?'
	String get title_android_mixed => 'Protect the app with your phone?';

	/// en: 'You'll confirm with Face ID when you open the app—you stay signed in.'
	String get message_ios_face => 'You\'ll confirm with Face ID when you open the app—you stay signed in.';

	/// en: 'You'll confirm with Touch ID when you open the app—you stay signed in.'
	String get message_ios_touch => 'You\'ll confirm with Touch ID when you open the app—you stay signed in.';

	/// en: 'When you launch you'll confirm with Face ID or Touch ID—you stay signed in.'
	String get message_ios_mixed => 'When you launch you\'ll confirm with Face ID or Touch ID—you stay signed in.';

	/// en: 'You'll confirm with face unlock when you open—you stay signed in.'
	String get message_android_face => 'You\'ll confirm with face unlock when you open—you stay signed in.';

	/// en: 'You'll confirm with fingerprint when you open—you stay signed in.'
	String get message_android_fingerprint => 'You\'ll confirm with fingerprint when you open—you stay signed in.';

	/// en: 'Turn on App Lock with fingerprint or face?'
	String get title_android_face_and_fingerprint => 'Turn on App Lock with fingerprint or face?';

	/// en: 'Either works—you stay signed in.'
	String get message_android_face_and_fingerprint => 'Either works—you stay signed in.';

	/// en: 'A quick check when you open—you stay signed in.'
	String get message_android_mixed => 'A quick check when you open—you stay signed in.';

	/// en: 'Not now'
	String get not_now => 'Not now';

	/// en: 'Turn on'
	String get enable => 'Turn on';
}

// Path: home_widget
class TranslationsHomeWidgetEn {
	TranslationsHomeWidgetEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Good morning'
	String get greeting_morning => 'Good morning';

	/// en: 'Good afternoon'
	String get greeting_afternoon => 'Good afternoon';

	/// en: 'Good evening'
	String get greeting_evening => 'Good evening';

	/// en: 'Hi, $name!'
	String title_with_name({required Object name}) => 'Hi, ${name}!';

	/// en: 'Hi there!'
	String get title_default => 'Hi there!';

	/// en: 'We'll be here when you're back'
	String get title_logged_out => 'We\'ll be here when you\'re back';

	/// en: 'Free plan'
	String get plan_free => 'Free plan';

	/// en: 'PRO'
	String get plan_pro => 'PRO';

	/// en: 'Your time is limited. Don't live someone else's life. Have the courage to follow your intuition. Everything else is secondary.'
	String get quote => 'Your time is limited.\nDon\'t live someone else\'s life.\nHave the courage to follow your intuition.\nEverything else is secondary.';

	/// en: 'Steve Jobs'
	String get quote_author => 'Steve Jobs';
}

// Path: kanban
class TranslationsKanbanEn {
	TranslationsKanbanEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Tasks'
	String get title => 'Tasks';

	/// en: 'Organize your tasks'
	String get empty_title => 'Organize your tasks';

	/// en: 'Create custom columns and start organizing what needs to be done in your project.'
	String get empty_description => 'Create custom columns and start organizing what needs to be done in your project.';

	/// en: 'No tasks in this column'
	String get empty_column => 'No tasks in this column';

	/// en: 'Failed to load'
	String get error_title => 'Failed to load';

	/// en: 'Add column'
	String get add_column => 'Add column';

	/// en: 'Pick a short name to organize tasks in this column.'
	String get add_column_subtitle => 'Pick a short name to organize tasks in this column.';

	/// en: 'Add another list'
	String get add_another_list => 'Add another list';

	/// en: 'Add list'
	String get add_list => 'Add list';

	/// en: 'Enter list name...'
	String get list_name_hint => 'Enter list name...';

	/// en: 'Add task'
	String get add_task => 'Add task';

	/// en: 'Set a title and, optionally, a description and priority.'
	String get add_task_subtitle => 'Set a title and, optionally, a description and priority.';

	/// en: 'Edit column'
	String get edit_column => 'Edit column';

	/// en: 'Update this task's details.'
	String get edit_task_subtitle => 'Update this task\'s details.';

	/// en: 'Cancel'
	String get cancel => 'Cancel';

	/// en: 'Save'
	String get save => 'Save';

	/// en: 'Delete column'
	String get delete_column => 'Delete column';

	/// en: 'Edit task'
	String get edit_task => 'Edit task';

	/// en: 'Delete task'
	String get delete_task => 'Delete task';

	/// en: 'Column name'
	String get column_name => 'Column name';

	/// en: 'e.g., In Progress, Done'
	String get column_name_hint => 'e.g., In Progress, Done';

	/// en: 'Task title'
	String get task_title => 'Task title';

	/// en: 'e.g., Implement login'
	String get task_title_hint => 'e.g., Implement login';

	/// en: 'Enter a task title.'
	String get task_title_required => 'Enter a task title.';

	/// en: 'Enter a column name.'
	String get column_name_required => 'Enter a column name.';

	/// en: 'Description'
	String get task_description => 'Description';

	/// en: 'Task details'
	String get task_description_hint => 'Task details';

	/// en: 'Create'
	String get create => 'Create';

	/// en: 'Mark as complete'
	String get mark_complete => 'Mark as complete';

	/// en: 'Mark as pending'
	String get mark_incomplete => 'Mark as pending';

	/// en: 'Column created'
	String get column_created => 'Column created';

	/// en: 'Column updated'
	String get column_updated => 'Column updated';

	/// en: 'Column deleted'
	String get column_deleted => 'Column deleted';

	/// en: 'Task created'
	String get task_created => 'Task created';

	/// en: 'Task updated'
	String get task_updated => 'Task updated';

	/// en: 'Task deleted'
	String get task_deleted => 'Task deleted';

	/// en: 'Priority'
	String get priority => 'Priority';

	/// en: 'None'
	String get priority_none => 'None';

	/// en: 'Low'
	String get priority_low => 'Low';

	/// en: 'Medium'
	String get priority_medium => 'Medium';

	/// en: 'High'
	String get priority_high => 'High';

	/// en: 'Urgent'
	String get priority_urgent => 'Urgent';

	/// en: '$count cards'
	String cards_count({required Object count}) => '${count} cards';

	/// en: 'Move to column'
	String get move_to => 'Move to column';

	/// en: 'Move left'
	String get move_left => 'Move left';

	/// en: 'Move right'
	String get move_right => 'Move right';

	/// en: 'This will permanently delete all cards in this column.'
	String get delete_column_confirm => 'This will permanently delete all cards in this column.';

	/// en: 'This task will be permanently deleted.'
	String get delete_task_confirm => 'This task will be permanently deleted.';

	/// en: 'Created on $date'
	String created_on({required Object date}) => 'Created on ${date}';
}

// Path: library
class TranslationsLibraryEn {
	TranslationsLibraryEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Library'
	String get title => 'Library';

	/// en: 'Categories'
	String get categories => 'Categories';

	/// en: 'Manage Categories'
	String get manage_categories => 'Manage Categories';

	/// en: 'Add Category'
	String get add_category => 'Add Category';

	/// en: 'Edit Category'
	String get edit_category => 'Edit Category';

	/// en: 'Delete Category'
	String get delete_category => 'Delete Category';

	/// en: 'Category Name'
	String get category_name => 'Category Name';

	/// en: 'Category Description'
	String get category_desc => 'Category Description';

	/// en: 'Save'
	String get save => 'Save';

	/// en: 'Cancel'
	String get cancel => 'Cancel';

	/// en: 'PDFs'
	String get pdfs => 'PDFs';

	/// en: 'Favorites'
	String get favorites => 'Favorites';

	/// en: 'Search by title, author, or tag...'
	String get search_hint => 'Search by title, author, or tag...';

	/// en: 'Add PDF'
	String get add_pdf => 'Add PDF';

	/// en: 'Edit PDF'
	String get edit_pdf => 'Edit PDF';

	/// en: 'Delete PDF'
	String get delete_pdf => 'Delete PDF';

	/// en: 'Title'
	String get pdf_title => 'Title';

	/// en: 'Description'
	String get pdf_desc => 'Description';

	/// en: 'Author'
	String get pdf_author => 'Author';

	/// en: 'PDF File URL'
	String get pdf_url => 'PDF File URL';

	/// en: 'Thumbnail URL'
	String get pdf_thumb => 'Thumbnail URL';

	/// en: 'Tags (comma-separated)'
	String get pdf_tags => 'Tags (comma-separated)';

	/// en: 'No PDFs found'
	String get no_pdfs => 'No PDFs found';

	/// en: 'Comments'
	String get comments => 'Comments';

	/// en: 'Write a comment...'
	String get write_comment => 'Write a comment...';

	/// en: 'Submit Comment'
	String get submit_comment => 'Submit Comment';

	/// en: 'Rating'
	String get rating => 'Rating';

	/// en: 'Download'
	String get download => 'Download';

	/// en: 'Read'
	String get read => 'Read';

	/// en: 'You must be an admin to view this page.'
	String get unauthorized => 'You must be an admin to view this page.';

	/// en: 'Switch Profile'
	String get profile_switcher => 'Switch Profile';

	/// en: 'Active Profile'
	String get active_profile => 'Active Profile';

	/// en: 'Admin / Dev'
	String get admin_dev => 'Admin / Dev';

	/// en: 'Client'
	String get client => 'Client';

	/// en: 'Simulated Reader'
	String get read_sim => 'Simulated Reader';

	/// en: 'Previous'
	String get prev_page => 'Previous';

	/// en: 'Next'
	String get next_page => 'Next';

	/// en: 'Zoom In'
	String get zoom_in => 'Zoom In';

	/// en: 'Zoom Out'
	String get zoom_out => 'Zoom Out';

	/// en: 'Page $page of $total'
	String page_info({required Object page, required Object total}) => 'Page ${page} of ${total}';

	/// en: 'No comments yet. Be the first to comment!'
	String get no_comments => 'No comments yet. Be the first to comment!';

	/// en: 'My PDFs'
	String get my_pdfs => 'My PDFs';

	/// en: 'Send PDF'
	String get send_pdf => 'Send PDF';

	/// en: 'No PDFs sent by clients yet.'
	String get no_client_pdfs => 'No PDFs sent by clients yet.';

	/// en: 'Click to upload your PDF'
	String get upload_box_title => 'Click to upload your PDF';

	/// en: 'Supported format: PDF (Max 10MB)'
	String get upload_box_subtitle => 'Supported format: PDF (Max 10MB)';

	/// en: 'PDF Preview'
	String get pdf_preview => 'PDF Preview';

	/// en: 'Pages'
	String get pages => 'Pages';

	/// en: 'Change File'
	String get change_file => 'Change File';

	/// en: 'Explore'
	String get explore => 'Explore';

	/// en: 'Visit profile'
	String get visit_profile => 'Visit profile';

	/// en: 'No public PDFs uploaded by others yet.'
	String get no_public_pdfs => 'No public PDFs uploaded by others yet.';

	/// en: 'Uploaded by'
	String get uploaded_by => 'Uploaded by';

	/// en: 'Sent by'
	String get sent_by => 'Sent by';

	/// en: 'Public Profile'
	String get public_profile => 'Public Profile';

	/// en: 'View all PDFs from this user'
	String get view_all_pdfs => 'View all PDFs from this user';
}

// Path: search
class TranslationsSearchEn {
	TranslationsSearchEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Global Search'
	String get title => 'Global Search';

	/// en: 'Search authors, themes and PDFs...'
	String get hint => 'Search authors, themes and PDFs...';

	/// en: 'Authors'
	String get authors => 'Authors';

	/// en: 'Themes'
	String get categories => 'Themes';

	/// en: 'PDFs'
	String get pdfs => 'PDFs';

	/// en: 'No results found for "{query}".'
	String get empty => 'No results found for "{query}".';
}

// Path: admin_console.tabs
class TranslationsAdminConsoleTabsEn {
	TranslationsAdminConsoleTabsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Overview'
	String get overview => 'Overview';

	/// en: 'Users'
	String get users => 'Users';

	/// en: 'Requests'
	String get requests => 'Requests';

	/// en: 'Categories'
	String get categories => 'Categories';

	/// en: 'Tools'
	String get tools => 'Tools';

	/// en: 'Debug'
	String get debug => 'Debug';
}

// Path: admin_console.overview
class TranslationsAdminConsoleOverviewEn {
	TranslationsAdminConsoleOverviewEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Project'
	String get section => 'Project';

	/// en: 'Summary'
	String get summary => 'Summary';

	/// en: 'Backend'
	String get backend => 'Backend';

	/// en: 'Account'
	String get account => 'Account';

	/// en: 'Guest'
	String get guest => 'Guest';

	/// en: 'User ID'
	String get user_id => 'User ID';

	/// en: 'Build'
	String get build => 'Build';

	/// en: 'Current session'
	String get session_title => 'Current session';

	/// en: 'Feature requests'
	String get requests_metric => 'Feature requests';

	/// en: 'Total users'
	String get total_users => 'Total users';

	/// en: 'Subscribers'
	String get subscribers => 'Subscribers';

	/// en: 'New (7 days)'
	String get new_7d => 'New (7 days)';

	/// en: 'New sign-ups'
	String get signups_title => 'New sign-ups';

	/// en: 'Last 14 days'
	String get signups_subtitle => 'Last 14 days';

	/// en: '$count in 14 days'
	String signups_total({required Object count}) => '${count} in 14 days';

	/// en: 'No sign-ups in this period.'
	String get signups_empty => 'No sign-ups in this period.';

	/// en: 'Plan breakdown'
	String get plan_split_title => 'Plan breakdown';

	/// en: 'Free'
	String get free => 'Free';

	/// en: 'Subscriber'
	String get subscriber => 'Subscriber';

	/// en: '$percent subscribers'
	String conversion({required Object percent}) => '${percent} subscribers';

	/// en: 'Based on the $count most recent users.'
	String loaded_note({required Object count}) => 'Based on the ${count} most recent users.';

	/// en: 'Open the Users tab to manage every account.'
	String get users_hint => 'Open the Users tab to manage every account.';

	/// en: 'Debug console — visible only in development builds.'
	String get debug_note => 'Debug console — visible only in development builds.';
}

// Path: admin_console.users
class TranslationsAdminConsoleUsersEn {
	TranslationsAdminConsoleUsersEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Users'
	String get title => 'Users';

	/// en: 'Search by name or e-mail'
	String get search_hint => 'Search by name or e-mail';

	/// en: 'User'
	String get col_user => 'User';

	/// en: 'Status'
	String get col_status => 'Status';

	/// en: 'Plan'
	String get col_plan => 'Plan';

	/// en: 'Role'
	String get col_role => 'Role';

	/// en: 'Actions'
	String get col_action => 'Actions';

	/// en: 'Joined'
	String get col_joined => 'Joined';

	/// en: 'Active'
	String get status_active => 'Active';

	/// en: 'Inactive'
	String get status_inactive => 'Inactive';

	/// en: 'Blocked'
	String get status_blocked => 'Blocked';

	/// en: 'Admin'
	String get role_admin => 'Admin';

	/// en: 'User'
	String get role_user => 'User';

	/// en: 'Make Admin'
	String get action_make_admin => 'Make Admin';

	/// en: 'Remove Admin'
	String get action_remove_admin => 'Remove Admin';

	/// en: 'Block Access'
	String get action_block => 'Block Access';

	/// en: 'Unblock Access'
	String get action_unblock => 'Unblock Access';

	/// en: 'Subscriber'
	String get plan_subscriber => 'Subscriber';

	/// en: 'Free'
	String get plan_free => 'Free';

	/// en: 'No users found'
	String get empty => 'No users found';

	/// en: 'When someone creates an account, it shows up here.'
	String get empty_hint => 'When someone creates an account, it shows up here.';

	/// en: 'Couldn't load users. Make sure you are an admin.'
	String get error => 'Couldn\'t load users. Make sure you are an admin.';

	/// en: 'Page $page of $total'
	String page({required Object page, required Object total}) => 'Page ${page} of ${total}';

	/// en: 'Previous'
	String get prev => 'Previous';

	/// en: 'Next'
	String get next => 'Next';

	/// en: 'Anonymous'
	String get anonymous => 'Anonymous';

	/// en: 'All users'
	String get filter_all => 'All users';

	/// en: 'Subscribers'
	String get filter_subscribers => 'Subscribers';

	/// en: 'Loading users…'
	String get loading => 'Loading users…';

	/// en: 'Showing $from to $to of $total'
	String results({required Object from, required Object to, required Object total}) => 'Showing ${from} to ${to} of ${total}';

	/// en: 'Showing the $count most recent. Search covers the loaded set.'
	String truncated({required Object count}) => 'Showing the ${count} most recent. Search covers the loaded set.';

	/// en: 'Search scanned a limited set. Some matches may be missing.'
	String get search_capped => 'Search scanned a limited set. Some matches may be missing.';

	/// en: 'No users match your search'
	String get empty_search => 'No users match your search';

	/// en: 'Try a different name or e-mail.'
	String get empty_search_hint => 'Try a different name or e-mail.';

	/// en: 'No subscribers found'
	String get empty_subscribers => 'No subscribers found';

	/// en: 'Anyone on the premium plan will show up in this filter.'
	String get empty_subscribers_hint => 'Anyone on the premium plan will show up in this filter.';

	/// en: 'Refresh'
	String get refresh => 'Refresh';

	/// en: 'Try again'
	String get retry => 'Try again';
}

// Path: admin_console.requests
class TranslationsAdminConsoleRequestsEn {
	TranslationsAdminConsoleRequestsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Feature requests'
	String get title => 'Feature requests';

	/// en: 'Feature requests and suggestions submitted by your users. Mark one visible to show it in the app, or hide the ones that don't fit.'
	String get subtitle => 'Feature requests and suggestions submitted by your users. Mark one visible to show it in the app, or hide the ones that don\'t fit.';

	/// en: 'No feature requests yet'
	String get empty => 'No feature requests yet';

	/// en: 'When a user sends an idea, it shows up here.'
	String get empty_hint => 'When a user sends an idea, it shows up here.';

	/// en: '$count votes'
	String votes({required Object count}) => '${count} votes';

	/// en: 'Visible'
	String get visible => 'Visible';

	/// en: 'Hidden'
	String get hidden => 'Hidden';

	/// en: 'Edit'
	String get edit => 'Edit';

	/// en: 'Couldn't load feature requests'
	String get error => 'Couldn\'t load feature requests';

	/// en: 'Feature request updated'
	String get saved => 'Feature request updated';

	/// en: 'Edit feature request'
	String get editor_title => 'Edit feature request';

	/// en: 'Title'
	String get field_title => 'Title';

	/// en: 'Description'
	String get field_description => 'Description';

	/// en: 'English'
	String get lang_en => 'English';

	/// en: 'Portuguese'
	String get lang_pt => 'Portuguese';

	/// en: 'Spanish'
	String get lang_es => 'Spanish';

	/// en: 'Visible to users'
	String get visibility => 'Visible to users';

	/// en: 'Save'
	String get save => 'Save';

	/// en: 'Cancel'
	String get cancel => 'Cancel';
}

// Path: admin_console.categories
class TranslationsAdminConsoleCategoriesEn {
	TranslationsAdminConsoleCategoriesEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Categories'
	String get title => 'Categories';

	/// en: 'Manage official library categories. PDFs linked to a deleted category will not be removed.'
	String get subtitle => 'Manage official library categories. PDFs linked to a deleted category will not be removed.';

	/// en: 'New Category'
	String get add => 'New Category';

	/// en: 'Edit'
	String get edit => 'Edit';

	/// en: 'Delete'
	String get delete => 'Delete';

	/// en: 'Are you sure you want to delete this category?'
	String get delete_confirm => 'Are you sure you want to delete this category?';

	/// en: 'Save'
	String get save => 'Save';

	/// en: 'Cancel'
	String get cancel => 'Cancel';

	/// en: 'Name'
	String get name => 'Name';

	/// en: 'Description'
	String get description => 'Description';

	/// en: 'Icon'
	String get icon => 'Icon';

	/// en: 'Color'
	String get color => 'Color';

	/// en: 'No categories found.'
	String get empty => 'No categories found.';

	/// en: 'Category saved successfully!'
	String get success_saved => 'Category saved successfully!';

	/// en: 'Category deleted!'
	String get success_deleted => 'Category deleted!';

	/// en: 'Please fill all required fields.'
	String get error_empty_fields => 'Please fill all required fields.';
}

// Path: admin_console.groups
class TranslationsAdminConsoleGroupsEn {
	TranslationsAdminConsoleGroupsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Actions'
	String get actions => 'Actions';

	/// en: 'Features'
	String get features => 'Features';

	/// en: 'Preview'
	String get preview => 'Preview';

	/// en: 'Debug actions'
	String get debug_actions => 'Debug actions';

	/// en: 'Identity'
	String get identity => 'Identity';

	/// en: 'Notification test'
	String get notification_test => 'Notification test';
}

// Path: admin_console.paywalls
class TranslationsAdminConsolePaywallsEn {
	TranslationsAdminConsolePaywallsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Tap a paywall to preview it. Copy its code to tell the assistant which one to use.'
	String get subtitle => 'Tap a paywall to preview it. Copy its code to tell the assistant which one to use.';

	/// en: 'Copy code'
	String get copy_code => 'Copy code';

	/// en: 'Code copied to clipboard'
	String get code_copied => 'Code copied to clipboard';

	/// en: 'Solo'
	String get solo_title => 'Solo';

	/// en: 'One plan with benefits and a single CTA. Best for single-tier apps.'
	String get solo_desc => 'One plan with benefits and a single CTA. Best for single-tier apps.';

	/// en: 'Compare'
	String get compare_title => 'Compare';

	/// en: 'Monthly vs annual side by side, with a free vs premium table.'
	String get compare_desc => 'Monthly vs annual side by side, with a free vs premium table.';

	/// en: 'Trial'
	String get trial_title => 'Trial';

	/// en: 'Optional free trial toggle, usually on the annual plan. Monthly stays paid upfront.'
	String get trial_desc => 'Optional free trial toggle, usually on the annual plan. Monthly stays paid upfront.';

	/// en: 'Unlock'
	String get unlock_title => 'Unlock';

	/// en: 'Conversion-focused paywall for onboarding or hard gates.'
	String get unlock_desc => 'Conversion-focused paywall for onboarding or hard gates.';
}

// Path: admin_console.settings_entry
class TranslationsAdminConsoleSettingsEntryEn {
	TranslationsAdminConsoleSettingsEntryEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Admin'
	String get title => 'Admin';

	/// en: 'Only visible to administrators and in development mode.'
	String get caption => 'Only visible to administrators and in development mode.';
}

// Path: home.cards
class TranslationsHomeCardsEn {
	TranslationsHomeCardsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Paywall'
	String get paywall_title => 'Paywall';

	/// en: 'Show the paywall page'
	String get paywall_description => 'Show the paywall page';

	/// en: 'Local notification test'
	String get notification_title => 'Local notification test';

	/// en: 'Fires an on-device alert only. It won't appear in the Notifications tab (push).'
	String get notification_description => 'Fires an on-device alert only. It won\'t appear in the Notifications tab (push).';

	/// en: 'Feedback'
	String get feedback_title => 'Feedback';

	/// en: 'Feature request or vote page'
	String get feedback_description => 'Feature request or vote page';

	/// en: 'Signup'
	String get signup_title => 'Signup';

	/// en: 'Anonymous user can signup using real email or other social login'
	String get signup_description => 'Anonymous user can signup using real email or other social login';

	/// en: 'AI Assistant'
	String get assistant_title => 'AI Assistant';

	/// en: 'Chat with the AI assistant'
	String get assistant_description => 'Chat with the AI assistant';
}

// Path: home.features_page
class TranslationsHomeFeaturesPageEn {
	TranslationsHomeFeaturesPageEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Kit features'
	String get title => 'Kit features';

	/// en: 'Chat with AI'
	String get assistant_title => 'Chat with AI';

	/// en: 'Ready-made AI chat for questions, ideas, and in-app help'
	String get assistant_description => 'Ready-made AI chat for questions, ideas, and in-app help';

	/// en: 'Vote & suggest'
	String get feedback_title => 'Vote & suggest';

	/// en: 'Join the roadmap—vote on ideas or submit your own'
	String get feedback_description => 'Join the roadmap—vote on ideas or submit your own';

	/// en: 'Test notification'
	String get notification_title => 'Test notification';

	/// en: 'Fires a local alert on this device only (not push)'
	String get notification_description => 'Fires a local alert on this device only (not push)';

	/// en: 'Test alert'
	String get notification_demo_title => 'Test alert';

	/// en: 'Local notification from the kit demo'
	String get notification_demo_body => 'Local notification from the kit demo';

	/// en: 'Send push notification'
	String get send_push_title => 'Send push notification';

	/// en: 'Send a push to specific users or everyone'
	String get send_push_description => 'Send a push to specific users or everyone';

	/// en: 'Plans & subscription'
	String get paywall_title => 'Plans & subscription';

	/// en: 'Paywall, trial, and RevenueCat subscription flows'
	String get paywall_description => 'Paywall, trial, and RevenueCat subscription flows';
}

// Path: home.dashboard
class TranslationsHomeDashboardEn {
	TranslationsHomeDashboardEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'kasy'
	String get brand => 'kasy';

	/// en: 'Components'
	String get components_title => 'Components';

	/// en: 'Explore design tokens and UI building blocks'
	String get components_subtitle => 'Explore design tokens and UI building blocks';

	/// en: 'Features'
	String get features_title => 'Features';

	/// en: 'AI, feedback, alerts, and subscription'
	String get features_subtitle => 'AI, feedback, alerts, and subscription';

	/// en: '$count total'
	String count_total({required Object count}) => '${count} total';

	/// en: 'Search components'
	String get search_hint => 'Search components';

	/// en: 'No components found'
	String get search_empty => 'No components found';

	/// en: 'In production'
	String get in_production => 'In production';

	/// en: 'Review'
	String get needs_review => 'Review';
}

// Path: home.components_preview
class TranslationsHomeComponentsPreviewEn {
	TranslationsHomeComponentsPreviewEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Components'
	String get nav_title => 'Components';

	/// en: 'PRO'
	String get pro_badge => 'PRO';
}

// Path: auth.signin
class TranslationsAuthSigninEn {
	TranslationsAuthSigninEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Welcome back'
	String get title => 'Welcome back';

	/// en: 'Sign in to continue your experience'
	String get subtitle => 'Sign in to continue your experience';

	/// en: 'bruce@wayne.com'
	String get email_hint => 'bruce@wayne.com';

	/// en: 'Email'
	String get email_label => 'Email';

	/// en: 'Password'
	String get password_hint => 'Password';

	/// en: 'Password'
	String get password_label => 'Password';

	/// en: 'Forgot your password?'
	String get forgot_password => 'Forgot your password?';

	/// en: 'Continue with email'
	String get submit => 'Continue with email';

	/// en: 'Create my account'
	String get create_account => 'Create my account';

	/// en: 'Don't have an account?'
	String get no_account => 'Don\'t have an account?';

	/// en: 'Sign up'
	String get signup_link => 'Sign up';

	/// en: 'Continue without account'
	String get continue_without => 'Continue without account';

	/// en: 'or'
	String get or_sign_in_with => 'or';

	/// en: 'Gmail'
	String get google => 'Gmail';

	/// en: 'Apple'
	String get apple => 'Apple';

	/// en: 'Facebook'
	String get facebook => 'Facebook';

	/// en: 'Error'
	String get error_title => 'Error';

	/// en: 'Wrong email, password or this email is not registered'
	String get error_text => 'Wrong email, password or this email is not registered';

	/// en: 'Email not valid'
	String get email_invalid => 'Email not valid';

	/// en: 'You must provide a password'
	String get password_required => 'You must provide a password';

	/// en: 'Your password must be at least 5 characters long'
	String get password_too_short => 'Your password must be at least 5 characters long';

	/// en: 'Couldn't sign in with $provider'
	String social_error({required Object provider}) => 'Couldn\'t sign in with ${provider}';

	/// en: 'This email already has an account with a different sign-in method. Use the method you signed up with.'
	String get email_already_registered => 'This email already has an account with a different sign-in method. Use the method you signed up with.';
}

// Path: auth.signup
class TranslationsAuthSignupEn {
	TranslationsAuthSignupEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Signup now'
	String get title => 'Signup now';

	/// en: 'Create your account to get started'
	String get subtitle => 'Create your account to get started';

	/// en: 'Create my account'
	String get submit => 'Create my account';

	/// en: 'Already have an account?'
	String get have_account => 'Already have an account?';

	/// en: 'Sign in'
	String get signin_link => 'Sign in';

	/// en: 'I already have an account'
	String get already_have_account => 'I already have an account';

	/// en: 'Error'
	String get error_title => 'Error';

	/// en: 'This email already exists or is invalid'
	String get error_text => 'This email already exists or is invalid';
}

// Path: auth.recover
class TranslationsAuthRecoverEn {
	TranslationsAuthRecoverEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Recover password'
	String get title => 'Recover password';

	/// en: 'We'll send a link to reset your password'
	String get subtitle => 'We\'ll send a link to reset your password';

	/// en: 'Email'
	String get email_label => 'Email';

	/// en: 'Recover password'
	String get submit => 'Recover password';

	/// en: 'Remembered your password?'
	String get remember => 'Remembered your password?';

	/// en: 'Sign in'
	String get signin_link => 'Sign in';

	/// en: 'Error'
	String get error_title => 'Error';

	/// en: 'Fill a valid email'
	String get error_text => 'Fill a valid email';
}

// Path: premium.solo
class TranslationsPremiumSoloEn {
	TranslationsPremiumSoloEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Back'
	String get back => 'Back';

	/// en: 'Upgrade for an'
	String get headline_1 => 'Upgrade for an';

	/// en: 'ad-free experience'
	String get headline_2 => 'ad-free experience';

	/// en: 'Ad-free listening'
	String get feature_1 => 'Ad-free listening';

	/// en: 'Offline mode'
	String get feature_2 => 'Offline mode';

	/// en: 'Unlimited skips'
	String get feature_3 => 'Unlimited skips';

	/// en: 'High-quality audio'
	String get feature_4 => 'High-quality audio';

	/// en: 'Subscribe now'
	String get subscribe => 'Subscribe now';
}

// Path: premium.comparePlan
class TranslationsPremiumComparePlanEn {
	TranslationsPremiumComparePlanEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Back'
	String get back => 'Back';

	/// en: 'Choose your plan'
	String get headline_1 => 'Choose your plan';

	/// en: 'that fits you best'
	String get headline_2 => 'that fits you best';

	/// en: 'Compare Free and Premium, then pick the monthly or annual billing that works for you.'
	String get headline_description => 'Compare Free and Premium, then pick the monthly or annual billing that works for you.';

	/// en: 'Full premium access'
	String get feature_1_title => 'Full premium access';

	/// en: 'Every feature unlocked on all devices'
	String get feature_1_subtitle => 'Every feature unlocked on all devices';

	/// en: 'No ads'
	String get feature_2_title => 'No ads';

	/// en: 'Stay focused without interruptions'
	String get feature_2_subtitle => 'Stay focused without interruptions';

	/// en: 'Cloud sync'
	String get feature_3_title => 'Cloud sync';

	/// en: 'Pick up where you left off'
	String get feature_3_subtitle => 'Pick up where you left off';

	/// en: 'Priority support'
	String get feature_4_title => 'Priority support';

	/// en: 'Help when you need it most'
	String get feature_4_subtitle => 'Help when you need it most';

	/// en: 'Continue'
	String get continue_cta => 'Continue';

	/// en: 'Save $percent%'
	String best_offer_badge({required Object percent}) => 'Save ${percent}%';

	/// en: '$price billed yearly'
	String per_month_line({required Object price}) => '${price} billed yearly';

	/// en: 'Billed every month'
	String get billed_monthly => 'Billed every month';

	/// en: 'Billed every $period'
	String billed_every({required Object period}) => 'Billed every ${period}';

	/// en: 'Flexible billing'
	String get flexible_plan => 'Flexible billing';

	/// en: '3 months'
	String get plan_three_month => '3 months';

	/// en: '6 months'
	String get plan_six_month => '6 months';

	/// en: 'Auto-renews until cancelled. Manage in the store.'
	String get billing_note => 'Auto-renews until cancelled. Manage in the store.';

	/// en: 'Auto-renews until cancelled. Manage in settings.'
	String get billing_note_web => 'Auto-renews until cancelled. Manage in settings.';

	/// en: 'What's included'
	String get benefits_heading => 'What\'s included';
}

// Path: premium.trialPlan
class TranslationsPremiumTrialPlanEn {
	TranslationsPremiumTrialPlanEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'KASY '
	String get title_before => 'KASY ';

	/// en: 'PRO'
	String get title_accent => 'PRO';

	/// en: 'Access to all features'
	String get subtitle => 'Access to all features';

	/// en: 'Join thousands of Kasy users'
	String get social_proof => 'Join thousands of Kasy users';

	/// en: 'Unlimited premium features'
	String get feature_1 => 'Unlimited premium features';

	/// en: 'High quality export'
	String get feature_2 => 'High quality export';

	/// en: 'No ads and no watermark'
	String get feature_3 => 'No ads and no watermark';

	/// en: 'Sync across all your devices'
	String get feature_4 => 'Sync across all your devices';

	/// en: 'Free trial enabled'
	String get trial_toggle_enabled => 'Free trial enabled';

	/// en: 'Enable free trial'
	String get trial_toggle_disabled => 'Enable free trial';

	/// en: 'Start free trial'
	String get cta_trial => 'Start free trial';

	/// en: 'Subscribe now'
	String get cta_no_trial => 'Subscribe now';

	/// en: '$days days free, then $price/year'
	String billing_trial({required Object days, required Object price}) => '${days} days free, then ${price}/year';

	/// en: '$price/year'
	String billing_annual({required Object price}) => '${price}/year';
}

// Path: premium.unlockPlan
class TranslationsPremiumUnlockPlanEn {
	TranslationsPremiumUnlockPlanEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'UNLOCK EVERYTHING'
	String get headline_1 => 'UNLOCK EVERYTHING';

	/// en: 'IN A FEW TAPS'
	String get headline_2 => 'IN A FEW TAPS';

	/// en: 'Unlock everything in an instant'
	String get headline_desktop => 'Unlock everything in an instant';

	/// en: 'Create more content'
	String get feature_1 => 'Create more content';

	/// en: 'Faster results'
	String get feature_2 => 'Faster results';

	/// en: 'Less waiting time'
	String get feature_3 => 'Less waiting time';

	/// en: 'Cloud sync'
	String get feature_4 => 'Cloud sync';

	/// en: 'Priority support'
	String get feature_5 => 'Priority support';

	/// en: 'Get access now'
	String get cta => 'Get access now';

	/// en: 'Unlock'
	String get cta_desktop => 'Unlock';

	/// en: 'Renews until canceled. Manage in the store.'
	String get billing_note => 'Renews until canceled. Manage in the store.';

	/// en: 'Renews until canceled. Manage in settings.'
	String get billing_note_web => 'Renews until canceled. Manage in settings.';

	/// en: 'Just $price / year'
	String plan_annual_price({required Object price}) => 'Just ${price} / year';

	/// en: '$price / month'
	String plan_monthly_price({required Object price}) => '${price} / month';
}

// Path: premium.comparison
class TranslationsPremiumComparisonEn {
	TranslationsPremiumComparisonEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Premium plan comparison'
	String get title => 'Premium plan comparison';

	/// en: 'Features'
	String get features_label => 'Features';

	/// en: 'Free'
	String get free_version => 'Free';

	/// en: 'Premium'
	String get premium_version => 'Premium';

	/// en: 'No ads'
	String get no_ads => 'No ads';

	/// en: 'Premium themes'
	String get premium_themes => 'Premium themes';

	/// en: 'Advanced customization'
	String get advanced_customization => 'Advanced customization';

	/// en: 'Priority support'
	String get priority_support => 'Priority support';

	/// en: 'Home widgets'
	String get home_widget => 'Home widgets';

	/// en: 'AI Assistant'
	String get talk_with_assistant => 'AI Assistant';
}

// Path: onboarding.feature_1
class TranslationsOnboardingFeature1En {
	TranslationsOnboardingFeature1En.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Monetize from day one'
	String get title => 'Monetize from day one';

	/// en: 'Production-ready paywalls, subscriptions and free trials. No billing backend to build.'
	String get description => 'Production-ready paywalls, subscriptions and free trials. No billing backend to build.';

	/// en: 'Continue'
	String get action => 'Continue';

	/// en: 'Skip'
	String get skip => 'Skip';

	/// en: 'Already have an account? Log in'
	String get login => 'Already have an account? Log in';
}

// Path: onboarding.feature_2
class TranslationsOnboardingFeature2En {
	TranslationsOnboardingFeature2En.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Sign-in, already built'
	String get title => 'Sign-in, already built';

	/// en: 'Email, social login and password recovery. Secure and ready to ship.'
	String get description => 'Email, social login and password recovery. Secure and ready to ship.';

	/// en: 'Continue'
	String get action => 'Continue';

	/// en: 'Back'
	String get back => 'Back';
}

// Path: onboarding.feature_3
class TranslationsOnboardingFeature3En {
	TranslationsOnboardingFeature3En.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Your built-in AI assistant'
	String get title => 'Your built-in AI assistant';

	/// en: 'A conversational assistant your users can chat with, ready out of the box.'
	String get description => 'A conversational assistant your users can chat with, ready out of the box.';

	/// en: 'Continue'
	String get action => 'Continue';
}

// Path: onboarding.mockups
class TranslationsOnboardingMockupsEn {
	TranslationsOnboardingMockupsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final TranslationsOnboardingMockupsPaywallEn paywall = TranslationsOnboardingMockupsPaywallEn.internal(_root);
	late final TranslationsOnboardingMockupsEarningsEn earnings = TranslationsOnboardingMockupsEarningsEn.internal(_root);
	late final TranslationsOnboardingMockupsAuthEn auth = TranslationsOnboardingMockupsAuthEn.internal(_root);
	late final TranslationsOnboardingMockupsNotificationEn notification = TranslationsOnboardingMockupsNotificationEn.internal(_root);
	late final TranslationsOnboardingMockupsAiChatEn ai_chat = TranslationsOnboardingMockupsAiChatEn.internal(_root);
}

// Path: onboarding.ageQuestion
class TranslationsOnboardingAgeQuestionEn {
	TranslationsOnboardingAgeQuestionEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'How old are you?'
	String get title => 'How old are you?';

	/// en: 'This helps us tailor your experience.'
	String get description => 'This helps us tailor your experience.';

	Map<String, String> get options => {
		'age18_30': '18 to 30',
		'age31_40': '31 to 40',
		'age41_50': '41 to 50',
		'age51_60': 'Over 50',
		'none': 'I\'d rather not say',
	};

	/// en: 'Continue'
	String get action => 'Continue';
}

// Path: onboarding.genderQuestion
class TranslationsOnboardingGenderQuestionEn {
	TranslationsOnboardingGenderQuestionEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'How do you identify?'
	String get title => 'How do you identify?';

	/// en: 'Pick what fits you best. You can skip this.'
	String get description => 'Pick what fits you best. You can skip this.';

	Map<String, String> get options => {
		'male': 'Male',
		'female': 'Female',
		'none': 'I\'d rather not say',
	};

	/// en: 'Continue'
	String get action => 'Continue';
}

// Path: onboarding.notifications
class TranslationsOnboardingNotificationsEn {
	TranslationsOnboardingNotificationsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Stay in the loop'
	String get title => 'Stay in the loop';

	/// en: 'We only reach out when it truly matters. No spam, ever.'
	String get description => 'We only reach out when it truly matters. No spam, ever.';

	/// en: 'Turn on notifications'
	String get continue_button => 'Turn on notifications';

	/// en: 'Not now'
	String get skip_button => 'Not now';

	late final TranslationsOnboardingNotificationsToastsEn toasts = TranslationsOnboardingNotificationsToastsEn.internal(_root);
}

// Path: onboarding.att
class TranslationsOnboardingAttEn {
	TranslationsOnboardingAttEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Personalized experience'
	String get title => 'Personalized experience';

	/// en: 'This permission helps tailor communications to your profile. It does not show ads inside the app.'
	String get description => 'This permission helps tailor communications to your profile. It does not show ads inside the app.';

	/// en: 'Continue'
	String get continue_button => 'Continue';

	/// en: 'Not now'
	String get skip_button => 'Not now';

	late final TranslationsOnboardingAttCardEn card = TranslationsOnboardingAttCardEn.internal(_root);
}

// Path: onboarding.loading
class TranslationsOnboardingLoadingEn {
	TranslationsOnboardingLoadingEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Account created.'
	String get welcome => 'Account created.';

	/// en: 'Account created. Welcome!'
	String get welcome_male => 'Account created. Welcome!';

	/// en: 'Account created. Welcome!'
	String get welcome_female => 'Account created. Welcome!';

	late final TranslationsOnboardingLoadingStepsEn steps = TranslationsOnboardingLoadingStepsEn.internal(_root);
}

// Path: feature_requests.vote_success
class TranslationsFeatureRequestsVoteSuccessEn {
	TranslationsFeatureRequestsVoteSuccessEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Vote registered'
	String get title => 'Vote registered';

	/// en: 'Thanks for helping us prioritize'
	String get description => 'Thanks for helping us prioritize';
}

// Path: feature_requests.vote_error
class TranslationsFeatureRequestsVoteErrorEn {
	TranslationsFeatureRequestsVoteErrorEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Already voted'
	String get title => 'Already voted';

	/// en: 'You have already voted for this idea'
	String get description => 'You have already voted for this idea';
}

// Path: feature_requests.add_feature
class TranslationsFeatureRequestsAddFeatureEn {
	TranslationsFeatureRequestsAddFeatureEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Add'
	String get chip_label => 'Add';

	/// en: 'Submit an idea'
	String get title => 'Submit an idea';

	/// en: 'Tell us what you'd like to see built next.'
	String get description => 'Tell us what you\'d like to see built next.';

	/// en: 'Submit'
	String get save_button => 'Submit';

	/// en: 'Cancel'
	String get cancel => 'Cancel';

	/// en: 'Title'
	String get title_label => 'Title';

	/// en: 'A short, descriptive title'
	String get title_hint => 'A short, descriptive title';

	/// en: 'Description'
	String get description_label => 'Description';

	/// en: 'Describe the feature or improvement in detail...'
	String get description_hint => 'Describe the feature or improvement in detail...';

	/// en: 'Error'
	String get error_title => 'Error';

	/// en: 'Title and description are required'
	String get error_required => 'Title and description are required';

	/// en: 'Something went wrong. Please try again.'
	String get error_sending => 'Something went wrong. Please try again.';

	/// en: 'Description is too short. Please add more detail'
	String get error_too_short => 'Description is too short. Please add more detail';

	late final TranslationsFeatureRequestsAddFeatureToastSuccessEn toast_success = TranslationsFeatureRequestsAddFeatureToastSuccessEn.internal(_root);
}

// Path: settings.avatar
class TranslationsSettingsAvatarEn {
	TranslationsSettingsAvatarEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Profile photo'
	String get title => 'Profile photo';

	/// en: 'Take photo'
	String get take_photo => 'Take photo';

	/// en: 'Photo library'
	String get choose_library => 'Photo library';

	/// en: 'Remove photo'
	String get remove_photo => 'Remove photo';

	/// en: 'Cancel'
	String get cancel => 'Cancel';
}

// Path: settings.delete_account
class TranslationsSettingsDeleteAccountEn {
	TranslationsSettingsDeleteAccountEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'I want to delete my account'
	String get button => 'I want to delete my account';

	/// en: 'Delete your account?'
	String get title => 'Delete your account?';

	/// en: 'Warning: this action is permanent and cannot be undone.'
	String get content => 'Warning: this action is permanent and cannot be undone.';

	/// en: 'Warning: this is permanent. You will lose your active subscription, and creating a new account later (even with the same email) will not restore it.'
	String get content_subscriber => 'Warning: this is permanent. You will lose your active subscription, and creating a new account later (even with the same email) will not restore it.';

	/// en: 'Cancel'
	String get cancel => 'Cancel';

	/// en: 'Yes, delete'
	String get confirm => 'Yes, delete';

	/// en: 'Something went wrong. Please try again.'
	String get error => 'Something went wrong. Please try again.';
}

// Path: settings.admin
class TranslationsSettingsAdminEn {
	TranslationsSettingsAdminEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Preview what's new'
	String get update_bottom_sheet => 'Preview what\'s new';

	/// en: 'Preview update available'
	String get preview_update_available => 'Preview update available';

	/// en: 'Paywalls'
	String get paywalls => 'Paywalls';

	/// en: 'Test onboarding'
	String get test_onboarding => 'Test onboarding';

	/// en: 'Copy user id'
	String get copy_user_id => 'Copy user id';

	/// en: 'User id copied to clipboard'
	String get user_id_copied => 'User id copied to clipboard';

	/// en: 'Copy FCM Token'
	String get copy_fcm_token => 'Copy FCM Token';

	/// en: 'FCM Token copied to clipboard'
	String get fcm_token_copied => 'FCM Token copied to clipboard';

	/// en: 'Token unavailable (notifications disabled?)'
	String get fcm_token_unavailable => 'Token unavailable (notifications disabled?)';

	/// en: 'Ask for notification'
	String get ask_notification => 'Ask for notification';

	/// en: 'Available only in the native app (iOS / Android)'
	String get native_only => 'Available only in the native app (iOS / Android)';

	/// en: 'Ask for review'
	String get ask_review => 'Ask for review';

	/// en: 'Home Widgets panel'
	String get home_widgets_panel => 'Home Widgets panel';

	/// en: 'Home Widgets Panel'
	String get home_widgets_title => 'Home Widgets Panel';

	/// en: 'Ads demo'
	String get ads_demo_panel => 'Ads demo';

	/// en: 'Ads demo'
	String get ads_demo_title => 'Ads demo';

	/// en: 'The four AdMob formats with Google test ads. Try each, then drop it wherever you want in your app.'
	String get ads_demo_subtitle => 'The four AdMob formats with Google test ads. Try each, then drop it wherever you want in your app.';

	/// en: 'Banner'
	String get ads_banner_label => 'Banner';

	/// en: 'Interstitial'
	String get ads_interstitial_title => 'Interstitial';

	/// en: 'Full-screen ad. Tap to show.'
	String get ads_interstitial_desc => 'Full-screen ad. Tap to show.';

	/// en: 'Rewarded'
	String get ads_rewarded_title => 'Rewarded';

	/// en: 'User watches to earn a reward. Tap to show.'
	String get ads_rewarded_desc => 'User watches to earn a reward. Tap to show.';

	/// en: 'Rewarded interstitial'
	String get ads_rewarded_interstitial_title => 'Rewarded interstitial';

	/// en: 'Full-screen ad that also grants a reward. Tap to show.'
	String get ads_rewarded_interstitial_desc => 'Full-screen ad that also grants a reward. Tap to show.';

	/// en: 'Reward earned: $amount $type'
	String ads_reward_earned({required Object amount, required Object type}) => 'Reward earned: ${amount} ${type}';

	/// en: 'Couldn't load the ad (no fill). Try again in a moment.'
	String get ads_load_failed => 'Couldn\'t load the ad (no fill). Try again in a moment.';

	/// en: 'Code copied to clipboard'
	String get ads_code_copied => 'Code copied to clipboard';

	/// en: 'This demo always shows Google test ads, so it's safe to tap, even in production.'
	String get ads_status_safe => 'This demo always shows Google test ads, so it\'s safe to tap, even in production.';

	/// en: 'Your real ad ids aren't set yet. Configure them to go live:'
	String get ads_status_test => 'Your real ad ids aren\'t set yet. Configure them to go live:';

	/// en: 'Real ad ids are configured for this platform.'
	String get ads_status_real => 'Real ad ids are configured for this platform.';

	/// en: 'Widget inspector'
	String get inspector_fab_title => 'Widget inspector';

	/// en: 'Global shortcut:'
	String get inspector_fab_subtitle_prefix => 'Global shortcut:';

	/// en: 'Update MyWidget Widget'
	String get update_mywidget_title => 'Update MyWidget Widget';

	/// en: 'Call manual update for MyWidget widget'
	String get update_mywidget_desc => 'Call manual update for MyWidget widget';

	/// en: 'Paywalls Admin Panel'
	String get paywalls_title => 'Paywalls Admin Panel';

	/// en: 'Send notification'
	String get send_push_title => 'Send notification';

	/// en: 'Send to all'
	String get send_push_to_all => 'Send to all';

	/// en: 'Add e-mail'
	String get send_push_email_hint => 'Add e-mail';

	/// en: 'Title'
	String get send_push_title_label => 'Title';

	/// en: 'e.g. New update available'
	String get send_push_title_hint => 'e.g. New update available';

	/// en: 'Message'
	String get send_push_body_label => 'Message';

	/// en: 'Up to 3 lines in the app list (140 characters max)'
	String get send_push_body_hint => 'Up to 3 lines in the app list (140 characters max)';

	/// en: 'Image URL (optional)'
	String get send_push_image_label => 'Image URL (optional)';

	/// en: 'https://...'
	String get send_push_image_hint => 'https://...';

	/// en: 'Recipient e-mails'
	String get send_push_email_label => 'Recipient e-mails';

	/// en: 'Notification sent!'
	String get send_push_success => 'Notification sent!';

	/// en: 'User not found: $email'
	String send_push_user_not_found({required Object email}) => 'User not found: ${email}';

	/// en: 'Send'
	String get send_push_send_button => 'Send';

	/// en: 'Title and message are required'
	String get send_push_required => 'Title and message are required';

	/// en: 'Add at least one e-mail'
	String get send_push_no_emails => 'Add at least one e-mail';

	/// en: 'Page to open'
	String get send_push_route_label => 'Page to open';

	/// en: 'Screen opened when the user taps the notification.'
	String get send_push_route_description => 'Screen opened when the user taps the notification.';

	/// en: 'Notifications'
	String get send_push_route_notifications => 'Notifications';

	/// en: 'Home'
	String get send_push_route_home => 'Home';

	/// en: 'Settings'
	String get send_push_route_settings => 'Settings';

	/// en: 'Premium'
	String get send_push_route_premium => 'Premium';

	/// en: 'Reminders'
	String get send_push_route_reminder => 'Reminders';

	/// en: 'Feedback'
	String get send_push_route_feedback => 'Feedback';

	/// en: 'Preview'
	String get send_push_preview_label => 'Preview';

	/// en: 'now'
	String get send_push_preview_now => 'now';

	/// en: 'Notification title'
	String get send_push_preview_title_placeholder => 'Notification title';

	/// en: 'Your message body shows here'
	String get send_push_preview_body_placeholder => 'Your message body shows here';

	/// en: 'Device Preview (web only)'
	String get device_preview_title => 'Device Preview (web only)';

	/// en: 'Recipients'
	String get send_push_section_recipients => 'Recipients';

	/// en: 'Content'
	String get send_push_section_content => 'Content';

	/// en: 'Advanced'
	String get send_push_section_advanced => 'Advanced';

	/// en: 'Everyone'
	String get send_push_audience_all => 'Everyone';

	/// en: 'Specific'
	String get send_push_audience_specific => 'Specific';

	/// en: 'The notification will be sent to every subscribed user.'
	String get send_push_audience_all_hint => 'The notification will be sent to every subscribed user.';
}

// Path: onboarding.mockups.paywall
class TranslationsOnboardingMockupsPaywallEn {
	TranslationsOnboardingMockupsPaywallEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Premium'
	String get title => 'Premium';

	/// en: 'Annual'
	String get annual => 'Annual';

	/// en: 'Monthly'
	String get monthly => 'Monthly';

	/// en: '-40%'
	String get save_badge => '-40%';

	/// en: '\$39.99 / yr'
	String get price_year => '\$39.99 / yr';

	/// en: '\$4.99 / mo'
	String get price_month => '\$4.99 / mo';

	/// en: 'Start free trial'
	String get cta => 'Start free trial';
}

// Path: onboarding.mockups.earnings
class TranslationsOnboardingMockupsEarningsEn {
	TranslationsOnboardingMockupsEarningsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'New Pro subscriber'
	String get notify_title => 'New Pro subscriber';

	/// en: 'Annual plan · +\$49.90'
	String get notify_subtitle => 'Annual plan · +\$49.90';

	/// en: '1:40 PM'
	String get notify_time => '1:40 PM';

	/// en: 'Processing payment…'
	String get processing => 'Processing payment…';

	/// en: 'Earnings'
	String get summary_label => 'Earnings';

	/// en: 'You earned \$312.40 this week from 14 new subscriptions.'
	String get summary_body => 'You earned \$312.40 this week from 14 new subscriptions.';
}

// Path: onboarding.mockups.auth
class TranslationsOnboardingMockupsAuthEn {
	TranslationsOnboardingMockupsAuthEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Welcome back'
	String get welcome => 'Welcome back';

	/// en: 'you@email.com'
	String get email_hint => 'you@email.com';

	/// en: 'Sign in'
	String get sign_in => 'Sign in';

	/// en: 'or'
	String get divider => 'or';
}

// Path: onboarding.mockups.notification
class TranslationsOnboardingMockupsNotificationEn {
	TranslationsOnboardingMockupsNotificationEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'New message'
	String get title => 'New message';

	/// en: 'now'
	String get time => 'now';
}

// Path: onboarding.mockups.ai_chat
class TranslationsOnboardingMockupsAiChatEn {
	TranslationsOnboardingMockupsAiChatEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'What can you do?'
	String get u1 => 'What can you do?';

	/// en: 'I write, summarize and answer anything in seconds.'
	String get a1 => 'I write, summarize and answer anything in seconds.';

	/// en: 'Summarize my notes'
	String get u2 => 'Summarize my notes';

	/// en: 'Done. Here are the 3 key points from today.'
	String get a2 => 'Done. Here are the 3 key points from today.';
}

// Path: onboarding.notifications.toasts
class TranslationsOnboardingNotificationsToastsEn {
	TranslationsOnboardingNotificationsToastsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Kasy'
	String get push_app_name => 'Kasy';

	/// en: 'Your weekly summary is ready'
	String get push_headline => 'Your weekly summary is ready';

	/// en: 'Tap to open.'
	String get push_body => 'Tap to open.';

	/// en: 'now'
	String get push_sent_at => 'now';

	/// en: 'New Pro subscriber'
	String get subscriber_title => 'New Pro subscriber';

	/// en: 'Annual plan · +\$49.90'
	String get subscriber_message => 'Annual plan · +\$49.90';

	/// en: '7-day streak!'
	String get streak_title => '7-day streak!';

	/// en: 'You hit your daily goal again.'
	String get streak_message => 'You hit your daily goal again.';

	/// en: 'New reply'
	String get message_title => 'New reply';

	/// en: 'Someone responded to your thread.'
	String get message_message => 'Someone responded to your thread.';

	/// en: 'Starting soon'
	String get reminder_title => 'Starting soon';

	/// en: 'Your session begins in 10 minutes.'
	String get reminder_message => 'Your session begins in 10 minutes.';

	/// en: 'Payment received'
	String get payment_title => 'Payment received';

	/// en: '+\$12.50 credited to your balance.'
	String get payment_message => '+\$12.50 credited to your balance.';

	/// en: 'Limited offer'
	String get offer_title => 'Limited offer';

	/// en: '50% off annual — ends tonight.'
	String get offer_message => '50% off annual — ends tonight.';

	/// en: 'New interaction'
	String get social_title => 'New interaction';

	/// en: '3 people liked your latest post.'
	String get social_message => '3 people liked your latest post.';
}

// Path: onboarding.att.card
class TranslationsOnboardingAttCardEn {
	TranslationsOnboardingAttCardEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Privacy'
	String get tag => 'Privacy';
}

// Path: onboarding.loading.steps
class TranslationsOnboardingLoadingStepsEn {
	TranslationsOnboardingLoadingStepsEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Creating your account'
	String get account => 'Creating your account';

	/// en: 'Saving your preferences'
	String get preferences => 'Saving your preferences';

	/// en: 'Personalizing your experience'
	String get ready => 'Personalizing your experience';
}

// Path: feature_requests.add_feature.toast_success
class TranslationsFeatureRequestsAddFeatureToastSuccessEn {
	TranslationsFeatureRequestsAddFeatureToastSuccessEn.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Idea submitted'
	String get title => 'Idea submitted';

	/// en: 'We'll review it and keep you posted'
	String get description => 'We\'ll review it and keep you posted';
}

/// The flat map containing all translations for locale <en>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on Translations {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'common.close' => 'Close',
			'common.copied' => 'Copied',
			'common.saved' => 'Saved',
			'common.error' => 'Error',
			'common.unavailable' => 'Unavailable',
			'common.native_only_title' => 'Native app only',
			'admin_console.tabs.overview' => 'Overview',
			'admin_console.tabs.users' => 'Users',
			'admin_console.tabs.requests' => 'Requests',
			'admin_console.tabs.categories' => 'Categories',
			'admin_console.tabs.tools' => 'Tools',
			'admin_console.tabs.debug' => 'Debug',
			'admin_console.back_to_app' => 'Back to app',
			'admin_console.overview.section' => 'Project',
			'admin_console.overview.summary' => 'Summary',
			'admin_console.overview.backend' => 'Backend',
			'admin_console.overview.account' => 'Account',
			'admin_console.overview.guest' => 'Guest',
			'admin_console.overview.user_id' => 'User ID',
			'admin_console.overview.build' => 'Build',
			'admin_console.overview.session_title' => 'Current session',
			'admin_console.overview.requests_metric' => 'Feature requests',
			'admin_console.overview.total_users' => 'Total users',
			'admin_console.overview.subscribers' => 'Subscribers',
			'admin_console.overview.new_7d' => 'New (7 days)',
			'admin_console.overview.signups_title' => 'New sign-ups',
			'admin_console.overview.signups_subtitle' => 'Last 14 days',
			'admin_console.overview.signups_total' => ({required Object count}) => '${count} in 14 days',
			'admin_console.overview.signups_empty' => 'No sign-ups in this period.',
			'admin_console.overview.plan_split_title' => 'Plan breakdown',
			'admin_console.overview.free' => 'Free',
			'admin_console.overview.subscriber' => 'Subscriber',
			'admin_console.overview.conversion' => ({required Object percent}) => '${percent} subscribers',
			'admin_console.overview.loaded_note' => ({required Object count}) => 'Based on the ${count} most recent users.',
			'admin_console.overview.users_hint' => 'Open the Users tab to manage every account.',
			'admin_console.overview.debug_note' => 'Debug console — visible only in development builds.',
			'admin_console.users.title' => 'Users',
			'admin_console.users.search_hint' => 'Search by name or e-mail',
			'admin_console.users.col_user' => 'User',
			'admin_console.users.col_status' => 'Status',
			'admin_console.users.col_plan' => 'Plan',
			'admin_console.users.col_role' => 'Role',
			'admin_console.users.col_action' => 'Actions',
			'admin_console.users.col_joined' => 'Joined',
			'admin_console.users.status_active' => 'Active',
			'admin_console.users.status_inactive' => 'Inactive',
			'admin_console.users.status_blocked' => 'Blocked',
			'admin_console.users.role_admin' => 'Admin',
			'admin_console.users.role_user' => 'User',
			'admin_console.users.action_make_admin' => 'Make Admin',
			'admin_console.users.action_remove_admin' => 'Remove Admin',
			'admin_console.users.action_block' => 'Block Access',
			'admin_console.users.action_unblock' => 'Unblock Access',
			'admin_console.users.plan_subscriber' => 'Subscriber',
			'admin_console.users.plan_free' => 'Free',
			'admin_console.users.empty' => 'No users found',
			'admin_console.users.empty_hint' => 'When someone creates an account, it shows up here.',
			'admin_console.users.error' => 'Couldn\'t load users. Make sure you are an admin.',
			'admin_console.users.page' => ({required Object page, required Object total}) => 'Page ${page} of ${total}',
			'admin_console.users.prev' => 'Previous',
			'admin_console.users.next' => 'Next',
			'admin_console.users.anonymous' => 'Anonymous',
			'admin_console.users.filter_all' => 'All users',
			'admin_console.users.filter_subscribers' => 'Subscribers',
			'admin_console.users.loading' => 'Loading users…',
			'admin_console.users.results' => ({required Object from, required Object to, required Object total}) => 'Showing ${from} to ${to} of ${total}',
			'admin_console.users.truncated' => ({required Object count}) => 'Showing the ${count} most recent. Search covers the loaded set.',
			'admin_console.users.search_capped' => 'Search scanned a limited set. Some matches may be missing.',
			'admin_console.users.empty_search' => 'No users match your search',
			'admin_console.users.empty_search_hint' => 'Try a different name or e-mail.',
			'admin_console.users.empty_subscribers' => 'No subscribers found',
			'admin_console.users.empty_subscribers_hint' => 'Anyone on the premium plan will show up in this filter.',
			'admin_console.users.refresh' => 'Refresh',
			'admin_console.users.retry' => 'Try again',
			'admin_console.requests.title' => 'Feature requests',
			'admin_console.requests.subtitle' => 'Feature requests and suggestions submitted by your users. Mark one visible to show it in the app, or hide the ones that don\'t fit.',
			'admin_console.requests.empty' => 'No feature requests yet',
			'admin_console.requests.empty_hint' => 'When a user sends an idea, it shows up here.',
			'admin_console.requests.votes' => ({required Object count}) => '${count} votes',
			'admin_console.requests.visible' => 'Visible',
			'admin_console.requests.hidden' => 'Hidden',
			'admin_console.requests.edit' => 'Edit',
			'admin_console.requests.error' => 'Couldn\'t load feature requests',
			'admin_console.requests.saved' => 'Feature request updated',
			'admin_console.requests.editor_title' => 'Edit feature request',
			'admin_console.requests.field_title' => 'Title',
			'admin_console.requests.field_description' => 'Description',
			'admin_console.requests.lang_en' => 'English',
			'admin_console.requests.lang_pt' => 'Portuguese',
			'admin_console.requests.lang_es' => 'Spanish',
			'admin_console.requests.visibility' => 'Visible to users',
			'admin_console.requests.save' => 'Save',
			'admin_console.requests.cancel' => 'Cancel',
			'admin_console.categories.title' => 'Categories',
			'admin_console.categories.subtitle' => 'Manage official library categories. PDFs linked to a deleted category will not be removed.',
			'admin_console.categories.add' => 'New Category',
			'admin_console.categories.edit' => 'Edit',
			'admin_console.categories.delete' => 'Delete',
			'admin_console.categories.delete_confirm' => 'Are you sure you want to delete this category?',
			'admin_console.categories.save' => 'Save',
			'admin_console.categories.cancel' => 'Cancel',
			'admin_console.categories.name' => 'Name',
			'admin_console.categories.description' => 'Description',
			'admin_console.categories.icon' => 'Icon',
			'admin_console.categories.color' => 'Color',
			'admin_console.categories.empty' => 'No categories found.',
			'admin_console.categories.success_saved' => 'Category saved successfully!',
			'admin_console.categories.success_deleted' => 'Category deleted!',
			'admin_console.categories.error_empty_fields' => 'Please fill all required fields.',
			'admin_console.groups.actions' => 'Actions',
			'admin_console.groups.features' => 'Features',
			'admin_console.groups.preview' => 'Preview',
			'admin_console.groups.debug_actions' => 'Debug actions',
			'admin_console.groups.identity' => 'Identity',
			'admin_console.groups.notification_test' => 'Notification test',
			'admin_console.paywalls.subtitle' => 'Tap a paywall to preview it. Copy its code to tell the assistant which one to use.',
			'admin_console.paywalls.copy_code' => 'Copy code',
			'admin_console.paywalls.code_copied' => 'Code copied to clipboard',
			'admin_console.paywalls.solo_title' => 'Solo',
			'admin_console.paywalls.solo_desc' => 'One plan with benefits and a single CTA. Best for single-tier apps.',
			'admin_console.paywalls.compare_title' => 'Compare',
			'admin_console.paywalls.compare_desc' => 'Monthly vs annual side by side, with a free vs premium table.',
			'admin_console.paywalls.trial_title' => 'Trial',
			'admin_console.paywalls.trial_desc' => 'Optional free trial toggle, usually on the annual plan. Monthly stays paid upfront.',
			'admin_console.paywalls.unlock_title' => 'Unlock',
			'admin_console.paywalls.unlock_desc' => 'Conversion-focused paywall for onboarding or hard gates.',
			'admin_console.settings_entry.title' => 'Admin',
			'admin_console.settings_entry.caption' => 'Only visible to administrators and in development mode.',
			'admin_console.requires_admin' => 'You need to be an admin to view this. Set role: admin on your user record in the backend. The app cannot change this field; validation runs on the server.',
			'home.title' => 'Kasy example',
			'home.welcome' => 'Welcome to the Kasy demo',
			'home.cards.paywall_title' => 'Paywall',
			'home.cards.paywall_description' => 'Show the paywall page',
			'home.cards.notification_title' => 'Local notification test',
			'home.cards.notification_description' => 'Fires an on-device alert only. It won\'t appear in the Notifications tab (push).',
			'home.cards.feedback_title' => 'Feedback',
			'home.cards.feedback_description' => 'Feature request or vote page',
			'home.cards.signup_title' => 'Signup',
			'home.cards.signup_description' => 'Anonymous user can signup using real email or other social login',
			'home.cards.assistant_title' => 'AI Assistant',
			'home.cards.assistant_description' => 'Chat with the AI assistant',
			'home.features_page.title' => 'Kit features',
			'home.features_page.assistant_title' => 'Chat with AI',
			'home.features_page.assistant_description' => 'Ready-made AI chat for questions, ideas, and in-app help',
			'home.features_page.feedback_title' => 'Vote & suggest',
			'home.features_page.feedback_description' => 'Join the roadmap—vote on ideas or submit your own',
			'home.features_page.notification_title' => 'Test notification',
			'home.features_page.notification_description' => 'Fires a local alert on this device only (not push)',
			'home.features_page.notification_demo_title' => 'Test alert',
			'home.features_page.notification_demo_body' => 'Local notification from the kit demo',
			'home.features_page.send_push_title' => 'Send push notification',
			'home.features_page.send_push_description' => 'Send a push to specific users or everyone',
			'home.features_page.paywall_title' => 'Plans & subscription',
			'home.features_page.paywall_description' => 'Paywall, trial, and RevenueCat subscription flows',
			'home.dashboard.brand' => 'kasy',
			'home.dashboard.components_title' => 'Components',
			'home.dashboard.components_subtitle' => 'Explore design tokens and UI building blocks',
			'home.dashboard.features_title' => 'Features',
			'home.dashboard.features_subtitle' => 'AI, feedback, alerts, and subscription',
			'home.dashboard.count_total' => ({required Object count}) => '${count} total',
			'home.dashboard.search_hint' => 'Search components',
			'home.dashboard.search_empty' => 'No components found',
			'home.dashboard.in_production' => 'In production',
			'home.dashboard.needs_review' => 'Review',
			'home.components_preview.nav_title' => 'Components',
			'home.components_preview.pro_badge' => 'PRO',
			'auth.signin.title' => 'Welcome back',
			'auth.signin.subtitle' => 'Sign in to continue your experience',
			'auth.signin.email_hint' => 'bruce@wayne.com',
			'auth.signin.email_label' => 'Email',
			'auth.signin.password_hint' => 'Password',
			'auth.signin.password_label' => 'Password',
			'auth.signin.forgot_password' => 'Forgot your password?',
			'auth.signin.submit' => 'Continue with email',
			'auth.signin.create_account' => 'Create my account',
			'auth.signin.no_account' => 'Don\'t have an account?',
			'auth.signin.signup_link' => 'Sign up',
			'auth.signin.continue_without' => 'Continue without account',
			'auth.signin.or_sign_in_with' => 'or',
			'auth.signin.google' => 'Gmail',
			'auth.signin.apple' => 'Apple',
			'auth.signin.facebook' => 'Facebook',
			'auth.signin.error_title' => 'Error',
			'auth.signin.error_text' => 'Wrong email, password or this email is not registered',
			'auth.signin.email_invalid' => 'Email not valid',
			'auth.signin.password_required' => 'You must provide a password',
			'auth.signin.password_too_short' => 'Your password must be at least 5 characters long',
			'auth.signin.social_error' => ({required Object provider}) => 'Couldn\'t sign in with ${provider}',
			'auth.signin.email_already_registered' => 'This email already has an account with a different sign-in method. Use the method you signed up with.',
			'auth.signup.title' => 'Signup now',
			'auth.signup.subtitle' => 'Create your account to get started',
			'auth.signup.submit' => 'Create my account',
			'auth.signup.have_account' => 'Already have an account?',
			'auth.signup.signin_link' => 'Sign in',
			'auth.signup.already_have_account' => 'I already have an account',
			'auth.signup.error_title' => 'Error',
			'auth.signup.error_text' => 'This email already exists or is invalid',
			'auth.recover.title' => 'Recover password',
			'auth.recover.subtitle' => 'We\'ll send a link to reset your password',
			'auth.recover.email_label' => 'Email',
			'auth.recover.submit' => 'Recover password',
			'auth.recover.remember' => 'Remembered your password?',
			'auth.recover.signin_link' => 'Sign in',
			'auth.recover.error_title' => 'Error',
			'auth.recover.error_text' => 'Fill a valid email',
			'rate_popup.title' => 'Would you have 15s to rate us?',
			'rate_popup.description' => 'It\'s fast and very helpful! Thanks a lot!',
			'rate_popup.cancel_button' => 'Maybe later',
			'rate_popup.rate_button' => 'Yes, with pleasure!',
			'premium.title_1' => 'Unlock full access',
			'premium.description' => 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
			'premium.feature_1' => 'Feature 1 lorem ipsum ',
			'premium.feature_2' => 'Feature 2 mop issum ',
			'premium.feature_3' => 'Feature 3 lorem ',
			'premium.duration_weekly' => 'Week',
			'premium.duration_annual' => 'Year',
			'premium.duration_monthly' => 'Month',
			'premium.duration_monthly_description' => 'Cancel anytime',
			'premium.duration_lifetime' => 'Lifetime',
			'premium.duration_lifetime_description' => 'One time payment',
			'premium.restore_action' => 'Restore',
			'premium.preview_disabled_title' => 'Preview',
			'premium.preview_disabled_text' => 'This is an admin preview. Purchase actions are disabled.',
			'premium.coupon_title' => 'Have a coupon?',
			'premium.payment_cancel_reassurance' => 'Easy 1-click cancel, always',
			'premium.payment_cancel_reassurance_free_trial' => 'No payment now, cancel anytime',
			'premium.payment_action' => 'Start free trial',
			'premium.payment_action_trial' => ({required Object money}) => '7-day free trial, then ${money}',
			'premium.try_free_btn_action' => ({required Object days}) => 'Try free for ${days} days',
			'premium.duration_recuring_label_annual' => 'Annual',
			'premium.duration_recuring_label_monthly' => 'Monthly',
			'premium.duration_recuring_label_weekly' => 'Weekly',
			'premium.price_per_week' => '/week',
			'premium.price_per_month' => '/month',
			'premium.price_per_three_month' => '/3 months',
			'premium.price_per_six_month' => '/6 months',
			'premium.price_per_year' => '/year',
			'premium.price_one_time' => '',
			'premium.action_button' => 'Continue',
			'premium.terms' => 'Terms',
			'premium.privacy' => 'Privacy',
			'premium.terms_of_use' => 'Terms of Use',
			'premium.privacy_policy' => 'Privacy Policy',
			'premium.error_loading' => 'Error while loading the offers',
			'premium.no_products_title' => 'Subscription options are not available yet',
			'premium.no_products_description' => 'Please try again in a moment. If this keeps happening, the store products may still be finishing setup.',
			'premium.restore_success_title' => 'Subscription restored',
			'premium.restore_success_text' => 'Thank you for your trust',
			'premium.purchase_success_title' => 'Subscription successful',
			'premium.purchase_success_text' => 'Thank you for your trust',
			'premium.error_title' => 'Error',
			'premium.error_text' => 'An error occurred. Please try again',
			'premium.web_checkout_timeout_title' => 'Payment not confirmed',
			'premium.web_checkout_timeout_text' => 'We did not receive payment confirmation. If you already paid, tap Restore.',
			'premium.restore_none_title' => 'No subscription found',
			'premium.restore_none_text' => 'We could not find an active subscription to restore.',
			'premium.solo.back' => 'Back',
			'premium.solo.headline_1' => 'Upgrade for an',
			'premium.solo.headline_2' => 'ad-free experience',
			'premium.solo.feature_1' => 'Ad-free listening',
			'premium.solo.feature_2' => 'Offline mode',
			'premium.solo.feature_3' => 'Unlimited skips',
			'premium.solo.feature_4' => 'High-quality audio',
			'premium.solo.subscribe' => 'Subscribe now',
			'premium.comparePlan.back' => 'Back',
			'premium.comparePlan.headline_1' => 'Choose your plan',
			'premium.comparePlan.headline_2' => 'that fits you best',
			'premium.comparePlan.headline_description' => 'Compare Free and Premium, then pick the monthly or annual billing that works for you.',
			'premium.comparePlan.feature_1_title' => 'Full premium access',
			'premium.comparePlan.feature_1_subtitle' => 'Every feature unlocked on all devices',
			'premium.comparePlan.feature_2_title' => 'No ads',
			'premium.comparePlan.feature_2_subtitle' => 'Stay focused without interruptions',
			'premium.comparePlan.feature_3_title' => 'Cloud sync',
			'premium.comparePlan.feature_3_subtitle' => 'Pick up where you left off',
			'premium.comparePlan.feature_4_title' => 'Priority support',
			'premium.comparePlan.feature_4_subtitle' => 'Help when you need it most',
			'premium.comparePlan.continue_cta' => 'Continue',
			'premium.comparePlan.best_offer_badge' => ({required Object percent}) => 'Save ${percent}%',
			'premium.comparePlan.per_month_line' => ({required Object price}) => '${price} billed yearly',
			'premium.comparePlan.billed_monthly' => 'Billed every month',
			'premium.comparePlan.billed_every' => ({required Object period}) => 'Billed every ${period}',
			'premium.comparePlan.flexible_plan' => 'Flexible billing',
			'premium.comparePlan.plan_three_month' => '3 months',
			'premium.comparePlan.plan_six_month' => '6 months',
			'premium.comparePlan.billing_note' => 'Auto-renews until cancelled. Manage in the store.',
			'premium.comparePlan.billing_note_web' => 'Auto-renews until cancelled. Manage in settings.',
			'premium.comparePlan.benefits_heading' => 'What\'s included',
			'premium.trialPlan.title_before' => 'KASY ',
			'premium.trialPlan.title_accent' => 'PRO',
			'premium.trialPlan.subtitle' => 'Access to all features',
			'premium.trialPlan.social_proof' => 'Join thousands of Kasy users',
			'premium.trialPlan.feature_1' => 'Unlimited premium features',
			'premium.trialPlan.feature_2' => 'High quality export',
			'premium.trialPlan.feature_3' => 'No ads and no watermark',
			'premium.trialPlan.feature_4' => 'Sync across all your devices',
			'premium.trialPlan.trial_toggle_enabled' => 'Free trial enabled',
			'premium.trialPlan.trial_toggle_disabled' => 'Enable free trial',
			'premium.trialPlan.cta_trial' => 'Start free trial',
			'premium.trialPlan.cta_no_trial' => 'Subscribe now',
			'premium.trialPlan.billing_trial' => ({required Object days, required Object price}) => '${days} days free, then ${price}/year',
			'premium.trialPlan.billing_annual' => ({required Object price}) => '${price}/year',
			'premium.unlockPlan.headline_1' => 'UNLOCK EVERYTHING',
			'premium.unlockPlan.headline_2' => 'IN A FEW TAPS',
			'premium.unlockPlan.headline_desktop' => 'Unlock everything in an instant',
			'premium.unlockPlan.feature_1' => 'Create more content',
			'premium.unlockPlan.feature_2' => 'Faster results',
			'premium.unlockPlan.feature_3' => 'Less waiting time',
			'premium.unlockPlan.feature_4' => 'Cloud sync',
			'premium.unlockPlan.feature_5' => 'Priority support',
			'premium.unlockPlan.cta' => 'Get access now',
			'premium.unlockPlan.cta_desktop' => 'Unlock',
			'premium.unlockPlan.billing_note' => 'Renews until canceled. Manage in the store.',
			'premium.unlockPlan.billing_note_web' => 'Renews until canceled. Manage in settings.',
			'premium.unlockPlan.plan_annual_price' => ({required Object price}) => 'Just ${price} / year',
			'premium.unlockPlan.plan_monthly_price' => ({required Object price}) => '${price} / month',
			'premium.comparison.title' => 'Premium plan comparison',
			'premium.comparison.features_label' => 'Features',
			'premium.comparison.free_version' => 'Free',
			'premium.comparison.premium_version' => 'Premium',
			'premium.comparison.no_ads' => 'No ads',
			'premium.comparison.premium_themes' => 'Premium themes',
			'premium.comparison.advanced_customization' => 'Advanced customization',
			'premium.comparison.priority_support' => 'Priority support',
			'premium.comparison.home_widget' => 'Home widgets',
			'premium.comparison.talk_with_assistant' => 'AI Assistant',
			'activePremium.title' => 'You are a premium user',
			'activePremium.description' => 'Enjoy all the features',
			'activePremium.unsubscribe_button' => 'Unsubscribe',
			'activePremium.early_bird_description' => 'You used a coupon that provided you access to the premium features for free without any subscription. Enjoy!',
			'activePremium.unsubscribe_feedback_title' => 'Help us improve',
			'activePremium.unsubscribe_feedback_description' => 'We\'re sorry to see you go. Could you briefly tell us why you\'re unsubscribing?',
			'activePremium.unsubscribe_feedback_hint' => 'Tell us your reason...',
			'activePremium.unsubscribe_feedback_min_chars' => 'Minimum 6 characters required',
			'activePremium.unsubscribe_confirm_button' => 'Continue',
			'activePremium.lifetime_user_description' => 'You are a lifetime user',
			'activePremium.managed_elsewhere_title' => 'Subscription on another platform',
			'activePremium.managed_elsewhere_description' => 'This subscription was made on another platform and can\'t be managed or cancelled here. Sign in to your account on the platform where you purchased it.',
			'activePremium.restore_button' => 'Restore purchases',
			'activePremium.cancel_button' => 'Close',
			'activePremium.billing_title' => 'Billing',
			'activePremium.plan_label' => 'Account plan',
			'activePremium.plan_fallback' => 'Premium',
			'activePremium.manage_subscription' => 'Manage subscription',
			'activePremium.restore_purchases' => 'Restore purchases',
			'activePremium.renews_on' => ({required Object date}) => 'Renews on ${date}',
			'activePremium.expires_on' => ({required Object date}) => 'Expires on ${date}',
			'activePremium.trial_label' => 'Free trial',
			'activePremium.trial_until' => ({required Object date}) => 'Free trial until ${date}',
			'activePremium.charges_from' => ({required Object price, required Object date}) => '${price} starting ${date}',
			'onboarding.feature_1.title' => 'Monetize from day one',
			'onboarding.feature_1.description' => 'Production-ready paywalls, subscriptions and free trials. No billing backend to build.',
			'onboarding.feature_1.action' => 'Continue',
			'onboarding.feature_1.skip' => 'Skip',
			'onboarding.feature_1.login' => 'Already have an account? Log in',
			'onboarding.feature_2.title' => 'Sign-in, already built',
			'onboarding.feature_2.description' => 'Email, social login and password recovery. Secure and ready to ship.',
			'onboarding.feature_2.action' => 'Continue',
			'onboarding.feature_2.back' => 'Back',
			'onboarding.feature_3.title' => 'Your built-in AI assistant',
			'onboarding.feature_3.description' => 'A conversational assistant your users can chat with, ready out of the box.',
			'onboarding.feature_3.action' => 'Continue',
			'onboarding.mockups.paywall.title' => 'Premium',
			'onboarding.mockups.paywall.annual' => 'Annual',
			'onboarding.mockups.paywall.monthly' => 'Monthly',
			'onboarding.mockups.paywall.save_badge' => '-40%',
			'onboarding.mockups.paywall.price_year' => '\$39.99 / yr',
			'onboarding.mockups.paywall.price_month' => '\$4.99 / mo',
			'onboarding.mockups.paywall.cta' => 'Start free trial',
			'onboarding.mockups.earnings.notify_title' => 'New Pro subscriber',
			'onboarding.mockups.earnings.notify_subtitle' => 'Annual plan · +\$49.90',
			'onboarding.mockups.earnings.notify_time' => '1:40 PM',
			'onboarding.mockups.earnings.processing' => 'Processing payment…',
			'onboarding.mockups.earnings.summary_label' => 'Earnings',
			'onboarding.mockups.earnings.summary_body' => 'You earned \$312.40 this week from 14 new subscriptions.',
			'onboarding.mockups.auth.welcome' => 'Welcome back',
			'onboarding.mockups.auth.email_hint' => 'you@email.com',
			'onboarding.mockups.auth.sign_in' => 'Sign in',
			'onboarding.mockups.auth.divider' => 'or',
			'onboarding.mockups.notification.title' => 'New message',
			'onboarding.mockups.notification.time' => 'now',
			'onboarding.mockups.ai_chat.u1' => 'What can you do?',
			'onboarding.mockups.ai_chat.a1' => 'I write, summarize and answer anything in seconds.',
			'onboarding.mockups.ai_chat.u2' => 'Summarize my notes',
			'onboarding.mockups.ai_chat.a2' => 'Done. Here are the 3 key points from today.',
			'onboarding.ageQuestion.title' => 'How old are you?',
			'onboarding.ageQuestion.description' => 'This helps us tailor your experience.',
			'onboarding.ageQuestion.options.age18_30' => '18 to 30',
			'onboarding.ageQuestion.options.age31_40' => '31 to 40',
			'onboarding.ageQuestion.options.age41_50' => '41 to 50',
			'onboarding.ageQuestion.options.age51_60' => 'Over 50',
			'onboarding.ageQuestion.options.none' => 'I\'d rather not say',
			'onboarding.ageQuestion.action' => 'Continue',
			'onboarding.genderQuestion.title' => 'How do you identify?',
			'onboarding.genderQuestion.description' => 'Pick what fits you best. You can skip this.',
			'onboarding.genderQuestion.options.male' => 'Male',
			'onboarding.genderQuestion.options.female' => 'Female',
			'onboarding.genderQuestion.options.none' => 'I\'d rather not say',
			'onboarding.genderQuestion.action' => 'Continue',
			'onboarding.notifications.title' => 'Stay in the loop',
			'onboarding.notifications.description' => 'We only reach out when it truly matters. No spam, ever.',
			'onboarding.notifications.continue_button' => 'Turn on notifications',
			'onboarding.notifications.skip_button' => 'Not now',
			'onboarding.notifications.toasts.push_app_name' => 'Kasy',
			'onboarding.notifications.toasts.push_headline' => 'Your weekly summary is ready',
			'onboarding.notifications.toasts.push_body' => 'Tap to open.',
			'onboarding.notifications.toasts.push_sent_at' => 'now',
			'onboarding.notifications.toasts.subscriber_title' => 'New Pro subscriber',
			'onboarding.notifications.toasts.subscriber_message' => 'Annual plan · +\$49.90',
			'onboarding.notifications.toasts.streak_title' => '7-day streak!',
			'onboarding.notifications.toasts.streak_message' => 'You hit your daily goal again.',
			'onboarding.notifications.toasts.message_title' => 'New reply',
			'onboarding.notifications.toasts.message_message' => 'Someone responded to your thread.',
			'onboarding.notifications.toasts.reminder_title' => 'Starting soon',
			'onboarding.notifications.toasts.reminder_message' => 'Your session begins in 10 minutes.',
			'onboarding.notifications.toasts.payment_title' => 'Payment received',
			'onboarding.notifications.toasts.payment_message' => '+\$12.50 credited to your balance.',
			'onboarding.notifications.toasts.offer_title' => 'Limited offer',
			'onboarding.notifications.toasts.offer_message' => '50% off annual — ends tonight.',
			'onboarding.notifications.toasts.social_title' => 'New interaction',
			'onboarding.notifications.toasts.social_message' => '3 people liked your latest post.',
			'onboarding.att.title' => 'Personalized experience',
			'onboarding.att.description' => 'This permission helps tailor communications to your profile. It does not show ads inside the app.',
			'onboarding.att.continue_button' => 'Continue',
			'onboarding.att.skip_button' => 'Not now',
			'onboarding.att.card.tag' => 'Privacy',
			'onboarding.loading.welcome' => 'Account created.',
			'onboarding.loading.welcome_male' => 'Account created. Welcome!',
			'onboarding.loading.welcome_female' => 'Account created. Welcome!',
			'onboarding.loading.steps.account' => 'Creating your account',
			'onboarding.loading.steps.preferences' => 'Saving your preferences',
			'onboarding.loading.steps.ready' => 'Personalizing your experience',
			'feature_requests.title' => 'Ideas',
			'feature_requests.description' => 'Vote on ideas or share your own. Every voice shapes the roadmap.',
			'feature_requests.community_ideas' => 'Community ideas',
			'feature_requests.no_requests' => 'No ideas yet',
			'feature_requests.no_requests_hint' => 'Be the first to suggest a feature or improvement.',
			'feature_requests.vote_success.title' => 'Vote registered',
			'feature_requests.vote_success.description' => 'Thanks for helping us prioritize',
			'feature_requests.vote_error.title' => 'Already voted',
			'feature_requests.vote_error.description' => 'You have already voted for this idea',
			'feature_requests.add_feature.chip_label' => 'Add',
			'feature_requests.add_feature.title' => 'Submit an idea',
			'feature_requests.add_feature.description' => 'Tell us what you\'d like to see built next.',
			'feature_requests.add_feature.save_button' => 'Submit',
			'feature_requests.add_feature.cancel' => 'Cancel',
			'feature_requests.add_feature.title_label' => 'Title',
			'feature_requests.add_feature.title_hint' => 'A short, descriptive title',
			'feature_requests.add_feature.description_label' => 'Description',
			'feature_requests.add_feature.description_hint' => 'Describe the feature or improvement in detail...',
			'feature_requests.add_feature.error_title' => 'Error',
			'feature_requests.add_feature.error_required' => 'Title and description are required',
			'feature_requests.add_feature.error_sending' => 'Something went wrong. Please try again.',
			'feature_requests.add_feature.error_too_short' => 'Description is too short. Please add more detail',
			'feature_requests.add_feature.toast_success.title' => 'Idea submitted',
			'feature_requests.add_feature.toast_success.description' => 'We\'ll review it and keep you posted',
			'update_bottom_sheet.title' => 'What\'s new?',
			'update_bottom_sheet.description' => 'We made some improvements',
			'update_bottom_sheet.highlights.0' => '- Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
			'update_bottom_sheet.highlights.1' => '- Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
			'update_bottom_sheet.highlights.2' => '- Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
			'update_bottom_sheet.continue_button' => 'Got it',
			'update_available.title' => 'Update available',
			'update_available.description' => 'A newer version of the app is available. Update to get the latest improvements and fixes.',
			'update_available.forced_title' => 'Update required',
			'update_available.forced_description' => 'This version is no longer supported. Please update to keep using the app.',
			'update_available.update_button' => 'Update now',
			'update_available.later_button' => 'Not now',
			'request_notification_permission.title' => 'Enable notifications?',
			'request_notification_permission.description' => 'Get real-time updates and stay on top of what matters.',
			'request_notification_permission.continue_button' => 'Enable',
			'request_notification_permission.skip_button' => 'Not now',
			'notification_permission_denied.title' => 'Permission Required',
			'notification_permission_denied.description' => 'To receive notifications, please enable notification permissions in your device settings.',
			'notification_permission_denied.allow_button' => 'Allow notifications',
			'notification_permission_denied.open_settings_button' => 'Open Settings',
			'notification_permission_denied.cancel_button' => 'Cancel',
			'review_popup.question_title' => 'Enjoying the app?',
			'review_popup.question_description' => 'Your answer helps us improve.',
			'review_popup.question_positive' => 'Yes, I am',
			'review_popup.question_negative' => 'Could be better',
			'review_popup.title' => 'Glad you like it!',
			'review_popup.description' => 'A store review makes all the difference. It takes a few seconds and really helps us grow.',
			'review_popup.rate_button' => 'Write a review',
			'navigation.home' => 'Home',
			'navigation.support' => 'Help',
			'navigation.notifications' => 'Notifications',
			'navigation.settings' => 'Config.',
			'navigation.logout' => 'Sign out',
			'navigation.skip_to_content' => 'Skip to content',
			'reminderPage.title' => 'Reminders',
			'reminderPage.toggleLabel' => 'Enable reminder',
			'reminderPage.typeLabel' => 'Repeat',
			'reminderPage.daily' => 'Every day',
			'reminderPage.weekly' => 'Every week',
			'reminderPage.specificDate' => 'Once',
			'reminderPage.timeLabel' => 'Time',
			'reminderPage.dayLabel' => 'Day of week',
			'reminderPage.dateLabel' => 'Date',
			'reminderPage.selectDate' => 'Select date',
			'reminderPage.hint' => 'Get reminded to come back to the app',
			'reminderPage.summaryDaily' => ({required Object time}) => 'Every day at ${time}',
			'reminderPage.summaryWeekly' => ({required Object day, required Object time}) => 'Every ${day} at ${time}',
			'reminderPage.summaryDate' => ({required Object date, required Object time}) => 'On ${date} at ${time}',
			'time_picker.title' => 'Select time',
			'time_picker.placeholder' => 'Select a time',
			'time_picker.hour' => 'Hour',
			'time_picker.minute' => 'Minute',
			'time_picker.am' => 'AM',
			'time_picker.pm' => 'PM',
			'time_picker.confirm' => 'OK',
			'time_picker.cancel' => 'Cancel',
			'dailyReminder.title' => 'Reminder',
			_ => null,
		} ?? switch (path) {
			'dailyReminder.body' => 'Time to drink a glass of water.',
			'settings.title' => 'Settings',
			'settings.avatar.title' => 'Profile photo',
			'settings.avatar.take_photo' => 'Take photo',
			'settings.avatar.choose_library' => 'Photo library',
			'settings.avatar.remove_photo' => 'Remove photo',
			'settings.avatar.cancel' => 'Cancel',
			'settings.language_title' => 'Languages',
			'settings.theme_title' => 'Theme',
			'settings.theme_option_system' => 'System',
			'settings.theme_option_light' => 'Light',
			'settings.theme_option_dark' => 'Dark',
			'settings.haptic_feedback_title' => 'Haptic feedback',
			'settings.hide_chrome_on_scroll_title' => 'Hide bars when scrolling',
			'settings.section_preferences_label' => 'PREFERENCES',
			'settings.section_security_label' => 'SECURITY',
			'settings.section_support_label' => 'HELP',
			'settings.biometric_title' => 'App lock',
			'settings.biometric_subtitle_ios' => 'Require Face ID or Touch ID each time you open the app while signed in.',
			'settings.biometric_subtitle_ios_face' => 'Require Face ID each time you open the app while signed in.',
			'settings.biometric_subtitle_ios_touch' => 'Require Touch ID each time you open the app while signed in.',
			'settings.biometric_subtitle_android' => 'We ask you to verify on this device when you open the app while signed in.',
			'settings.biometric_subtitle_android_face' => 'Require face unlock when you open the app while signed in.',
			'settings.biometric_subtitle_android_fingerprint' => 'Require fingerprint unlock when you open the app while signed in.',
			'settings.biometric_subtitle_android_face_and_fingerprint' => 'Require fingerprint or face unlock when you open while signed in.',
			'settings.biometric_disable_title' => 'Turn off lock?',
			'settings.biometric_disable_message' => 'Anyone with your unlocked phone can open the app until you sign out.',
			'settings.biometric_disable_confirm' => 'Turn off',
			'settings.biometric_disable_cancel' => 'Cancel',
			'settings.biometric_enable_reason_ios' => 'Confirm with Face ID or Touch ID to turn on App Lock',
			'settings.biometric_enable_reason_ios_face' => 'Confirm with Face ID to turn on App Lock',
			'settings.biometric_enable_reason_ios_touch' => 'Confirm with Touch ID to turn on App Lock',
			'settings.biometric_enable_reason_android' => 'Confirm on this phone to turn on App Lock',
			'settings.biometric_enable_reason_android_face' => 'Confirm with face unlock to turn on App Lock',
			'settings.biometric_enable_reason_android_fingerprint' => 'Confirm with fingerprint to turn on App Lock',
			'settings.biometric_enable_reason_android_face_and_fingerprint' => 'Confirm with fingerprint or face unlock to turn on App Lock',
			'settings.biometric_login_reason_ios' => 'Unlock with Face ID or Touch ID',
			'settings.biometric_login_reason_ios_face' => 'Unlock with Face ID',
			'settings.biometric_login_reason_ios_touch' => 'Unlock with Touch ID',
			'settings.biometric_login_reason_android' => 'Verify it\'s you',
			'settings.biometric_login_reason_android_face' => 'Unlock using face unlock',
			'settings.biometric_login_reason_android_fingerprint' => 'Unlock using fingerprint',
			'settings.biometric_login_reason_android_face_and_fingerprint' => 'Unlock with fingerprint or face',
			'settings.biometric_unavailable_message_ios' => 'Enable Face ID, Touch ID, or a device passcode in Settings.',
			'settings.biometric_unavailable_message_ios_face' => 'Turn on Face ID or a device passcode in Settings.',
			'settings.biometric_unavailable_message_ios_touch' => 'Turn on Touch ID or a device passcode in Settings.',
			'settings.biometric_unavailable_message_android' => 'Turn on biometric unlock or a screen lock in Settings.',
			'settings.biometric_unavailable_message_android_face' => 'Add face unlock or a secure screen lock in system settings.',
			'settings.biometric_unavailable_message_android_fingerprint' => 'Add a fingerprint or a secure screen lock in system settings.',
			'settings.biometric_unavailable_message_android_face_and_fingerprint' => 'Add a fingerprint or face unlock in Settings.',
			'settings.biometric_not_enabled_message' => 'App Lock wasn\'t enabled.',
			'settings.feedback' => 'Send feedback',
			'settings.premium' => 'Premium',
			'settings.billing' => 'Billing',
			'settings.privacy' => 'Privacy policy',
			'settings.support' => 'Help center',
			'settings.disconnect' => 'Yes, sign out',
			'settings.disconnect_confirm_title' => 'Sign out of your account?',
			'settings.disconnect_confirm_message' => 'Are you sure you want to sign out?',
			'settings.disconnect_cancel' => 'Cancel',
			'settings.logout' => 'Sign out',
			'settings.my_account' => 'My account',
			'settings.not_signed_in' => 'Not signed in',
			'settings.register' => 'Register',
			'settings.name_label' => 'Name',
			'settings.edit' => 'Edit',
			'settings.email_label' => 'Email',
			'settings.connected_with_label' => 'Connected with',
			'settings.provider_email' => 'Email & password',
			'settings.provider_phone' => 'Phone',
			'settings.create_password_title' => 'Create password',
			'settings.create_password_subtitle' => 'Set a password so you can also sign in with email and password, on top of social login.',
			'settings.create_password_field' => 'New password',
			'settings.create_password_confirm_label' => 'Confirm password',
			'settings.create_password_success' => 'Password created',
			'settings.create_password_error' => 'Couldn\'t create the password. Please try again.',
			'settings.create_password_too_short' => 'Password must be at least 6 characters',
			'settings.create_password_mismatch' => 'Passwords don\'t match',
			'settings.link_social' => ({required Object provider}) => 'Link ${provider}',
			'settings.link_social_success' => ({required Object provider}) => '${provider} linked',
			'settings.link_social_error' => 'Couldn\'t link the account. Please try again.',
			'settings.edit_name_title' => 'Edit name',
			'settings.edit_name_hint' => 'Your name',
			'settings.edit_name_save' => 'Save',
			'settings.edit_name_cancel' => 'Cancel',
			'settings.edit_name_success' => 'Name updated',
			'settings.edit_name_error' => 'Couldn\'t update your name. Please try again.',
			'settings.bio_label' => 'Bio',
			'settings.bio_hint' => 'Write something about yourself...',
			'settings.edit_profile_title' => 'Edit profile',
			'settings.edit_profile_save' => 'Save',
			'settings.edit_profile_success' => 'Profile updated',
			'settings.edit_profile_error' => 'Couldn\'t update your profile. Please try again.',
			'settings.reminders' => 'Reminders',
			'settings.admin_panel' => 'Admin Panel',
			'settings.admin_debug_section_label' => 'ADMIN (DEBUG ONLY)',
			'settings.admin_panel_debug_notice' => 'This entire Admin section (header, panel, and all options below) only exists in debug builds. It is not included in release; people who install from the store or a production APK never see any of it.',
			'settings.delete_account.button' => 'I want to delete my account',
			'settings.delete_account.title' => 'Delete your account?',
			'settings.delete_account.content' => 'Warning: this action is permanent and cannot be undone.',
			'settings.delete_account.content_subscriber' => 'Warning: this is permanent. You will lose your active subscription, and creating a new account later (even with the same email) will not restore it.',
			'settings.delete_account.cancel' => 'Cancel',
			'settings.delete_account.confirm' => 'Yes, delete',
			'settings.delete_account.error' => 'Something went wrong. Please try again.',
			'settings.admin.update_bottom_sheet' => 'Preview what\'s new',
			'settings.admin.preview_update_available' => 'Preview update available',
			'settings.admin.paywalls' => 'Paywalls',
			'settings.admin.test_onboarding' => 'Test onboarding',
			'settings.admin.copy_user_id' => 'Copy user id',
			'settings.admin.user_id_copied' => 'User id copied to clipboard',
			'settings.admin.copy_fcm_token' => 'Copy FCM Token',
			'settings.admin.fcm_token_copied' => 'FCM Token copied to clipboard',
			'settings.admin.fcm_token_unavailable' => 'Token unavailable (notifications disabled?)',
			'settings.admin.ask_notification' => 'Ask for notification',
			'settings.admin.native_only' => 'Available only in the native app (iOS / Android)',
			'settings.admin.ask_review' => 'Ask for review',
			'settings.admin.home_widgets_panel' => 'Home Widgets panel',
			'settings.admin.home_widgets_title' => 'Home Widgets Panel',
			'settings.admin.ads_demo_panel' => 'Ads demo',
			'settings.admin.ads_demo_title' => 'Ads demo',
			'settings.admin.ads_demo_subtitle' => 'The four AdMob formats with Google test ads. Try each, then drop it wherever you want in your app.',
			'settings.admin.ads_banner_label' => 'Banner',
			'settings.admin.ads_interstitial_title' => 'Interstitial',
			'settings.admin.ads_interstitial_desc' => 'Full-screen ad. Tap to show.',
			'settings.admin.ads_rewarded_title' => 'Rewarded',
			'settings.admin.ads_rewarded_desc' => 'User watches to earn a reward. Tap to show.',
			'settings.admin.ads_rewarded_interstitial_title' => 'Rewarded interstitial',
			'settings.admin.ads_rewarded_interstitial_desc' => 'Full-screen ad that also grants a reward. Tap to show.',
			'settings.admin.ads_reward_earned' => ({required Object amount, required Object type}) => 'Reward earned: ${amount} ${type}',
			'settings.admin.ads_load_failed' => 'Couldn\'t load the ad (no fill). Try again in a moment.',
			'settings.admin.ads_code_copied' => 'Code copied to clipboard',
			'settings.admin.ads_status_safe' => 'This demo always shows Google test ads, so it\'s safe to tap, even in production.',
			'settings.admin.ads_status_test' => 'Your real ad ids aren\'t set yet. Configure them to go live:',
			'settings.admin.ads_status_real' => 'Real ad ids are configured for this platform.',
			'settings.admin.inspector_fab_title' => 'Widget inspector',
			'settings.admin.inspector_fab_subtitle_prefix' => 'Global shortcut:',
			'settings.admin.update_mywidget_title' => 'Update MyWidget Widget',
			'settings.admin.update_mywidget_desc' => 'Call manual update for MyWidget widget',
			'settings.admin.paywalls_title' => 'Paywalls Admin Panel',
			'settings.admin.send_push_title' => 'Send notification',
			'settings.admin.send_push_to_all' => 'Send to all',
			'settings.admin.send_push_email_hint' => 'Add e-mail',
			'settings.admin.send_push_title_label' => 'Title',
			'settings.admin.send_push_title_hint' => 'e.g. New update available',
			'settings.admin.send_push_body_label' => 'Message',
			'settings.admin.send_push_body_hint' => 'Up to 3 lines in the app list (140 characters max)',
			'settings.admin.send_push_image_label' => 'Image URL (optional)',
			'settings.admin.send_push_image_hint' => 'https://...',
			'settings.admin.send_push_email_label' => 'Recipient e-mails',
			'settings.admin.send_push_success' => 'Notification sent!',
			'settings.admin.send_push_user_not_found' => ({required Object email}) => 'User not found: ${email}',
			'settings.admin.send_push_send_button' => 'Send',
			'settings.admin.send_push_required' => 'Title and message are required',
			'settings.admin.send_push_no_emails' => 'Add at least one e-mail',
			'settings.admin.send_push_route_label' => 'Page to open',
			'settings.admin.send_push_route_description' => 'Screen opened when the user taps the notification.',
			'settings.admin.send_push_route_notifications' => 'Notifications',
			'settings.admin.send_push_route_home' => 'Home',
			'settings.admin.send_push_route_settings' => 'Settings',
			'settings.admin.send_push_route_premium' => 'Premium',
			'settings.admin.send_push_route_reminder' => 'Reminders',
			'settings.admin.send_push_route_feedback' => 'Feedback',
			'settings.admin.send_push_preview_label' => 'Preview',
			'settings.admin.send_push_preview_now' => 'now',
			'settings.admin.send_push_preview_title_placeholder' => 'Notification title',
			'settings.admin.send_push_preview_body_placeholder' => 'Your message body shows here',
			'settings.admin.device_preview_title' => 'Device Preview (web only)',
			'settings.admin.send_push_section_recipients' => 'Recipients',
			'settings.admin.send_push_section_content' => 'Content',
			'settings.admin.send_push_section_advanced' => 'Advanced',
			'settings.admin.send_push_audience_all' => 'Everyone',
			'settings.admin.send_push_audience_specific' => 'Specific',
			'settings.admin.send_push_audience_all_hint' => 'The notification will be sent to every subscribed user.',
			'rate_banner.title' => 'Do you like our app?',
			'rate_banner.text' => 'Do you have a minute to leave us a review on the store?',
			'rate_banner.rate_button' => 'Yes sure!',
			'rate_banner.later_button' => 'Later...',
			'notifications.title' => 'Notifications',
			'notifications.empty_title' => 'No notifications yet',
			'notifications.empty_subtitle' => 'Stay tuned for updates',
			'notifications.error_fetching' => 'Error fetching notifications',
			'notifications.push_title' => 'Push notifications',
			'notifications.push_subtitle_enabled' => 'You are receiving alerts',
			'notifications.push_subtitle_disabled' => 'Tap to enable in Settings',
			'notifications.push_subtitle_waiting' => 'Enable to stay in the loop',
			'notifications.mark_all_read' => 'Mark as read',
			'notifications.see_all' => 'See all',
			'notifications.group_today' => 'Today',
			'notifications.group_yesterday' => 'Yesterday',
			'notifications.group_older' => 'Older',
			'notifications.empty_cta' => 'Enable notifications',
			'notifications.empty_cta_open_settings' => 'Open settings',
			'notifications.delete_all' => 'Delete all',
			'notifications.options' => 'Options',
			'notifications.delete_all_confirm_title' => 'Delete all notifications?',
			'notifications.delete_all_confirm_message' => 'This will permanently remove every notification from your account. This cannot be undone.',
			'notifications.delete_action' => 'Yes, delete',
			'notifications.cancel_action' => 'Cancel',
			'notifications.deleted_one' => 'Notification deleted',
			'notifications.deleted_all' => 'All notifications deleted',
			'notifications.new_comment_title' => 'New Comment',
			'notifications.new_comment_body' => 'A new comment was added to your PDF: "{pdfTitle}"',
			'bottom_router.fake_page_text' => 'This is a fake page',
			'ai_chat.title' => 'AI Assistant',
			'ai_chat.empty_state' => 'Start a conversation with your assistant.',
			'ai_chat.hint' => 'Ask something...',
			'ai_chat.error_not_configured' => 'The assistant isn\'t available yet. Please try again later.',
			'ai_chat.error_no_reply' => 'We couldn\'t get a reply. Please try again.',
			'ai_chat.error_network' => 'Could not reach the AI assistant.',
			'ai_chat.new_conversation' => 'New conversation',
			'ai_chat.conversations_empty' => 'No conversations yet',
			'ai_chat.conversations_empty_hint' => 'Tap New conversation to get started.',
			'ai_chat.no_conversation_selected' => 'Pick a conversation, or start a new one.',
			'ai_chat.delete_title' => 'Delete conversation?',
			'ai_chat.delete_message' => 'This conversation and all its messages will be permanently deleted.',
			'ai_chat.delete_cancel' => 'Cancel',
			'ai_chat.delete_confirm' => 'Yes, delete',
			'phone_auth.title_input' => 'Phone Authentication',
			'phone_auth.subtitle_input' => 'Enter your phone number',
			'phone_auth.description_input' => 'We will send you a verification code to confirm your identity',
			'phone_auth.phone_label' => 'Phone Number',
			'phone_auth.phone_hint' => '+1 (555) 123-4567',
			'phone_auth.error_empty' => 'Please enter a phone number',
			'phone_auth.error_invalid' => 'Please enter a valid phone number',
			'phone_auth.continue_btn' => 'Continue',
			'phone_auth.title_verify' => 'Verify code',
			'phone_auth.verification_code' => 'Verification Code',
			'phone_auth.code_sent' => ({required Object phone}) => 'We have sent a verification code to ${phone}',
			'phone_auth.signin_success_title' => 'All set',
			'phone_auth.signin_success_text' => 'You\'re now signed in with your phone number',
			'phone_auth.verify_code' => 'Verify Code',
			'phone_auth.resend_code' => 'Resend Code',
			'phone_auth.enter_all_digits' => 'Please enter all 6 digits',
			'recover_password_result.title' => 'Email sent',
			'recover_password_result.description' => 'We sent you an email with a link to reset your password',
			'recover_password_result.back_to_signin' => 'Get back to Sign in',
			'recover_password_result.note' => 'Note: If you don\'t receive an email, please check your spam folder',
			'page_not_found.title' => '404 - Page not found',
			'devInspector.copied' => 'Context copied. Paste into your AI chat.',
			'devInspector.activate' => 'Activate widget inspector',
			'devInspector.deactivate' => 'Deactivate widget inspector',
			'devInspector.copyForAi' => 'Copy for AI',
			'devInspector.selectWidgetFirst' => 'Select a widget on screen first.',
			'devInspector.inspectorHint' => 'Tap a widget to select. Context copies automatically. Press C to copy again.',
			'devInspector.statusActive' => 'Inspecting',
			'webDevicePreview.frame' => 'Frame',
			'webDevicePreview.darkBackground' => 'Dark background',
			'webDevicePreview.darkTheme' => 'Dark theme',
			'webDevicePreview.landscape' => 'Landscape',
			'webDevicePreview.textScale' => 'Text scale',
			'webDevicePreview.screenshot' => 'Screenshot',
			'webDevicePreview.imageCopied' => 'Image copied — paste it in chat',
			'webDevicePreview.imageDownloaded' => 'Image downloaded',
			'webDevicePreview.hotReload' => 'Hot reload',
			'webDevicePreview.hotRestart' => 'Hot restart',
			'webDevicePreview.hotReloading' => 'Reloading…',
			'webDevicePreview.hotRestarting' => 'Restarting…',
			'webDevicePreview.hotReloadDone' => 'Reload complete',
			'webDevicePreview.hotRestartDone' => 'Restart complete',
			'webDevicePreview.hotReloadFailed' => 'Reload failed',
			'webDevicePreview.hotReloadNeedsRestart' => 'That change needs a full restart — tap R',
			'webDevicePreview.hotReloadCompileError' => 'Code error — fix it in the editor, then reload',
			'webDevicePreview.hotRestartFailed' => 'Restart failed',
			'webDevicePreview.hotRestartCompileError' => 'Code error — fix it in the editor, then restart',
			'webDevicePreview.terminalStatusOk' => 'Terminal clear — r is good to go',
			'webDevicePreview.terminalStatusError' => 'Terminal has an error — fix it or tap R',
			'webDevicePreview.terminalStatusOffline' => 'Terminal bridge offline — run kasy run --web',
			'webDevicePreview.devBridgeUnavailable' => 'Dev server offline — run kasy run --web, keep the terminal open, and open the URL it prints',
			'biometric_prompt.title_ios_face' => 'Turn on Face ID for App Lock?',
			'biometric_prompt.title_ios_touch' => 'Turn on Touch ID for App Lock?',
			'biometric_prompt.title_ios_mixed' => 'Turn on Face ID/Touch ID for App Lock?',
			'biometric_prompt.title_android_face' => 'Turn on App Lock with face unlock?',
			'biometric_prompt.title_android_fingerprint' => 'Turn on App Lock with fingerprint?',
			'biometric_prompt.title_android_mixed' => 'Protect the app with your phone?',
			'biometric_prompt.message_ios_face' => 'You\'ll confirm with Face ID when you open the app—you stay signed in.',
			'biometric_prompt.message_ios_touch' => 'You\'ll confirm with Touch ID when you open the app—you stay signed in.',
			'biometric_prompt.message_ios_mixed' => 'When you launch you\'ll confirm with Face ID or Touch ID—you stay signed in.',
			'biometric_prompt.message_android_face' => 'You\'ll confirm with face unlock when you open—you stay signed in.',
			'biometric_prompt.message_android_fingerprint' => 'You\'ll confirm with fingerprint when you open—you stay signed in.',
			'biometric_prompt.title_android_face_and_fingerprint' => 'Turn on App Lock with fingerprint or face?',
			'biometric_prompt.message_android_face_and_fingerprint' => 'Either works—you stay signed in.',
			'biometric_prompt.message_android_mixed' => 'A quick check when you open—you stay signed in.',
			'biometric_prompt.not_now' => 'Not now',
			'biometric_prompt.enable' => 'Turn on',
			'home_widget.greeting_morning' => 'Good morning',
			'home_widget.greeting_afternoon' => 'Good afternoon',
			'home_widget.greeting_evening' => 'Good evening',
			'home_widget.title_with_name' => ({required Object name}) => 'Hi, ${name}!',
			'home_widget.title_default' => 'Hi there!',
			'home_widget.title_logged_out' => 'We\'ll be here when you\'re back',
			'home_widget.plan_free' => 'Free plan',
			'home_widget.plan_pro' => 'PRO',
			'home_widget.quote' => 'Your time is limited.\nDon\'t live someone else\'s life.\nHave the courage to follow your intuition.\nEverything else is secondary.',
			'home_widget.quote_author' => 'Steve Jobs',
			'kanban.title' => 'Tasks',
			'kanban.empty_title' => 'Organize your tasks',
			'kanban.empty_description' => 'Create custom columns and start organizing what needs to be done in your project.',
			'kanban.empty_column' => 'No tasks in this column',
			'kanban.error_title' => 'Failed to load',
			'kanban.add_column' => 'Add column',
			'kanban.add_column_subtitle' => 'Pick a short name to organize tasks in this column.',
			'kanban.add_another_list' => 'Add another list',
			'kanban.add_list' => 'Add list',
			'kanban.list_name_hint' => 'Enter list name...',
			'kanban.add_task' => 'Add task',
			'kanban.add_task_subtitle' => 'Set a title and, optionally, a description and priority.',
			'kanban.edit_column' => 'Edit column',
			'kanban.edit_task_subtitle' => 'Update this task\'s details.',
			'kanban.cancel' => 'Cancel',
			'kanban.save' => 'Save',
			'kanban.delete_column' => 'Delete column',
			'kanban.edit_task' => 'Edit task',
			'kanban.delete_task' => 'Delete task',
			'kanban.column_name' => 'Column name',
			'kanban.column_name_hint' => 'e.g., In Progress, Done',
			'kanban.task_title' => 'Task title',
			'kanban.task_title_hint' => 'e.g., Implement login',
			'kanban.task_title_required' => 'Enter a task title.',
			'kanban.column_name_required' => 'Enter a column name.',
			'kanban.task_description' => 'Description',
			'kanban.task_description_hint' => 'Task details',
			'kanban.create' => 'Create',
			'kanban.mark_complete' => 'Mark as complete',
			'kanban.mark_incomplete' => 'Mark as pending',
			'kanban.column_created' => 'Column created',
			'kanban.column_updated' => 'Column updated',
			'kanban.column_deleted' => 'Column deleted',
			'kanban.task_created' => 'Task created',
			'kanban.task_updated' => 'Task updated',
			'kanban.task_deleted' => 'Task deleted',
			'kanban.priority' => 'Priority',
			'kanban.priority_none' => 'None',
			'kanban.priority_low' => 'Low',
			'kanban.priority_medium' => 'Medium',
			'kanban.priority_high' => 'High',
			'kanban.priority_urgent' => 'Urgent',
			'kanban.cards_count' => ({required Object count}) => '${count} cards',
			'kanban.move_to' => 'Move to column',
			'kanban.move_left' => 'Move left',
			'kanban.move_right' => 'Move right',
			'kanban.delete_column_confirm' => 'This will permanently delete all cards in this column.',
			'kanban.delete_task_confirm' => 'This task will be permanently deleted.',
			'kanban.created_on' => ({required Object date}) => 'Created on ${date}',
			'library.title' => 'Library',
			'library.categories' => 'Categories',
			'library.manage_categories' => 'Manage Categories',
			'library.add_category' => 'Add Category',
			'library.edit_category' => 'Edit Category',
			'library.delete_category' => 'Delete Category',
			'library.category_name' => 'Category Name',
			'library.category_desc' => 'Category Description',
			'library.save' => 'Save',
			'library.cancel' => 'Cancel',
			'library.pdfs' => 'PDFs',
			'library.favorites' => 'Favorites',
			'library.search_hint' => 'Search by title, author, or tag...',
			'library.add_pdf' => 'Add PDF',
			'library.edit_pdf' => 'Edit PDF',
			'library.delete_pdf' => 'Delete PDF',
			'library.pdf_title' => 'Title',
			'library.pdf_desc' => 'Description',
			'library.pdf_author' => 'Author',
			'library.pdf_url' => 'PDF File URL',
			'library.pdf_thumb' => 'Thumbnail URL',
			'library.pdf_tags' => 'Tags (comma-separated)',
			'library.no_pdfs' => 'No PDFs found',
			'library.comments' => 'Comments',
			'library.write_comment' => 'Write a comment...',
			'library.submit_comment' => 'Submit Comment',
			'library.rating' => 'Rating',
			'library.download' => 'Download',
			'library.read' => 'Read',
			'library.unauthorized' => 'You must be an admin to view this page.',
			'library.profile_switcher' => 'Switch Profile',
			'library.active_profile' => 'Active Profile',
			'library.admin_dev' => 'Admin / Dev',
			'library.client' => 'Client',
			'library.read_sim' => 'Simulated Reader',
			'library.prev_page' => 'Previous',
			'library.next_page' => 'Next',
			'library.zoom_in' => 'Zoom In',
			'library.zoom_out' => 'Zoom Out',
			'library.page_info' => ({required Object page, required Object total}) => 'Page ${page} of ${total}',
			'library.no_comments' => 'No comments yet. Be the first to comment!',
			'library.my_pdfs' => 'My PDFs',
			'library.send_pdf' => 'Send PDF',
			'library.no_client_pdfs' => 'No PDFs sent by clients yet.',
			'library.upload_box_title' => 'Click to upload your PDF',
			'library.upload_box_subtitle' => 'Supported format: PDF (Max 10MB)',
			'library.pdf_preview' => 'PDF Preview',
			'library.pages' => 'Pages',
			'library.change_file' => 'Change File',
			'library.explore' => 'Explore',
			'library.visit_profile' => 'Visit profile',
			'library.no_public_pdfs' => 'No public PDFs uploaded by others yet.',
			'library.uploaded_by' => 'Uploaded by',
			'library.sent_by' => 'Sent by',
			'library.public_profile' => 'Public Profile',
			'library.view_all_pdfs' => 'View all PDFs from this user',
			'search.title' => 'Global Search',
			'search.hint' => 'Search authors, themes and PDFs...',
			'search.authors' => 'Authors',
			'search.categories' => 'Themes',
			'search.pdfs' => 'PDFs',
			'search.empty' => 'No results found for "{query}".',
			_ => null,
		};
	}
}
