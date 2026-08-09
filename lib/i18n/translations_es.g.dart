///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:slang/generated.dart';
import 'translations.g.dart';

// Path: <root>
class TranslationsEs extends Translations with BaseTranslations<AppLocale, Translations> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsEs({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.es,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		super.$meta.setFlatMapFunction($meta.getTranslation); // copy base translations to super.$meta
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <es>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key) ?? super.$meta.getTranslation(key);

	late final TranslationsEs _root = this; // ignore: unused_field

	@override 
	TranslationsEs $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsEs(meta: meta ?? this.$meta);

	// Translations
	@override late final _TranslationsCommonEs common = _TranslationsCommonEs._(_root);
	@override late final _TranslationsAdminConsoleEs admin_console = _TranslationsAdminConsoleEs._(_root);
	@override late final _TranslationsHomeEs home = _TranslationsHomeEs._(_root);
	@override late final _TranslationsAuthEs auth = _TranslationsAuthEs._(_root);
	@override late final _TranslationsRatePopupEs rate_popup = _TranslationsRatePopupEs._(_root);
	@override late final _TranslationsPremiumEs premium = _TranslationsPremiumEs._(_root);
	@override late final _TranslationsActivePremiumEs activePremium = _TranslationsActivePremiumEs._(_root);
	@override late final _TranslationsOnboardingEs onboarding = _TranslationsOnboardingEs._(_root);
	@override late final _TranslationsFeatureRequestsEs feature_requests = _TranslationsFeatureRequestsEs._(_root);
	@override late final _TranslationsUpdateBottomSheetEs update_bottom_sheet = _TranslationsUpdateBottomSheetEs._(_root);
	@override late final _TranslationsUpdateAvailableEs update_available = _TranslationsUpdateAvailableEs._(_root);
	@override late final _TranslationsRequestNotificationPermissionEs request_notification_permission = _TranslationsRequestNotificationPermissionEs._(_root);
	@override late final _TranslationsNotificationPermissionDeniedEs notification_permission_denied = _TranslationsNotificationPermissionDeniedEs._(_root);
	@override late final _TranslationsReviewPopupEs review_popup = _TranslationsReviewPopupEs._(_root);
	@override late final _TranslationsNavigationEs navigation = _TranslationsNavigationEs._(_root);
	@override late final _TranslationsReminderPageEs reminderPage = _TranslationsReminderPageEs._(_root);
	@override late final _TranslationsTimePickerEs time_picker = _TranslationsTimePickerEs._(_root);
	@override late final _TranslationsDailyReminderEs dailyReminder = _TranslationsDailyReminderEs._(_root);
	@override late final _TranslationsSettingsEs settings = _TranslationsSettingsEs._(_root);
	@override late final _TranslationsRateBannerEs rate_banner = _TranslationsRateBannerEs._(_root);
	@override late final _TranslationsNotificationsEs notifications = _TranslationsNotificationsEs._(_root);
	@override late final _TranslationsBottomRouterEs bottom_router = _TranslationsBottomRouterEs._(_root);
	@override late final _TranslationsAiChatEs ai_chat = _TranslationsAiChatEs._(_root);
	@override late final _TranslationsPhoneAuthEs phone_auth = _TranslationsPhoneAuthEs._(_root);
	@override late final _TranslationsRecoverPasswordResultEs recover_password_result = _TranslationsRecoverPasswordResultEs._(_root);
	@override late final _TranslationsPageNotFoundEs page_not_found = _TranslationsPageNotFoundEs._(_root);
	@override late final _TranslationsDevInspectorEs devInspector = _TranslationsDevInspectorEs._(_root);
	@override late final _TranslationsWebDevicePreviewEs webDevicePreview = _TranslationsWebDevicePreviewEs._(_root);
	@override late final _TranslationsBiometricPromptEs biometric_prompt = _TranslationsBiometricPromptEs._(_root);
	@override late final _TranslationsHomeWidgetEs home_widget = _TranslationsHomeWidgetEs._(_root);
	@override late final _TranslationsKanbanEs kanban = _TranslationsKanbanEs._(_root);
	@override late final _TranslationsLibraryEs library = _TranslationsLibraryEs._(_root);
	@override late final _TranslationsSearchEs search = _TranslationsSearchEs._(_root);
}

// Path: common
class _TranslationsCommonEs extends TranslationsCommonEn {
	_TranslationsCommonEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get close => 'Cerrar';
	@override String get copied => 'Copiado';
	@override String get saved => 'Guardado';
	@override String get error => 'Error';
	@override String get unavailable => 'No disponible';
	@override String get native_only_title => 'Solo en la app nativa';
}

// Path: admin_console
class _TranslationsAdminConsoleEs extends TranslationsAdminConsoleEn {
	_TranslationsAdminConsoleEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsAdminConsoleTabsEs tabs = _TranslationsAdminConsoleTabsEs._(_root);
	@override String get back_to_app => 'Volver a la app';
	@override late final _TranslationsAdminConsoleOverviewEs overview = _TranslationsAdminConsoleOverviewEs._(_root);
	@override late final _TranslationsAdminConsoleUsersEs users = _TranslationsAdminConsoleUsersEs._(_root);
	@override late final _TranslationsAdminConsoleRequestsEs requests = _TranslationsAdminConsoleRequestsEs._(_root);
	@override late final _TranslationsAdminConsoleCategoriesEs categories = _TranslationsAdminConsoleCategoriesEs._(_root);
	@override late final _TranslationsAdminConsoleGroupsEs groups = _TranslationsAdminConsoleGroupsEs._(_root);
	@override late final _TranslationsAdminConsolePaywallsEs paywalls = _TranslationsAdminConsolePaywallsEs._(_root);
	@override late final _TranslationsAdminConsoleSettingsEntryEs settings_entry = _TranslationsAdminConsoleSettingsEntryEs._(_root);
	@override String get requires_admin => 'Necesitas ser admin para ver esto. Define role: admin en el registro de tu usuario en el backend. La app no puede cambiar este campo; la validación está en el servidor.';
}

// Path: home
class _TranslationsHomeEs extends TranslationsHomeEn {
	_TranslationsHomeEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Ejemplo Kasy';
	@override String get welcome => 'Bienvenido al demo de Kasy';
	@override late final _TranslationsHomeCardsEs cards = _TranslationsHomeCardsEs._(_root);
	@override late final _TranslationsHomeFeaturesPageEs features_page = _TranslationsHomeFeaturesPageEs._(_root);
	@override late final _TranslationsHomeDashboardEs dashboard = _TranslationsHomeDashboardEs._(_root);
	@override late final _TranslationsHomeComponentsPreviewEs components_preview = _TranslationsHomeComponentsPreviewEs._(_root);
}

// Path: auth
class _TranslationsAuthEs extends TranslationsAuthEn {
	_TranslationsAuthEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsAuthSigninEs signin = _TranslationsAuthSigninEs._(_root);
	@override late final _TranslationsAuthSignupEs signup = _TranslationsAuthSignupEs._(_root);
	@override late final _TranslationsAuthRecoverEs recover = _TranslationsAuthRecoverEs._(_root);
}

// Path: rate_popup
class _TranslationsRatePopupEs extends TranslationsRatePopupEn {
	_TranslationsRatePopupEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => '¿Tienes 15 segundos para calificarnos?';
	@override String get description => '¡Es rápido y muy útil! ¡Muchas gracias!';
	@override String get cancel_button => 'Quizás más tarde';
	@override String get rate_button => '¡Sí, con gusto!';
}

// Path: premium
class _TranslationsPremiumEs extends TranslationsPremiumEn {
	_TranslationsPremiumEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title_1 => 'Desbloquea el acceso completo';
	@override String get description => 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.';
	@override String get feature_1 => 'Característica 1 lorem ipsum';
	@override String get feature_2 => 'Característica 2 mop issum';
	@override String get feature_3 => 'Característica 3 lorem';
	@override String get duration_weekly => 'Semana';
	@override String get duration_annual => 'Año';
	@override String get duration_monthly => 'Mes';
	@override String get duration_monthly_description => 'Cancela cuando quieras';
	@override String get duration_lifetime => 'De por vida';
	@override String get duration_lifetime_description => 'Pago único';
	@override String get restore_action => 'Restaurar';
	@override String get preview_disabled_title => 'Vista previa';
	@override String get preview_disabled_text => 'Esta es una vista previa de administrador. Las acciones de compra están desactivadas.';
	@override String get coupon_title => '¿Tienes un cupón?';
	@override String get payment_cancel_reassurance => 'Cancelación fácil con 1 clic, siempre';
	@override String get payment_cancel_reassurance_free_trial => 'Sin pago ahora, cancela cuando quieras';
	@override String get payment_action => 'Iniciar prueba gratuita';
	@override String payment_action_trial({required Object money}) => '7 días gratis, luego ${money}';
	@override String try_free_btn_action({required Object days}) => 'Prueba gratis por ${days} días';
	@override String get duration_recuring_label_annual => 'Anual';
	@override String get duration_recuring_label_monthly => 'Mensual';
	@override String get duration_recuring_label_weekly => 'Semanal';
	@override String get price_per_week => '/semana';
	@override String get price_per_month => '/mes';
	@override String get price_per_three_month => '/3 meses';
	@override String get price_per_six_month => '/6 meses';
	@override String get price_per_year => '/año';
	@override String get price_one_time => '';
	@override String get action_button => 'Continuar';
	@override String get terms => 'Términos';
	@override String get privacy => 'Privacidad';
	@override String get terms_of_use => 'Términos de uso';
	@override String get privacy_policy => 'Política de privacidad';
	@override String get error_loading => 'Error al cargar las ofertas';
	@override String get no_products_title => 'Las opciones de suscripción aún no están disponibles';
	@override String get no_products_description => 'Inténtalo de nuevo en unos instantes. Si sigue ocurriendo, es posible que los productos de la tienda aún estén terminando la configuración.';
	@override String get restore_success_title => 'Suscripción restaurada';
	@override String get restore_success_text => 'Gracias por tu confianza';
	@override String get purchase_success_title => 'Suscripción realizada con éxito';
	@override String get purchase_success_text => 'Gracias por tu confianza';
	@override String get error_title => 'Error';
	@override String get error_text => 'Ocurrió un error. Inténtalo de nuevo';
	@override String get web_checkout_timeout_title => 'Pago no confirmado';
	@override String get web_checkout_timeout_text => 'No recibimos confirmación del pago. Si ya pagaste, toca Restaurar.';
	@override String get restore_none_title => 'No se encontró ninguna suscripción';
	@override String get restore_none_text => 'No encontramos una suscripción activa para restaurar.';
	@override late final _TranslationsPremiumSoloEs solo = _TranslationsPremiumSoloEs._(_root);
	@override late final _TranslationsPremiumComparePlanEs comparePlan = _TranslationsPremiumComparePlanEs._(_root);
	@override late final _TranslationsPremiumTrialPlanEs trialPlan = _TranslationsPremiumTrialPlanEs._(_root);
	@override late final _TranslationsPremiumUnlockPlanEs unlockPlan = _TranslationsPremiumUnlockPlanEs._(_root);
	@override late final _TranslationsPremiumComparisonEs comparison = _TranslationsPremiumComparisonEs._(_root);
}

// Path: activePremium
class _TranslationsActivePremiumEs extends TranslationsActivePremiumEn {
	_TranslationsActivePremiumEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Eres un usuario premium';
	@override String get description => 'Disfruta todas las funciones';
	@override String get unsubscribe_button => 'Cancelar suscripción';
	@override String get early_bird_description => 'Usaste un cupón que te dio acceso gratuito a las funciones premium sin suscripción. ¡Disfrútalo!';
	@override String get unsubscribe_feedback_title => 'Ayúdanos a mejorar';
	@override String get unsubscribe_feedback_description => 'Lamentamos verte partir. ¿Podrías decirnos brevemente por qué te estás dando de baja?';
	@override String get unsubscribe_feedback_hint => 'Cuéntanos tu motivo...';
	@override String get unsubscribe_feedback_min_chars => 'Se requieren mínimo 6 caracteres';
	@override String get unsubscribe_confirm_button => 'Continuar';
	@override String get lifetime_user_description => 'Eres un usuario de por vida';
	@override String get managed_elsewhere_title => 'Suscripción en otra plataforma';
	@override String get managed_elsewhere_description => 'Esta suscripción se realizó en otra plataforma y no se puede gestionar ni cancelar aquí. Inicia sesión en tu cuenta en la plataforma donde la compraste.';
	@override String get restore_button => 'Restaurar compras';
	@override String get cancel_button => 'Cerrar';
	@override String get billing_title => 'Facturación';
	@override String get plan_label => 'Plan de cuenta';
	@override String get plan_fallback => 'Premium';
	@override String get manage_subscription => 'Administrar suscripción';
	@override String get restore_purchases => 'Restaurar compras';
	@override String renews_on({required Object date}) => 'Renueva el ${date}';
	@override String expires_on({required Object date}) => 'Expira el ${date}';
	@override String get trial_label => 'Evaluación gratuita';
	@override String trial_until({required Object date}) => 'Evaluación gratuita hasta el ${date}';
	@override String charges_from({required Object price, required Object date}) => '${price} a partir del ${date}';
}

// Path: onboarding
class _TranslationsOnboardingEs extends TranslationsOnboardingEn {
	_TranslationsOnboardingEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsOnboardingFeature1Es feature_1 = _TranslationsOnboardingFeature1Es._(_root);
	@override late final _TranslationsOnboardingFeature2Es feature_2 = _TranslationsOnboardingFeature2Es._(_root);
	@override late final _TranslationsOnboardingFeature3Es feature_3 = _TranslationsOnboardingFeature3Es._(_root);
	@override late final _TranslationsOnboardingMockupsEs mockups = _TranslationsOnboardingMockupsEs._(_root);
	@override late final _TranslationsOnboardingAgeQuestionEs ageQuestion = _TranslationsOnboardingAgeQuestionEs._(_root);
	@override late final _TranslationsOnboardingGenderQuestionEs genderQuestion = _TranslationsOnboardingGenderQuestionEs._(_root);
	@override late final _TranslationsOnboardingNotificationsEs notifications = _TranslationsOnboardingNotificationsEs._(_root);
	@override late final _TranslationsOnboardingAttEs att = _TranslationsOnboardingAttEs._(_root);
	@override late final _TranslationsOnboardingLoadingEs loading = _TranslationsOnboardingLoadingEs._(_root);
}

// Path: feature_requests
class _TranslationsFeatureRequestsEs extends TranslationsFeatureRequestsEn {
	_TranslationsFeatureRequestsEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Ideas';
	@override String get description => 'Vota ideas o comparte la tuya. Cada voz define lo que construimos.';
	@override String get community_ideas => 'Ideas de la comunidad';
	@override String get no_requests => 'Sin ideas aún';
	@override String get no_requests_hint => 'Sé el primero en sugerir una función o mejora.';
	@override late final _TranslationsFeatureRequestsVoteSuccessEs vote_success = _TranslationsFeatureRequestsVoteSuccessEs._(_root);
	@override late final _TranslationsFeatureRequestsVoteErrorEs vote_error = _TranslationsFeatureRequestsVoteErrorEs._(_root);
	@override late final _TranslationsFeatureRequestsAddFeatureEs add_feature = _TranslationsFeatureRequestsAddFeatureEs._(_root);
}

// Path: update_bottom_sheet
class _TranslationsUpdateBottomSheetEs extends TranslationsUpdateBottomSheetEn {
	_TranslationsUpdateBottomSheetEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => '¿Qué hay de nuevo?';
	@override String get description => 'Hicimos algunas mejoras';
	@override List<String> get highlights => [
		'- Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
		'- Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
		'- Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
	];
	@override String get continue_button => 'Entendido';
}

// Path: update_available
class _TranslationsUpdateAvailableEs extends TranslationsUpdateAvailableEn {
	_TranslationsUpdateAvailableEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Actualización disponible';
	@override String get description => 'Hay una versión más nueva de la app. Actualiza para tener las últimas mejoras y correcciones.';
	@override String get forced_title => 'Actualización requerida';
	@override String get forced_description => 'Esta versión ya no es compatible. Actualiza para seguir usando la app.';
	@override String get update_button => 'Actualizar ahora';
	@override String get later_button => 'Ahora no';
}

// Path: request_notification_permission
class _TranslationsRequestNotificationPermissionEs extends TranslationsRequestNotificationPermissionEn {
	_TranslationsRequestNotificationPermissionEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => '¿Activar notificaciones?';
	@override String get description => 'Recibe actualizaciones en tiempo real y mantente al día con lo que importa.';
	@override String get continue_button => 'Activar';
	@override String get skip_button => 'Ahora no';
}

// Path: notification_permission_denied
class _TranslationsNotificationPermissionDeniedEs extends TranslationsNotificationPermissionDeniedEn {
	_TranslationsNotificationPermissionDeniedEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Permiso requerido';
	@override String get description => 'Para recibir notificaciones, activa los permisos de notificación en la configuración de tu dispositivo.';
	@override String get allow_button => 'Permitir notificaciones';
	@override String get open_settings_button => 'Abrir configuración';
	@override String get cancel_button => 'Cancelar';
}

// Path: review_popup
class _TranslationsReviewPopupEs extends TranslationsReviewPopupEn {
	_TranslationsReviewPopupEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get question_title => '¿Te gusta la app?';
	@override String get question_description => 'Tu respuesta nos ayuda a mejorar.';
	@override String get question_positive => 'Sí, me gusta';
	@override String get question_negative => 'Podría mejorar';
	@override String get title => '¡Qué bueno que te guste!';
	@override String get description => 'Una reseña en la tienda marca la diferencia. Toma unos segundos y nos ayuda mucho a crecer.';
	@override String get rate_button => 'Escribir una reseña';
}

// Path: navigation
class _TranslationsNavigationEs extends TranslationsNavigationEn {
	_TranslationsNavigationEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get home => 'Inicio';
	@override String get support => 'Ayuda';
	@override String get notifications => 'Notificaciones';
	@override String get settings => 'Config.';
	@override String get logout => 'Salir';
	@override String get skip_to_content => 'Saltar al contenido';
}

// Path: reminderPage
class _TranslationsReminderPageEs extends TranslationsReminderPageEn {
	_TranslationsReminderPageEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Recordatorios';
	@override String get toggleLabel => 'Activar recordatorio';
	@override String get typeLabel => 'Repetir';
	@override String get daily => 'Cada día';
	@override String get weekly => 'Cada semana';
	@override String get specificDate => 'Una vez';
	@override String get timeLabel => 'Hora';
	@override String get dayLabel => 'Día de la semana';
	@override String get dateLabel => 'Fecha';
	@override String get selectDate => 'Seleccionar fecha';
	@override String get hint => 'Recibe un recordatorio para volver a la app';
	@override String summaryDaily({required Object time}) => 'Todos los días a las ${time}';
	@override String summaryWeekly({required Object day, required Object time}) => 'Cada ${day} a las ${time}';
	@override String summaryDate({required Object date, required Object time}) => 'El ${date} a las ${time}';
}

// Path: time_picker
class _TranslationsTimePickerEs extends TranslationsTimePickerEn {
	_TranslationsTimePickerEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Selecciona la hora';
	@override String get placeholder => 'Selecciona una hora';
	@override String get hour => 'Hora';
	@override String get minute => 'Minuto';
	@override String get am => 'AM';
	@override String get pm => 'PM';
	@override String get confirm => 'OK';
	@override String get cancel => 'Cancelar';
}

// Path: dailyReminder
class _TranslationsDailyReminderEs extends TranslationsDailyReminderEn {
	_TranslationsDailyReminderEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Recordatorio';
	@override String get body => 'Es hora de beber un vaso de agua.';
}

// Path: settings
class _TranslationsSettingsEs extends TranslationsSettingsEn {
	_TranslationsSettingsEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Configuración';
	@override late final _TranslationsSettingsAvatarEs avatar = _TranslationsSettingsAvatarEs._(_root);
	@override String get language_title => 'Idiomas';
	@override String get theme_title => 'Tema';
	@override String get theme_option_system => 'Sistema';
	@override String get theme_option_light => 'Claro';
	@override String get theme_option_dark => 'Oscuro';
	@override String get haptic_feedback_title => 'Feedback háptico';
	@override String get hide_chrome_on_scroll_title => 'Ocultar barras al desplazar';
	@override String get section_preferences_label => 'PREFERENCIAS';
	@override String get section_security_label => 'SEGURIDAD';
	@override String get section_support_label => 'AYUDA';
	@override String get biometric_title => 'Bloqueo de la app';
	@override String get biometric_subtitle_ios => 'Pide Face ID o Touch ID al abrir con la sesión iniciada.';
	@override String get biometric_subtitle_ios_face => 'Exige Face ID al abrir con sesión iniciada.';
	@override String get biometric_subtitle_ios_touch => 'Exige Touch ID al abrir con sesión iniciada.';
	@override String get biometric_subtitle_android => 'Pediremos una verificación rápida en el teléfono cuando abras con sesión iniciada.';
	@override String get biometric_subtitle_android_face => 'Exige desbloqueo facial al abrir con sesión iniciada.';
	@override String get biometric_subtitle_android_fingerprint => 'Exige huella digital al abrir con sesión iniciada.';
	@override String get biometric_subtitle_android_face_and_fingerprint => 'Exige huella digital o desbloqueo facial al abrir con sesión iniciada.';
	@override String get biometric_disable_title => '¿Desactivar bloqueo?';
	@override String get biometric_disable_message => 'Sin bloqueo, quien tenga el teléfono desbloqueado puede usar la app hasta que cierres sesión.';
	@override String get biometric_disable_confirm => 'Desactivar';
	@override String get biometric_disable_cancel => 'Cancelar';
	@override String get biometric_enable_reason_ios => 'Confirma con Face ID o Touch ID para activar el bloqueo';
	@override String get biometric_enable_reason_ios_face => 'Confirma con Face ID para activar el bloqueo';
	@override String get biometric_enable_reason_ios_touch => 'Confirma con Touch ID para activar el bloqueo';
	@override String get biometric_enable_reason_android => 'Confirma en el teléfono para activar el bloqueo';
	@override String get biometric_enable_reason_android_face => 'Confirma con reconocimiento facial para activar el bloqueo';
	@override String get biometric_enable_reason_android_fingerprint => 'Confirma con huella digital para activar el bloqueo';
	@override String get biometric_enable_reason_android_face_and_fingerprint => 'Confirma con huella o rostro para activar el bloqueo';
	@override String get biometric_login_reason_ios => 'Desbloquea con Face ID o Touch ID';
	@override String get biometric_login_reason_ios_face => 'Desbloquea con Face ID';
	@override String get biometric_login_reason_ios_touch => 'Desbloquea con Touch ID';
	@override String get biometric_login_reason_android => 'Confirma tu identidad';
	@override String get biometric_login_reason_android_face => 'Desbloquea con reconocimiento facial';
	@override String get biometric_login_reason_android_fingerprint => 'Desbloquea con huella digital';
	@override String get biometric_login_reason_android_face_and_fingerprint => 'Desbloquea con huella o rostro';
	@override String get biometric_unavailable_message_ios => 'Activa Face ID, Touch ID o código en Ajustes.';
	@override String get biometric_unavailable_message_ios_face => 'Activa Face ID o un código del dispositivo en Ajustes.';
	@override String get biometric_unavailable_message_ios_touch => 'Activa Touch ID o un código del dispositivo en Ajustes.';
	@override String get biometric_unavailable_message_android => 'Activa desbloqueo biométrico o bloqueo de pantalla en Ajustes.';
	@override String get biometric_unavailable_message_android_face => 'Configura reconocimiento facial o bloqueo de pantalla en ajustes.';
	@override String get biometric_unavailable_message_android_fingerprint => 'Configura huella digital o bloqueo de pantalla en ajustes.';
	@override String get biometric_unavailable_message_android_face_and_fingerprint => 'Añade huella o reconocimiento facial en Ajustes.';
	@override String get biometric_not_enabled_message => 'El bloqueo de la app no se activó.';
	@override String get feedback => 'Enviar comentarios';
	@override String get premium => 'Premium';
	@override String get billing => 'Facturación';
	@override String get privacy => 'Política de privacidad';
	@override String get support => 'Centro de ayuda';
	@override String get disconnect => 'Sí, salir';
	@override String get disconnect_confirm_title => '¿Salir de tu cuenta?';
	@override String get disconnect_confirm_message => '¿Seguro que quieres salir?';
	@override String get disconnect_cancel => 'Cancelar';
	@override String get logout => 'Cerrar sesión';
	@override String get my_account => 'Mi cuenta';
	@override String get not_signed_in => 'No conectado';
	@override String get register => 'Registrarse';
	@override String get name_label => 'Nombre';
	@override String get edit => 'Editar';
	@override String get email_label => 'Correo electrónico';
	@override String get connected_with_label => 'Conectado con';
	@override String get provider_email => 'Correo y contraseña';
	@override String get provider_phone => 'Teléfono';
	@override String get create_password_title => 'Crear contraseña';
	@override String get create_password_subtitle => 'Define una contraseña para también iniciar sesión con correo y contraseña, además del inicio de sesión social.';
	@override String get create_password_field => 'Nueva contraseña';
	@override String get create_password_confirm_label => 'Confirmar contraseña';
	@override String get create_password_success => 'Contraseña creada';
	@override String get create_password_error => 'No se pudo crear la contraseña. Inténtalo de nuevo.';
	@override String get create_password_too_short => 'La contraseña debe tener al menos 6 caracteres';
	@override String get create_password_mismatch => 'Las contraseñas no coinciden';
	@override String link_social({required Object provider}) => 'Vincular ${provider}';
	@override String link_social_success({required Object provider}) => '${provider} vinculado';
	@override String get link_social_error => 'No se pudo vincular la cuenta. Inténtalo de nuevo.';
	@override String get edit_name_title => 'Editar nombre';
	@override String get edit_name_hint => 'Tu nombre';
	@override String get edit_name_save => 'Guardar';
	@override String get edit_name_cancel => 'Cancelar';
	@override String get edit_name_success => 'Nombre actualizado';
	@override String get edit_name_error => 'No se pudo actualizar tu nombre. Inténtalo de nuevo.';
	@override String get bio_label => 'Bio';
	@override String get bio_hint => 'Escribe algo sobre ti...';
	@override String get edit_profile_title => 'Editar perfil';
	@override String get edit_profile_save => 'Guardar';
	@override String get edit_profile_success => 'Perfil actualizado';
	@override String get edit_profile_error => 'No se pudo actualizar tu perfil. Inténtalo de nuevo.';
	@override String get reminders => 'Recordatorios';
	@override String get admin_panel => 'Panel de Administración';
	@override String get admin_debug_section_label => 'ADMIN (SOLO DEBUG)';
	@override String get admin_panel_debug_notice => 'Toda esta sección Admin (título, panel y opciones) solo existe en builds de debug. No se incluye en release; quien instala desde la tienda o un APK de producción no ve nada de esto.';
	@override late final _TranslationsSettingsDeleteAccountEs delete_account = _TranslationsSettingsDeleteAccountEs._(_root);
	@override late final _TranslationsSettingsAdminEs admin = _TranslationsSettingsAdminEs._(_root);
}

// Path: rate_banner
class _TranslationsRateBannerEs extends TranslationsRateBannerEn {
	_TranslationsRateBannerEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => '¿Te gusta nuestra app?';
	@override String get text => '¿Tienes un minuto para dejarnos una reseña en la tienda?';
	@override String get rate_button => '¡Sí, seguro!';
	@override String get later_button => 'Más tarde...';
}

// Path: notifications
class _TranslationsNotificationsEs extends TranslationsNotificationsEn {
	_TranslationsNotificationsEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Notificaciones';
	@override String get empty_title => 'No tienes notificaciones';
	@override String get empty_subtitle => 'Mantente atento a las actualizaciones';
	@override String get error_fetching => 'Error al obtener notificaciones';
	@override String get push_title => 'Notificaciones push';
	@override String get push_subtitle_enabled => 'Estás recibiendo alertas';
	@override String get push_subtitle_disabled => 'Toca para activar en Configuración';
	@override String get push_subtitle_waiting => 'Activa para no perderte nada';
	@override String get mark_all_read => 'Marcar leídas';
	@override String get see_all => 'Ver todas';
	@override String get group_today => 'Hoy';
	@override String get group_yesterday => 'Ayer';
	@override String get group_older => 'Más antiguas';
	@override String get empty_cta => 'Activar notificaciones';
	@override String get empty_cta_open_settings => 'Abrir ajustes';
	@override String get delete_all => 'Eliminar todo';
	@override String get options => 'Opciones';
	@override String get delete_all_confirm_title => '¿Eliminar todas las notificaciones?';
	@override String get delete_all_confirm_message => 'Esto eliminará todas las notificaciones de tu cuenta. Esta acción no se puede deshacer.';
	@override String get delete_action => 'Sí, eliminar';
	@override String get cancel_action => 'Cancelar';
	@override String get deleted_one => 'Notificación eliminada';
	@override String get deleted_all => 'Todas las notificaciones eliminadas';
	@override String get new_comment_title => 'Nuevo Comentario';
	@override String get new_comment_body => 'Se ha añadido un nuevo comentario a tu PDF: "{pdfTitle}"';
}

// Path: bottom_router
class _TranslationsBottomRouterEs extends TranslationsBottomRouterEn {
	_TranslationsBottomRouterEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get fake_page_text => 'Esta es una página de prueba';
}

// Path: ai_chat
class _TranslationsAiChatEs extends TranslationsAiChatEn {
	_TranslationsAiChatEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Asistente IA';
	@override String get empty_state => 'Inicia una conversación con tu asistente.';
	@override String get hint => 'Pregunta algo...';
	@override String get error_not_configured => 'El asistente aún no está disponible. Inténtalo más tarde.';
	@override String get error_no_reply => 'No pudimos obtener una respuesta. Inténtalo de nuevo.';
	@override String get error_network => 'No se pudo conectar al asistente de IA.';
	@override String get new_conversation => 'Nueva conversación';
	@override String get conversations_empty => 'Aún no hay conversaciones';
	@override String get conversations_empty_hint => 'Toca en Nueva conversación para empezar.';
	@override String get no_conversation_selected => 'Elige una conversación o empieza una nueva.';
	@override String get delete_title => '¿Eliminar conversación?';
	@override String get delete_message => 'Esta conversación y todos sus mensajes se eliminarán de forma permanente.';
	@override String get delete_cancel => 'Cancelar';
	@override String get delete_confirm => 'Sí, eliminar';
}

// Path: phone_auth
class _TranslationsPhoneAuthEs extends TranslationsPhoneAuthEn {
	_TranslationsPhoneAuthEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title_input => 'Autenticación por Teléfono';
	@override String get subtitle_input => 'Ingresa tu número de teléfono';
	@override String get description_input => 'Te enviaremos un código de verificación para confirmar tu identidad';
	@override String get phone_label => 'Número de teléfono';
	@override String get phone_hint => '+34 600 123 456';
	@override String get error_empty => 'Por favor, ingresa un número de teléfono';
	@override String get error_invalid => 'Por favor, ingresa un número válido';
	@override String get continue_btn => 'Continuar';
	@override String get title_verify => 'Verificar Código';
	@override String get verification_code => 'Código de Verificación';
	@override String code_sent({required Object phone}) => 'Hemos enviado un código de verificación a ${phone}';
	@override String get signin_success_title => 'Listo';
	@override String get signin_success_text => 'Has iniciado sesión con tu número de teléfono';
	@override String get verify_code => 'Verificar Código';
	@override String get resend_code => 'Reenviar Código';
	@override String get enter_all_digits => 'Por favor, ingresa los 6 dígitos';
}

// Path: recover_password_result
class _TranslationsRecoverPasswordResultEs extends TranslationsRecoverPasswordResultEn {
	_TranslationsRecoverPasswordResultEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Email enviado';
	@override String get description => 'Te hemos enviado un email con un enlace para restablecer tu contraseña';
	@override String get back_to_signin => 'Volver a Iniciar Sesión';
	@override String get note => 'Nota: Si no recibes un email, por favor revisa tu carpeta de spam';
}

// Path: page_not_found
class _TranslationsPageNotFoundEs extends TranslationsPageNotFoundEn {
	_TranslationsPageNotFoundEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => '404 - Página no encontrada';
}

// Path: devInspector
class _TranslationsDevInspectorEs extends TranslationsDevInspectorEn {
	_TranslationsDevInspectorEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get copied => 'Contexto copiado. Pégalo en el chat de IA.';
	@override String get activate => 'Activar inspector de widgets';
	@override String get deactivate => 'Desactivar inspector de widgets';
	@override String get copyForAi => 'Copiar para IA';
	@override String get selectWidgetFirst => 'Selecciona un widget en pantalla primero.';
	@override String get inspectorHint => 'Toca un widget para seleccionar. El contexto se copia solo. Tecla C para copiar de nuevo.';
	@override String get statusActive => 'Inspeccionando';
}

// Path: webDevicePreview
class _TranslationsWebDevicePreviewEs extends TranslationsWebDevicePreviewEn {
	_TranslationsWebDevicePreviewEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get frame => 'Frame';
	@override String get darkBackground => 'Fondo oscuro';
	@override String get darkTheme => 'Tema oscuro';
	@override String get landscape => 'Horizontal';
	@override String get textScale => 'Escala de texto';
	@override String get screenshot => 'Captura de pantalla';
	@override String get imageCopied => 'Imagen copiada — pégala en el chat';
	@override String get imageDownloaded => 'Imagen descargada';
	@override String get hotReload => 'Hot reload';
	@override String get hotRestart => 'Hot restart';
	@override String get hotReloading => 'Recargando…';
	@override String get hotRestarting => 'Reiniciando…';
	@override String get hotReloadDone => 'Recarga completa';
	@override String get hotRestartDone => 'Reinicio completo';
	@override String get hotReloadFailed => 'Error al recargar';
	@override String get hotReloadNeedsRestart => 'Ese cambio necesita reinicio — usa el botón R';
	@override String get hotReloadCompileError => 'Error en el código — corrígelo en el editor y recarga';
	@override String get hotRestartFailed => 'Error al reiniciar';
	@override String get hotRestartCompileError => 'Error en el código — corrígelo en el editor y reinicia';
	@override String get terminalStatusOk => 'Terminal sin errores — puedes usar r';
	@override String get terminalStatusError => 'Terminal con error — corrígelo o usa R';
	@override String get terminalStatusOffline => 'Puente del terminal offline — usa kasy run --web';
	@override String get devBridgeUnavailable => 'Servidor dev offline — ejecuta kasy run --web, deja el terminal abierto y abre la URL que muestre';
}

// Path: biometric_prompt
class _TranslationsBiometricPromptEs extends TranslationsBiometricPromptEn {
	_TranslationsBiometricPromptEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title_ios_face => '¿Activar Face ID en el bloqueo?';
	@override String get title_ios_touch => '¿Activar Touch ID en el bloqueo?';
	@override String get title_ios_mixed => '¿Activar Face ID/Touch ID en el bloqueo?';
	@override String get title_android_face => '¿Activar bloqueo con reconocimiento facial?';
	@override String get title_android_fingerprint => '¿Activar bloqueo con huella digital?';
	@override String get title_android_mixed => '¿Proteger la app con tu teléfono?';
	@override String get message_ios_face => 'Al abrir confirmarás con Face ID—sigues con sesión iniciada.';
	@override String get message_ios_touch => 'Al abrir confirmarás con Touch ID—sigues con sesión iniciada.';
	@override String get message_ios_mixed => 'Al abrir confirmarás con Face ID o Touch ID—sigues con sesión iniciada.';
	@override String get message_android_face => 'Al abrir verificarás con reconocimiento facial—sigues con sesión iniciada.';
	@override String get message_android_fingerprint => 'Al abrir verificarás con huella digital—sigues con sesión iniciada.';
	@override String get title_android_face_and_fingerprint => '¿Activar bloqueo con huella o rostro?';
	@override String get message_android_face_and_fingerprint => 'Puedes usar cualquiera de los dos—sigues dentro.';
	@override String get message_android_mixed => 'Una confirmación rápida al abrir—sigues con la sesión.';
	@override String get not_now => 'Ahora no';
	@override String get enable => 'Activar';
}

// Path: home_widget
class _TranslationsHomeWidgetEs extends TranslationsHomeWidgetEn {
	_TranslationsHomeWidgetEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get greeting_morning => 'Buenos días';
	@override String get greeting_afternoon => 'Buenas tardes';
	@override String get greeting_evening => 'Buenas noches';
	@override String title_with_name({required Object name}) => '¡Hola, ${name}!';
	@override String get title_default => '¡Hola!';
	@override String get title_logged_out => 'Te esperamos de vuelta';
	@override String get plan_free => 'Plan gratuito';
	@override String get plan_pro => 'PRO';
	@override String get quote => 'Tu tiempo es limitado.\nNo vivas la vida de otra persona.\nTen el coraje de seguir tu intuición.\nTodo lo demás es secundario.';
	@override String get quote_author => 'Steve Jobs';
}

// Path: kanban
class _TranslationsKanbanEs extends TranslationsKanbanEn {
	_TranslationsKanbanEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Tareas';
	@override String get empty_title => 'Organiza tus tareas';
	@override String get empty_description => 'Crea columnas personalizadas y comienza a organizar lo que hay que hacer en tu proyecto.';
	@override String get empty_column => 'Sin tareas en esta columna';
	@override String get error_title => 'Error al cargar';
	@override String get add_column => 'Añadir columna';
	@override String get add_column_subtitle => 'Elige un nombre corto para organizar las tareas en esta columna.';
	@override String get add_another_list => 'Añadir otra lista';
	@override String get add_list => 'Añadir lista';
	@override String get list_name_hint => 'Escribe el nombre de la lista...';
	@override String get add_task => 'Añadir tarea';
	@override String get add_task_subtitle => 'Define el titulo y, si quieres, una descripcion y la prioridad.';
	@override String get edit_column => 'Editar columna';
	@override String get edit_task_subtitle => 'Actualiza los detalles de esta tarea.';
	@override String get cancel => 'Cancelar';
	@override String get save => 'Guardar';
	@override String get delete_column => 'Eliminar columna';
	@override String get edit_task => 'Editar tarea';
	@override String get delete_task => 'Eliminar tarea';
	@override String get column_name => 'Nombre de columna';
	@override String get column_name_hint => 'Ej: En progreso, Hecho';
	@override String get task_title => 'Título de tarea';
	@override String get task_title_hint => 'Ej: Implementar login';
	@override String get task_title_required => 'Ingresa un título para la tarea.';
	@override String get column_name_required => 'Ingresa un nombre para la columna.';
	@override String get task_description => 'Descripción';
	@override String get task_description_hint => 'Detalles sobre la tarea';
	@override String get create => 'Crear';
	@override String get mark_complete => 'Marcar como completada';
	@override String get mark_incomplete => 'Marcar como pendiente';
	@override String get column_created => 'Columna creada';
	@override String get column_updated => 'Columna actualizada';
	@override String get column_deleted => 'Columna eliminada';
	@override String get task_created => 'Tarea creada';
	@override String get task_updated => 'Tarea actualizada';
	@override String get task_deleted => 'Tarea eliminada';
	@override String get priority => 'Prioridad';
	@override String get priority_none => 'Ninguna';
	@override String get priority_low => 'Baja';
	@override String get priority_medium => 'Media';
	@override String get priority_high => 'Alta';
	@override String get priority_urgent => 'Urgente';
	@override String cards_count({required Object count}) => '${count} cards';
	@override String get move_to => 'Mover a columna';
	@override String get move_left => 'Mover a la izquierda';
	@override String get move_right => 'Mover a la derecha';
	@override String get delete_column_confirm => 'Se eliminaran permanentemente todas las tarjetas de esta columna.';
	@override String get delete_task_confirm => 'Esta tarea se eliminara permanentemente.';
	@override String created_on({required Object date}) => 'Creado el ${date}';
}

// Path: library
class _TranslationsLibraryEs extends TranslationsLibraryEn {
	_TranslationsLibraryEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Biblioteca';
	@override String get categories => 'Categorías';
	@override String get manage_categories => 'Administrar Categorías';
	@override String get add_category => 'Agregar Categoría';
	@override String get edit_category => 'Editar Categoría';
	@override String get delete_category => 'Eliminar Categoría';
	@override String get category_name => 'Nombre de la Categoría';
	@override String get category_desc => 'Descripción de la Categoría';
	@override String get save => 'Guardar';
	@override String get cancel => 'Cancelar';
	@override String get pdfs => 'PDFs';
	@override String get favorites => 'Favoritos';
	@override String get search_hint => 'Buscar por título, autor o etiqueta...';
	@override String get add_pdf => 'Registrar PDF';
	@override String get edit_pdf => 'Editar PDF';
	@override String get delete_pdf => 'Eliminar PDF';
	@override String get pdf_title => 'Título';
	@override String get pdf_desc => 'Descripción';
	@override String get pdf_author => 'Autor';
	@override String get pdf_url => 'URL del archivo PDF';
	@override String get pdf_thumb => 'URL de la miniatura (portada)';
	@override String get pdf_tags => 'Etiquetas (separadas por comas)';
	@override String get no_pdfs => 'Ningún PDF encontrado';
	@override String get comments => 'Comentarios';
	@override String get write_comment => 'Escribir un comentario...';
	@override String get submit_comment => 'Enviar Comentario';
	@override String get rating => 'Calificación';
	@override String get download => 'Descargar';
	@override String get read => 'Leer';
	@override String get unauthorized => 'Debes ser administrador para ver esta página.';
	@override String get profile_switcher => 'Cambiar Perfil';
	@override String get active_profile => 'Perfil Activo';
	@override String get admin_dev => 'Admin / Dev';
	@override String get client => 'Cliente';
	@override String get read_sim => 'Lector Simulado';
	@override String get prev_page => 'Anterior';
	@override String get next_page => 'Siguiente';
	@override String get zoom_in => 'Acercar';
	@override String get zoom_out => 'Alejar';
	@override String page_info({required Object page, required Object total}) => 'Página ${page} de ${total}';
	@override String get no_comments => 'Aún no hay comentarios. ¡Sé el primero en comentar!';
	@override String get my_pdfs => 'Mis PDFs';
	@override String get send_pdf => 'Enviar PDF';
	@override String get no_client_pdfs => 'Ningún PDF enviado por clientes aún.';
	@override String get upload_box_title => 'Haz clic para subir tu PDF';
	@override String get upload_box_subtitle => 'Formato soportado: PDF (Máx. 10MB)';
	@override String get pdf_preview => 'Vista previa del PDF';
	@override String get pages => 'Páginas';
	@override String get change_file => 'Cambiar Archivo';
	@override String get explore => 'Explorar';
	@override String get visit_profile => 'Visitar perfil';
	@override String get no_public_pdfs => 'Ningún PDF público enviado por otros usuarios aún.';
	@override String get uploaded_by => 'Enviado por';
	@override String get sent_by => 'Enviado por';
	@override String get public_profile => 'Perfil Público';
	@override String get view_all_pdfs => 'Ver todos los PDFs subidos por este usuario';
}

// Path: search
class _TranslationsSearchEs extends TranslationsSearchEn {
	_TranslationsSearchEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Búsqueda Global';
	@override String get hint => 'Buscar autores, temas y PDFs...';
	@override String get authors => 'Autores';
	@override String get categories => 'Temas';
	@override String get pdfs => 'PDFs';
	@override String get empty => 'No se encontraron resultados para "{query}".';
}

// Path: admin_console.tabs
class _TranslationsAdminConsoleTabsEs extends TranslationsAdminConsoleTabsEn {
	_TranslationsAdminConsoleTabsEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get overview => 'Resumen';
	@override String get users => 'Usuarios';
	@override String get requests => 'Solicitudes';
	@override String get categories => 'Categorías';
	@override String get tools => 'Herramientas';
	@override String get debug => 'Depuración';
}

// Path: admin_console.overview
class _TranslationsAdminConsoleOverviewEs extends TranslationsAdminConsoleOverviewEn {
	_TranslationsAdminConsoleOverviewEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get section => 'Proyecto';
	@override String get summary => 'Resumen';
	@override String get backend => 'Backend';
	@override String get account => 'Cuenta';
	@override String get guest => 'Invitado';
	@override String get user_id => 'ID de usuario';
	@override String get build => 'Versión';
	@override String get session_title => 'Sesión actual';
	@override String get requests_metric => 'Solicitudes de función';
	@override String get total_users => 'Usuarios totales';
	@override String get subscribers => 'Suscriptores';
	@override String get new_7d => 'Nuevos (7 días)';
	@override String get signups_title => 'Nuevos registros';
	@override String get signups_subtitle => 'Últimos 14 días';
	@override String signups_total({required Object count}) => '${count} en 14 días';
	@override String get signups_empty => 'Sin registros en este período.';
	@override String get plan_split_title => 'Distribución de planes';
	@override String get free => 'Gratis';
	@override String get subscriber => 'Suscriptor';
	@override String conversion({required Object percent}) => '${percent} suscriben';
	@override String loaded_note({required Object count}) => 'Según los ${count} usuarios más recientes.';
	@override String get users_hint => 'Abre la pestaña Usuarios para gestionar todas las cuentas.';
	@override String get debug_note => 'Consola de depuración — visible solo en builds de desarrollo.';
}

// Path: admin_console.users
class _TranslationsAdminConsoleUsersEs extends TranslationsAdminConsoleUsersEn {
	_TranslationsAdminConsoleUsersEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Usuarios';
	@override String get search_hint => 'Buscar por nombre o correo';
	@override String get col_user => 'Usuario';
	@override String get col_status => 'Estado';
	@override String get col_plan => 'Plan';
	@override String get col_role => 'Rol';
	@override String get col_action => 'Acciones';
	@override String get col_joined => 'Registro';
	@override String get status_active => 'Activo';
	@override String get status_inactive => 'Inactivo';
	@override String get status_blocked => 'Bloqueado';
	@override String get role_admin => 'Admin';
	@override String get role_user => 'Usuario';
	@override String get action_make_admin => 'Hacer Administrador';
	@override String get action_remove_admin => 'Quitar Admin';
	@override String get action_block => 'Bloquear Acceso';
	@override String get action_unblock => 'Desbloquear';
	@override String get plan_subscriber => 'Suscriptor';
	@override String get plan_free => 'Gratis';
	@override String get empty => 'No se encontraron usuarios';
	@override String get empty_hint => 'Cuando alguien cree una cuenta, aparecerá aquí.';
	@override String get error => 'No se pudieron cargar los usuarios. Asegúrate de ser admin.';
	@override String page({required Object page, required Object total}) => 'Página ${page} de ${total}';
	@override String get prev => 'Anterior';
	@override String get next => 'Siguiente';
	@override String get anonymous => 'Anónimo';
	@override String get filter_all => 'Todos los usuarios';
	@override String get filter_subscribers => 'Suscriptores';
	@override String get loading => 'Cargando usuarios…';
	@override String results({required Object from, required Object to, required Object total}) => 'Mostrando ${from} a ${to} de ${total}';
	@override String truncated({required Object count}) => 'Mostrando los ${count} más recientes. La búsqueda cubre solo los cargados.';
	@override String get search_capped => 'La búsqueda escaneó un conjunto limitado. Pueden faltar coincidencias.';
	@override String get empty_search => 'Ningún usuario coincide con la búsqueda';
	@override String get empty_search_hint => 'Prueba con otro nombre o correo.';
	@override String get empty_subscribers => 'No se encontraron suscriptores';
	@override String get empty_subscribers_hint => 'Quien tenga el plan premium aparece en este filtro.';
	@override String get refresh => 'Actualizar';
	@override String get retry => 'Reintentar';
}

// Path: admin_console.requests
class _TranslationsAdminConsoleRequestsEs extends TranslationsAdminConsoleRequestsEn {
	_TranslationsAdminConsoleRequestsEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Solicitudes de función';
	@override String get subtitle => 'Solicitudes y sugerencias enviadas por tus usuarios. Márcalas como visibles para mostrarlas en la app, u ocúltalas si no corresponden.';
	@override String get empty => 'Aún no hay solicitudes';
	@override String get empty_hint => 'Cuando un usuario envíe una idea, aparecerá aquí.';
	@override String votes({required Object count}) => '${count} votos';
	@override String get visible => 'Visible';
	@override String get hidden => 'Oculto';
	@override String get edit => 'Editar';
	@override String get error => 'No se pudieron cargar las solicitudes';
	@override String get saved => 'Solicitud actualizada';
	@override String get editor_title => 'Editar solicitud';
	@override String get field_title => 'Título';
	@override String get field_description => 'Descripción';
	@override String get lang_en => 'Inglés';
	@override String get lang_pt => 'Portugués';
	@override String get lang_es => 'Español';
	@override String get visibility => 'Visible para los usuarios';
	@override String get save => 'Guardar';
	@override String get cancel => 'Cancelar';
}

// Path: admin_console.categories
class _TranslationsAdminConsoleCategoriesEs extends TranslationsAdminConsoleCategoriesEn {
	_TranslationsAdminConsoleCategoriesEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Categorías';
	@override String get subtitle => 'Administre las categorías oficiales de la biblioteca. Los PDF vinculados a una categoría eliminada no se borrarán.';
	@override String get add => 'Nueva Categoría';
	@override String get edit => 'Editar';
	@override String get delete => 'Eliminar';
	@override String get delete_confirm => '¿Está seguro de que desea eliminar esta categoría?';
	@override String get save => 'Guardar';
	@override String get cancel => 'Cancelar';
	@override String get name => 'Nombre';
	@override String get description => 'Descripción';
	@override String get icon => 'Icono';
	@override String get color => 'Color';
	@override String get empty => 'No hay categorías.';
	@override String get success_saved => '¡Categoría guardada con éxito!';
	@override String get success_deleted => '¡Categoría eliminada!';
	@override String get error_empty_fields => 'Por favor, complete todos los campos requeridos.';
}

// Path: admin_console.groups
class _TranslationsAdminConsoleGroupsEs extends TranslationsAdminConsoleGroupsEn {
	_TranslationsAdminConsoleGroupsEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get actions => 'Acciones';
	@override String get features => 'Funciones';
	@override String get preview => 'Vista previa';
	@override String get debug_actions => 'Acciones de debug';
	@override String get identity => 'Identidad';
	@override String get notification_test => 'Prueba de notificación';
}

// Path: admin_console.paywalls
class _TranslationsAdminConsolePaywallsEs extends TranslationsAdminConsolePaywallsEn {
	_TranslationsAdminConsolePaywallsEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get subtitle => 'Toca un paywall para previsualizarlo. Copia su código para decirle al asistente cuál usar.';
	@override String get copy_code => 'Copiar código';
	@override String get code_copied => 'Código copiado al portapapeles';
	@override String get solo_title => 'Solo';
	@override String get solo_desc => 'Un solo plan con beneficios y un CTA. Ideal para apps de un tier.';
	@override String get compare_title => 'Compare';
	@override String get compare_desc => 'Mensual vs anual lado a lado, con tabla free vs premium.';
	@override String get trial_title => 'Trial';
	@override String get trial_desc => 'Toggle de prueba gratis, normalmente en el anual. Mensual cobra al instante.';
	@override String get unlock_title => 'Unlock';
	@override String get unlock_desc => 'Paywall de conversión para onboarding o bloqueo fuerte.';
}

// Path: admin_console.settings_entry
class _TranslationsAdminConsoleSettingsEntryEs extends TranslationsAdminConsoleSettingsEntryEn {
	_TranslationsAdminConsoleSettingsEntryEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Admin';
	@override String get caption => 'Visible solo para administradores y en modo de desarrollo.';
}

// Path: home.cards
class _TranslationsHomeCardsEs extends TranslationsHomeCardsEn {
	_TranslationsHomeCardsEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get paywall_title => 'Paywall';
	@override String get paywall_description => 'Ver la página de suscripción';
	@override String get notification_title => 'Prueba de notificación local';
	@override String get notification_description => 'Muestra una alerta solo en este dispositivo. No aparece en la pestaña Notificaciones (push).';
	@override String get feedback_title => 'Feedback';
	@override String get feedback_description => 'Página de solicitud de funciones o votación';
	@override String get signup_title => 'Registro';
	@override String get signup_description => 'El usuario anónimo puede registrarse con correo o red social';
	@override String get assistant_title => 'Asistente IA';
	@override String get assistant_description => 'Chatear con el asistente de IA';
}

// Path: home.features_page
class _TranslationsHomeFeaturesPageEs extends TranslationsHomeFeaturesPageEn {
	_TranslationsHomeFeaturesPageEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Recursos del kit';
	@override String get assistant_title => 'Chatea con la IA';
	@override String get assistant_description => 'Chat listo para preguntas, ideas y ayuda dentro de la app';
	@override String get feedback_title => 'Vota y sugiere';
	@override String get feedback_description => 'Participa en el roadmap: vota ideas o envía la tuya';
	@override String get notification_title => 'Probar notificación';
	@override String get notification_description => 'Muestra una alerta solo en este dispositivo (no es push)';
	@override String get notification_demo_title => 'Alerta de prueba';
	@override String get notification_demo_body => 'Notificación local del demo del kit';
	@override String get send_push_title => 'Enviar notificación push';
	@override String get send_push_description => 'Envía un push a usuarios específicos o a todos';
	@override String get paywall_title => 'Planes y suscripción';
	@override String get paywall_description => 'Pantallas de paywall, prueba y flujo RevenueCat';
}

// Path: home.dashboard
class _TranslationsHomeDashboardEs extends TranslationsHomeDashboardEn {
	_TranslationsHomeDashboardEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get brand => 'kasy';
	@override String get components_title => 'Componentes';
	@override String get components_subtitle => 'Explora tokens de diseño y bloques de UI';
	@override String get features_title => 'Features';
	@override String get features_subtitle => 'IA, feedback, alertas y suscripción';
	@override String count_total({required Object count}) => '${count} en total';
	@override String get search_hint => 'Buscar componentes';
	@override String get search_empty => 'Ningún componente encontrado';
	@override String get in_production => 'En producción';
	@override String get needs_review => 'Revisar';
}

// Path: home.components_preview
class _TranslationsHomeComponentsPreviewEs extends TranslationsHomeComponentsPreviewEn {
	_TranslationsHomeComponentsPreviewEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get nav_title => 'Componentes';
	@override String get pro_badge => 'PRO';
}

// Path: auth.signin
class _TranslationsAuthSigninEs extends TranslationsAuthSigninEn {
	_TranslationsAuthSigninEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Bienvenido de nuevo';
	@override String get subtitle => 'Inicia sesión para continuar tu experiencia';
	@override String get email_hint => 'bruce@wayne.com';
	@override String get email_label => 'Correo electrónico';
	@override String get password_hint => 'Contraseña';
	@override String get password_label => 'Contraseña';
	@override String get forgot_password => 'Olvidé contraseña';
	@override String get submit => 'Continuar con correo';
	@override String get create_account => 'Crear mi cuenta';
	@override String get no_account => '¿No tienes una cuenta?';
	@override String get signup_link => 'Regístrate';
	@override String get continue_without => 'Continuar sin cuenta';
	@override String get or_sign_in_with => 'o';
	@override String get google => 'Gmail';
	@override String get apple => 'Apple';
	@override String get facebook => 'Facebook';
	@override String get error_title => 'Error';
	@override String get error_text => 'Correo, contraseña incorrectos o este correo no está registrado';
	@override String get email_invalid => 'Correo electrónico inválido';
	@override String get password_required => 'Debes ingresar una contraseña';
	@override String get password_too_short => 'Tu contraseña debe tener al menos 5 caracteres';
	@override String social_error({required Object provider}) => 'No se pudo iniciar sesión con ${provider}';
	@override String get email_already_registered => 'Este correo ya tiene una cuenta con otro método de inicio de sesión. Usa el método con el que te registraste.';
}

// Path: auth.signup
class _TranslationsAuthSignupEs extends TranslationsAuthSignupEn {
	_TranslationsAuthSignupEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Regístrate ahora';
	@override String get subtitle => 'Crea tu cuenta para empezar';
	@override String get submit => 'Crear mi cuenta';
	@override String get have_account => '¿Ya tienes una cuenta?';
	@override String get signin_link => 'Iniciar sesión';
	@override String get already_have_account => 'Ya tengo una cuenta';
	@override String get error_title => 'Error';
	@override String get error_text => 'Este correo ya existe o es inválido';
}

// Path: auth.recover
class _TranslationsAuthRecoverEs extends TranslationsAuthRecoverEn {
	_TranslationsAuthRecoverEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Recuperar contraseña';
	@override String get subtitle => 'Te enviaremos un enlace para restablecerla';
	@override String get email_label => 'Correo electrónico';
	@override String get submit => 'Recuperar contraseña';
	@override String get remember => '¿Recordaste tu contraseña?';
	@override String get signin_link => 'Iniciar sesión';
	@override String get error_title => 'Error';
	@override String get error_text => 'Ingresa un correo electrónico válido';
}

// Path: premium.solo
class _TranslationsPremiumSoloEs extends TranslationsPremiumSoloEn {
	_TranslationsPremiumSoloEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get back => 'Volver';
	@override String get headline_1 => 'Mejora para una';
	@override String get headline_2 => 'experiencia sin anuncios';
	@override String get feature_1 => 'Sin anuncios';
	@override String get feature_2 => 'Modo sin conexión';
	@override String get feature_3 => 'Saltos ilimitados';
	@override String get feature_4 => 'Audio en alta calidad';
	@override String get subscribe => 'Suscribirse ahora';
}

// Path: premium.comparePlan
class _TranslationsPremiumComparePlanEs extends TranslationsPremiumComparePlanEn {
	_TranslationsPremiumComparePlanEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get back => 'Volver';
	@override String get headline_1 => 'Elige tu plan';
	@override String get headline_2 => 'que mejor te encaje';
	@override String get headline_description => 'Compara Gratis y Premium y elige la facturación mensual o anual que mejor te encaje.';
	@override String get feature_1_title => 'Acceso premium completo';
	@override String get feature_1_subtitle => 'Todas las funciones en todos tus dispositivos';
	@override String get feature_2_title => 'Sin anuncios';
	@override String get feature_2_subtitle => 'Enfócate sin interrupciones';
	@override String get feature_3_title => 'Sync en la nube';
	@override String get feature_3_subtitle => 'Continúa donde lo dejaste';
	@override String get feature_4_title => 'Soporte prioritario';
	@override String get feature_4_subtitle => 'Ayuda cuando la necesites';
	@override String get continue_cta => 'Continuar';
	@override String best_offer_badge({required Object percent}) => 'Ahorra ${percent}%';
	@override String per_month_line({required Object price}) => '${price} facturado al año';
	@override String get billed_monthly => 'Facturación mensual';
	@override String billed_every({required Object period}) => 'Facturación por ${period}';
	@override String get flexible_plan => 'Facturación flexible';
	@override String get plan_three_month => '3 meses';
	@override String get plan_six_month => '6 meses';
	@override String get billing_note => 'Se renueva hasta cancelar. Gestiona en la tienda.';
	@override String get billing_note_web => 'Se renueva hasta cancelar. Gestiona en configuración.';
	@override String get benefits_heading => 'Incluido en el plan';
}

// Path: premium.trialPlan
class _TranslationsPremiumTrialPlanEs extends TranslationsPremiumTrialPlanEn {
	_TranslationsPremiumTrialPlanEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title_before => 'KASY ';
	@override String get title_accent => 'PRO';
	@override String get subtitle => 'Acceso a todas las funciones';
	@override String get social_proof => 'Únete a miles de usuarios de Kasy';
	@override String get feature_1 => 'Funciones premium ilimitadas';
	@override String get feature_2 => 'Exportación de alta calidad';
	@override String get feature_3 => 'Sin anuncios ni marca de agua';
	@override String get feature_4 => 'Sincroniza en todos tus dispositivos';
	@override String get trial_toggle_enabled => 'Prueba gratis activada';
	@override String get trial_toggle_disabled => 'Activar prueba gratis';
	@override String get cta_trial => 'Iniciar prueba gratis';
	@override String get cta_no_trial => 'Suscribirse ahora';
	@override String billing_trial({required Object days, required Object price}) => '${days} días gratis, luego ${price}/año';
	@override String billing_annual({required Object price}) => '${price}/año';
}

// Path: premium.unlockPlan
class _TranslationsPremiumUnlockPlanEs extends TranslationsPremiumUnlockPlanEn {
	_TranslationsPremiumUnlockPlanEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get headline_1 => 'DESBLOQUEA TODO';
	@override String get headline_2 => 'CON POCOS TOQUES';
	@override String get headline_desktop => 'Desbloquea todo en instantes';
	@override String get feature_1 => 'Crea más contenido';
	@override String get feature_2 => 'Resultados más rápidos';
	@override String get feature_3 => 'Menos tiempo de espera';
	@override String get feature_4 => 'Sync en la nube';
	@override String get feature_5 => 'Soporte prioritario';
	@override String get cta => 'Desbloquear ahora';
	@override String get cta_desktop => 'Desbloquear';
	@override String get billing_note => 'Renueva hasta cancelar. Gestiona en la tienda.';
	@override String get billing_note_web => 'Renueva hasta cancelar. Gestiona en configuración.';
	@override String plan_annual_price({required Object price}) => 'Solo ${price} / año';
	@override String plan_monthly_price({required Object price}) => '${price} / mes';
}

// Path: premium.comparison
class _TranslationsPremiumComparisonEs extends TranslationsPremiumComparisonEn {
	_TranslationsPremiumComparisonEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Comparación de planes Premium';
	@override String get features_label => 'Características';
	@override String get free_version => 'Gratis';
	@override String get premium_version => 'Premium';
	@override String get no_ads => 'Sin anuncios';
	@override String get premium_themes => 'Temas Premium';
	@override String get advanced_customization => 'Personalización avanzada';
	@override String get priority_support => 'Soporte prioritario';
	@override String get home_widget => 'Widgets en pantalla de inicio';
	@override String get talk_with_assistant => 'Asistente IA';
}

// Path: onboarding.feature_1
class _TranslationsOnboardingFeature1Es extends TranslationsOnboardingFeature1En {
	_TranslationsOnboardingFeature1Es._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Monetiza desde el día uno';
	@override String get description => 'Paywalls, suscripciones y prueba gratis listos para producción. Sin crear backend de cobros.';
	@override String get action => 'Continuar';
	@override String get skip => 'Omitir';
	@override String get login => '¿Ya tienes cuenta? Iniciar sesión';
}

// Path: onboarding.feature_2
class _TranslationsOnboardingFeature2Es extends TranslationsOnboardingFeature2En {
	_TranslationsOnboardingFeature2Es._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Inicio de sesión, ya resuelto';
	@override String get description => 'Correo, login social y recuperación de contraseña. Seguro y listo para publicar.';
	@override String get action => 'Continuar';
	@override String get back => 'Atrás';
}

// Path: onboarding.feature_3
class _TranslationsOnboardingFeature3Es extends TranslationsOnboardingFeature3En {
	_TranslationsOnboardingFeature3Es._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Tu asistente de IA integrado';
	@override String get description => 'Un asistente conversacional listo para usar, ya integrado.';
	@override String get action => 'Continuar';
}

// Path: onboarding.mockups
class _TranslationsOnboardingMockupsEs extends TranslationsOnboardingMockupsEn {
	_TranslationsOnboardingMockupsEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsOnboardingMockupsPaywallEs paywall = _TranslationsOnboardingMockupsPaywallEs._(_root);
	@override late final _TranslationsOnboardingMockupsEarningsEs earnings = _TranslationsOnboardingMockupsEarningsEs._(_root);
	@override late final _TranslationsOnboardingMockupsAuthEs auth = _TranslationsOnboardingMockupsAuthEs._(_root);
	@override late final _TranslationsOnboardingMockupsNotificationEs notification = _TranslationsOnboardingMockupsNotificationEs._(_root);
	@override late final _TranslationsOnboardingMockupsAiChatEs ai_chat = _TranslationsOnboardingMockupsAiChatEs._(_root);
}

// Path: onboarding.ageQuestion
class _TranslationsOnboardingAgeQuestionEs extends TranslationsOnboardingAgeQuestionEn {
	_TranslationsOnboardingAgeQuestionEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => '¿Cuántos años tienes?';
	@override String get description => 'Esto nos ayuda a personalizar tu experiencia.';
	@override Map<String, String> get options => {
		'age18_30': '18 a 30',
		'age31_40': '31 a 40',
		'age41_50': '41 a 50',
		'age51_60': 'Más de 50',
		'none': 'Prefiero no decirlo',
	};
	@override String get action => 'Continuar';
}

// Path: onboarding.genderQuestion
class _TranslationsOnboardingGenderQuestionEs extends TranslationsOnboardingGenderQuestionEn {
	_TranslationsOnboardingGenderQuestionEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => '¿Cómo te identificas?';
	@override String get description => 'Elige lo que mejor te represente. Puedes omitir si prefieres.';
	@override Map<String, String> get options => {
		'male': 'Masculino',
		'female': 'Femenino',
		'none': 'Prefiero no decirlo',
	};
	@override String get action => 'Continuar';
}

// Path: onboarding.notifications
class _TranslationsOnboardingNotificationsEs extends TranslationsOnboardingNotificationsEn {
	_TranslationsOnboardingNotificationsEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'No te pierdas nada';
	@override String get description => 'Solo te escribiremos cuando de verdad importe. Nada de spam.';
	@override String get continue_button => 'Activar notificaciones';
	@override String get skip_button => 'Ahora no';
	@override late final _TranslationsOnboardingNotificationsToastsEs toasts = _TranslationsOnboardingNotificationsToastsEs._(_root);
}

// Path: onboarding.att
class _TranslationsOnboardingAttEs extends TranslationsOnboardingAttEn {
	_TranslationsOnboardingAttEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Experiencia personalizada';
	@override String get description => 'El permiso ayuda a ajustar comunicaciones a tu perfil. No muestra anuncios dentro de la app.';
	@override String get continue_button => 'Continuar';
	@override String get skip_button => 'Ahora no';
	@override late final _TranslationsOnboardingAttCardEs card = _TranslationsOnboardingAttCardEs._(_root);
}

// Path: onboarding.loading
class _TranslationsOnboardingLoadingEs extends TranslationsOnboardingLoadingEn {
	_TranslationsOnboardingLoadingEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get welcome => 'Cuenta creada.';
	@override String get welcome_male => 'Cuenta creada. Bienvenido!';
	@override String get welcome_female => 'Cuenta creada. Bienvenida!';
	@override late final _TranslationsOnboardingLoadingStepsEs steps = _TranslationsOnboardingLoadingStepsEs._(_root);
}

// Path: feature_requests.vote_success
class _TranslationsFeatureRequestsVoteSuccessEs extends TranslationsFeatureRequestsVoteSuccessEn {
	_TranslationsFeatureRequestsVoteSuccessEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Voto registrado';
	@override String get description => 'Gracias por ayudarnos a priorizar';
}

// Path: feature_requests.vote_error
class _TranslationsFeatureRequestsVoteErrorEs extends TranslationsFeatureRequestsVoteErrorEn {
	_TranslationsFeatureRequestsVoteErrorEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Ya votado';
	@override String get description => 'Ya votaste por esta idea';
}

// Path: feature_requests.add_feature
class _TranslationsFeatureRequestsAddFeatureEs extends TranslationsFeatureRequestsAddFeatureEn {
	_TranslationsFeatureRequestsAddFeatureEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get chip_label => 'Agregar';
	@override String get title => 'Enviar una idea';
	@override String get description => 'Cuéntanos qué te gustaría ver en la app.';
	@override String get save_button => 'Enviar';
	@override String get cancel => 'Cancelar';
	@override String get title_label => 'Título';
	@override String get title_hint => 'Un título corto y descriptivo';
	@override String get description_label => 'Descripción';
	@override String get description_hint => 'Describe el recurso o la mejora en detalle...';
	@override String get error_title => 'Error';
	@override String get error_required => 'El título y la descripción son obligatorios';
	@override String get error_sending => 'Algo salió mal. Inténtalo de nuevo.';
	@override String get error_too_short => 'Descripción muy corta. Agrega más detalles';
	@override late final _TranslationsFeatureRequestsAddFeatureToastSuccessEs toast_success = _TranslationsFeatureRequestsAddFeatureToastSuccessEs._(_root);
}

// Path: settings.avatar
class _TranslationsSettingsAvatarEs extends TranslationsSettingsAvatarEn {
	_TranslationsSettingsAvatarEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Foto de perfil';
	@override String get take_photo => 'Tomar foto';
	@override String get choose_library => 'Biblioteca de fotos';
	@override String get remove_photo => 'Eliminar foto';
	@override String get cancel => 'Cancelar';
}

// Path: settings.delete_account
class _TranslationsSettingsDeleteAccountEs extends TranslationsSettingsDeleteAccountEn {
	_TranslationsSettingsDeleteAccountEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get button => 'Quiero eliminar mi cuenta';
	@override String get title => '¿Quieres eliminar tu cuenta?';
	@override String get content => 'Advertencia: esta acción es permanente y no se puede deshacer.';
	@override String get content_subscriber => 'Advertencia: esta acción es permanente. Perderás tu suscripción activa, y crear una cuenta nueva más tarde (incluso con el mismo correo) no la recuperará.';
	@override String get cancel => 'Cancelar';
	@override String get confirm => 'Sí, eliminar';
	@override String get error => 'Algo salió mal. Por favor, inténtalo de nuevo.';
}

// Path: settings.admin
class _TranslationsSettingsAdminEs extends TranslationsSettingsAdminEn {
	_TranslationsSettingsAdminEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get update_bottom_sheet => 'Previsualizar novedades';
	@override String get preview_update_available => 'Previsualizar actualización disponible';
	@override String get paywalls => 'Paywalls';
	@override String get test_onboarding => 'Probar onboarding';
	@override String get copy_user_id => 'Copiar ID de usuario';
	@override String get user_id_copied => 'ID de usuario copiado al portapapeles';
	@override String get copy_fcm_token => 'Copiar FCM Token';
	@override String get fcm_token_copied => 'FCM Token copiado al portapapeles';
	@override String get fcm_token_unavailable => 'Token no disponible (¿notificaciones desactivadas?)';
	@override String get ask_notification => 'Pedir permiso de notificación';
	@override String get native_only => 'Disponible solo en la app nativa (iOS / Android)';
	@override String get ask_review => 'Pedir evaluación';
	@override String get home_widgets_panel => 'Panel de Home Widgets';
	@override String get home_widgets_title => 'Panel de Home Widgets';
	@override String get ads_demo_panel => 'Demo de anuncios';
	@override String get ads_demo_title => 'Demo de anuncios';
	@override String get ads_demo_subtitle => 'Los cuatro formatos de AdMob con anuncios de prueba de Google. Prueba cada uno y colócalo donde quieras en tu app.';
	@override String get ads_banner_label => 'Banner';
	@override String get ads_interstitial_title => 'Intersticial';
	@override String get ads_interstitial_desc => 'Anuncio a pantalla completa. Toca para mostrar.';
	@override String get ads_rewarded_title => 'Recompensado';
	@override String get ads_rewarded_desc => 'El usuario mira para ganar una recompensa. Toca para mostrar.';
	@override String get ads_rewarded_interstitial_title => 'Recompensado intersticial';
	@override String get ads_rewarded_interstitial_desc => 'Anuncio a pantalla completa que también da recompensa. Toca para mostrar.';
	@override String ads_reward_earned({required Object amount, required Object type}) => 'Recompensa ganada: ${amount} ${type}';
	@override String get ads_load_failed => 'No se pudo cargar el anuncio (sin relleno). Inténtalo de nuevo en un momento.';
	@override String get ads_code_copied => 'Código copiado al portapapeles';
	@override String get ads_status_safe => 'Esta demo siempre muestra anuncios de prueba de Google, así que es seguro tocar, incluso en producción.';
	@override String get ads_status_test => 'Tus ad ids reales aún no están configurados. Configúralos para publicar:';
	@override String get ads_status_real => 'Ad ids reales configurados para esta plataforma.';
	@override String get inspector_fab_title => 'Inspector de widgets';
	@override String get inspector_fab_subtitle_prefix => 'Atajo global:';
	@override String get update_mywidget_title => 'Actualizar Widget MyWidget';
	@override String get update_mywidget_desc => 'Llamar a la actualización manual para el widget MyWidget';
	@override String get paywalls_title => 'Panel de Admin de Paywalls';
	@override String get send_push_title => 'Enviar notificación';
	@override String get send_push_to_all => 'Enviar a todos';
	@override String get send_push_email_hint => 'Agregar e-mail';
	@override String get send_push_title_label => 'Título';
	@override String get send_push_title_hint => 'Ej: Nueva actualización disponible';
	@override String get send_push_body_label => 'Mensaje';
	@override String get send_push_body_hint => 'Hasta 3 líneas en la lista de la app (máx. 140 caracteres)';
	@override String get send_push_image_label => 'URL de imagen (opcional)';
	@override String get send_push_image_hint => 'https://...';
	@override String get send_push_email_label => 'Correos destinatarios';
	@override String get send_push_success => '¡Notificación enviada!';
	@override String send_push_user_not_found({required Object email}) => 'Usuario no encontrado: ${email}';
	@override String get send_push_send_button => 'Enviar';
	@override String get send_push_required => 'El título y el mensaje son obligatorios';
	@override String get send_push_no_emails => 'Agrega al menos un correo';
	@override String get send_push_route_label => 'Página al abrir';
	@override String get send_push_route_description => 'Pantalla que se abre cuando el usuario toca la notificación.';
	@override String get send_push_route_notifications => 'Notificaciones';
	@override String get send_push_route_home => 'Inicio';
	@override String get send_push_route_settings => 'Configuración';
	@override String get send_push_route_premium => 'Premium';
	@override String get send_push_route_reminder => 'Recordatorios';
	@override String get send_push_route_feedback => 'Comentarios';
	@override String get send_push_preview_label => 'Vista previa';
	@override String get send_push_preview_now => 'ahora';
	@override String get send_push_preview_title_placeholder => 'Título de la notificación';
	@override String get send_push_preview_body_placeholder => 'El cuerpo del mensaje aparece aquí';
	@override String get device_preview_title => 'Device Preview (solo web)';
	@override String get send_push_section_recipients => 'Destinatarios';
	@override String get send_push_section_content => 'Contenido';
	@override String get send_push_section_advanced => 'Avanzado';
	@override String get send_push_audience_all => 'Todos';
	@override String get send_push_audience_specific => 'Específicos';
	@override String get send_push_audience_all_hint => 'La notificación se enviará a todos los usuarios suscritos.';
}

// Path: onboarding.mockups.paywall
class _TranslationsOnboardingMockupsPaywallEs extends TranslationsOnboardingMockupsPaywallEn {
	_TranslationsOnboardingMockupsPaywallEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Premium';
	@override String get annual => 'Anual';
	@override String get monthly => 'Mensual';
	@override String get save_badge => '-40%';
	@override String get price_year => '\$39,99 / año';
	@override String get price_month => '\$4,99 / mes';
	@override String get cta => 'Iniciar prueba gratis';
}

// Path: onboarding.mockups.earnings
class _TranslationsOnboardingMockupsEarningsEs extends TranslationsOnboardingMockupsEarningsEn {
	_TranslationsOnboardingMockupsEarningsEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get notify_title => 'Nuevo suscriptor Pro';
	@override String get notify_subtitle => 'Plan anual · +\$49.90';
	@override String get notify_time => '1:40 PM';
	@override String get processing => 'Procesando pago…';
	@override String get summary_label => 'Ganancias';
	@override String get summary_body => 'Ganaste \$312.40 esta semana de 14 nuevas suscripciones.';
}

// Path: onboarding.mockups.auth
class _TranslationsOnboardingMockupsAuthEs extends TranslationsOnboardingMockupsAuthEn {
	_TranslationsOnboardingMockupsAuthEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get welcome => 'Bienvenido de vuelta';
	@override String get email_hint => 'tu@email.com';
	@override String get sign_in => 'Iniciar sesión';
	@override String get divider => 'o';
}

// Path: onboarding.mockups.notification
class _TranslationsOnboardingMockupsNotificationEs extends TranslationsOnboardingMockupsNotificationEn {
	_TranslationsOnboardingMockupsNotificationEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Nuevo mensaje';
	@override String get time => 'ahora';
}

// Path: onboarding.mockups.ai_chat
class _TranslationsOnboardingMockupsAiChatEs extends TranslationsOnboardingMockupsAiChatEn {
	_TranslationsOnboardingMockupsAiChatEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get u1 => '¿Qué puedes hacer?';
	@override String get a1 => 'Escribo, resumo y respondo cualquier cosa en segundos.';
	@override String get u2 => 'Resume mis notas';
	@override String get a2 => 'Listo. Aquí tienes los 3 puntos clave de hoy.';
}

// Path: onboarding.notifications.toasts
class _TranslationsOnboardingNotificationsToastsEs extends TranslationsOnboardingNotificationsToastsEn {
	_TranslationsOnboardingNotificationsToastsEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get push_app_name => 'Kasy';
	@override String get push_headline => 'Tu resumen semanal está listo';
	@override String get push_body => 'Toca para abrir.';
	@override String get push_sent_at => 'ahora';
	@override String get subscriber_title => 'Nuevo suscriptor Pro';
	@override String get subscriber_message => 'Plan anual · +\$49,90';
	@override String get streak_title => '¡Racha de 7 días!';
	@override String get streak_message => 'Volviste a cumplir tu meta diaria.';
	@override String get message_title => 'Nueva respuesta';
	@override String get message_message => 'Alguien respondió en tu conversación.';
	@override String get reminder_title => 'Empieza pronto';
	@override String get reminder_message => 'Tu sesión comienza en 10 minutos.';
	@override String get payment_title => 'Pago recibido';
	@override String get payment_message => '+\$12,50 acreditados en tu saldo.';
	@override String get offer_title => 'Oferta limitada';
	@override String get offer_message => '50% en el plan anual — termina hoy.';
	@override String get social_title => 'Nueva interacción';
	@override String get social_message => '3 personas dieron like a tu publicación.';
}

// Path: onboarding.att.card
class _TranslationsOnboardingAttCardEs extends TranslationsOnboardingAttCardEn {
	_TranslationsOnboardingAttCardEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get tag => 'Privacidad';
}

// Path: onboarding.loading.steps
class _TranslationsOnboardingLoadingStepsEs extends TranslationsOnboardingLoadingStepsEn {
	_TranslationsOnboardingLoadingStepsEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get account => 'Creando tu cuenta';
	@override String get preferences => 'Guardando tus preferencias';
	@override String get ready => 'Personalizando tu experiencia';
}

// Path: feature_requests.add_feature.toast_success
class _TranslationsFeatureRequestsAddFeatureToastSuccessEs extends TranslationsFeatureRequestsAddFeatureToastSuccessEn {
	_TranslationsFeatureRequestsAddFeatureToastSuccessEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Idea enviada';
	@override String get description => 'La revisaremos y te daremos una respuesta';
}

/// The flat map containing all translations for locale <es>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsEs {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'common.close' => 'Cerrar',
			'common.copied' => 'Copiado',
			'common.saved' => 'Guardado',
			'common.error' => 'Error',
			'common.unavailable' => 'No disponible',
			'common.native_only_title' => 'Solo en la app nativa',
			'admin_console.tabs.overview' => 'Resumen',
			'admin_console.tabs.users' => 'Usuarios',
			'admin_console.tabs.requests' => 'Solicitudes',
			'admin_console.tabs.categories' => 'Categorías',
			'admin_console.tabs.tools' => 'Herramientas',
			'admin_console.tabs.debug' => 'Depuración',
			'admin_console.back_to_app' => 'Volver a la app',
			'admin_console.overview.section' => 'Proyecto',
			'admin_console.overview.summary' => 'Resumen',
			'admin_console.overview.backend' => 'Backend',
			'admin_console.overview.account' => 'Cuenta',
			'admin_console.overview.guest' => 'Invitado',
			'admin_console.overview.user_id' => 'ID de usuario',
			'admin_console.overview.build' => 'Versión',
			'admin_console.overview.session_title' => 'Sesión actual',
			'admin_console.overview.requests_metric' => 'Solicitudes de función',
			'admin_console.overview.total_users' => 'Usuarios totales',
			'admin_console.overview.subscribers' => 'Suscriptores',
			'admin_console.overview.new_7d' => 'Nuevos (7 días)',
			'admin_console.overview.signups_title' => 'Nuevos registros',
			'admin_console.overview.signups_subtitle' => 'Últimos 14 días',
			'admin_console.overview.signups_total' => ({required Object count}) => '${count} en 14 días',
			'admin_console.overview.signups_empty' => 'Sin registros en este período.',
			'admin_console.overview.plan_split_title' => 'Distribución de planes',
			'admin_console.overview.free' => 'Gratis',
			'admin_console.overview.subscriber' => 'Suscriptor',
			'admin_console.overview.conversion' => ({required Object percent}) => '${percent} suscriben',
			'admin_console.overview.loaded_note' => ({required Object count}) => 'Según los ${count} usuarios más recientes.',
			'admin_console.overview.users_hint' => 'Abre la pestaña Usuarios para gestionar todas las cuentas.',
			'admin_console.overview.debug_note' => 'Consola de depuración — visible solo en builds de desarrollo.',
			'admin_console.users.title' => 'Usuarios',
			'admin_console.users.search_hint' => 'Buscar por nombre o correo',
			'admin_console.users.col_user' => 'Usuario',
			'admin_console.users.col_status' => 'Estado',
			'admin_console.users.col_plan' => 'Plan',
			'admin_console.users.col_role' => 'Rol',
			'admin_console.users.col_action' => 'Acciones',
			'admin_console.users.col_joined' => 'Registro',
			'admin_console.users.status_active' => 'Activo',
			'admin_console.users.status_inactive' => 'Inactivo',
			'admin_console.users.status_blocked' => 'Bloqueado',
			'admin_console.users.role_admin' => 'Admin',
			'admin_console.users.role_user' => 'Usuario',
			'admin_console.users.action_make_admin' => 'Hacer Administrador',
			'admin_console.users.action_remove_admin' => 'Quitar Admin',
			'admin_console.users.action_block' => 'Bloquear Acceso',
			'admin_console.users.action_unblock' => 'Desbloquear',
			'admin_console.users.plan_subscriber' => 'Suscriptor',
			'admin_console.users.plan_free' => 'Gratis',
			'admin_console.users.empty' => 'No se encontraron usuarios',
			'admin_console.users.empty_hint' => 'Cuando alguien cree una cuenta, aparecerá aquí.',
			'admin_console.users.error' => 'No se pudieron cargar los usuarios. Asegúrate de ser admin.',
			'admin_console.users.page' => ({required Object page, required Object total}) => 'Página ${page} de ${total}',
			'admin_console.users.prev' => 'Anterior',
			'admin_console.users.next' => 'Siguiente',
			'admin_console.users.anonymous' => 'Anónimo',
			'admin_console.users.filter_all' => 'Todos los usuarios',
			'admin_console.users.filter_subscribers' => 'Suscriptores',
			'admin_console.users.loading' => 'Cargando usuarios…',
			'admin_console.users.results' => ({required Object from, required Object to, required Object total}) => 'Mostrando ${from} a ${to} de ${total}',
			'admin_console.users.truncated' => ({required Object count}) => 'Mostrando los ${count} más recientes. La búsqueda cubre solo los cargados.',
			'admin_console.users.search_capped' => 'La búsqueda escaneó un conjunto limitado. Pueden faltar coincidencias.',
			'admin_console.users.empty_search' => 'Ningún usuario coincide con la búsqueda',
			'admin_console.users.empty_search_hint' => 'Prueba con otro nombre o correo.',
			'admin_console.users.empty_subscribers' => 'No se encontraron suscriptores',
			'admin_console.users.empty_subscribers_hint' => 'Quien tenga el plan premium aparece en este filtro.',
			'admin_console.users.refresh' => 'Actualizar',
			'admin_console.users.retry' => 'Reintentar',
			'admin_console.requests.title' => 'Solicitudes de función',
			'admin_console.requests.subtitle' => 'Solicitudes y sugerencias enviadas por tus usuarios. Márcalas como visibles para mostrarlas en la app, u ocúltalas si no corresponden.',
			'admin_console.requests.empty' => 'Aún no hay solicitudes',
			'admin_console.requests.empty_hint' => 'Cuando un usuario envíe una idea, aparecerá aquí.',
			'admin_console.requests.votes' => ({required Object count}) => '${count} votos',
			'admin_console.requests.visible' => 'Visible',
			'admin_console.requests.hidden' => 'Oculto',
			'admin_console.requests.edit' => 'Editar',
			'admin_console.requests.error' => 'No se pudieron cargar las solicitudes',
			'admin_console.requests.saved' => 'Solicitud actualizada',
			'admin_console.requests.editor_title' => 'Editar solicitud',
			'admin_console.requests.field_title' => 'Título',
			'admin_console.requests.field_description' => 'Descripción',
			'admin_console.requests.lang_en' => 'Inglés',
			'admin_console.requests.lang_pt' => 'Portugués',
			'admin_console.requests.lang_es' => 'Español',
			'admin_console.requests.visibility' => 'Visible para los usuarios',
			'admin_console.requests.save' => 'Guardar',
			'admin_console.requests.cancel' => 'Cancelar',
			'admin_console.categories.title' => 'Categorías',
			'admin_console.categories.subtitle' => 'Administre las categorías oficiales de la biblioteca. Los PDF vinculados a una categoría eliminada no se borrarán.',
			'admin_console.categories.add' => 'Nueva Categoría',
			'admin_console.categories.edit' => 'Editar',
			'admin_console.categories.delete' => 'Eliminar',
			'admin_console.categories.delete_confirm' => '¿Está seguro de que desea eliminar esta categoría?',
			'admin_console.categories.save' => 'Guardar',
			'admin_console.categories.cancel' => 'Cancelar',
			'admin_console.categories.name' => 'Nombre',
			'admin_console.categories.description' => 'Descripción',
			'admin_console.categories.icon' => 'Icono',
			'admin_console.categories.color' => 'Color',
			'admin_console.categories.empty' => 'No hay categorías.',
			'admin_console.categories.success_saved' => '¡Categoría guardada con éxito!',
			'admin_console.categories.success_deleted' => '¡Categoría eliminada!',
			'admin_console.categories.error_empty_fields' => 'Por favor, complete todos los campos requeridos.',
			'admin_console.groups.actions' => 'Acciones',
			'admin_console.groups.features' => 'Funciones',
			'admin_console.groups.preview' => 'Vista previa',
			'admin_console.groups.debug_actions' => 'Acciones de debug',
			'admin_console.groups.identity' => 'Identidad',
			'admin_console.groups.notification_test' => 'Prueba de notificación',
			'admin_console.paywalls.subtitle' => 'Toca un paywall para previsualizarlo. Copia su código para decirle al asistente cuál usar.',
			'admin_console.paywalls.copy_code' => 'Copiar código',
			'admin_console.paywalls.code_copied' => 'Código copiado al portapapeles',
			'admin_console.paywalls.solo_title' => 'Solo',
			'admin_console.paywalls.solo_desc' => 'Un solo plan con beneficios y un CTA. Ideal para apps de un tier.',
			'admin_console.paywalls.compare_title' => 'Compare',
			'admin_console.paywalls.compare_desc' => 'Mensual vs anual lado a lado, con tabla free vs premium.',
			'admin_console.paywalls.trial_title' => 'Trial',
			'admin_console.paywalls.trial_desc' => 'Toggle de prueba gratis, normalmente en el anual. Mensual cobra al instante.',
			'admin_console.paywalls.unlock_title' => 'Unlock',
			'admin_console.paywalls.unlock_desc' => 'Paywall de conversión para onboarding o bloqueo fuerte.',
			'admin_console.settings_entry.title' => 'Admin',
			'admin_console.settings_entry.caption' => 'Visible solo para administradores y en modo de desarrollo.',
			'admin_console.requires_admin' => 'Necesitas ser admin para ver esto. Define role: admin en el registro de tu usuario en el backend. La app no puede cambiar este campo; la validación está en el servidor.',
			'home.title' => 'Ejemplo Kasy',
			'home.welcome' => 'Bienvenido al demo de Kasy',
			'home.cards.paywall_title' => 'Paywall',
			'home.cards.paywall_description' => 'Ver la página de suscripción',
			'home.cards.notification_title' => 'Prueba de notificación local',
			'home.cards.notification_description' => 'Muestra una alerta solo en este dispositivo. No aparece en la pestaña Notificaciones (push).',
			'home.cards.feedback_title' => 'Feedback',
			'home.cards.feedback_description' => 'Página de solicitud de funciones o votación',
			'home.cards.signup_title' => 'Registro',
			'home.cards.signup_description' => 'El usuario anónimo puede registrarse con correo o red social',
			'home.cards.assistant_title' => 'Asistente IA',
			'home.cards.assistant_description' => 'Chatear con el asistente de IA',
			'home.features_page.title' => 'Recursos del kit',
			'home.features_page.assistant_title' => 'Chatea con la IA',
			'home.features_page.assistant_description' => 'Chat listo para preguntas, ideas y ayuda dentro de la app',
			'home.features_page.feedback_title' => 'Vota y sugiere',
			'home.features_page.feedback_description' => 'Participa en el roadmap: vota ideas o envía la tuya',
			'home.features_page.notification_title' => 'Probar notificación',
			'home.features_page.notification_description' => 'Muestra una alerta solo en este dispositivo (no es push)',
			'home.features_page.notification_demo_title' => 'Alerta de prueba',
			'home.features_page.notification_demo_body' => 'Notificación local del demo del kit',
			'home.features_page.send_push_title' => 'Enviar notificación push',
			'home.features_page.send_push_description' => 'Envía un push a usuarios específicos o a todos',
			'home.features_page.paywall_title' => 'Planes y suscripción',
			'home.features_page.paywall_description' => 'Pantallas de paywall, prueba y flujo RevenueCat',
			'home.dashboard.brand' => 'kasy',
			'home.dashboard.components_title' => 'Componentes',
			'home.dashboard.components_subtitle' => 'Explora tokens de diseño y bloques de UI',
			'home.dashboard.features_title' => 'Features',
			'home.dashboard.features_subtitle' => 'IA, feedback, alertas y suscripción',
			'home.dashboard.count_total' => ({required Object count}) => '${count} en total',
			'home.dashboard.search_hint' => 'Buscar componentes',
			'home.dashboard.search_empty' => 'Ningún componente encontrado',
			'home.dashboard.in_production' => 'En producción',
			'home.dashboard.needs_review' => 'Revisar',
			'home.components_preview.nav_title' => 'Componentes',
			'home.components_preview.pro_badge' => 'PRO',
			'auth.signin.title' => 'Bienvenido de nuevo',
			'auth.signin.subtitle' => 'Inicia sesión para continuar tu experiencia',
			'auth.signin.email_hint' => 'bruce@wayne.com',
			'auth.signin.email_label' => 'Correo electrónico',
			'auth.signin.password_hint' => 'Contraseña',
			'auth.signin.password_label' => 'Contraseña',
			'auth.signin.forgot_password' => 'Olvidé contraseña',
			'auth.signin.submit' => 'Continuar con correo',
			'auth.signin.create_account' => 'Crear mi cuenta',
			'auth.signin.no_account' => '¿No tienes una cuenta?',
			'auth.signin.signup_link' => 'Regístrate',
			'auth.signin.continue_without' => 'Continuar sin cuenta',
			'auth.signin.or_sign_in_with' => 'o',
			'auth.signin.google' => 'Gmail',
			'auth.signin.apple' => 'Apple',
			'auth.signin.facebook' => 'Facebook',
			'auth.signin.error_title' => 'Error',
			'auth.signin.error_text' => 'Correo, contraseña incorrectos o este correo no está registrado',
			'auth.signin.email_invalid' => 'Correo electrónico inválido',
			'auth.signin.password_required' => 'Debes ingresar una contraseña',
			'auth.signin.password_too_short' => 'Tu contraseña debe tener al menos 5 caracteres',
			'auth.signin.social_error' => ({required Object provider}) => 'No se pudo iniciar sesión con ${provider}',
			'auth.signin.email_already_registered' => 'Este correo ya tiene una cuenta con otro método de inicio de sesión. Usa el método con el que te registraste.',
			'auth.signup.title' => 'Regístrate ahora',
			'auth.signup.subtitle' => 'Crea tu cuenta para empezar',
			'auth.signup.submit' => 'Crear mi cuenta',
			'auth.signup.have_account' => '¿Ya tienes una cuenta?',
			'auth.signup.signin_link' => 'Iniciar sesión',
			'auth.signup.already_have_account' => 'Ya tengo una cuenta',
			'auth.signup.error_title' => 'Error',
			'auth.signup.error_text' => 'Este correo ya existe o es inválido',
			'auth.recover.title' => 'Recuperar contraseña',
			'auth.recover.subtitle' => 'Te enviaremos un enlace para restablecerla',
			'auth.recover.email_label' => 'Correo electrónico',
			'auth.recover.submit' => 'Recuperar contraseña',
			'auth.recover.remember' => '¿Recordaste tu contraseña?',
			'auth.recover.signin_link' => 'Iniciar sesión',
			'auth.recover.error_title' => 'Error',
			'auth.recover.error_text' => 'Ingresa un correo electrónico válido',
			'rate_popup.title' => '¿Tienes 15 segundos para calificarnos?',
			'rate_popup.description' => '¡Es rápido y muy útil! ¡Muchas gracias!',
			'rate_popup.cancel_button' => 'Quizás más tarde',
			'rate_popup.rate_button' => '¡Sí, con gusto!',
			'premium.title_1' => 'Desbloquea el acceso completo',
			'premium.description' => 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
			'premium.feature_1' => 'Característica 1 lorem ipsum',
			'premium.feature_2' => 'Característica 2 mop issum',
			'premium.feature_3' => 'Característica 3 lorem',
			'premium.duration_weekly' => 'Semana',
			'premium.duration_annual' => 'Año',
			'premium.duration_monthly' => 'Mes',
			'premium.duration_monthly_description' => 'Cancela cuando quieras',
			'premium.duration_lifetime' => 'De por vida',
			'premium.duration_lifetime_description' => 'Pago único',
			'premium.restore_action' => 'Restaurar',
			'premium.preview_disabled_title' => 'Vista previa',
			'premium.preview_disabled_text' => 'Esta es una vista previa de administrador. Las acciones de compra están desactivadas.',
			'premium.coupon_title' => '¿Tienes un cupón?',
			'premium.payment_cancel_reassurance' => 'Cancelación fácil con 1 clic, siempre',
			'premium.payment_cancel_reassurance_free_trial' => 'Sin pago ahora, cancela cuando quieras',
			'premium.payment_action' => 'Iniciar prueba gratuita',
			'premium.payment_action_trial' => ({required Object money}) => '7 días gratis, luego ${money}',
			'premium.try_free_btn_action' => ({required Object days}) => 'Prueba gratis por ${days} días',
			'premium.duration_recuring_label_annual' => 'Anual',
			'premium.duration_recuring_label_monthly' => 'Mensual',
			'premium.duration_recuring_label_weekly' => 'Semanal',
			'premium.price_per_week' => '/semana',
			'premium.price_per_month' => '/mes',
			'premium.price_per_three_month' => '/3 meses',
			'premium.price_per_six_month' => '/6 meses',
			'premium.price_per_year' => '/año',
			'premium.price_one_time' => '',
			'premium.action_button' => 'Continuar',
			'premium.terms' => 'Términos',
			'premium.privacy' => 'Privacidad',
			'premium.terms_of_use' => 'Términos de uso',
			'premium.privacy_policy' => 'Política de privacidad',
			'premium.error_loading' => 'Error al cargar las ofertas',
			'premium.no_products_title' => 'Las opciones de suscripción aún no están disponibles',
			'premium.no_products_description' => 'Inténtalo de nuevo en unos instantes. Si sigue ocurriendo, es posible que los productos de la tienda aún estén terminando la configuración.',
			'premium.restore_success_title' => 'Suscripción restaurada',
			'premium.restore_success_text' => 'Gracias por tu confianza',
			'premium.purchase_success_title' => 'Suscripción realizada con éxito',
			'premium.purchase_success_text' => 'Gracias por tu confianza',
			'premium.error_title' => 'Error',
			'premium.error_text' => 'Ocurrió un error. Inténtalo de nuevo',
			'premium.web_checkout_timeout_title' => 'Pago no confirmado',
			'premium.web_checkout_timeout_text' => 'No recibimos confirmación del pago. Si ya pagaste, toca Restaurar.',
			'premium.restore_none_title' => 'No se encontró ninguna suscripción',
			'premium.restore_none_text' => 'No encontramos una suscripción activa para restaurar.',
			'premium.solo.back' => 'Volver',
			'premium.solo.headline_1' => 'Mejora para una',
			'premium.solo.headline_2' => 'experiencia sin anuncios',
			'premium.solo.feature_1' => 'Sin anuncios',
			'premium.solo.feature_2' => 'Modo sin conexión',
			'premium.solo.feature_3' => 'Saltos ilimitados',
			'premium.solo.feature_4' => 'Audio en alta calidad',
			'premium.solo.subscribe' => 'Suscribirse ahora',
			'premium.comparePlan.back' => 'Volver',
			'premium.comparePlan.headline_1' => 'Elige tu plan',
			'premium.comparePlan.headline_2' => 'que mejor te encaje',
			'premium.comparePlan.headline_description' => 'Compara Gratis y Premium y elige la facturación mensual o anual que mejor te encaje.',
			'premium.comparePlan.feature_1_title' => 'Acceso premium completo',
			'premium.comparePlan.feature_1_subtitle' => 'Todas las funciones en todos tus dispositivos',
			'premium.comparePlan.feature_2_title' => 'Sin anuncios',
			'premium.comparePlan.feature_2_subtitle' => 'Enfócate sin interrupciones',
			'premium.comparePlan.feature_3_title' => 'Sync en la nube',
			'premium.comparePlan.feature_3_subtitle' => 'Continúa donde lo dejaste',
			'premium.comparePlan.feature_4_title' => 'Soporte prioritario',
			'premium.comparePlan.feature_4_subtitle' => 'Ayuda cuando la necesites',
			'premium.comparePlan.continue_cta' => 'Continuar',
			'premium.comparePlan.best_offer_badge' => ({required Object percent}) => 'Ahorra ${percent}%',
			'premium.comparePlan.per_month_line' => ({required Object price}) => '${price} facturado al año',
			'premium.comparePlan.billed_monthly' => 'Facturación mensual',
			'premium.comparePlan.billed_every' => ({required Object period}) => 'Facturación por ${period}',
			'premium.comparePlan.flexible_plan' => 'Facturación flexible',
			'premium.comparePlan.plan_three_month' => '3 meses',
			'premium.comparePlan.plan_six_month' => '6 meses',
			'premium.comparePlan.billing_note' => 'Se renueva hasta cancelar. Gestiona en la tienda.',
			'premium.comparePlan.billing_note_web' => 'Se renueva hasta cancelar. Gestiona en configuración.',
			'premium.comparePlan.benefits_heading' => 'Incluido en el plan',
			'premium.trialPlan.title_before' => 'KASY ',
			'premium.trialPlan.title_accent' => 'PRO',
			'premium.trialPlan.subtitle' => 'Acceso a todas las funciones',
			'premium.trialPlan.social_proof' => 'Únete a miles de usuarios de Kasy',
			'premium.trialPlan.feature_1' => 'Funciones premium ilimitadas',
			'premium.trialPlan.feature_2' => 'Exportación de alta calidad',
			'premium.trialPlan.feature_3' => 'Sin anuncios ni marca de agua',
			'premium.trialPlan.feature_4' => 'Sincroniza en todos tus dispositivos',
			'premium.trialPlan.trial_toggle_enabled' => 'Prueba gratis activada',
			'premium.trialPlan.trial_toggle_disabled' => 'Activar prueba gratis',
			'premium.trialPlan.cta_trial' => 'Iniciar prueba gratis',
			'premium.trialPlan.cta_no_trial' => 'Suscribirse ahora',
			'premium.trialPlan.billing_trial' => ({required Object days, required Object price}) => '${days} días gratis, luego ${price}/año',
			'premium.trialPlan.billing_annual' => ({required Object price}) => '${price}/año',
			'premium.unlockPlan.headline_1' => 'DESBLOQUEA TODO',
			'premium.unlockPlan.headline_2' => 'CON POCOS TOQUES',
			'premium.unlockPlan.headline_desktop' => 'Desbloquea todo en instantes',
			'premium.unlockPlan.feature_1' => 'Crea más contenido',
			'premium.unlockPlan.feature_2' => 'Resultados más rápidos',
			'premium.unlockPlan.feature_3' => 'Menos tiempo de espera',
			'premium.unlockPlan.feature_4' => 'Sync en la nube',
			'premium.unlockPlan.feature_5' => 'Soporte prioritario',
			'premium.unlockPlan.cta' => 'Desbloquear ahora',
			'premium.unlockPlan.cta_desktop' => 'Desbloquear',
			'premium.unlockPlan.billing_note' => 'Renueva hasta cancelar. Gestiona en la tienda.',
			'premium.unlockPlan.billing_note_web' => 'Renueva hasta cancelar. Gestiona en configuración.',
			'premium.unlockPlan.plan_annual_price' => ({required Object price}) => 'Solo ${price} / año',
			'premium.unlockPlan.plan_monthly_price' => ({required Object price}) => '${price} / mes',
			'premium.comparison.title' => 'Comparación de planes Premium',
			'premium.comparison.features_label' => 'Características',
			'premium.comparison.free_version' => 'Gratis',
			'premium.comparison.premium_version' => 'Premium',
			'premium.comparison.no_ads' => 'Sin anuncios',
			'premium.comparison.premium_themes' => 'Temas Premium',
			'premium.comparison.advanced_customization' => 'Personalización avanzada',
			'premium.comparison.priority_support' => 'Soporte prioritario',
			'premium.comparison.home_widget' => 'Widgets en pantalla de inicio',
			'premium.comparison.talk_with_assistant' => 'Asistente IA',
			'activePremium.title' => 'Eres un usuario premium',
			'activePremium.description' => 'Disfruta todas las funciones',
			'activePremium.unsubscribe_button' => 'Cancelar suscripción',
			'activePremium.early_bird_description' => 'Usaste un cupón que te dio acceso gratuito a las funciones premium sin suscripción. ¡Disfrútalo!',
			'activePremium.unsubscribe_feedback_title' => 'Ayúdanos a mejorar',
			'activePremium.unsubscribe_feedback_description' => 'Lamentamos verte partir. ¿Podrías decirnos brevemente por qué te estás dando de baja?',
			'activePremium.unsubscribe_feedback_hint' => 'Cuéntanos tu motivo...',
			'activePremium.unsubscribe_feedback_min_chars' => 'Se requieren mínimo 6 caracteres',
			'activePremium.unsubscribe_confirm_button' => 'Continuar',
			'activePremium.lifetime_user_description' => 'Eres un usuario de por vida',
			'activePremium.managed_elsewhere_title' => 'Suscripción en otra plataforma',
			'activePremium.managed_elsewhere_description' => 'Esta suscripción se realizó en otra plataforma y no se puede gestionar ni cancelar aquí. Inicia sesión en tu cuenta en la plataforma donde la compraste.',
			'activePremium.restore_button' => 'Restaurar compras',
			'activePremium.cancel_button' => 'Cerrar',
			'activePremium.billing_title' => 'Facturación',
			'activePremium.plan_label' => 'Plan de cuenta',
			'activePremium.plan_fallback' => 'Premium',
			'activePremium.manage_subscription' => 'Administrar suscripción',
			'activePremium.restore_purchases' => 'Restaurar compras',
			'activePremium.renews_on' => ({required Object date}) => 'Renueva el ${date}',
			'activePremium.expires_on' => ({required Object date}) => 'Expira el ${date}',
			'activePremium.trial_label' => 'Evaluación gratuita',
			'activePremium.trial_until' => ({required Object date}) => 'Evaluación gratuita hasta el ${date}',
			'activePremium.charges_from' => ({required Object price, required Object date}) => '${price} a partir del ${date}',
			'onboarding.feature_1.title' => 'Monetiza desde el día uno',
			'onboarding.feature_1.description' => 'Paywalls, suscripciones y prueba gratis listos para producción. Sin crear backend de cobros.',
			'onboarding.feature_1.action' => 'Continuar',
			'onboarding.feature_1.skip' => 'Omitir',
			'onboarding.feature_1.login' => '¿Ya tienes cuenta? Iniciar sesión',
			'onboarding.feature_2.title' => 'Inicio de sesión, ya resuelto',
			'onboarding.feature_2.description' => 'Correo, login social y recuperación de contraseña. Seguro y listo para publicar.',
			'onboarding.feature_2.action' => 'Continuar',
			'onboarding.feature_2.back' => 'Atrás',
			'onboarding.feature_3.title' => 'Tu asistente de IA integrado',
			'onboarding.feature_3.description' => 'Un asistente conversacional listo para usar, ya integrado.',
			'onboarding.feature_3.action' => 'Continuar',
			'onboarding.mockups.paywall.title' => 'Premium',
			'onboarding.mockups.paywall.annual' => 'Anual',
			'onboarding.mockups.paywall.monthly' => 'Mensual',
			'onboarding.mockups.paywall.save_badge' => '-40%',
			'onboarding.mockups.paywall.price_year' => '\$39,99 / año',
			'onboarding.mockups.paywall.price_month' => '\$4,99 / mes',
			'onboarding.mockups.paywall.cta' => 'Iniciar prueba gratis',
			'onboarding.mockups.earnings.notify_title' => 'Nuevo suscriptor Pro',
			'onboarding.mockups.earnings.notify_subtitle' => 'Plan anual · +\$49.90',
			'onboarding.mockups.earnings.notify_time' => '1:40 PM',
			'onboarding.mockups.earnings.processing' => 'Procesando pago…',
			'onboarding.mockups.earnings.summary_label' => 'Ganancias',
			'onboarding.mockups.earnings.summary_body' => 'Ganaste \$312.40 esta semana de 14 nuevas suscripciones.',
			'onboarding.mockups.auth.welcome' => 'Bienvenido de vuelta',
			'onboarding.mockups.auth.email_hint' => 'tu@email.com',
			'onboarding.mockups.auth.sign_in' => 'Iniciar sesión',
			'onboarding.mockups.auth.divider' => 'o',
			'onboarding.mockups.notification.title' => 'Nuevo mensaje',
			'onboarding.mockups.notification.time' => 'ahora',
			'onboarding.mockups.ai_chat.u1' => '¿Qué puedes hacer?',
			'onboarding.mockups.ai_chat.a1' => 'Escribo, resumo y respondo cualquier cosa en segundos.',
			'onboarding.mockups.ai_chat.u2' => 'Resume mis notas',
			'onboarding.mockups.ai_chat.a2' => 'Listo. Aquí tienes los 3 puntos clave de hoy.',
			'onboarding.ageQuestion.title' => '¿Cuántos años tienes?',
			'onboarding.ageQuestion.description' => 'Esto nos ayuda a personalizar tu experiencia.',
			'onboarding.ageQuestion.options.age18_30' => '18 a 30',
			'onboarding.ageQuestion.options.age31_40' => '31 a 40',
			'onboarding.ageQuestion.options.age41_50' => '41 a 50',
			'onboarding.ageQuestion.options.age51_60' => 'Más de 50',
			'onboarding.ageQuestion.options.none' => 'Prefiero no decirlo',
			'onboarding.ageQuestion.action' => 'Continuar',
			'onboarding.genderQuestion.title' => '¿Cómo te identificas?',
			'onboarding.genderQuestion.description' => 'Elige lo que mejor te represente. Puedes omitir si prefieres.',
			'onboarding.genderQuestion.options.male' => 'Masculino',
			'onboarding.genderQuestion.options.female' => 'Femenino',
			'onboarding.genderQuestion.options.none' => 'Prefiero no decirlo',
			'onboarding.genderQuestion.action' => 'Continuar',
			'onboarding.notifications.title' => 'No te pierdas nada',
			'onboarding.notifications.description' => 'Solo te escribiremos cuando de verdad importe. Nada de spam.',
			'onboarding.notifications.continue_button' => 'Activar notificaciones',
			'onboarding.notifications.skip_button' => 'Ahora no',
			'onboarding.notifications.toasts.push_app_name' => 'Kasy',
			'onboarding.notifications.toasts.push_headline' => 'Tu resumen semanal está listo',
			'onboarding.notifications.toasts.push_body' => 'Toca para abrir.',
			'onboarding.notifications.toasts.push_sent_at' => 'ahora',
			'onboarding.notifications.toasts.subscriber_title' => 'Nuevo suscriptor Pro',
			'onboarding.notifications.toasts.subscriber_message' => 'Plan anual · +\$49,90',
			'onboarding.notifications.toasts.streak_title' => '¡Racha de 7 días!',
			'onboarding.notifications.toasts.streak_message' => 'Volviste a cumplir tu meta diaria.',
			'onboarding.notifications.toasts.message_title' => 'Nueva respuesta',
			'onboarding.notifications.toasts.message_message' => 'Alguien respondió en tu conversación.',
			'onboarding.notifications.toasts.reminder_title' => 'Empieza pronto',
			'onboarding.notifications.toasts.reminder_message' => 'Tu sesión comienza en 10 minutos.',
			'onboarding.notifications.toasts.payment_title' => 'Pago recibido',
			'onboarding.notifications.toasts.payment_message' => '+\$12,50 acreditados en tu saldo.',
			'onboarding.notifications.toasts.offer_title' => 'Oferta limitada',
			'onboarding.notifications.toasts.offer_message' => '50% en el plan anual — termina hoy.',
			'onboarding.notifications.toasts.social_title' => 'Nueva interacción',
			'onboarding.notifications.toasts.social_message' => '3 personas dieron like a tu publicación.',
			'onboarding.att.title' => 'Experiencia personalizada',
			'onboarding.att.description' => 'El permiso ayuda a ajustar comunicaciones a tu perfil. No muestra anuncios dentro de la app.',
			'onboarding.att.continue_button' => 'Continuar',
			'onboarding.att.skip_button' => 'Ahora no',
			'onboarding.att.card.tag' => 'Privacidad',
			'onboarding.loading.welcome' => 'Cuenta creada.',
			'onboarding.loading.welcome_male' => 'Cuenta creada. Bienvenido!',
			'onboarding.loading.welcome_female' => 'Cuenta creada. Bienvenida!',
			'onboarding.loading.steps.account' => 'Creando tu cuenta',
			'onboarding.loading.steps.preferences' => 'Guardando tus preferencias',
			'onboarding.loading.steps.ready' => 'Personalizando tu experiencia',
			'feature_requests.title' => 'Ideas',
			'feature_requests.description' => 'Vota ideas o comparte la tuya. Cada voz define lo que construimos.',
			'feature_requests.community_ideas' => 'Ideas de la comunidad',
			'feature_requests.no_requests' => 'Sin ideas aún',
			'feature_requests.no_requests_hint' => 'Sé el primero en sugerir una función o mejora.',
			'feature_requests.vote_success.title' => 'Voto registrado',
			'feature_requests.vote_success.description' => 'Gracias por ayudarnos a priorizar',
			'feature_requests.vote_error.title' => 'Ya votado',
			'feature_requests.vote_error.description' => 'Ya votaste por esta idea',
			'feature_requests.add_feature.chip_label' => 'Agregar',
			'feature_requests.add_feature.title' => 'Enviar una idea',
			'feature_requests.add_feature.description' => 'Cuéntanos qué te gustaría ver en la app.',
			'feature_requests.add_feature.save_button' => 'Enviar',
			'feature_requests.add_feature.cancel' => 'Cancelar',
			'feature_requests.add_feature.title_label' => 'Título',
			'feature_requests.add_feature.title_hint' => 'Un título corto y descriptivo',
			'feature_requests.add_feature.description_label' => 'Descripción',
			'feature_requests.add_feature.description_hint' => 'Describe el recurso o la mejora en detalle...',
			'feature_requests.add_feature.error_title' => 'Error',
			'feature_requests.add_feature.error_required' => 'El título y la descripción son obligatorios',
			'feature_requests.add_feature.error_sending' => 'Algo salió mal. Inténtalo de nuevo.',
			'feature_requests.add_feature.error_too_short' => 'Descripción muy corta. Agrega más detalles',
			'feature_requests.add_feature.toast_success.title' => 'Idea enviada',
			'feature_requests.add_feature.toast_success.description' => 'La revisaremos y te daremos una respuesta',
			'update_bottom_sheet.title' => '¿Qué hay de nuevo?',
			'update_bottom_sheet.description' => 'Hicimos algunas mejoras',
			'update_bottom_sheet.highlights.0' => '- Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
			'update_bottom_sheet.highlights.1' => '- Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
			'update_bottom_sheet.highlights.2' => '- Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
			'update_bottom_sheet.continue_button' => 'Entendido',
			'update_available.title' => 'Actualización disponible',
			'update_available.description' => 'Hay una versión más nueva de la app. Actualiza para tener las últimas mejoras y correcciones.',
			'update_available.forced_title' => 'Actualización requerida',
			'update_available.forced_description' => 'Esta versión ya no es compatible. Actualiza para seguir usando la app.',
			'update_available.update_button' => 'Actualizar ahora',
			'update_available.later_button' => 'Ahora no',
			'request_notification_permission.title' => '¿Activar notificaciones?',
			'request_notification_permission.description' => 'Recibe actualizaciones en tiempo real y mantente al día con lo que importa.',
			'request_notification_permission.continue_button' => 'Activar',
			'request_notification_permission.skip_button' => 'Ahora no',
			'notification_permission_denied.title' => 'Permiso requerido',
			'notification_permission_denied.description' => 'Para recibir notificaciones, activa los permisos de notificación en la configuración de tu dispositivo.',
			'notification_permission_denied.allow_button' => 'Permitir notificaciones',
			'notification_permission_denied.open_settings_button' => 'Abrir configuración',
			'notification_permission_denied.cancel_button' => 'Cancelar',
			'review_popup.question_title' => '¿Te gusta la app?',
			'review_popup.question_description' => 'Tu respuesta nos ayuda a mejorar.',
			'review_popup.question_positive' => 'Sí, me gusta',
			'review_popup.question_negative' => 'Podría mejorar',
			'review_popup.title' => '¡Qué bueno que te guste!',
			'review_popup.description' => 'Una reseña en la tienda marca la diferencia. Toma unos segundos y nos ayuda mucho a crecer.',
			'review_popup.rate_button' => 'Escribir una reseña',
			'navigation.home' => 'Inicio',
			'navigation.support' => 'Ayuda',
			'navigation.notifications' => 'Notificaciones',
			'navigation.settings' => 'Config.',
			'navigation.logout' => 'Salir',
			'navigation.skip_to_content' => 'Saltar al contenido',
			'reminderPage.title' => 'Recordatorios',
			'reminderPage.toggleLabel' => 'Activar recordatorio',
			'reminderPage.typeLabel' => 'Repetir',
			'reminderPage.daily' => 'Cada día',
			'reminderPage.weekly' => 'Cada semana',
			'reminderPage.specificDate' => 'Una vez',
			'reminderPage.timeLabel' => 'Hora',
			'reminderPage.dayLabel' => 'Día de la semana',
			'reminderPage.dateLabel' => 'Fecha',
			'reminderPage.selectDate' => 'Seleccionar fecha',
			'reminderPage.hint' => 'Recibe un recordatorio para volver a la app',
			'reminderPage.summaryDaily' => ({required Object time}) => 'Todos los días a las ${time}',
			'reminderPage.summaryWeekly' => ({required Object day, required Object time}) => 'Cada ${day} a las ${time}',
			'reminderPage.summaryDate' => ({required Object date, required Object time}) => 'El ${date} a las ${time}',
			'time_picker.title' => 'Selecciona la hora',
			'time_picker.placeholder' => 'Selecciona una hora',
			'time_picker.hour' => 'Hora',
			'time_picker.minute' => 'Minuto',
			'time_picker.am' => 'AM',
			'time_picker.pm' => 'PM',
			'time_picker.confirm' => 'OK',
			'time_picker.cancel' => 'Cancelar',
			'dailyReminder.title' => 'Recordatorio',
			_ => null,
		} ?? switch (path) {
			'dailyReminder.body' => 'Es hora de beber un vaso de agua.',
			'settings.title' => 'Configuración',
			'settings.avatar.title' => 'Foto de perfil',
			'settings.avatar.take_photo' => 'Tomar foto',
			'settings.avatar.choose_library' => 'Biblioteca de fotos',
			'settings.avatar.remove_photo' => 'Eliminar foto',
			'settings.avatar.cancel' => 'Cancelar',
			'settings.language_title' => 'Idiomas',
			'settings.theme_title' => 'Tema',
			'settings.theme_option_system' => 'Sistema',
			'settings.theme_option_light' => 'Claro',
			'settings.theme_option_dark' => 'Oscuro',
			'settings.haptic_feedback_title' => 'Feedback háptico',
			'settings.hide_chrome_on_scroll_title' => 'Ocultar barras al desplazar',
			'settings.section_preferences_label' => 'PREFERENCIAS',
			'settings.section_security_label' => 'SEGURIDAD',
			'settings.section_support_label' => 'AYUDA',
			'settings.biometric_title' => 'Bloqueo de la app',
			'settings.biometric_subtitle_ios' => 'Pide Face ID o Touch ID al abrir con la sesión iniciada.',
			'settings.biometric_subtitle_ios_face' => 'Exige Face ID al abrir con sesión iniciada.',
			'settings.biometric_subtitle_ios_touch' => 'Exige Touch ID al abrir con sesión iniciada.',
			'settings.biometric_subtitle_android' => 'Pediremos una verificación rápida en el teléfono cuando abras con sesión iniciada.',
			'settings.biometric_subtitle_android_face' => 'Exige desbloqueo facial al abrir con sesión iniciada.',
			'settings.biometric_subtitle_android_fingerprint' => 'Exige huella digital al abrir con sesión iniciada.',
			'settings.biometric_subtitle_android_face_and_fingerprint' => 'Exige huella digital o desbloqueo facial al abrir con sesión iniciada.',
			'settings.biometric_disable_title' => '¿Desactivar bloqueo?',
			'settings.biometric_disable_message' => 'Sin bloqueo, quien tenga el teléfono desbloqueado puede usar la app hasta que cierres sesión.',
			'settings.biometric_disable_confirm' => 'Desactivar',
			'settings.biometric_disable_cancel' => 'Cancelar',
			'settings.biometric_enable_reason_ios' => 'Confirma con Face ID o Touch ID para activar el bloqueo',
			'settings.biometric_enable_reason_ios_face' => 'Confirma con Face ID para activar el bloqueo',
			'settings.biometric_enable_reason_ios_touch' => 'Confirma con Touch ID para activar el bloqueo',
			'settings.biometric_enable_reason_android' => 'Confirma en el teléfono para activar el bloqueo',
			'settings.biometric_enable_reason_android_face' => 'Confirma con reconocimiento facial para activar el bloqueo',
			'settings.biometric_enable_reason_android_fingerprint' => 'Confirma con huella digital para activar el bloqueo',
			'settings.biometric_enable_reason_android_face_and_fingerprint' => 'Confirma con huella o rostro para activar el bloqueo',
			'settings.biometric_login_reason_ios' => 'Desbloquea con Face ID o Touch ID',
			'settings.biometric_login_reason_ios_face' => 'Desbloquea con Face ID',
			'settings.biometric_login_reason_ios_touch' => 'Desbloquea con Touch ID',
			'settings.biometric_login_reason_android' => 'Confirma tu identidad',
			'settings.biometric_login_reason_android_face' => 'Desbloquea con reconocimiento facial',
			'settings.biometric_login_reason_android_fingerprint' => 'Desbloquea con huella digital',
			'settings.biometric_login_reason_android_face_and_fingerprint' => 'Desbloquea con huella o rostro',
			'settings.biometric_unavailable_message_ios' => 'Activa Face ID, Touch ID o código en Ajustes.',
			'settings.biometric_unavailable_message_ios_face' => 'Activa Face ID o un código del dispositivo en Ajustes.',
			'settings.biometric_unavailable_message_ios_touch' => 'Activa Touch ID o un código del dispositivo en Ajustes.',
			'settings.biometric_unavailable_message_android' => 'Activa desbloqueo biométrico o bloqueo de pantalla en Ajustes.',
			'settings.biometric_unavailable_message_android_face' => 'Configura reconocimiento facial o bloqueo de pantalla en ajustes.',
			'settings.biometric_unavailable_message_android_fingerprint' => 'Configura huella digital o bloqueo de pantalla en ajustes.',
			'settings.biometric_unavailable_message_android_face_and_fingerprint' => 'Añade huella o reconocimiento facial en Ajustes.',
			'settings.biometric_not_enabled_message' => 'El bloqueo de la app no se activó.',
			'settings.feedback' => 'Enviar comentarios',
			'settings.premium' => 'Premium',
			'settings.billing' => 'Facturación',
			'settings.privacy' => 'Política de privacidad',
			'settings.support' => 'Centro de ayuda',
			'settings.disconnect' => 'Sí, salir',
			'settings.disconnect_confirm_title' => '¿Salir de tu cuenta?',
			'settings.disconnect_confirm_message' => '¿Seguro que quieres salir?',
			'settings.disconnect_cancel' => 'Cancelar',
			'settings.logout' => 'Cerrar sesión',
			'settings.my_account' => 'Mi cuenta',
			'settings.not_signed_in' => 'No conectado',
			'settings.register' => 'Registrarse',
			'settings.name_label' => 'Nombre',
			'settings.edit' => 'Editar',
			'settings.email_label' => 'Correo electrónico',
			'settings.connected_with_label' => 'Conectado con',
			'settings.provider_email' => 'Correo y contraseña',
			'settings.provider_phone' => 'Teléfono',
			'settings.create_password_title' => 'Crear contraseña',
			'settings.create_password_subtitle' => 'Define una contraseña para también iniciar sesión con correo y contraseña, además del inicio de sesión social.',
			'settings.create_password_field' => 'Nueva contraseña',
			'settings.create_password_confirm_label' => 'Confirmar contraseña',
			'settings.create_password_success' => 'Contraseña creada',
			'settings.create_password_error' => 'No se pudo crear la contraseña. Inténtalo de nuevo.',
			'settings.create_password_too_short' => 'La contraseña debe tener al menos 6 caracteres',
			'settings.create_password_mismatch' => 'Las contraseñas no coinciden',
			'settings.link_social' => ({required Object provider}) => 'Vincular ${provider}',
			'settings.link_social_success' => ({required Object provider}) => '${provider} vinculado',
			'settings.link_social_error' => 'No se pudo vincular la cuenta. Inténtalo de nuevo.',
			'settings.edit_name_title' => 'Editar nombre',
			'settings.edit_name_hint' => 'Tu nombre',
			'settings.edit_name_save' => 'Guardar',
			'settings.edit_name_cancel' => 'Cancelar',
			'settings.edit_name_success' => 'Nombre actualizado',
			'settings.edit_name_error' => 'No se pudo actualizar tu nombre. Inténtalo de nuevo.',
			'settings.bio_label' => 'Bio',
			'settings.bio_hint' => 'Escribe algo sobre ti...',
			'settings.edit_profile_title' => 'Editar perfil',
			'settings.edit_profile_save' => 'Guardar',
			'settings.edit_profile_success' => 'Perfil actualizado',
			'settings.edit_profile_error' => 'No se pudo actualizar tu perfil. Inténtalo de nuevo.',
			'settings.reminders' => 'Recordatorios',
			'settings.admin_panel' => 'Panel de Administración',
			'settings.admin_debug_section_label' => 'ADMIN (SOLO DEBUG)',
			'settings.admin_panel_debug_notice' => 'Toda esta sección Admin (título, panel y opciones) solo existe en builds de debug. No se incluye en release; quien instala desde la tienda o un APK de producción no ve nada de esto.',
			'settings.delete_account.button' => 'Quiero eliminar mi cuenta',
			'settings.delete_account.title' => '¿Quieres eliminar tu cuenta?',
			'settings.delete_account.content' => 'Advertencia: esta acción es permanente y no se puede deshacer.',
			'settings.delete_account.content_subscriber' => 'Advertencia: esta acción es permanente. Perderás tu suscripción activa, y crear una cuenta nueva más tarde (incluso con el mismo correo) no la recuperará.',
			'settings.delete_account.cancel' => 'Cancelar',
			'settings.delete_account.confirm' => 'Sí, eliminar',
			'settings.delete_account.error' => 'Algo salió mal. Por favor, inténtalo de nuevo.',
			'settings.admin.update_bottom_sheet' => 'Previsualizar novedades',
			'settings.admin.preview_update_available' => 'Previsualizar actualización disponible',
			'settings.admin.paywalls' => 'Paywalls',
			'settings.admin.test_onboarding' => 'Probar onboarding',
			'settings.admin.copy_user_id' => 'Copiar ID de usuario',
			'settings.admin.user_id_copied' => 'ID de usuario copiado al portapapeles',
			'settings.admin.copy_fcm_token' => 'Copiar FCM Token',
			'settings.admin.fcm_token_copied' => 'FCM Token copiado al portapapeles',
			'settings.admin.fcm_token_unavailable' => 'Token no disponible (¿notificaciones desactivadas?)',
			'settings.admin.ask_notification' => 'Pedir permiso de notificación',
			'settings.admin.native_only' => 'Disponible solo en la app nativa (iOS / Android)',
			'settings.admin.ask_review' => 'Pedir evaluación',
			'settings.admin.home_widgets_panel' => 'Panel de Home Widgets',
			'settings.admin.home_widgets_title' => 'Panel de Home Widgets',
			'settings.admin.ads_demo_panel' => 'Demo de anuncios',
			'settings.admin.ads_demo_title' => 'Demo de anuncios',
			'settings.admin.ads_demo_subtitle' => 'Los cuatro formatos de AdMob con anuncios de prueba de Google. Prueba cada uno y colócalo donde quieras en tu app.',
			'settings.admin.ads_banner_label' => 'Banner',
			'settings.admin.ads_interstitial_title' => 'Intersticial',
			'settings.admin.ads_interstitial_desc' => 'Anuncio a pantalla completa. Toca para mostrar.',
			'settings.admin.ads_rewarded_title' => 'Recompensado',
			'settings.admin.ads_rewarded_desc' => 'El usuario mira para ganar una recompensa. Toca para mostrar.',
			'settings.admin.ads_rewarded_interstitial_title' => 'Recompensado intersticial',
			'settings.admin.ads_rewarded_interstitial_desc' => 'Anuncio a pantalla completa que también da recompensa. Toca para mostrar.',
			'settings.admin.ads_reward_earned' => ({required Object amount, required Object type}) => 'Recompensa ganada: ${amount} ${type}',
			'settings.admin.ads_load_failed' => 'No se pudo cargar el anuncio (sin relleno). Inténtalo de nuevo en un momento.',
			'settings.admin.ads_code_copied' => 'Código copiado al portapapeles',
			'settings.admin.ads_status_safe' => 'Esta demo siempre muestra anuncios de prueba de Google, así que es seguro tocar, incluso en producción.',
			'settings.admin.ads_status_test' => 'Tus ad ids reales aún no están configurados. Configúralos para publicar:',
			'settings.admin.ads_status_real' => 'Ad ids reales configurados para esta plataforma.',
			'settings.admin.inspector_fab_title' => 'Inspector de widgets',
			'settings.admin.inspector_fab_subtitle_prefix' => 'Atajo global:',
			'settings.admin.update_mywidget_title' => 'Actualizar Widget MyWidget',
			'settings.admin.update_mywidget_desc' => 'Llamar a la actualización manual para el widget MyWidget',
			'settings.admin.paywalls_title' => 'Panel de Admin de Paywalls',
			'settings.admin.send_push_title' => 'Enviar notificación',
			'settings.admin.send_push_to_all' => 'Enviar a todos',
			'settings.admin.send_push_email_hint' => 'Agregar e-mail',
			'settings.admin.send_push_title_label' => 'Título',
			'settings.admin.send_push_title_hint' => 'Ej: Nueva actualización disponible',
			'settings.admin.send_push_body_label' => 'Mensaje',
			'settings.admin.send_push_body_hint' => 'Hasta 3 líneas en la lista de la app (máx. 140 caracteres)',
			'settings.admin.send_push_image_label' => 'URL de imagen (opcional)',
			'settings.admin.send_push_image_hint' => 'https://...',
			'settings.admin.send_push_email_label' => 'Correos destinatarios',
			'settings.admin.send_push_success' => '¡Notificación enviada!',
			'settings.admin.send_push_user_not_found' => ({required Object email}) => 'Usuario no encontrado: ${email}',
			'settings.admin.send_push_send_button' => 'Enviar',
			'settings.admin.send_push_required' => 'El título y el mensaje son obligatorios',
			'settings.admin.send_push_no_emails' => 'Agrega al menos un correo',
			'settings.admin.send_push_route_label' => 'Página al abrir',
			'settings.admin.send_push_route_description' => 'Pantalla que se abre cuando el usuario toca la notificación.',
			'settings.admin.send_push_route_notifications' => 'Notificaciones',
			'settings.admin.send_push_route_home' => 'Inicio',
			'settings.admin.send_push_route_settings' => 'Configuración',
			'settings.admin.send_push_route_premium' => 'Premium',
			'settings.admin.send_push_route_reminder' => 'Recordatorios',
			'settings.admin.send_push_route_feedback' => 'Comentarios',
			'settings.admin.send_push_preview_label' => 'Vista previa',
			'settings.admin.send_push_preview_now' => 'ahora',
			'settings.admin.send_push_preview_title_placeholder' => 'Título de la notificación',
			'settings.admin.send_push_preview_body_placeholder' => 'El cuerpo del mensaje aparece aquí',
			'settings.admin.device_preview_title' => 'Device Preview (solo web)',
			'settings.admin.send_push_section_recipients' => 'Destinatarios',
			'settings.admin.send_push_section_content' => 'Contenido',
			'settings.admin.send_push_section_advanced' => 'Avanzado',
			'settings.admin.send_push_audience_all' => 'Todos',
			'settings.admin.send_push_audience_specific' => 'Específicos',
			'settings.admin.send_push_audience_all_hint' => 'La notificación se enviará a todos los usuarios suscritos.',
			'rate_banner.title' => '¿Te gusta nuestra app?',
			'rate_banner.text' => '¿Tienes un minuto para dejarnos una reseña en la tienda?',
			'rate_banner.rate_button' => '¡Sí, seguro!',
			'rate_banner.later_button' => 'Más tarde...',
			'notifications.title' => 'Notificaciones',
			'notifications.empty_title' => 'No tienes notificaciones',
			'notifications.empty_subtitle' => 'Mantente atento a las actualizaciones',
			'notifications.error_fetching' => 'Error al obtener notificaciones',
			'notifications.push_title' => 'Notificaciones push',
			'notifications.push_subtitle_enabled' => 'Estás recibiendo alertas',
			'notifications.push_subtitle_disabled' => 'Toca para activar en Configuración',
			'notifications.push_subtitle_waiting' => 'Activa para no perderte nada',
			'notifications.mark_all_read' => 'Marcar leídas',
			'notifications.see_all' => 'Ver todas',
			'notifications.group_today' => 'Hoy',
			'notifications.group_yesterday' => 'Ayer',
			'notifications.group_older' => 'Más antiguas',
			'notifications.empty_cta' => 'Activar notificaciones',
			'notifications.empty_cta_open_settings' => 'Abrir ajustes',
			'notifications.delete_all' => 'Eliminar todo',
			'notifications.options' => 'Opciones',
			'notifications.delete_all_confirm_title' => '¿Eliminar todas las notificaciones?',
			'notifications.delete_all_confirm_message' => 'Esto eliminará todas las notificaciones de tu cuenta. Esta acción no se puede deshacer.',
			'notifications.delete_action' => 'Sí, eliminar',
			'notifications.cancel_action' => 'Cancelar',
			'notifications.deleted_one' => 'Notificación eliminada',
			'notifications.deleted_all' => 'Todas las notificaciones eliminadas',
			'notifications.new_comment_title' => 'Nuevo Comentario',
			'notifications.new_comment_body' => 'Se ha añadido un nuevo comentario a tu PDF: "{pdfTitle}"',
			'bottom_router.fake_page_text' => 'Esta es una página de prueba',
			'ai_chat.title' => 'Asistente IA',
			'ai_chat.empty_state' => 'Inicia una conversación con tu asistente.',
			'ai_chat.hint' => 'Pregunta algo...',
			'ai_chat.error_not_configured' => 'El asistente aún no está disponible. Inténtalo más tarde.',
			'ai_chat.error_no_reply' => 'No pudimos obtener una respuesta. Inténtalo de nuevo.',
			'ai_chat.error_network' => 'No se pudo conectar al asistente de IA.',
			'ai_chat.new_conversation' => 'Nueva conversación',
			'ai_chat.conversations_empty' => 'Aún no hay conversaciones',
			'ai_chat.conversations_empty_hint' => 'Toca en Nueva conversación para empezar.',
			'ai_chat.no_conversation_selected' => 'Elige una conversación o empieza una nueva.',
			'ai_chat.delete_title' => '¿Eliminar conversación?',
			'ai_chat.delete_message' => 'Esta conversación y todos sus mensajes se eliminarán de forma permanente.',
			'ai_chat.delete_cancel' => 'Cancelar',
			'ai_chat.delete_confirm' => 'Sí, eliminar',
			'phone_auth.title_input' => 'Autenticación por Teléfono',
			'phone_auth.subtitle_input' => 'Ingresa tu número de teléfono',
			'phone_auth.description_input' => 'Te enviaremos un código de verificación para confirmar tu identidad',
			'phone_auth.phone_label' => 'Número de teléfono',
			'phone_auth.phone_hint' => '+34 600 123 456',
			'phone_auth.error_empty' => 'Por favor, ingresa un número de teléfono',
			'phone_auth.error_invalid' => 'Por favor, ingresa un número válido',
			'phone_auth.continue_btn' => 'Continuar',
			'phone_auth.title_verify' => 'Verificar Código',
			'phone_auth.verification_code' => 'Código de Verificación',
			'phone_auth.code_sent' => ({required Object phone}) => 'Hemos enviado un código de verificación a ${phone}',
			'phone_auth.signin_success_title' => 'Listo',
			'phone_auth.signin_success_text' => 'Has iniciado sesión con tu número de teléfono',
			'phone_auth.verify_code' => 'Verificar Código',
			'phone_auth.resend_code' => 'Reenviar Código',
			'phone_auth.enter_all_digits' => 'Por favor, ingresa los 6 dígitos',
			'recover_password_result.title' => 'Email enviado',
			'recover_password_result.description' => 'Te hemos enviado un email con un enlace para restablecer tu contraseña',
			'recover_password_result.back_to_signin' => 'Volver a Iniciar Sesión',
			'recover_password_result.note' => 'Nota: Si no recibes un email, por favor revisa tu carpeta de spam',
			'page_not_found.title' => '404 - Página no encontrada',
			'devInspector.copied' => 'Contexto copiado. Pégalo en el chat de IA.',
			'devInspector.activate' => 'Activar inspector de widgets',
			'devInspector.deactivate' => 'Desactivar inspector de widgets',
			'devInspector.copyForAi' => 'Copiar para IA',
			'devInspector.selectWidgetFirst' => 'Selecciona un widget en pantalla primero.',
			'devInspector.inspectorHint' => 'Toca un widget para seleccionar. El contexto se copia solo. Tecla C para copiar de nuevo.',
			'devInspector.statusActive' => 'Inspeccionando',
			'webDevicePreview.frame' => 'Frame',
			'webDevicePreview.darkBackground' => 'Fondo oscuro',
			'webDevicePreview.darkTheme' => 'Tema oscuro',
			'webDevicePreview.landscape' => 'Horizontal',
			'webDevicePreview.textScale' => 'Escala de texto',
			'webDevicePreview.screenshot' => 'Captura de pantalla',
			'webDevicePreview.imageCopied' => 'Imagen copiada — pégala en el chat',
			'webDevicePreview.imageDownloaded' => 'Imagen descargada',
			'webDevicePreview.hotReload' => 'Hot reload',
			'webDevicePreview.hotRestart' => 'Hot restart',
			'webDevicePreview.hotReloading' => 'Recargando…',
			'webDevicePreview.hotRestarting' => 'Reiniciando…',
			'webDevicePreview.hotReloadDone' => 'Recarga completa',
			'webDevicePreview.hotRestartDone' => 'Reinicio completo',
			'webDevicePreview.hotReloadFailed' => 'Error al recargar',
			'webDevicePreview.hotReloadNeedsRestart' => 'Ese cambio necesita reinicio — usa el botón R',
			'webDevicePreview.hotReloadCompileError' => 'Error en el código — corrígelo en el editor y recarga',
			'webDevicePreview.hotRestartFailed' => 'Error al reiniciar',
			'webDevicePreview.hotRestartCompileError' => 'Error en el código — corrígelo en el editor y reinicia',
			'webDevicePreview.terminalStatusOk' => 'Terminal sin errores — puedes usar r',
			'webDevicePreview.terminalStatusError' => 'Terminal con error — corrígelo o usa R',
			'webDevicePreview.terminalStatusOffline' => 'Puente del terminal offline — usa kasy run --web',
			'webDevicePreview.devBridgeUnavailable' => 'Servidor dev offline — ejecuta kasy run --web, deja el terminal abierto y abre la URL que muestre',
			'biometric_prompt.title_ios_face' => '¿Activar Face ID en el bloqueo?',
			'biometric_prompt.title_ios_touch' => '¿Activar Touch ID en el bloqueo?',
			'biometric_prompt.title_ios_mixed' => '¿Activar Face ID/Touch ID en el bloqueo?',
			'biometric_prompt.title_android_face' => '¿Activar bloqueo con reconocimiento facial?',
			'biometric_prompt.title_android_fingerprint' => '¿Activar bloqueo con huella digital?',
			'biometric_prompt.title_android_mixed' => '¿Proteger la app con tu teléfono?',
			'biometric_prompt.message_ios_face' => 'Al abrir confirmarás con Face ID—sigues con sesión iniciada.',
			'biometric_prompt.message_ios_touch' => 'Al abrir confirmarás con Touch ID—sigues con sesión iniciada.',
			'biometric_prompt.message_ios_mixed' => 'Al abrir confirmarás con Face ID o Touch ID—sigues con sesión iniciada.',
			'biometric_prompt.message_android_face' => 'Al abrir verificarás con reconocimiento facial—sigues con sesión iniciada.',
			'biometric_prompt.message_android_fingerprint' => 'Al abrir verificarás con huella digital—sigues con sesión iniciada.',
			'biometric_prompt.title_android_face_and_fingerprint' => '¿Activar bloqueo con huella o rostro?',
			'biometric_prompt.message_android_face_and_fingerprint' => 'Puedes usar cualquiera de los dos—sigues dentro.',
			'biometric_prompt.message_android_mixed' => 'Una confirmación rápida al abrir—sigues con la sesión.',
			'biometric_prompt.not_now' => 'Ahora no',
			'biometric_prompt.enable' => 'Activar',
			'home_widget.greeting_morning' => 'Buenos días',
			'home_widget.greeting_afternoon' => 'Buenas tardes',
			'home_widget.greeting_evening' => 'Buenas noches',
			'home_widget.title_with_name' => ({required Object name}) => '¡Hola, ${name}!',
			'home_widget.title_default' => '¡Hola!',
			'home_widget.title_logged_out' => 'Te esperamos de vuelta',
			'home_widget.plan_free' => 'Plan gratuito',
			'home_widget.plan_pro' => 'PRO',
			'home_widget.quote' => 'Tu tiempo es limitado.\nNo vivas la vida de otra persona.\nTen el coraje de seguir tu intuición.\nTodo lo demás es secundario.',
			'home_widget.quote_author' => 'Steve Jobs',
			'kanban.title' => 'Tareas',
			'kanban.empty_title' => 'Organiza tus tareas',
			'kanban.empty_description' => 'Crea columnas personalizadas y comienza a organizar lo que hay que hacer en tu proyecto.',
			'kanban.empty_column' => 'Sin tareas en esta columna',
			'kanban.error_title' => 'Error al cargar',
			'kanban.add_column' => 'Añadir columna',
			'kanban.add_column_subtitle' => 'Elige un nombre corto para organizar las tareas en esta columna.',
			'kanban.add_another_list' => 'Añadir otra lista',
			'kanban.add_list' => 'Añadir lista',
			'kanban.list_name_hint' => 'Escribe el nombre de la lista...',
			'kanban.add_task' => 'Añadir tarea',
			'kanban.add_task_subtitle' => 'Define el titulo y, si quieres, una descripcion y la prioridad.',
			'kanban.edit_column' => 'Editar columna',
			'kanban.edit_task_subtitle' => 'Actualiza los detalles de esta tarea.',
			'kanban.cancel' => 'Cancelar',
			'kanban.save' => 'Guardar',
			'kanban.delete_column' => 'Eliminar columna',
			'kanban.edit_task' => 'Editar tarea',
			'kanban.delete_task' => 'Eliminar tarea',
			'kanban.column_name' => 'Nombre de columna',
			'kanban.column_name_hint' => 'Ej: En progreso, Hecho',
			'kanban.task_title' => 'Título de tarea',
			'kanban.task_title_hint' => 'Ej: Implementar login',
			'kanban.task_title_required' => 'Ingresa un título para la tarea.',
			'kanban.column_name_required' => 'Ingresa un nombre para la columna.',
			'kanban.task_description' => 'Descripción',
			'kanban.task_description_hint' => 'Detalles sobre la tarea',
			'kanban.create' => 'Crear',
			'kanban.mark_complete' => 'Marcar como completada',
			'kanban.mark_incomplete' => 'Marcar como pendiente',
			'kanban.column_created' => 'Columna creada',
			'kanban.column_updated' => 'Columna actualizada',
			'kanban.column_deleted' => 'Columna eliminada',
			'kanban.task_created' => 'Tarea creada',
			'kanban.task_updated' => 'Tarea actualizada',
			'kanban.task_deleted' => 'Tarea eliminada',
			'kanban.priority' => 'Prioridad',
			'kanban.priority_none' => 'Ninguna',
			'kanban.priority_low' => 'Baja',
			'kanban.priority_medium' => 'Media',
			'kanban.priority_high' => 'Alta',
			'kanban.priority_urgent' => 'Urgente',
			'kanban.cards_count' => ({required Object count}) => '${count} cards',
			'kanban.move_to' => 'Mover a columna',
			'kanban.move_left' => 'Mover a la izquierda',
			'kanban.move_right' => 'Mover a la derecha',
			'kanban.delete_column_confirm' => 'Se eliminaran permanentemente todas las tarjetas de esta columna.',
			'kanban.delete_task_confirm' => 'Esta tarea se eliminara permanentemente.',
			'kanban.created_on' => ({required Object date}) => 'Creado el ${date}',
			'library.title' => 'Biblioteca',
			'library.categories' => 'Categorías',
			'library.manage_categories' => 'Administrar Categorías',
			'library.add_category' => 'Agregar Categoría',
			'library.edit_category' => 'Editar Categoría',
			'library.delete_category' => 'Eliminar Categoría',
			'library.category_name' => 'Nombre de la Categoría',
			'library.category_desc' => 'Descripción de la Categoría',
			'library.save' => 'Guardar',
			'library.cancel' => 'Cancelar',
			'library.pdfs' => 'PDFs',
			'library.favorites' => 'Favoritos',
			'library.search_hint' => 'Buscar por título, autor o etiqueta...',
			'library.add_pdf' => 'Registrar PDF',
			'library.edit_pdf' => 'Editar PDF',
			'library.delete_pdf' => 'Eliminar PDF',
			'library.pdf_title' => 'Título',
			'library.pdf_desc' => 'Descripción',
			'library.pdf_author' => 'Autor',
			'library.pdf_url' => 'URL del archivo PDF',
			'library.pdf_thumb' => 'URL de la miniatura (portada)',
			'library.pdf_tags' => 'Etiquetas (separadas por comas)',
			'library.no_pdfs' => 'Ningún PDF encontrado',
			'library.comments' => 'Comentarios',
			'library.write_comment' => 'Escribir un comentario...',
			'library.submit_comment' => 'Enviar Comentario',
			'library.rating' => 'Calificación',
			'library.download' => 'Descargar',
			'library.read' => 'Leer',
			'library.unauthorized' => 'Debes ser administrador para ver esta página.',
			'library.profile_switcher' => 'Cambiar Perfil',
			'library.active_profile' => 'Perfil Activo',
			'library.admin_dev' => 'Admin / Dev',
			'library.client' => 'Cliente',
			'library.read_sim' => 'Lector Simulado',
			'library.prev_page' => 'Anterior',
			'library.next_page' => 'Siguiente',
			'library.zoom_in' => 'Acercar',
			'library.zoom_out' => 'Alejar',
			'library.page_info' => ({required Object page, required Object total}) => 'Página ${page} de ${total}',
			'library.no_comments' => 'Aún no hay comentarios. ¡Sé el primero en comentar!',
			'library.my_pdfs' => 'Mis PDFs',
			'library.send_pdf' => 'Enviar PDF',
			'library.no_client_pdfs' => 'Ningún PDF enviado por clientes aún.',
			'library.upload_box_title' => 'Haz clic para subir tu PDF',
			'library.upload_box_subtitle' => 'Formato soportado: PDF (Máx. 10MB)',
			'library.pdf_preview' => 'Vista previa del PDF',
			'library.pages' => 'Páginas',
			'library.change_file' => 'Cambiar Archivo',
			'library.explore' => 'Explorar',
			'library.visit_profile' => 'Visitar perfil',
			'library.no_public_pdfs' => 'Ningún PDF público enviado por otros usuarios aún.',
			'library.uploaded_by' => 'Enviado por',
			'library.sent_by' => 'Enviado por',
			'library.public_profile' => 'Perfil Público',
			'library.view_all_pdfs' => 'Ver todos los PDFs subidos por este usuario',
			'search.title' => 'Búsqueda Global',
			'search.hint' => 'Buscar autores, temas y PDFs...',
			'search.authors' => 'Autores',
			'search.categories' => 'Temas',
			'search.pdfs' => 'PDFs',
			'search.empty' => 'No se encontraron resultados para "{query}".',
			_ => null,
		};
	}
}
