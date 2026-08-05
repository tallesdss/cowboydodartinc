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
class TranslationsPt extends Translations with BaseTranslations<AppLocale, Translations> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsPt({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.pt,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		super.$meta.setFlatMapFunction($meta.getTranslation); // copy base translations to super.$meta
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <pt>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key) ?? super.$meta.getTranslation(key);

	late final TranslationsPt _root = this; // ignore: unused_field

	@override 
	TranslationsPt $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsPt(meta: meta ?? this.$meta);

	// Translations
	@override late final _TranslationsCommonPt common = _TranslationsCommonPt._(_root);
	@override late final _TranslationsAdminConsolePt admin_console = _TranslationsAdminConsolePt._(_root);
	@override late final _TranslationsHomePt home = _TranslationsHomePt._(_root);
	@override late final _TranslationsAuthPt auth = _TranslationsAuthPt._(_root);
	@override late final _TranslationsRatePopupPt rate_popup = _TranslationsRatePopupPt._(_root);
	@override late final _TranslationsPremiumPt premium = _TranslationsPremiumPt._(_root);
	@override late final _TranslationsActivePremiumPt activePremium = _TranslationsActivePremiumPt._(_root);
	@override late final _TranslationsOnboardingPt onboarding = _TranslationsOnboardingPt._(_root);
	@override late final _TranslationsFeatureRequestsPt feature_requests = _TranslationsFeatureRequestsPt._(_root);
	@override late final _TranslationsUpdateBottomSheetPt update_bottom_sheet = _TranslationsUpdateBottomSheetPt._(_root);
	@override late final _TranslationsUpdateAvailablePt update_available = _TranslationsUpdateAvailablePt._(_root);
	@override late final _TranslationsRequestNotificationPermissionPt request_notification_permission = _TranslationsRequestNotificationPermissionPt._(_root);
	@override late final _TranslationsNotificationPermissionDeniedPt notification_permission_denied = _TranslationsNotificationPermissionDeniedPt._(_root);
	@override late final _TranslationsReviewPopupPt review_popup = _TranslationsReviewPopupPt._(_root);
	@override late final _TranslationsNavigationPt navigation = _TranslationsNavigationPt._(_root);
	@override late final _TranslationsReminderPagePt reminderPage = _TranslationsReminderPagePt._(_root);
	@override late final _TranslationsTimePickerPt time_picker = _TranslationsTimePickerPt._(_root);
	@override late final _TranslationsDailyReminderPt dailyReminder = _TranslationsDailyReminderPt._(_root);
	@override late final _TranslationsSettingsPt settings = _TranslationsSettingsPt._(_root);
	@override late final _TranslationsRateBannerPt rate_banner = _TranslationsRateBannerPt._(_root);
	@override late final _TranslationsNotificationsPt notifications = _TranslationsNotificationsPt._(_root);
	@override late final _TranslationsBottomRouterPt bottom_router = _TranslationsBottomRouterPt._(_root);
	@override late final _TranslationsAiChatPt ai_chat = _TranslationsAiChatPt._(_root);
	@override late final _TranslationsPhoneAuthPt phone_auth = _TranslationsPhoneAuthPt._(_root);
	@override late final _TranslationsRecoverPasswordResultPt recover_password_result = _TranslationsRecoverPasswordResultPt._(_root);
	@override late final _TranslationsPageNotFoundPt page_not_found = _TranslationsPageNotFoundPt._(_root);
	@override late final _TranslationsDevInspectorPt devInspector = _TranslationsDevInspectorPt._(_root);
	@override late final _TranslationsWebDevicePreviewPt webDevicePreview = _TranslationsWebDevicePreviewPt._(_root);
	@override late final _TranslationsBiometricPromptPt biometric_prompt = _TranslationsBiometricPromptPt._(_root);
	@override late final _TranslationsHomeWidgetPt home_widget = _TranslationsHomeWidgetPt._(_root);
	@override late final _TranslationsKanbanPt kanban = _TranslationsKanbanPt._(_root);
	@override late final _TranslationsLibraryPt library = _TranslationsLibraryPt._(_root);
}

// Path: common
class _TranslationsCommonPt extends TranslationsCommonEn {
	_TranslationsCommonPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get close => 'Fechar';
	@override String get copied => 'Copiado';
	@override String get saved => 'Salvo';
	@override String get error => 'Erro';
	@override String get unavailable => 'Indisponível';
	@override String get native_only_title => 'Apenas no app nativo';
}

// Path: admin_console
class _TranslationsAdminConsolePt extends TranslationsAdminConsoleEn {
	_TranslationsAdminConsolePt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsAdminConsoleTabsPt tabs = _TranslationsAdminConsoleTabsPt._(_root);
	@override String get back_to_app => 'Voltar ao app';
	@override late final _TranslationsAdminConsoleOverviewPt overview = _TranslationsAdminConsoleOverviewPt._(_root);
	@override late final _TranslationsAdminConsoleUsersPt users = _TranslationsAdminConsoleUsersPt._(_root);
	@override late final _TranslationsAdminConsoleRequestsPt requests = _TranslationsAdminConsoleRequestsPt._(_root);
	@override late final _TranslationsAdminConsoleGroupsPt groups = _TranslationsAdminConsoleGroupsPt._(_root);
	@override late final _TranslationsAdminConsolePaywallsPt paywalls = _TranslationsAdminConsolePaywallsPt._(_root);
	@override late final _TranslationsAdminConsoleSettingsEntryPt settings_entry = _TranslationsAdminConsoleSettingsEntryPt._(_root);
	@override String get requires_admin => 'Você precisa ser admin para ver isto. Defina role: admin no registro do seu usuário no backend. O app não altera esse campo; a validação é no servidor.';
}

// Path: home
class _TranslationsHomePt extends TranslationsHomeEn {
	_TranslationsHomePt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Exemplo Kasy';
	@override String get welcome => 'Bem-vindo ao demo do Kasy';
	@override late final _TranslationsHomeCardsPt cards = _TranslationsHomeCardsPt._(_root);
	@override late final _TranslationsHomeFeaturesPagePt features_page = _TranslationsHomeFeaturesPagePt._(_root);
	@override late final _TranslationsHomeDashboardPt dashboard = _TranslationsHomeDashboardPt._(_root);
	@override late final _TranslationsHomeComponentsPreviewPt components_preview = _TranslationsHomeComponentsPreviewPt._(_root);
}

// Path: auth
class _TranslationsAuthPt extends TranslationsAuthEn {
	_TranslationsAuthPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsAuthSigninPt signin = _TranslationsAuthSigninPt._(_root);
	@override late final _TranslationsAuthSignupPt signup = _TranslationsAuthSignupPt._(_root);
	@override late final _TranslationsAuthRecoverPt recover = _TranslationsAuthRecoverPt._(_root);
}

// Path: rate_popup
class _TranslationsRatePopupPt extends TranslationsRatePopupEn {
	_TranslationsRatePopupPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Você teria 15s para nos avaliar?';
	@override String get description => 'É rápido e muito útil! Muito obrigado!';
	@override String get cancel_button => 'Talvez mais tarde';
	@override String get rate_button => 'Sim, com prazer!';
}

// Path: premium
class _TranslationsPremiumPt extends TranslationsPremiumEn {
	_TranslationsPremiumPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get title_1 => 'Desbloqueie o acesso completo';
	@override String get description => 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.';
	@override String get feature_1 => 'Recurso 1 lorem ipsum';
	@override String get feature_2 => 'Recurso 2 mop issum';
	@override String get feature_3 => 'Recurso 3 lorem';
	@override String get duration_weekly => 'Semana';
	@override String get duration_annual => 'Ano';
	@override String get duration_monthly => 'Mês';
	@override String get duration_monthly_description => 'Cancele quando quiser';
	@override String get duration_lifetime => 'Vitalício';
	@override String get duration_lifetime_description => 'Pagamento único';
	@override String get restore_action => 'Restaurar';
	@override String get preview_disabled_title => 'Pré-visualização';
	@override String get preview_disabled_text => 'Esta é uma pré-visualização do admin. As ações de compra ficam desativadas.';
	@override String get coupon_title => 'Tem um cupom?';
	@override String get payment_cancel_reassurance => 'Cancelamento fácil com 1 clique, sempre';
	@override String get payment_cancel_reassurance_free_trial => 'Sem pagamento agora, cancele quando quiser';
	@override String get payment_action => 'Iniciar teste gratuito';
	@override String payment_action_trial({required Object money}) => '7 dias grátis, depois ${money}';
	@override String try_free_btn_action({required Object days}) => 'Experimente grátis por ${days} dias';
	@override String get duration_recuring_label_annual => 'Anual';
	@override String get duration_recuring_label_monthly => 'Mensal';
	@override String get duration_recuring_label_weekly => 'Semanal';
	@override String get price_per_week => '/semana';
	@override String get price_per_month => '/mês';
	@override String get price_per_three_month => '/3 meses';
	@override String get price_per_six_month => '/6 meses';
	@override String get price_per_year => '/ano';
	@override String get price_one_time => '';
	@override String get action_button => 'Continuar';
	@override String get terms => 'Termos';
	@override String get privacy => 'Privacidade';
	@override String get terms_of_use => 'Termos de uso';
	@override String get privacy_policy => 'Política de privacidade';
	@override String get error_loading => 'Erro ao carregar as ofertas';
	@override String get no_products_title => 'As opções de assinatura ainda não estão disponíveis';
	@override String get no_products_description => 'Tente novamente em alguns instantes. Se continuar acontecendo, os produtos da loja ainda podem estar finalizando a configuração.';
	@override String get restore_success_title => 'Assinatura restaurada';
	@override String get restore_success_text => 'Obrigado pela sua confiança';
	@override String get purchase_success_title => 'Assinatura realizada com sucesso';
	@override String get purchase_success_text => 'Obrigado pela sua confiança';
	@override String get error_title => 'Erro';
	@override String get error_text => 'Ocorreu um erro. Tente novamente';
	@override String get web_checkout_timeout_title => 'Pagamento não confirmado';
	@override String get web_checkout_timeout_text => 'Não recebemos a confirmação do pagamento. Se você já pagou, toque em Restaurar.';
	@override String get restore_none_title => 'Nenhuma assinatura encontrada';
	@override String get restore_none_text => 'Não encontramos uma assinatura ativa para restaurar.';
	@override late final _TranslationsPremiumSoloPt solo = _TranslationsPremiumSoloPt._(_root);
	@override late final _TranslationsPremiumComparePlanPt comparePlan = _TranslationsPremiumComparePlanPt._(_root);
	@override late final _TranslationsPremiumTrialPlanPt trialPlan = _TranslationsPremiumTrialPlanPt._(_root);
	@override late final _TranslationsPremiumUnlockPlanPt unlockPlan = _TranslationsPremiumUnlockPlanPt._(_root);
	@override late final _TranslationsPremiumComparisonPt comparison = _TranslationsPremiumComparisonPt._(_root);
}

// Path: activePremium
class _TranslationsActivePremiumPt extends TranslationsActivePremiumEn {
	_TranslationsActivePremiumPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Você é um usuário premium';
	@override String get description => 'Aproveite todos os recursos';
	@override String get unsubscribe_button => 'Cancelar assinatura';
	@override String get early_bird_description => 'Você usou um cupom que lhe deu acesso gratuito aos recursos premium sem assinatura. Aproveite!';
	@override String get unsubscribe_feedback_title => 'Ajude-nos a melhorar';
	@override String get unsubscribe_feedback_description => 'Lamentamos vê-lo partir. Poderia nos dizer brevemente por que está cancelando?';
	@override String get unsubscribe_feedback_hint => 'Conte-nos o motivo...';
	@override String get unsubscribe_feedback_min_chars => 'Mínimo de 6 caracteres necessários';
	@override String get unsubscribe_confirm_button => 'Prosseguir';
	@override String get lifetime_user_description => 'Você é um usuário vitalício';
	@override String get managed_elsewhere_title => 'Assinatura em outra plataforma';
	@override String get managed_elsewhere_description => 'Esta assinatura foi feita em outra plataforma e não pode ser gerenciada ou cancelada por aqui. Acesse a conta na plataforma onde você fez a compra.';
	@override String get restore_button => 'Restaurar compras';
	@override String get cancel_button => 'Fechar';
	@override String get billing_title => 'Cobrança';
	@override String get plan_label => 'Plano da conta';
	@override String get plan_fallback => 'Premium';
	@override String get manage_subscription => 'Gerenciar assinatura';
	@override String get restore_purchases => 'Restaurar compras';
	@override String renews_on({required Object date}) => 'Renova em ${date}';
	@override String expires_on({required Object date}) => 'Expira em ${date}';
	@override String get trial_label => 'Avaliação gratuita';
	@override String trial_until({required Object date}) => 'Avaliação gratuita até ${date}';
	@override String charges_from({required Object price, required Object date}) => '${price} a partir de ${date}';
}

// Path: onboarding
class _TranslationsOnboardingPt extends TranslationsOnboardingEn {
	_TranslationsOnboardingPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsOnboardingFeature1Pt feature_1 = _TranslationsOnboardingFeature1Pt._(_root);
	@override late final _TranslationsOnboardingFeature2Pt feature_2 = _TranslationsOnboardingFeature2Pt._(_root);
	@override late final _TranslationsOnboardingFeature3Pt feature_3 = _TranslationsOnboardingFeature3Pt._(_root);
	@override late final _TranslationsOnboardingMockupsPt mockups = _TranslationsOnboardingMockupsPt._(_root);
	@override late final _TranslationsOnboardingAgeQuestionPt ageQuestion = _TranslationsOnboardingAgeQuestionPt._(_root);
	@override late final _TranslationsOnboardingGenderQuestionPt genderQuestion = _TranslationsOnboardingGenderQuestionPt._(_root);
	@override late final _TranslationsOnboardingNotificationsPt notifications = _TranslationsOnboardingNotificationsPt._(_root);
	@override late final _TranslationsOnboardingAttPt att = _TranslationsOnboardingAttPt._(_root);
	@override late final _TranslationsOnboardingLoadingPt loading = _TranslationsOnboardingLoadingPt._(_root);
}

// Path: feature_requests
class _TranslationsFeatureRequestsPt extends TranslationsFeatureRequestsEn {
	_TranslationsFeatureRequestsPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Ideias';
	@override String get description => 'Vote nas ideias ou envie a sua. Cada voz define o que construímos.';
	@override String get community_ideas => 'Ideias da comunidade';
	@override String get no_requests => 'Nenhuma ideia ainda';
	@override String get no_requests_hint => 'Seja o primeiro a sugerir um recurso ou melhoria.';
	@override late final _TranslationsFeatureRequestsVoteSuccessPt vote_success = _TranslationsFeatureRequestsVoteSuccessPt._(_root);
	@override late final _TranslationsFeatureRequestsVoteErrorPt vote_error = _TranslationsFeatureRequestsVoteErrorPt._(_root);
	@override late final _TranslationsFeatureRequestsAddFeaturePt add_feature = _TranslationsFeatureRequestsAddFeaturePt._(_root);
}

// Path: update_bottom_sheet
class _TranslationsUpdateBottomSheetPt extends TranslationsUpdateBottomSheetEn {
	_TranslationsUpdateBottomSheetPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get title => 'O que há de novo?';
	@override String get description => 'Fizemos algumas melhorias';
	@override List<String> get highlights => [
		'- Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
		'- Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
		'- Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
	];
	@override String get continue_button => 'Entendi';
}

// Path: update_available
class _TranslationsUpdateAvailablePt extends TranslationsUpdateAvailableEn {
	_TranslationsUpdateAvailablePt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Atualização disponível';
	@override String get description => 'Há uma versão mais nova do app. Atualize para ter as últimas melhorias e correções.';
	@override String get forced_title => 'Atualização necessária';
	@override String get forced_description => 'Esta versão não é mais suportada. Atualize para continuar usando o app.';
	@override String get update_button => 'Atualizar agora';
	@override String get later_button => 'Agora não';
}

// Path: request_notification_permission
class _TranslationsRequestNotificationPermissionPt extends TranslationsRequestNotificationPermissionEn {
	_TranslationsRequestNotificationPermissionPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Ativar notificações?';
	@override String get description => 'Receba atualizações em tempo real e fique sempre por dentro do que importa.';
	@override String get continue_button => 'Ativar';
	@override String get skip_button => 'Agora não';
}

// Path: notification_permission_denied
class _TranslationsNotificationPermissionDeniedPt extends TranslationsNotificationPermissionDeniedEn {
	_TranslationsNotificationPermissionDeniedPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Permissão necessária';
	@override String get description => 'Para receber notificações, ative as permissões de notificação nas configurações do dispositivo.';
	@override String get allow_button => 'Permitir notificações';
	@override String get open_settings_button => 'Abrir configurações';
	@override String get cancel_button => 'Cancelar';
}

// Path: review_popup
class _TranslationsReviewPopupPt extends TranslationsReviewPopupEn {
	_TranslationsReviewPopupPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get question_title => 'Está gostando do app?';
	@override String get question_description => 'Sua resposta ajuda a gente a melhorar.';
	@override String get question_positive => 'Sim, estou gostando';
	@override String get question_negative => 'Poderia melhorar';
	@override String get title => 'Que bom que curtiu!';
	@override String get description => 'Uma avaliação na loja faz toda a diferença. Leva poucos segundos e ajuda demais a gente a crescer.';
	@override String get rate_button => 'Escrever uma avaliação';
}

// Path: navigation
class _TranslationsNavigationPt extends TranslationsNavigationEn {
	_TranslationsNavigationPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get home => 'Início';
	@override String get support => 'Ajuda';
	@override String get notifications => 'Notificações';
	@override String get settings => 'Config.';
	@override String get logout => 'Sair';
	@override String get skip_to_content => 'Pular para o conteúdo';
}

// Path: reminderPage
class _TranslationsReminderPagePt extends TranslationsReminderPageEn {
	_TranslationsReminderPagePt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Lembretes';
	@override String get toggleLabel => 'Ativar lembrete';
	@override String get typeLabel => 'Repetir';
	@override String get daily => 'Todo dia';
	@override String get weekly => 'Toda semana';
	@override String get specificDate => 'Uma vez';
	@override String get timeLabel => 'Horário';
	@override String get dayLabel => 'Dia da semana';
	@override String get dateLabel => 'Data';
	@override String get selectDate => 'Selecionar data';
	@override String get hint => 'Receba um lembrete para voltar ao app';
	@override String summaryDaily({required Object time}) => 'Todo dia às ${time}';
	@override String summaryWeekly({required Object day, required Object time}) => 'Toda semana, ${day} às ${time}';
	@override String summaryDate({required Object date, required Object time}) => 'Em ${date} às ${time}';
}

// Path: time_picker
class _TranslationsTimePickerPt extends TranslationsTimePickerEn {
	_TranslationsTimePickerPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Selecione o horário';
	@override String get placeholder => 'Selecione um horário';
	@override String get hour => 'Hora';
	@override String get minute => 'Minuto';
	@override String get am => 'AM';
	@override String get pm => 'PM';
	@override String get confirm => 'OK';
	@override String get cancel => 'Cancelar';
}

// Path: dailyReminder
class _TranslationsDailyReminderPt extends TranslationsDailyReminderEn {
	_TranslationsDailyReminderPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Lembrete';
	@override String get body => 'Está na hora de beber água.';
}

// Path: settings
class _TranslationsSettingsPt extends TranslationsSettingsEn {
	_TranslationsSettingsPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Configurações';
	@override late final _TranslationsSettingsAvatarPt avatar = _TranslationsSettingsAvatarPt._(_root);
	@override String get language_title => 'Idiomas';
	@override String get theme_title => 'Tema';
	@override String get theme_option_system => 'Sistema';
	@override String get theme_option_light => 'Claro';
	@override String get theme_option_dark => 'Escuro';
	@override String get haptic_feedback_title => 'Feedback háptico';
	@override String get hide_chrome_on_scroll_title => 'Ocultar barras ao rolar';
	@override String get section_preferences_label => 'PREFERÊNCIAS';
	@override String get section_security_label => 'SEGURANÇA';
	@override String get section_support_label => 'AJUDA';
	@override String get biometric_title => 'Bloqueio do app';
	@override String get biometric_subtitle_ios => 'Exige Face ID ou Touch ID ao abrir com sessão ativa.';
	@override String get biometric_subtitle_ios_face => 'Exige Face ID ao abrir com sessão ativa.';
	@override String get biometric_subtitle_ios_touch => 'Exige Touch ID ao abrir com sessão ativa.';
	@override String get biometric_subtitle_android => 'Pedimos uma confirmação no celular sempre que você abrir com sessão ativa.';
	@override String get biometric_subtitle_android_face => 'Exige desbloqueio facial ao abrir com sessão ativa.';
	@override String get biometric_subtitle_android_fingerprint => 'Exige impressão digital ao abrir com sessão ativa.';
	@override String get biometric_subtitle_android_face_and_fingerprint => 'Exige impressão digital ou desbloqueio facial ao abrir com sessão ativa.';
	@override String get biometric_disable_title => 'Desligar bloqueio?';
	@override String get biometric_disable_message => 'Sem bloqueio, quem pegar no celular desbloqueado abre o app até você sair da conta.';
	@override String get biometric_disable_confirm => 'Desligar';
	@override String get biometric_disable_cancel => 'Cancelar';
	@override String get biometric_enable_reason_ios => 'Confirme com Face ID ou Touch ID para ativar o bloqueio';
	@override String get biometric_enable_reason_ios_face => 'Confirme com Face ID para ativar o bloqueio';
	@override String get biometric_enable_reason_ios_touch => 'Confirme com Touch ID para ativar o bloqueio';
	@override String get biometric_enable_reason_android => 'Confirme no celular para ativar o bloqueio';
	@override String get biometric_enable_reason_android_face => 'Confirme com desbloqueio facial para ativar o bloqueio';
	@override String get biometric_enable_reason_android_fingerprint => 'Confirme com impressão digital para ativar o bloqueio';
	@override String get biometric_enable_reason_android_face_and_fingerprint => 'Confirme com digital ou rosto para ativar o bloqueio';
	@override String get biometric_login_reason_ios => 'Desbloqueie com Face ID ou Touch ID';
	@override String get biometric_login_reason_ios_face => 'Desbloqueie com Face ID';
	@override String get biometric_login_reason_ios_touch => 'Desbloqueie com Touch ID';
	@override String get biometric_login_reason_android => 'Confirme sua identidade';
	@override String get biometric_login_reason_android_face => 'Desbloqueie com desbloqueio facial';
	@override String get biometric_login_reason_android_fingerprint => 'Desbloqueie com impressão digital';
	@override String get biometric_login_reason_android_face_and_fingerprint => 'Desbloqueie com digital ou rosto';
	@override String get biometric_unavailable_message_ios => 'Ative Face ID, Touch ID ou código em Ajustes.';
	@override String get biometric_unavailable_message_ios_face => 'Ative Face ID ou código do aparelho em Ajustes.';
	@override String get biometric_unavailable_message_ios_touch => 'Ative Touch ID ou código do aparelho em Ajustes.';
	@override String get biometric_unavailable_message_android => 'Ative biometria ou um bloqueio de tela nas definições do telefone.';
	@override String get biometric_unavailable_message_android_face => 'Cadastre rosto ou bloqueio de tela nos ajustes.';
	@override String get biometric_unavailable_message_android_fingerprint => 'Cadastre impressão digital ou bloqueio de tela nos ajustes.';
	@override String get biometric_unavailable_message_android_face_and_fingerprint => 'Cadastre impressão digital ou rosto nas definições do telefone.';
	@override String get biometric_not_enabled_message => 'Bloqueio do app não foi ativado.';
	@override String get feedback => 'Enviar feedback';
	@override String get premium => 'Premium';
	@override String get billing => 'Cobrança';
	@override String get privacy => 'Política de privacidade';
	@override String get support => 'Central de ajuda';
	@override String get disconnect => 'Sim, sair';
	@override String get disconnect_confirm_title => 'Sair da conta?';
	@override String get disconnect_confirm_message => 'Tem certeza que deseja sair?';
	@override String get disconnect_cancel => 'Cancelar';
	@override String get logout => 'Sair';
	@override String get my_account => 'Minha conta';
	@override String get not_signed_in => 'Não conectado';
	@override String get register => 'Cadastrar';
	@override String get name_label => 'Nome';
	@override String get edit => 'Editar';
	@override String get email_label => 'Email';
	@override String get connected_with_label => 'Conectado com';
	@override String get provider_email => 'E-mail e senha';
	@override String get provider_phone => 'Telefone';
	@override String get create_password_title => 'Criar senha';
	@override String get create_password_subtitle => 'Defina uma senha para também entrar com e-mail e senha, além do login social.';
	@override String get create_password_field => 'Nova senha';
	@override String get create_password_confirm_label => 'Confirmar senha';
	@override String get create_password_success => 'Senha criada';
	@override String get create_password_error => 'Não foi possível criar a senha. Tente novamente.';
	@override String get create_password_too_short => 'A senha deve ter pelo menos 6 caracteres';
	@override String get create_password_mismatch => 'As senhas não coincidem';
	@override String link_social({required Object provider}) => 'Vincular ${provider}';
	@override String link_social_success({required Object provider}) => '${provider} vinculado';
	@override String get link_social_error => 'Não foi possível vincular. Tente novamente.';
	@override String get edit_name_title => 'Editar nome';
	@override String get edit_name_hint => 'Seu nome';
	@override String get edit_name_save => 'Salvar';
	@override String get edit_name_cancel => 'Cancelar';
	@override String get edit_name_success => 'Nome atualizado';
	@override String get edit_name_error => 'Não foi possível atualizar seu nome. Tente novamente.';
	@override String get reminders => 'Lembretes';
	@override String get admin_panel => 'Painel Admin';
	@override String get admin_debug_section_label => 'ADMIN (SÓ EM DEBUG)';
	@override String get admin_panel_debug_notice => 'Toda esta seção Admin (título, painel e opções) só existe em build de debug. Em release esse bloco não é incluído; quem instala pela loja ou por APK de produção não vê nada disso.';
	@override late final _TranslationsSettingsDeleteAccountPt delete_account = _TranslationsSettingsDeleteAccountPt._(_root);
	@override late final _TranslationsSettingsAdminPt admin = _TranslationsSettingsAdminPt._(_root);
}

// Path: rate_banner
class _TranslationsRateBannerPt extends TranslationsRateBannerEn {
	_TranslationsRateBannerPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Você gostou do nosso app?';
	@override String get text => 'Você teria um minuto para nos avaliar na loja?';
	@override String get rate_button => 'Sim, claro!';
	@override String get later_button => 'Mais tarde...';
}

// Path: notifications
class _TranslationsNotificationsPt extends TranslationsNotificationsEn {
	_TranslationsNotificationsPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Notificações';
	@override String get empty_title => 'Nenhuma notificação ainda';
	@override String get empty_subtitle => 'Fique ligado nas atualizações';
	@override String get error_fetching => 'Erro ao buscar notificações';
	@override String get push_title => 'Notificações push';
	@override String get push_subtitle_enabled => 'Você está recebendo alertas';
	@override String get push_subtitle_disabled => 'Toque para ativar nas configurações';
	@override String get push_subtitle_waiting => 'Ative para não perder novidades';
	@override String get mark_all_read => 'Marcar lidas';
	@override String get see_all => 'Ver todas';
	@override String get group_today => 'Hoje';
	@override String get group_yesterday => 'Ontem';
	@override String get group_older => 'Mais antigas';
	@override String get empty_cta => 'Ativar notificações';
	@override String get empty_cta_open_settings => 'Abrir configurações';
	@override String get delete_all => 'Excluir tudo';
	@override String get options => 'Opções';
	@override String get delete_all_confirm_title => 'Excluir todas as notificações?';
	@override String get delete_all_confirm_message => 'Isso vai remover todas as notificações da sua conta. Essa ação não pode ser desfeita.';
	@override String get delete_action => 'Sim, excluir';
	@override String get cancel_action => 'Cancelar';
	@override String get deleted_one => 'Notificação excluída';
	@override String get deleted_all => 'Todas as notificações foram excluídas';
}

// Path: bottom_router
class _TranslationsBottomRouterPt extends TranslationsBottomRouterEn {
	_TranslationsBottomRouterPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get fake_page_text => 'Esta é uma página de exemplo';
}

// Path: ai_chat
class _TranslationsAiChatPt extends TranslationsAiChatEn {
	_TranslationsAiChatPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Assistente IA';
	@override String get empty_state => 'Inicie uma conversa com seu assistente.';
	@override String get hint => 'Pergunte algo...';
	@override String get error_not_configured => 'O assistente ainda não está disponível. Tente novamente mais tarde.';
	@override String get error_no_reply => 'Não conseguimos obter uma resposta. Tente de novo.';
	@override String get error_network => 'Não foi possível conectar ao assistente de IA.';
	@override String get new_conversation => 'Nova conversa';
	@override String get conversations_empty => 'Nenhuma conversa ainda';
	@override String get conversations_empty_hint => 'Toque em Nova conversa para começar.';
	@override String get no_conversation_selected => 'Escolha uma conversa ou comece uma nova.';
	@override String get delete_title => 'Excluir conversa?';
	@override String get delete_message => 'Esta conversa e todas as mensagens serão excluídas permanentemente.';
	@override String get delete_cancel => 'Cancelar';
	@override String get delete_confirm => 'Sim, excluir';
}

// Path: phone_auth
class _TranslationsPhoneAuthPt extends TranslationsPhoneAuthEn {
	_TranslationsPhoneAuthPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get title_input => 'Autenticação por Telefone';
	@override String get subtitle_input => 'Digite seu número de telefone';
	@override String get description_input => 'Enviaremos um código de verificação para confirmar sua identidade';
	@override String get phone_label => 'Número de telefone';
	@override String get phone_hint => '+55 (11) 91234-5678';
	@override String get error_empty => 'Por favor, digite um número de telefone';
	@override String get error_invalid => 'Por favor, digite um número válido';
	@override String get continue_btn => 'Continuar';
	@override String get title_verify => 'Verificar Código';
	@override String get verification_code => 'Código de Verificação';
	@override String code_sent({required Object phone}) => 'Enviamos um código de verificação para ${phone}';
	@override String get signin_success_title => 'Tudo certo';
	@override String get signin_success_text => 'Você entrou com seu número de telefone';
	@override String get verify_code => 'Verificar Código';
	@override String get resend_code => 'Reenviar Código';
	@override String get enter_all_digits => 'Por favor, digite todos os 6 números';
}

// Path: recover_password_result
class _TranslationsRecoverPasswordResultPt extends TranslationsRecoverPasswordResultEn {
	_TranslationsRecoverPasswordResultPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get title => 'E-mail enviado';
	@override String get description => 'Enviamos um e-mail com um link para redefinir sua senha';
	@override String get back_to_signin => 'Voltar para o Login';
	@override String get note => 'Nota: Se você não receber um e-mail, verifique sua pasta de spam';
}

// Path: page_not_found
class _TranslationsPageNotFoundPt extends TranslationsPageNotFoundEn {
	_TranslationsPageNotFoundPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get title => '404 - Página não encontrada';
}

// Path: devInspector
class _TranslationsDevInspectorPt extends TranslationsDevInspectorEn {
	_TranslationsDevInspectorPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get copied => 'Contexto copiado. Cole no chat da IA.';
	@override String get activate => 'Ativar inspetor de widgets';
	@override String get deactivate => 'Desativar inspetor de widgets';
	@override String get copyForAi => 'Copiar para IA';
	@override String get selectWidgetFirst => 'Selecione um widget na tela primeiro.';
	@override String get inspectorHint => 'Toque em um widget para selecionar. O contexto copia automaticamente. Tecla C para copiar de novo.';
	@override String get statusActive => 'Inspecionando';
}

// Path: webDevicePreview
class _TranslationsWebDevicePreviewPt extends TranslationsWebDevicePreviewEn {
	_TranslationsWebDevicePreviewPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get frame => 'Frame';
	@override String get darkBackground => 'Fundo escuro';
	@override String get darkTheme => 'Tema escuro';
	@override String get landscape => 'Paisagem';
	@override String get textScale => 'Escala de texto';
	@override String get screenshot => 'Screenshot';
	@override String get imageCopied => 'Imagem copiada — cole no chat';
	@override String get imageDownloaded => 'Imagem baixada';
	@override String get hotReload => 'Hot reload';
	@override String get hotRestart => 'Hot restart';
	@override String get hotReloading => 'Recarregando…';
	@override String get hotRestarting => 'Reiniciando…';
	@override String get hotReloadDone => 'Reload concluído';
	@override String get hotRestartDone => 'Restart concluído';
	@override String get hotReloadFailed => 'Falha no reload';
	@override String get hotReloadNeedsRestart => 'Essa mudança precisa de restart — use o botão R';
	@override String get hotReloadCompileError => 'Erro no código — corrija no editor e recarregue';
	@override String get hotRestartFailed => 'Falha no restart';
	@override String get hotRestartCompileError => 'Erro no código — corrija no editor e reinicie';
	@override String get terminalStatusOk => 'Terminal ok — pode usar o r';
	@override String get terminalStatusError => 'Terminal com erro — corrija ou use o R';
	@override String get terminalStatusOffline => 'Ponte do terminal offline — use kasy run --web';
	@override String get devBridgeUnavailable => 'Servidor dev offline — rode kasy run --web, deixe o terminal aberto e abra a URL que aparecer';
}

// Path: biometric_prompt
class _TranslationsBiometricPromptPt extends TranslationsBiometricPromptEn {
	_TranslationsBiometricPromptPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get title_ios_face => 'Ativar Face ID no bloqueio do app?';
	@override String get title_ios_touch => 'Ativar Touch ID no bloqueio do app?';
	@override String get title_ios_mixed => 'Ativar Face ID ou Touch ID no bloqueio?';
	@override String get title_android_face => 'Ativar bloqueio com desbloqueio facial?';
	@override String get title_android_fingerprint => 'Ativar bloqueio com impressão digital?';
	@override String get title_android_mixed => 'Proteger o app com biometria?';
	@override String get message_ios_face => 'Ao abrir, você confirma com Face ID — continua na conta.';
	@override String get message_ios_touch => 'Ao abrir, você confirma com Touch ID — continua na conta.';
	@override String get message_ios_mixed => 'Ao abrir, usa Face ID ou Touch ID — continua na conta.';
	@override String get message_android_face => 'Ao abrir, confirme com reconhecimento facial — continua na conta.';
	@override String get message_android_fingerprint => 'Ao abrir, confirme com impressão digital — continua na conta.';
	@override String get title_android_face_and_fingerprint => 'Ativar bloqueio com digital ou rosto?';
	@override String get message_android_face_and_fingerprint => 'Qualquer um serve — continua na conta.';
	@override String get message_android_mixed => 'Confirmação rápida ao abrir — continua na conta.';
	@override String get not_now => 'Agora não';
	@override String get enable => 'Ativar';
}

// Path: home_widget
class _TranslationsHomeWidgetPt extends TranslationsHomeWidgetEn {
	_TranslationsHomeWidgetPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get greeting_morning => 'Bom dia';
	@override String get greeting_afternoon => 'Boa tarde';
	@override String get greeting_evening => 'Boa noite';
	@override String title_with_name({required Object name}) => 'Olá, ${name}!';
	@override String get title_default => 'Olá!';
	@override String get title_logged_out => 'Aguardamos seu retorno';
	@override String get plan_free => 'Plano grátis';
	@override String get plan_pro => 'PRO';
	@override String get quote => 'Seu tempo é limitado.\nNão viva a vida de outra pessoa.\nTenha coragem de seguir sua intuição.\nTodo o resto é secundário.';
	@override String get quote_author => 'Steve Jobs';
}

// Path: kanban
class _TranslationsKanbanPt extends TranslationsKanbanEn {
	_TranslationsKanbanPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Tarefas';
	@override String get empty_title => 'Organize suas tarefas';
	@override String get empty_description => 'Crie colunas personalizadas e comece a organizar o que precisa ser feito no seu projeto.';
	@override String get empty_column => 'Nenhuma tarefa nesta coluna';
	@override String get error_title => 'Erro ao carregar';
	@override String get add_column => 'Adicionar coluna';
	@override String get add_column_subtitle => 'Escolha um nome curto para organizar suas tarefas nesta coluna.';
	@override String get add_another_list => 'Adicionar outra lista';
	@override String get add_list => 'Adicionar Lista';
	@override String get list_name_hint => 'Digite o nome da lista...';
	@override String get add_task => 'Adicionar tarefa';
	@override String get add_task_subtitle => 'Defina o titulo e, se quiser, uma descricao e a prioridade.';
	@override String get edit_column => 'Editar coluna';
	@override String get edit_task_subtitle => 'Atualize os detalhes desta tarefa.';
	@override String get cancel => 'Cancelar';
	@override String get save => 'Salvar';
	@override String get delete_column => 'Excluir coluna';
	@override String get edit_task => 'Editar tarefa';
	@override String get delete_task => 'Excluir tarefa';
	@override String get column_name => 'Nome da coluna';
	@override String get column_name_hint => 'Ex: Em andamento, Concluído';
	@override String get task_title => 'Título da tarefa';
	@override String get task_title_hint => 'Ex: Implementar login';
	@override String get task_title_required => 'Informe um título para a tarefa.';
	@override String get column_name_required => 'Informe um nome para a coluna.';
	@override String get task_description => 'Descrição';
	@override String get task_description_hint => 'Detalhes sobre a tarefa';
	@override String get create => 'Criar';
	@override String get mark_complete => 'Marcar como concluída';
	@override String get mark_incomplete => 'Marcar como pendente';
	@override String get column_created => 'Coluna criada';
	@override String get column_updated => 'Coluna atualizada';
	@override String get column_deleted => 'Coluna excluída';
	@override String get task_created => 'Tarefa criada';
	@override String get task_updated => 'Tarefa atualizada';
	@override String get task_deleted => 'Tarefa excluída';
	@override String get priority => 'Prioridade';
	@override String get priority_none => 'Nenhuma';
	@override String get priority_low => 'Baixa';
	@override String get priority_medium => 'Media';
	@override String get priority_high => 'Alta';
	@override String get priority_urgent => 'Urgente';
	@override String cards_count({required Object count}) => '${count} cards';
	@override String get move_to => 'Mover para coluna';
	@override String get move_left => 'Mover para esquerda';
	@override String get move_right => 'Mover para direita';
	@override String get delete_column_confirm => 'Isso excluira permanentemente todos os cards desta coluna.';
	@override String get delete_task_confirm => 'Esta tarefa sera excluida permanentemente.';
	@override String created_on({required Object date}) => 'Criado em ${date}';
}

// Path: library
class _TranslationsLibraryPt extends TranslationsLibraryEn {
	_TranslationsLibraryPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Biblioteca';
	@override String get categories => 'Categorias';
	@override String get manage_categories => 'Gerenciar Categorias';
	@override String get add_category => 'Adicionar Categoria';
	@override String get edit_category => 'Editar Categoria';
	@override String get delete_category => 'Excluir Categoria';
	@override String get category_name => 'Nome da Categoria';
	@override String get category_desc => 'Descrição da Categoria';
	@override String get save => 'Salvar';
	@override String get cancel => 'Cancelar';
	@override String get pdfs => 'PDFs';
	@override String get favorites => 'Favoritos';
	@override String get search_hint => 'Buscar por título, autor ou tag...';
	@override String get add_pdf => 'Cadastrar PDF';
	@override String get edit_pdf => 'Editar PDF';
	@override String get delete_pdf => 'Excluir PDF';
	@override String get pdf_title => 'Título';
	@override String get pdf_desc => 'Descrição';
	@override String get pdf_author => 'Autor';
	@override String get pdf_url => 'URL do arquivo PDF';
	@override String get pdf_thumb => 'URL da miniatura (capa)';
	@override String get pdf_tags => 'Tags (separadas por vírgula)';
	@override String get no_pdfs => 'Nenhum PDF encontrado';
	@override String get comments => 'Comentários';
	@override String get write_comment => 'Escreva um comentário...';
	@override String get submit_comment => 'Enviar Comentário';
	@override String get rating => 'Avaliação';
	@override String get download => 'Baixar';
	@override String get read => 'Ler';
	@override String get unauthorized => 'Você precisa ser administrador para ver esta página.';
	@override String get profile_switcher => 'Trocar Perfil';
	@override String get active_profile => 'Perfil Ativo';
	@override String get admin_dev => 'Admin / Dev';
	@override String get client => 'Cliente';
	@override String get read_sim => 'Leitor Simulado';
	@override String get prev_page => 'Anterior';
	@override String get next_page => 'Próxima';
	@override String get zoom_in => 'Mais Zoom';
	@override String get zoom_out => 'Menos Zoom';
	@override String page_info({required Object page, required Object total}) => 'Página ${page} de ${total}';
	@override String get no_comments => 'Nenhum comentário ainda. Seja o primeiro a comentar!';
	@override String get my_pdfs => 'Meus PDFs';
	@override String get send_pdf => 'Enviar PDF';
	@override String get no_client_pdfs => 'Nenhum PDF enviado por clientes ainda.';
	@override String get upload_box_title => 'Clique para fazer upload do seu PDF';
	@override String get upload_box_subtitle => 'Formato suportado: PDF (Máx. 10MB)';
	@override String get pdf_preview => 'Pré-visualização do PDF';
	@override String get pages => 'Páginas';
	@override String get change_file => 'Alterar Arquivo';
	@override String get explore => 'Explorar';
	@override String get visit_profile => 'Visitar perfil';
	@override String get no_public_pdfs => 'Nenhum PDF público enviado por outros usuários ainda.';
	@override String get uploaded_by => 'Enviado por';
	@override String get sent_by => 'Enviado por';
	@override String get public_profile => 'Perfil Público';
	@override String get view_all_pdfs => 'Ver todos os PDFs enviados por este usuário';
}

// Path: admin_console.tabs
class _TranslationsAdminConsoleTabsPt extends TranslationsAdminConsoleTabsEn {
	_TranslationsAdminConsoleTabsPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get overview => 'Visão geral';
	@override String get users => 'Usuários';
	@override String get requests => 'Solicitações';
	@override String get tools => 'Ferramentas';
	@override String get debug => 'Depuração';
}

// Path: admin_console.overview
class _TranslationsAdminConsoleOverviewPt extends TranslationsAdminConsoleOverviewEn {
	_TranslationsAdminConsoleOverviewPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get section => 'Projeto';
	@override String get summary => 'Resumo';
	@override String get backend => 'Backend';
	@override String get account => 'Conta';
	@override String get guest => 'Visitante';
	@override String get user_id => 'ID do usuário';
	@override String get build => 'Versão';
	@override String get session_title => 'Sessão atual';
	@override String get requests_metric => 'Solicitações de recurso';
	@override String get total_users => 'Total de usuários';
	@override String get subscribers => 'Assinantes';
	@override String get new_7d => 'Novos (7 dias)';
	@override String get signups_title => 'Novos cadastros';
	@override String get signups_subtitle => 'Últimos 14 dias';
	@override String signups_total({required Object count}) => '${count} em 14 dias';
	@override String get signups_empty => 'Nenhum cadastro neste período.';
	@override String get plan_split_title => 'Distribuição de planos';
	@override String get free => 'Grátis';
	@override String get subscriber => 'Assinante';
	@override String conversion({required Object percent}) => '${percent} assinam';
	@override String loaded_note({required Object count}) => 'Com base nos ${count} usuários mais recentes.';
	@override String get users_hint => 'Abra a aba Usuários para gerenciar todas as contas.';
	@override String get debug_note => 'Console de debug — visível só em builds de desenvolvimento.';
}

// Path: admin_console.users
class _TranslationsAdminConsoleUsersPt extends TranslationsAdminConsoleUsersEn {
	_TranslationsAdminConsoleUsersPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Usuários';
	@override String get search_hint => 'Buscar por nome ou e-mail';
	@override String get col_user => 'Usuário';
	@override String get col_status => 'Status';
	@override String get col_plan => 'Plano';
	@override String get col_joined => 'Cadastro';
	@override String get status_active => 'Ativo';
	@override String get status_inactive => 'Inativo';
	@override String get plan_subscriber => 'Assinante';
	@override String get plan_free => 'Grátis';
	@override String get empty => 'Nenhum usuário encontrado';
	@override String get empty_hint => 'Quando alguém criar uma conta, ela aparece aqui.';
	@override String get error => 'Não foi possível carregar os usuários. Confirme que você é admin.';
	@override String page({required Object page, required Object total}) => 'Página ${page} de ${total}';
	@override String get prev => 'Anterior';
	@override String get next => 'Próxima';
	@override String get anonymous => 'Anônimo';
	@override String get filter_all => 'Todos os usuários';
	@override String get filter_subscribers => 'Assinantes';
	@override String get loading => 'Carregando usuários…';
	@override String results({required Object from, required Object to, required Object total}) => 'Mostrando ${from} a ${to} de ${total}';
	@override String truncated({required Object count}) => 'Mostrando os ${count} mais recentes. A busca cobre só os carregados.';
	@override String get search_capped => 'A busca varreu um conjunto limitado. Podem faltar correspondências.';
	@override String get empty_search => 'Nenhum usuário corresponde à busca';
	@override String get empty_search_hint => 'Tente outro nome ou e-mail.';
	@override String get empty_subscribers => 'Nenhum assinante encontrado';
	@override String get empty_subscribers_hint => 'Quem assinar o plano premium aparece neste filtro.';
	@override String get refresh => 'Atualizar';
	@override String get retry => 'Tentar de novo';
}

// Path: admin_console.requests
class _TranslationsAdminConsoleRequestsPt extends TranslationsAdminConsoleRequestsEn {
	_TranslationsAdminConsoleRequestsPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Solicitações de recurso';
	@override String get subtitle => 'Pedidos e sugestões enviados pelos seus usuários. Marque como visível para aparecer no app, ou oculte os que não fizerem sentido.';
	@override String get empty => 'Ainda não há solicitações';
	@override String get empty_hint => 'Quando um usuário enviar uma ideia, ela aparece aqui.';
	@override String votes({required Object count}) => '${count} votos';
	@override String get visible => 'Visível';
	@override String get hidden => 'Oculto';
	@override String get edit => 'Editar';
	@override String get error => 'Não foi possível carregar as solicitações';
	@override String get saved => 'Solicitação atualizada';
	@override String get editor_title => 'Editar solicitação';
	@override String get field_title => 'Título';
	@override String get field_description => 'Descrição';
	@override String get lang_en => 'Inglês';
	@override String get lang_pt => 'Português';
	@override String get lang_es => 'Espanhol';
	@override String get visibility => 'Visível para os usuários';
	@override String get save => 'Salvar';
	@override String get cancel => 'Cancelar';
}

// Path: admin_console.groups
class _TranslationsAdminConsoleGroupsPt extends TranslationsAdminConsoleGroupsEn {
	_TranslationsAdminConsoleGroupsPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get actions => 'Ações';
	@override String get features => 'Recursos';
	@override String get preview => 'Preview';
	@override String get debug_actions => 'Ações de debug';
	@override String get identity => 'Identidade';
	@override String get notification_test => 'Teste de notificação';
}

// Path: admin_console.paywalls
class _TranslationsAdminConsolePaywallsPt extends TranslationsAdminConsolePaywallsEn {
	_TranslationsAdminConsolePaywallsPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get subtitle => 'Toque num paywall para visualizar. Copie o código dele para dizer ao assistente qual usar.';
	@override String get copy_code => 'Copiar código';
	@override String get code_copied => 'Código copiado para a área de transferência';
	@override String get solo_title => 'Solo';
	@override String get solo_desc => 'Um plano só, com benefícios e um CTA. Ideal para apps de uma faixa.';
	@override String get compare_title => 'Compare';
	@override String get compare_desc => 'Mensal vs anual lado a lado, com tabela free vs premium.';
	@override String get trial_title => 'Trial';
	@override String get trial_desc => 'Toggle de teste grátis, em geral no anual. Mensal cobra na hora.';
	@override String get unlock_title => 'Unlock';
	@override String get unlock_desc => 'Paywall de conversão para onboarding ou bloqueio forte.';
}

// Path: admin_console.settings_entry
class _TranslationsAdminConsoleSettingsEntryPt extends TranslationsAdminConsoleSettingsEntryEn {
	_TranslationsAdminConsoleSettingsEntryPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Admin';
	@override String get caption => 'Visível só para administradores e em modo de desenvolvimento.';
}

// Path: home.cards
class _TranslationsHomeCardsPt extends TranslationsHomeCardsEn {
	_TranslationsHomeCardsPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get paywall_title => 'Paywall';
	@override String get paywall_description => 'Ver a página de assinatura';
	@override String get notification_title => 'Teste de notificação local';
	@override String get notification_description => 'Dispara um alerta só neste aparelho. Não entra na aba Notificações (push).';
	@override String get feedback_title => 'Feedback';
	@override String get feedback_description => 'Página de solicitação de recursos ou votação';
	@override String get signup_title => 'Cadastro';
	@override String get signup_description => 'Usuário anônimo pode se cadastrar com e-mail ou rede social';
	@override String get assistant_title => 'Assistente IA';
	@override String get assistant_description => 'Conversar com o assistente de IA';
}

// Path: home.features_page
class _TranslationsHomeFeaturesPagePt extends TranslationsHomeFeaturesPageEn {
	_TranslationsHomeFeaturesPagePt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Recursos do kit';
	@override String get assistant_title => 'Converse com a IA';
	@override String get assistant_description => 'Chat pronto para perguntas, ideias e suporte dentro do app';
	@override String get feedback_title => 'Vote e sugira';
	@override String get feedback_description => 'Participe do roadmap: vote em ideias ou envie a sua';
	@override String get notification_title => 'Testar notificação';
	@override String get notification_description => 'Dispara um alerta só neste aparelho (não é push)';
	@override String get notification_demo_title => 'Alerta de teste';
	@override String get notification_demo_body => 'Notificação local do demo do kit';
	@override String get send_push_title => 'Enviar notificação push';
	@override String get send_push_description => 'Dispare uma push para usuários específicos ou para todos';
	@override String get paywall_title => 'Planos e assinatura';
	@override String get paywall_description => 'Telas de paywall, trial e fluxo RevenueCat';
}

// Path: home.dashboard
class _TranslationsHomeDashboardPt extends TranslationsHomeDashboardEn {
	_TranslationsHomeDashboardPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get brand => 'kasy';
	@override String get components_title => 'Componentes';
	@override String get components_subtitle => 'Explore tokens de design e blocos de interface';
	@override String get features_title => 'Features';
	@override String get features_subtitle => 'IA, feedback, alertas e assinatura';
	@override String count_total({required Object count}) => '${count} no total';
	@override String get search_hint => 'Buscar componentes';
	@override String get search_empty => 'Nenhum componente encontrado';
	@override String get in_production => 'Em produção';
	@override String get needs_review => 'Revisar';
}

// Path: home.components_preview
class _TranslationsHomeComponentsPreviewPt extends TranslationsHomeComponentsPreviewEn {
	_TranslationsHomeComponentsPreviewPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get nav_title => 'Componentes';
	@override String get pro_badge => 'PRO';
}

// Path: auth.signin
class _TranslationsAuthSigninPt extends TranslationsAuthSigninEn {
	_TranslationsAuthSigninPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Bem-vindo de volta';
	@override String get subtitle => 'Entre para continuar sua experiência';
	@override String get email_hint => 'bruce@wayne.com';
	@override String get email_label => 'E-mail';
	@override String get password_hint => 'Senha';
	@override String get password_label => 'Senha';
	@override String get forgot_password => 'Esqueceu sua senha?';
	@override String get submit => 'Continuar com e-mail';
	@override String get create_account => 'Criar minha conta';
	@override String get no_account => 'Não tem uma conta?';
	@override String get signup_link => 'Cadastre-se';
	@override String get continue_without => 'Continuar sem conta';
	@override String get or_sign_in_with => 'ou';
	@override String get google => 'Gmail';
	@override String get apple => 'Apple';
	@override String get facebook => 'Facebook';
	@override String get error_title => 'Erro';
	@override String get error_text => 'E-mail, senha incorretos ou este e-mail não está cadastrado';
	@override String get email_invalid => 'E-mail inválido';
	@override String get password_required => 'Informe uma senha';
	@override String get password_too_short => 'Sua senha deve ter pelo menos 5 caracteres';
	@override String social_error({required Object provider}) => 'Não foi possível entrar com ${provider}';
	@override String get email_already_registered => 'Esse e-mail já tem conta com outro método de login. Entre com o método que você usou antes.';
}

// Path: auth.signup
class _TranslationsAuthSignupPt extends TranslationsAuthSignupEn {
	_TranslationsAuthSignupPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Cadastre-se agora';
	@override String get subtitle => 'Crie sua conta para começar';
	@override String get submit => 'Criar minha conta';
	@override String get have_account => 'Já tem uma conta?';
	@override String get signin_link => 'Entrar';
	@override String get already_have_account => 'Já tenho uma conta';
	@override String get error_title => 'Erro';
	@override String get error_text => 'Este e-mail já existe ou é inválido';
}

// Path: auth.recover
class _TranslationsAuthRecoverPt extends TranslationsAuthRecoverEn {
	_TranslationsAuthRecoverPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Recuperar senha';
	@override String get subtitle => 'Enviaremos um link para redefinir sua senha';
	@override String get email_label => 'E-mail';
	@override String get submit => 'Recuperar senha';
	@override String get remember => 'Lembrou sua senha?';
	@override String get signin_link => 'Entrar';
	@override String get error_title => 'Erro';
	@override String get error_text => 'Informe um e-mail válido';
}

// Path: premium.solo
class _TranslationsPremiumSoloPt extends TranslationsPremiumSoloEn {
	_TranslationsPremiumSoloPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get back => 'Voltar';
	@override String get headline_1 => 'Upgrade para uma';
	@override String get headline_2 => 'experiência sem anúncios';
	@override String get feature_1 => 'Sem anúncios';
	@override String get feature_2 => 'Modo offline';
	@override String get feature_3 => 'Pulos ilimitados';
	@override String get feature_4 => 'Áudio em alta qualidade';
	@override String get subscribe => 'Assinar agora';
}

// Path: premium.comparePlan
class _TranslationsPremiumComparePlanPt extends TranslationsPremiumComparePlanEn {
	_TranslationsPremiumComparePlanPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get back => 'Voltar';
	@override String get headline_1 => 'Escolha seu plano';
	@override String get headline_2 => 'ideal para você';
	@override String get headline_description => 'Compare Grátis e Premium e escolha a cobrança mensal ou anual que combina com você.';
	@override String get feature_1_title => 'Acesso premium completo';
	@override String get feature_1_subtitle => 'Todos os recursos em todos os dispositivos';
	@override String get feature_2_title => 'Sem anúncios';
	@override String get feature_2_subtitle => 'Foco total, sem interrupções';
	@override String get feature_3_title => 'Sync na nuvem';
	@override String get feature_3_subtitle => 'Continue de onde parou';
	@override String get feature_4_title => 'Suporte prioritário';
	@override String get feature_4_subtitle => 'Ajuda quando você precisar';
	@override String get continue_cta => 'Continuar';
	@override String best_offer_badge({required Object percent}) => 'Economize ${percent}%';
	@override String per_month_line({required Object price}) => '${price} cobrado por ano';
	@override String get billed_monthly => 'Cobrança mensal';
	@override String billed_every({required Object period}) => 'Cobrança por ${period}';
	@override String get flexible_plan => 'Cobrança flexível';
	@override String get plan_three_month => '3 meses';
	@override String get plan_six_month => '6 meses';
	@override String get billing_note => 'Renova até cancelar. Gerencie na loja.';
	@override String get billing_note_web => 'Renova até cancelar. Gerencie nas configurações.';
	@override String get benefits_heading => 'Incluso no plano';
}

// Path: premium.trialPlan
class _TranslationsPremiumTrialPlanPt extends TranslationsPremiumTrialPlanEn {
	_TranslationsPremiumTrialPlanPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get title_before => 'KASY ';
	@override String get title_accent => 'PRO';
	@override String get subtitle => 'Acesso a todos os recursos';
	@override String get social_proof => 'Junte-se a milhares de usuários Kasy';
	@override String get feature_1 => 'Recursos premium ilimitados';
	@override String get feature_2 => 'Export em alta qualidade';
	@override String get feature_3 => 'Sem anúncios e sem marca d\'água';
	@override String get feature_4 => 'Sincronize em todos os seus dispositivos';
	@override String get trial_toggle_enabled => 'Teste grátis ativado';
	@override String get trial_toggle_disabled => 'Ativar teste grátis';
	@override String get cta_trial => 'Iniciar teste grátis';
	@override String get cta_no_trial => 'Assinar agora';
	@override String billing_trial({required Object days, required Object price}) => '${days} dias grátis, depois ${price}/ano';
	@override String billing_annual({required Object price}) => '${price}/ano';
}

// Path: premium.unlockPlan
class _TranslationsPremiumUnlockPlanPt extends TranslationsPremiumUnlockPlanEn {
	_TranslationsPremiumUnlockPlanPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get headline_1 => 'DESBLOQUEIE TUDO';
	@override String get headline_2 => 'COM POUCOS TOQUES';
	@override String get headline_desktop => 'Desbloqueie tudo em instantes';
	@override String get feature_1 => 'Crie mais conteúdo';
	@override String get feature_2 => 'Resultados mais rápidos';
	@override String get feature_3 => 'Menos tempo de espera';
	@override String get feature_4 => 'Sync na nuvem';
	@override String get feature_5 => 'Suporte prioritário';
	@override String get cta => 'Desbloquear agora';
	@override String get cta_desktop => 'Desbloquear';
	@override String get billing_note => 'Renova até cancelar. Gerencie na loja.';
	@override String get billing_note_web => 'Renova até cancelar. Gerencie nas configurações.';
	@override String plan_annual_price({required Object price}) => 'Apenas ${price} / ano';
	@override String plan_monthly_price({required Object price}) => '${price} / mês';
}

// Path: premium.comparison
class _TranslationsPremiumComparisonPt extends TranslationsPremiumComparisonEn {
	_TranslationsPremiumComparisonPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Comparação de planos Premium';
	@override String get features_label => 'Recursos';
	@override String get free_version => 'Grátis';
	@override String get premium_version => 'Premium';
	@override String get no_ads => 'Sem anúncios';
	@override String get premium_themes => 'Temas Premium';
	@override String get advanced_customization => 'Personalização avançada';
	@override String get priority_support => 'Suporte prioritário';
	@override String get home_widget => 'Widgets na tela inicial';
	@override String get talk_with_assistant => 'Assistente IA';
}

// Path: onboarding.feature_1
class _TranslationsOnboardingFeature1Pt extends TranslationsOnboardingFeature1En {
	_TranslationsOnboardingFeature1Pt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Fature desde o dia um';
	@override String get description => 'Paywalls, assinaturas e período de teste prontos para produção. Sem montar backend de cobrança.';
	@override String get action => 'Continuar';
	@override String get skip => 'Pular';
	@override String get login => 'Já tem conta? Entrar';
}

// Path: onboarding.feature_2
class _TranslationsOnboardingFeature2Pt extends TranslationsOnboardingFeature2En {
	_TranslationsOnboardingFeature2Pt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Login pronto para produção';
	@override String get description => 'E-mail, login social e recuperação de senha. Seguro e pronto para publicar.';
	@override String get action => 'Continuar';
	@override String get back => 'Voltar';
}

// Path: onboarding.feature_3
class _TranslationsOnboardingFeature3Pt extends TranslationsOnboardingFeature3En {
	_TranslationsOnboardingFeature3Pt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Seu assistente de IA nativo';
	@override String get description => 'Um assistente de conversa pronto pra usar, já integrado ao app.';
	@override String get action => 'Continuar';
}

// Path: onboarding.mockups
class _TranslationsOnboardingMockupsPt extends TranslationsOnboardingMockupsEn {
	_TranslationsOnboardingMockupsPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsOnboardingMockupsPaywallPt paywall = _TranslationsOnboardingMockupsPaywallPt._(_root);
	@override late final _TranslationsOnboardingMockupsEarningsPt earnings = _TranslationsOnboardingMockupsEarningsPt._(_root);
	@override late final _TranslationsOnboardingMockupsAuthPt auth = _TranslationsOnboardingMockupsAuthPt._(_root);
	@override late final _TranslationsOnboardingMockupsNotificationPt notification = _TranslationsOnboardingMockupsNotificationPt._(_root);
	@override late final _TranslationsOnboardingMockupsAiChatPt ai_chat = _TranslationsOnboardingMockupsAiChatPt._(_root);
}

// Path: onboarding.ageQuestion
class _TranslationsOnboardingAgeQuestionPt extends TranslationsOnboardingAgeQuestionEn {
	_TranslationsOnboardingAgeQuestionPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Qual a sua idade?';
	@override String get description => 'Isso nos ajuda a personalizar a sua experiência.';
	@override Map<String, String> get options => {
		'age18_30': '18 a 30',
		'age31_40': '31 a 40',
		'age41_50': '41 a 50',
		'age51_60': 'Mais de 50',
		'none': 'Prefiro não dizer',
	};
	@override String get action => 'Continuar';
}

// Path: onboarding.genderQuestion
class _TranslationsOnboardingGenderQuestionPt extends TranslationsOnboardingGenderQuestionEn {
	_TranslationsOnboardingGenderQuestionPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Como você se identifica?';
	@override String get description => 'Escolha o que combina com você. Pode pular se preferir.';
	@override Map<String, String> get options => {
		'male': 'Masculino',
		'female': 'Feminino',
		'none': 'Prefiro não dizer',
	};
	@override String get action => 'Continuar';
}

// Path: onboarding.notifications
class _TranslationsOnboardingNotificationsPt extends TranslationsOnboardingNotificationsEn {
	_TranslationsOnboardingNotificationsPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Fique por dentro';
	@override String get description => 'Só falamos com você quando realmente importa. Nada de spam.';
	@override String get continue_button => 'Ativar notificações';
	@override String get skip_button => 'Agora não';
	@override late final _TranslationsOnboardingNotificationsToastsPt toasts = _TranslationsOnboardingNotificationsToastsPt._(_root);
}

// Path: onboarding.att
class _TranslationsOnboardingAttPt extends TranslationsOnboardingAttEn {
	_TranslationsOnboardingAttPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Experiência personalizada';
	@override String get description => 'A permissão ajuda a ajustar comunicações ao seu perfil. Não exibe anúncios dentro do app.';
	@override String get continue_button => 'Continuar';
	@override String get skip_button => 'Agora não';
	@override late final _TranslationsOnboardingAttCardPt card = _TranslationsOnboardingAttCardPt._(_root);
}

// Path: onboarding.loading
class _TranslationsOnboardingLoadingPt extends TranslationsOnboardingLoadingEn {
	_TranslationsOnboardingLoadingPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get welcome => 'Conta criada.';
	@override String get welcome_male => 'Conta criada. Bem-vindo!';
	@override String get welcome_female => 'Conta criada. Bem-vinda!';
	@override late final _TranslationsOnboardingLoadingStepsPt steps = _TranslationsOnboardingLoadingStepsPt._(_root);
}

// Path: feature_requests.vote_success
class _TranslationsFeatureRequestsVoteSuccessPt extends TranslationsFeatureRequestsVoteSuccessEn {
	_TranslationsFeatureRequestsVoteSuccessPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Voto registrado';
	@override String get description => 'Obrigado por ajudar a definir as prioridades';
}

// Path: feature_requests.vote_error
class _TranslationsFeatureRequestsVoteErrorPt extends TranslationsFeatureRequestsVoteErrorEn {
	_TranslationsFeatureRequestsVoteErrorPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Já votado';
	@override String get description => 'Você já votou nesta ideia';
}

// Path: feature_requests.add_feature
class _TranslationsFeatureRequestsAddFeaturePt extends TranslationsFeatureRequestsAddFeatureEn {
	_TranslationsFeatureRequestsAddFeaturePt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get chip_label => 'Add';
	@override String get title => 'Enviar uma ideia';
	@override String get description => 'Conte o que você gostaria de ver no app.';
	@override String get save_button => 'Enviar';
	@override String get cancel => 'Cancelar';
	@override String get title_label => 'Título';
	@override String get title_hint => 'Um título curto e descritivo';
	@override String get description_label => 'Descrição';
	@override String get description_hint => 'Descreva o recurso ou melhoria em detalhes...';
	@override String get error_title => 'Erro';
	@override String get error_required => 'Título e descrição são obrigatórios';
	@override String get error_sending => 'Algo deu errado. Tente novamente.';
	@override String get error_too_short => 'Descrição muito curta. Adicione mais detalhes';
	@override late final _TranslationsFeatureRequestsAddFeatureToastSuccessPt toast_success = _TranslationsFeatureRequestsAddFeatureToastSuccessPt._(_root);
}

// Path: settings.avatar
class _TranslationsSettingsAvatarPt extends TranslationsSettingsAvatarEn {
	_TranslationsSettingsAvatarPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Foto do perfil';
	@override String get take_photo => 'Tirar foto';
	@override String get choose_library => 'Biblioteca de fotos';
	@override String get remove_photo => 'Remover foto';
	@override String get cancel => 'Cancelar';
}

// Path: settings.delete_account
class _TranslationsSettingsDeleteAccountPt extends TranslationsSettingsDeleteAccountEn {
	_TranslationsSettingsDeleteAccountPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get button => 'Quero excluir minha conta';
	@override String get title => 'Quer excluir sua conta?';
	@override String get content => 'Atenção: esta ação é permanente e não pode ser desfeita.';
	@override String get content_subscriber => 'Atenção: esta ação é permanente. Você perde sua assinatura ativa, e criar uma nova conta depois (mesmo com o mesmo e-mail) não recupera ela.';
	@override String get cancel => 'Cancelar';
	@override String get confirm => 'Sim, excluir';
	@override String get error => 'Algo deu errado. Por favor, tente novamente.';
}

// Path: settings.admin
class _TranslationsSettingsAdminPt extends TranslationsSettingsAdminEn {
	_TranslationsSettingsAdminPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get update_bottom_sheet => 'Pré-visualizar novidades';
	@override String get preview_update_available => 'Pré-visualizar atualização disponível';
	@override String get paywalls => 'Paywalls';
	@override String get test_onboarding => 'Testar onboarding';
	@override String get copy_user_id => 'Copiar ID do usuário';
	@override String get user_id_copied => 'ID do usuário copiado para a área de transferência';
	@override String get copy_fcm_token => 'Copiar FCM Token';
	@override String get fcm_token_copied => 'FCM Token copiado para a área de transferência';
	@override String get fcm_token_unavailable => 'Token não disponível (notificações desativadas?)';
	@override String get ask_notification => 'Pedir permissão de notificação';
	@override String get native_only => 'Disponível apenas no app nativo (iOS / Android)';
	@override String get ask_review => 'Pedir avaliação';
	@override String get home_widgets_panel => 'Painel de Home Widgets';
	@override String get home_widgets_title => 'Painel de Home Widgets';
	@override String get ads_demo_panel => 'Demo de anúncios';
	@override String get ads_demo_title => 'Demo de anúncios';
	@override String get ads_demo_subtitle => 'Os quatro formatos do AdMob com anúncios de teste do Google. Teste cada um e coloque onde quiser no seu app.';
	@override String get ads_banner_label => 'Banner';
	@override String get ads_interstitial_title => 'Intersticial';
	@override String get ads_interstitial_desc => 'Anúncio em tela cheia. Toque para mostrar.';
	@override String get ads_rewarded_title => 'Recompensado';
	@override String get ads_rewarded_desc => 'O usuário assiste para ganhar uma recompensa. Toque para mostrar.';
	@override String get ads_rewarded_interstitial_title => 'Recompensado intersticial';
	@override String get ads_rewarded_interstitial_desc => 'Anúncio em tela cheia que também dá recompensa. Toque para mostrar.';
	@override String ads_reward_earned({required Object amount, required Object type}) => 'Recompensa ganha: ${amount} ${type}';
	@override String get ads_load_failed => 'Não foi possível carregar o anúncio (sem preenchimento). Tente de novo em instantes.';
	@override String get ads_code_copied => 'Código copiado para a área de transferência';
	@override String get ads_status_safe => 'Esta demo sempre mostra anúncios de teste do Google, então é seguro tocar, mesmo em produção.';
	@override String get ads_status_test => 'Seus ad ids reais ainda não estão definidos. Configure para ir ao ar:';
	@override String get ads_status_real => 'Ad ids reais configurados para esta plataforma.';
	@override String get inspector_fab_title => 'Inspector de widgets';
	@override String get inspector_fab_subtitle_prefix => 'Atalho global:';
	@override String get update_mywidget_title => 'Atualizar Widget MyWidget';
	@override String get update_mywidget_desc => 'Chamar atualização manual para o widget MyWidget';
	@override String get paywalls_title => 'Painel Admin de Paywalls';
	@override String get send_push_title => 'Enviar notificação';
	@override String get send_push_to_all => 'Enviar para todos';
	@override String get send_push_email_hint => 'Adicionar e-mail';
	@override String get send_push_title_label => 'Título';
	@override String get send_push_title_hint => 'Ex: Nova atualização disponível';
	@override String get send_push_body_label => 'Mensagem';
	@override String get send_push_body_hint => 'Até 3 linhas na lista do app (máx. 140 caracteres)';
	@override String get send_push_image_label => 'URL da imagem (opcional)';
	@override String get send_push_image_hint => 'https://...';
	@override String get send_push_email_label => 'E-mails dos destinatários';
	@override String get send_push_success => 'Notificação enviada!';
	@override String send_push_user_not_found({required Object email}) => 'Usuário não encontrado: ${email}';
	@override String get send_push_send_button => 'Enviar';
	@override String get send_push_required => 'Título e mensagem são obrigatórios';
	@override String get send_push_no_emails => 'Adicione pelo menos um e-mail';
	@override String get send_push_route_label => 'Página ao abrir';
	@override String get send_push_route_description => 'Tela aberta quando o usuário toca na notificação.';
	@override String get send_push_route_notifications => 'Notificações';
	@override String get send_push_route_home => 'Início';
	@override String get send_push_route_settings => 'Configurações';
	@override String get send_push_route_premium => 'Premium';
	@override String get send_push_route_reminder => 'Lembretes';
	@override String get send_push_route_feedback => 'Feedback';
	@override String get send_push_preview_label => 'Prévia';
	@override String get send_push_preview_now => 'agora';
	@override String get send_push_preview_title_placeholder => 'Título da notificação';
	@override String get send_push_preview_body_placeholder => 'O corpo da mensagem aparece aqui';
	@override String get device_preview_title => 'Device Preview (somente web)';
	@override String get send_push_section_recipients => 'Destinatários';
	@override String get send_push_section_content => 'Conteúdo';
	@override String get send_push_section_advanced => 'Avançado';
	@override String get send_push_audience_all => 'Todos';
	@override String get send_push_audience_specific => 'Específicos';
	@override String get send_push_audience_all_hint => 'A notificação será enviada para todos os usuários inscritos.';
}

// Path: onboarding.mockups.paywall
class _TranslationsOnboardingMockupsPaywallPt extends TranslationsOnboardingMockupsPaywallEn {
	_TranslationsOnboardingMockupsPaywallPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Premium';
	@override String get annual => 'Anual';
	@override String get monthly => 'Mensal';
	@override String get save_badge => '-40%';
	@override String get price_year => 'R\$ 39,99 / ano';
	@override String get price_month => 'R\$ 4,99 / mês';
	@override String get cta => 'Iniciar teste grátis';
}

// Path: onboarding.mockups.earnings
class _TranslationsOnboardingMockupsEarningsPt extends TranslationsOnboardingMockupsEarningsEn {
	_TranslationsOnboardingMockupsEarningsPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get notify_title => 'Novo assinante Pro';
	@override String get notify_subtitle => 'Plano anual · +\$49.90';
	@override String get notify_time => '1:40 PM';
	@override String get processing => 'Processando pagamento…';
	@override String get summary_label => 'Ganhos';
	@override String get summary_body => 'Você ganhou \$312.40 esta semana de 14 novas assinaturas.';
}

// Path: onboarding.mockups.auth
class _TranslationsOnboardingMockupsAuthPt extends TranslationsOnboardingMockupsAuthEn {
	_TranslationsOnboardingMockupsAuthPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get welcome => 'Bem-vindo de volta';
	@override String get email_hint => 'voce@email.com';
	@override String get sign_in => 'Entrar';
	@override String get divider => 'ou';
}

// Path: onboarding.mockups.notification
class _TranslationsOnboardingMockupsNotificationPt extends TranslationsOnboardingMockupsNotificationEn {
	_TranslationsOnboardingMockupsNotificationPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Nova mensagem';
	@override String get time => 'agora';
}

// Path: onboarding.mockups.ai_chat
class _TranslationsOnboardingMockupsAiChatPt extends TranslationsOnboardingMockupsAiChatEn {
	_TranslationsOnboardingMockupsAiChatPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get u1 => 'O que você faz?';
	@override String get a1 => 'Escrevo, resumo e respondo qualquer coisa em segundos.';
	@override String get u2 => 'Resuma minhas anotações';
	@override String get a2 => 'Pronto. Separei os 3 pontos principais de hoje.';
}

// Path: onboarding.notifications.toasts
class _TranslationsOnboardingNotificationsToastsPt extends TranslationsOnboardingNotificationsToastsEn {
	_TranslationsOnboardingNotificationsToastsPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get push_app_name => 'Kasy';
	@override String get push_headline => 'Seu resumo semanal está pronto';
	@override String get push_body => 'Toque para abrir.';
	@override String get push_sent_at => 'agora';
	@override String get subscriber_title => 'Novo assinante Pro';
	@override String get subscriber_message => 'Plano anual · +\$49,90';
	@override String get streak_title => 'Sequência de 7 dias!';
	@override String get streak_message => 'Você bateu sua meta diária de novo.';
	@override String get message_title => 'Nova resposta';
	@override String get message_message => 'Alguém respondeu na sua conversa.';
	@override String get reminder_title => 'Começa em breve';
	@override String get reminder_message => 'Sua sessão começa em 10 minutos.';
	@override String get payment_title => 'Pagamento recebido';
	@override String get payment_message => '+R\$ 12,50 creditados no seu saldo.';
	@override String get offer_title => 'Oferta limitada';
	@override String get offer_message => '50% off no anual — acaba hoje.';
	@override String get social_title => 'Nova interação';
	@override String get social_message => '3 pessoas curtiram sua publicação.';
}

// Path: onboarding.att.card
class _TranslationsOnboardingAttCardPt extends TranslationsOnboardingAttCardEn {
	_TranslationsOnboardingAttCardPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get tag => 'Privacidade';
}

// Path: onboarding.loading.steps
class _TranslationsOnboardingLoadingStepsPt extends TranslationsOnboardingLoadingStepsEn {
	_TranslationsOnboardingLoadingStepsPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get account => 'Criando sua conta';
	@override String get preferences => 'Salvando suas preferências';
	@override String get ready => 'Personalizando sua experiência';
}

// Path: feature_requests.add_feature.toast_success
class _TranslationsFeatureRequestsAddFeatureToastSuccessPt extends TranslationsFeatureRequestsAddFeatureToastSuccessEn {
	_TranslationsFeatureRequestsAddFeatureToastSuccessPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Ideia enviada';
	@override String get description => 'Vamos analisar e te dar um retorno';
}

/// The flat map containing all translations for locale <pt>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsPt {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'common.close' => 'Fechar',
			'common.copied' => 'Copiado',
			'common.saved' => 'Salvo',
			'common.error' => 'Erro',
			'common.unavailable' => 'Indisponível',
			'common.native_only_title' => 'Apenas no app nativo',
			'admin_console.tabs.overview' => 'Visão geral',
			'admin_console.tabs.users' => 'Usuários',
			'admin_console.tabs.requests' => 'Solicitações',
			'admin_console.tabs.tools' => 'Ferramentas',
			'admin_console.tabs.debug' => 'Depuração',
			'admin_console.back_to_app' => 'Voltar ao app',
			'admin_console.overview.section' => 'Projeto',
			'admin_console.overview.summary' => 'Resumo',
			'admin_console.overview.backend' => 'Backend',
			'admin_console.overview.account' => 'Conta',
			'admin_console.overview.guest' => 'Visitante',
			'admin_console.overview.user_id' => 'ID do usuário',
			'admin_console.overview.build' => 'Versão',
			'admin_console.overview.session_title' => 'Sessão atual',
			'admin_console.overview.requests_metric' => 'Solicitações de recurso',
			'admin_console.overview.total_users' => 'Total de usuários',
			'admin_console.overview.subscribers' => 'Assinantes',
			'admin_console.overview.new_7d' => 'Novos (7 dias)',
			'admin_console.overview.signups_title' => 'Novos cadastros',
			'admin_console.overview.signups_subtitle' => 'Últimos 14 dias',
			'admin_console.overview.signups_total' => ({required Object count}) => '${count} em 14 dias',
			'admin_console.overview.signups_empty' => 'Nenhum cadastro neste período.',
			'admin_console.overview.plan_split_title' => 'Distribuição de planos',
			'admin_console.overview.free' => 'Grátis',
			'admin_console.overview.subscriber' => 'Assinante',
			'admin_console.overview.conversion' => ({required Object percent}) => '${percent} assinam',
			'admin_console.overview.loaded_note' => ({required Object count}) => 'Com base nos ${count} usuários mais recentes.',
			'admin_console.overview.users_hint' => 'Abra a aba Usuários para gerenciar todas as contas.',
			'admin_console.overview.debug_note' => 'Console de debug — visível só em builds de desenvolvimento.',
			'admin_console.users.title' => 'Usuários',
			'admin_console.users.search_hint' => 'Buscar por nome ou e-mail',
			'admin_console.users.col_user' => 'Usuário',
			'admin_console.users.col_status' => 'Status',
			'admin_console.users.col_plan' => 'Plano',
			'admin_console.users.col_joined' => 'Cadastro',
			'admin_console.users.status_active' => 'Ativo',
			'admin_console.users.status_inactive' => 'Inativo',
			'admin_console.users.plan_subscriber' => 'Assinante',
			'admin_console.users.plan_free' => 'Grátis',
			'admin_console.users.empty' => 'Nenhum usuário encontrado',
			'admin_console.users.empty_hint' => 'Quando alguém criar uma conta, ela aparece aqui.',
			'admin_console.users.error' => 'Não foi possível carregar os usuários. Confirme que você é admin.',
			'admin_console.users.page' => ({required Object page, required Object total}) => 'Página ${page} de ${total}',
			'admin_console.users.prev' => 'Anterior',
			'admin_console.users.next' => 'Próxima',
			'admin_console.users.anonymous' => 'Anônimo',
			'admin_console.users.filter_all' => 'Todos os usuários',
			'admin_console.users.filter_subscribers' => 'Assinantes',
			'admin_console.users.loading' => 'Carregando usuários…',
			'admin_console.users.results' => ({required Object from, required Object to, required Object total}) => 'Mostrando ${from} a ${to} de ${total}',
			'admin_console.users.truncated' => ({required Object count}) => 'Mostrando os ${count} mais recentes. A busca cobre só os carregados.',
			'admin_console.users.search_capped' => 'A busca varreu um conjunto limitado. Podem faltar correspondências.',
			'admin_console.users.empty_search' => 'Nenhum usuário corresponde à busca',
			'admin_console.users.empty_search_hint' => 'Tente outro nome ou e-mail.',
			'admin_console.users.empty_subscribers' => 'Nenhum assinante encontrado',
			'admin_console.users.empty_subscribers_hint' => 'Quem assinar o plano premium aparece neste filtro.',
			'admin_console.users.refresh' => 'Atualizar',
			'admin_console.users.retry' => 'Tentar de novo',
			'admin_console.requests.title' => 'Solicitações de recurso',
			'admin_console.requests.subtitle' => 'Pedidos e sugestões enviados pelos seus usuários. Marque como visível para aparecer no app, ou oculte os que não fizerem sentido.',
			'admin_console.requests.empty' => 'Ainda não há solicitações',
			'admin_console.requests.empty_hint' => 'Quando um usuário enviar uma ideia, ela aparece aqui.',
			'admin_console.requests.votes' => ({required Object count}) => '${count} votos',
			'admin_console.requests.visible' => 'Visível',
			'admin_console.requests.hidden' => 'Oculto',
			'admin_console.requests.edit' => 'Editar',
			'admin_console.requests.error' => 'Não foi possível carregar as solicitações',
			'admin_console.requests.saved' => 'Solicitação atualizada',
			'admin_console.requests.editor_title' => 'Editar solicitação',
			'admin_console.requests.field_title' => 'Título',
			'admin_console.requests.field_description' => 'Descrição',
			'admin_console.requests.lang_en' => 'Inglês',
			'admin_console.requests.lang_pt' => 'Português',
			'admin_console.requests.lang_es' => 'Espanhol',
			'admin_console.requests.visibility' => 'Visível para os usuários',
			'admin_console.requests.save' => 'Salvar',
			'admin_console.requests.cancel' => 'Cancelar',
			'admin_console.groups.actions' => 'Ações',
			'admin_console.groups.features' => 'Recursos',
			'admin_console.groups.preview' => 'Preview',
			'admin_console.groups.debug_actions' => 'Ações de debug',
			'admin_console.groups.identity' => 'Identidade',
			'admin_console.groups.notification_test' => 'Teste de notificação',
			'admin_console.paywalls.subtitle' => 'Toque num paywall para visualizar. Copie o código dele para dizer ao assistente qual usar.',
			'admin_console.paywalls.copy_code' => 'Copiar código',
			'admin_console.paywalls.code_copied' => 'Código copiado para a área de transferência',
			'admin_console.paywalls.solo_title' => 'Solo',
			'admin_console.paywalls.solo_desc' => 'Um plano só, com benefícios e um CTA. Ideal para apps de uma faixa.',
			'admin_console.paywalls.compare_title' => 'Compare',
			'admin_console.paywalls.compare_desc' => 'Mensal vs anual lado a lado, com tabela free vs premium.',
			'admin_console.paywalls.trial_title' => 'Trial',
			'admin_console.paywalls.trial_desc' => 'Toggle de teste grátis, em geral no anual. Mensal cobra na hora.',
			'admin_console.paywalls.unlock_title' => 'Unlock',
			'admin_console.paywalls.unlock_desc' => 'Paywall de conversão para onboarding ou bloqueio forte.',
			'admin_console.settings_entry.title' => 'Admin',
			'admin_console.settings_entry.caption' => 'Visível só para administradores e em modo de desenvolvimento.',
			'admin_console.requires_admin' => 'Você precisa ser admin para ver isto. Defina role: admin no registro do seu usuário no backend. O app não altera esse campo; a validação é no servidor.',
			'home.title' => 'Exemplo Kasy',
			'home.welcome' => 'Bem-vindo ao demo do Kasy',
			'home.cards.paywall_title' => 'Paywall',
			'home.cards.paywall_description' => 'Ver a página de assinatura',
			'home.cards.notification_title' => 'Teste de notificação local',
			'home.cards.notification_description' => 'Dispara um alerta só neste aparelho. Não entra na aba Notificações (push).',
			'home.cards.feedback_title' => 'Feedback',
			'home.cards.feedback_description' => 'Página de solicitação de recursos ou votação',
			'home.cards.signup_title' => 'Cadastro',
			'home.cards.signup_description' => 'Usuário anônimo pode se cadastrar com e-mail ou rede social',
			'home.cards.assistant_title' => 'Assistente IA',
			'home.cards.assistant_description' => 'Conversar com o assistente de IA',
			'home.features_page.title' => 'Recursos do kit',
			'home.features_page.assistant_title' => 'Converse com a IA',
			'home.features_page.assistant_description' => 'Chat pronto para perguntas, ideias e suporte dentro do app',
			'home.features_page.feedback_title' => 'Vote e sugira',
			'home.features_page.feedback_description' => 'Participe do roadmap: vote em ideias ou envie a sua',
			'home.features_page.notification_title' => 'Testar notificação',
			'home.features_page.notification_description' => 'Dispara um alerta só neste aparelho (não é push)',
			'home.features_page.notification_demo_title' => 'Alerta de teste',
			'home.features_page.notification_demo_body' => 'Notificação local do demo do kit',
			'home.features_page.send_push_title' => 'Enviar notificação push',
			'home.features_page.send_push_description' => 'Dispare uma push para usuários específicos ou para todos',
			'home.features_page.paywall_title' => 'Planos e assinatura',
			'home.features_page.paywall_description' => 'Telas de paywall, trial e fluxo RevenueCat',
			'home.dashboard.brand' => 'kasy',
			'home.dashboard.components_title' => 'Componentes',
			'home.dashboard.components_subtitle' => 'Explore tokens de design e blocos de interface',
			'home.dashboard.features_title' => 'Features',
			'home.dashboard.features_subtitle' => 'IA, feedback, alertas e assinatura',
			'home.dashboard.count_total' => ({required Object count}) => '${count} no total',
			'home.dashboard.search_hint' => 'Buscar componentes',
			'home.dashboard.search_empty' => 'Nenhum componente encontrado',
			'home.dashboard.in_production' => 'Em produção',
			'home.dashboard.needs_review' => 'Revisar',
			'home.components_preview.nav_title' => 'Componentes',
			'home.components_preview.pro_badge' => 'PRO',
			'auth.signin.title' => 'Bem-vindo de volta',
			'auth.signin.subtitle' => 'Entre para continuar sua experiência',
			'auth.signin.email_hint' => 'bruce@wayne.com',
			'auth.signin.email_label' => 'E-mail',
			'auth.signin.password_hint' => 'Senha',
			'auth.signin.password_label' => 'Senha',
			'auth.signin.forgot_password' => 'Esqueceu sua senha?',
			'auth.signin.submit' => 'Continuar com e-mail',
			'auth.signin.create_account' => 'Criar minha conta',
			'auth.signin.no_account' => 'Não tem uma conta?',
			'auth.signin.signup_link' => 'Cadastre-se',
			'auth.signin.continue_without' => 'Continuar sem conta',
			'auth.signin.or_sign_in_with' => 'ou',
			'auth.signin.google' => 'Gmail',
			'auth.signin.apple' => 'Apple',
			'auth.signin.facebook' => 'Facebook',
			'auth.signin.error_title' => 'Erro',
			'auth.signin.error_text' => 'E-mail, senha incorretos ou este e-mail não está cadastrado',
			'auth.signin.email_invalid' => 'E-mail inválido',
			'auth.signin.password_required' => 'Informe uma senha',
			'auth.signin.password_too_short' => 'Sua senha deve ter pelo menos 5 caracteres',
			'auth.signin.social_error' => ({required Object provider}) => 'Não foi possível entrar com ${provider}',
			'auth.signin.email_already_registered' => 'Esse e-mail já tem conta com outro método de login. Entre com o método que você usou antes.',
			'auth.signup.title' => 'Cadastre-se agora',
			'auth.signup.subtitle' => 'Crie sua conta para começar',
			'auth.signup.submit' => 'Criar minha conta',
			'auth.signup.have_account' => 'Já tem uma conta?',
			'auth.signup.signin_link' => 'Entrar',
			'auth.signup.already_have_account' => 'Já tenho uma conta',
			'auth.signup.error_title' => 'Erro',
			'auth.signup.error_text' => 'Este e-mail já existe ou é inválido',
			'auth.recover.title' => 'Recuperar senha',
			'auth.recover.subtitle' => 'Enviaremos um link para redefinir sua senha',
			'auth.recover.email_label' => 'E-mail',
			'auth.recover.submit' => 'Recuperar senha',
			'auth.recover.remember' => 'Lembrou sua senha?',
			'auth.recover.signin_link' => 'Entrar',
			'auth.recover.error_title' => 'Erro',
			'auth.recover.error_text' => 'Informe um e-mail válido',
			'rate_popup.title' => 'Você teria 15s para nos avaliar?',
			'rate_popup.description' => 'É rápido e muito útil! Muito obrigado!',
			'rate_popup.cancel_button' => 'Talvez mais tarde',
			'rate_popup.rate_button' => 'Sim, com prazer!',
			'premium.title_1' => 'Desbloqueie o acesso completo',
			'premium.description' => 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
			'premium.feature_1' => 'Recurso 1 lorem ipsum',
			'premium.feature_2' => 'Recurso 2 mop issum',
			'premium.feature_3' => 'Recurso 3 lorem',
			'premium.duration_weekly' => 'Semana',
			'premium.duration_annual' => 'Ano',
			'premium.duration_monthly' => 'Mês',
			'premium.duration_monthly_description' => 'Cancele quando quiser',
			'premium.duration_lifetime' => 'Vitalício',
			'premium.duration_lifetime_description' => 'Pagamento único',
			'premium.restore_action' => 'Restaurar',
			'premium.preview_disabled_title' => 'Pré-visualização',
			'premium.preview_disabled_text' => 'Esta é uma pré-visualização do admin. As ações de compra ficam desativadas.',
			'premium.coupon_title' => 'Tem um cupom?',
			'premium.payment_cancel_reassurance' => 'Cancelamento fácil com 1 clique, sempre',
			'premium.payment_cancel_reassurance_free_trial' => 'Sem pagamento agora, cancele quando quiser',
			'premium.payment_action' => 'Iniciar teste gratuito',
			'premium.payment_action_trial' => ({required Object money}) => '7 dias grátis, depois ${money}',
			'premium.try_free_btn_action' => ({required Object days}) => 'Experimente grátis por ${days} dias',
			'premium.duration_recuring_label_annual' => 'Anual',
			'premium.duration_recuring_label_monthly' => 'Mensal',
			'premium.duration_recuring_label_weekly' => 'Semanal',
			'premium.price_per_week' => '/semana',
			'premium.price_per_month' => '/mês',
			'premium.price_per_three_month' => '/3 meses',
			'premium.price_per_six_month' => '/6 meses',
			'premium.price_per_year' => '/ano',
			'premium.price_one_time' => '',
			'premium.action_button' => 'Continuar',
			'premium.terms' => 'Termos',
			'premium.privacy' => 'Privacidade',
			'premium.terms_of_use' => 'Termos de uso',
			'premium.privacy_policy' => 'Política de privacidade',
			'premium.error_loading' => 'Erro ao carregar as ofertas',
			'premium.no_products_title' => 'As opções de assinatura ainda não estão disponíveis',
			'premium.no_products_description' => 'Tente novamente em alguns instantes. Se continuar acontecendo, os produtos da loja ainda podem estar finalizando a configuração.',
			'premium.restore_success_title' => 'Assinatura restaurada',
			'premium.restore_success_text' => 'Obrigado pela sua confiança',
			'premium.purchase_success_title' => 'Assinatura realizada com sucesso',
			'premium.purchase_success_text' => 'Obrigado pela sua confiança',
			'premium.error_title' => 'Erro',
			'premium.error_text' => 'Ocorreu um erro. Tente novamente',
			'premium.web_checkout_timeout_title' => 'Pagamento não confirmado',
			'premium.web_checkout_timeout_text' => 'Não recebemos a confirmação do pagamento. Se você já pagou, toque em Restaurar.',
			'premium.restore_none_title' => 'Nenhuma assinatura encontrada',
			'premium.restore_none_text' => 'Não encontramos uma assinatura ativa para restaurar.',
			'premium.solo.back' => 'Voltar',
			'premium.solo.headline_1' => 'Upgrade para uma',
			'premium.solo.headline_2' => 'experiência sem anúncios',
			'premium.solo.feature_1' => 'Sem anúncios',
			'premium.solo.feature_2' => 'Modo offline',
			'premium.solo.feature_3' => 'Pulos ilimitados',
			'premium.solo.feature_4' => 'Áudio em alta qualidade',
			'premium.solo.subscribe' => 'Assinar agora',
			'premium.comparePlan.back' => 'Voltar',
			'premium.comparePlan.headline_1' => 'Escolha seu plano',
			'premium.comparePlan.headline_2' => 'ideal para você',
			'premium.comparePlan.headline_description' => 'Compare Grátis e Premium e escolha a cobrança mensal ou anual que combina com você.',
			'premium.comparePlan.feature_1_title' => 'Acesso premium completo',
			'premium.comparePlan.feature_1_subtitle' => 'Todos os recursos em todos os dispositivos',
			'premium.comparePlan.feature_2_title' => 'Sem anúncios',
			'premium.comparePlan.feature_2_subtitle' => 'Foco total, sem interrupções',
			'premium.comparePlan.feature_3_title' => 'Sync na nuvem',
			'premium.comparePlan.feature_3_subtitle' => 'Continue de onde parou',
			'premium.comparePlan.feature_4_title' => 'Suporte prioritário',
			'premium.comparePlan.feature_4_subtitle' => 'Ajuda quando você precisar',
			'premium.comparePlan.continue_cta' => 'Continuar',
			'premium.comparePlan.best_offer_badge' => ({required Object percent}) => 'Economize ${percent}%',
			'premium.comparePlan.per_month_line' => ({required Object price}) => '${price} cobrado por ano',
			'premium.comparePlan.billed_monthly' => 'Cobrança mensal',
			'premium.comparePlan.billed_every' => ({required Object period}) => 'Cobrança por ${period}',
			'premium.comparePlan.flexible_plan' => 'Cobrança flexível',
			'premium.comparePlan.plan_three_month' => '3 meses',
			'premium.comparePlan.plan_six_month' => '6 meses',
			'premium.comparePlan.billing_note' => 'Renova até cancelar. Gerencie na loja.',
			'premium.comparePlan.billing_note_web' => 'Renova até cancelar. Gerencie nas configurações.',
			'premium.comparePlan.benefits_heading' => 'Incluso no plano',
			'premium.trialPlan.title_before' => 'KASY ',
			'premium.trialPlan.title_accent' => 'PRO',
			'premium.trialPlan.subtitle' => 'Acesso a todos os recursos',
			'premium.trialPlan.social_proof' => 'Junte-se a milhares de usuários Kasy',
			'premium.trialPlan.feature_1' => 'Recursos premium ilimitados',
			'premium.trialPlan.feature_2' => 'Export em alta qualidade',
			'premium.trialPlan.feature_3' => 'Sem anúncios e sem marca d\'água',
			'premium.trialPlan.feature_4' => 'Sincronize em todos os seus dispositivos',
			'premium.trialPlan.trial_toggle_enabled' => 'Teste grátis ativado',
			'premium.trialPlan.trial_toggle_disabled' => 'Ativar teste grátis',
			'premium.trialPlan.cta_trial' => 'Iniciar teste grátis',
			'premium.trialPlan.cta_no_trial' => 'Assinar agora',
			'premium.trialPlan.billing_trial' => ({required Object days, required Object price}) => '${days} dias grátis, depois ${price}/ano',
			'premium.trialPlan.billing_annual' => ({required Object price}) => '${price}/ano',
			'premium.unlockPlan.headline_1' => 'DESBLOQUEIE TUDO',
			'premium.unlockPlan.headline_2' => 'COM POUCOS TOQUES',
			'premium.unlockPlan.headline_desktop' => 'Desbloqueie tudo em instantes',
			'premium.unlockPlan.feature_1' => 'Crie mais conteúdo',
			'premium.unlockPlan.feature_2' => 'Resultados mais rápidos',
			'premium.unlockPlan.feature_3' => 'Menos tempo de espera',
			'premium.unlockPlan.feature_4' => 'Sync na nuvem',
			'premium.unlockPlan.feature_5' => 'Suporte prioritário',
			'premium.unlockPlan.cta' => 'Desbloquear agora',
			'premium.unlockPlan.cta_desktop' => 'Desbloquear',
			'premium.unlockPlan.billing_note' => 'Renova até cancelar. Gerencie na loja.',
			'premium.unlockPlan.billing_note_web' => 'Renova até cancelar. Gerencie nas configurações.',
			'premium.unlockPlan.plan_annual_price' => ({required Object price}) => 'Apenas ${price} / ano',
			'premium.unlockPlan.plan_monthly_price' => ({required Object price}) => '${price} / mês',
			'premium.comparison.title' => 'Comparação de planos Premium',
			'premium.comparison.features_label' => 'Recursos',
			'premium.comparison.free_version' => 'Grátis',
			'premium.comparison.premium_version' => 'Premium',
			'premium.comparison.no_ads' => 'Sem anúncios',
			'premium.comparison.premium_themes' => 'Temas Premium',
			'premium.comparison.advanced_customization' => 'Personalização avançada',
			'premium.comparison.priority_support' => 'Suporte prioritário',
			'premium.comparison.home_widget' => 'Widgets na tela inicial',
			'premium.comparison.talk_with_assistant' => 'Assistente IA',
			'activePremium.title' => 'Você é um usuário premium',
			'activePremium.description' => 'Aproveite todos os recursos',
			'activePremium.unsubscribe_button' => 'Cancelar assinatura',
			'activePremium.early_bird_description' => 'Você usou um cupom que lhe deu acesso gratuito aos recursos premium sem assinatura. Aproveite!',
			'activePremium.unsubscribe_feedback_title' => 'Ajude-nos a melhorar',
			'activePremium.unsubscribe_feedback_description' => 'Lamentamos vê-lo partir. Poderia nos dizer brevemente por que está cancelando?',
			'activePremium.unsubscribe_feedback_hint' => 'Conte-nos o motivo...',
			'activePremium.unsubscribe_feedback_min_chars' => 'Mínimo de 6 caracteres necessários',
			'activePremium.unsubscribe_confirm_button' => 'Prosseguir',
			'activePremium.lifetime_user_description' => 'Você é um usuário vitalício',
			'activePremium.managed_elsewhere_title' => 'Assinatura em outra plataforma',
			'activePremium.managed_elsewhere_description' => 'Esta assinatura foi feita em outra plataforma e não pode ser gerenciada ou cancelada por aqui. Acesse a conta na plataforma onde você fez a compra.',
			'activePremium.restore_button' => 'Restaurar compras',
			'activePremium.cancel_button' => 'Fechar',
			'activePremium.billing_title' => 'Cobrança',
			'activePremium.plan_label' => 'Plano da conta',
			'activePremium.plan_fallback' => 'Premium',
			'activePremium.manage_subscription' => 'Gerenciar assinatura',
			'activePremium.restore_purchases' => 'Restaurar compras',
			'activePremium.renews_on' => ({required Object date}) => 'Renova em ${date}',
			'activePremium.expires_on' => ({required Object date}) => 'Expira em ${date}',
			'activePremium.trial_label' => 'Avaliação gratuita',
			'activePremium.trial_until' => ({required Object date}) => 'Avaliação gratuita até ${date}',
			'activePremium.charges_from' => ({required Object price, required Object date}) => '${price} a partir de ${date}',
			'onboarding.feature_1.title' => 'Fature desde o dia um',
			'onboarding.feature_1.description' => 'Paywalls, assinaturas e período de teste prontos para produção. Sem montar backend de cobrança.',
			'onboarding.feature_1.action' => 'Continuar',
			'onboarding.feature_1.skip' => 'Pular',
			'onboarding.feature_1.login' => 'Já tem conta? Entrar',
			'onboarding.feature_2.title' => 'Login pronto para produção',
			'onboarding.feature_2.description' => 'E-mail, login social e recuperação de senha. Seguro e pronto para publicar.',
			'onboarding.feature_2.action' => 'Continuar',
			'onboarding.feature_2.back' => 'Voltar',
			'onboarding.feature_3.title' => 'Seu assistente de IA nativo',
			'onboarding.feature_3.description' => 'Um assistente de conversa pronto pra usar, já integrado ao app.',
			'onboarding.feature_3.action' => 'Continuar',
			'onboarding.mockups.paywall.title' => 'Premium',
			'onboarding.mockups.paywall.annual' => 'Anual',
			'onboarding.mockups.paywall.monthly' => 'Mensal',
			'onboarding.mockups.paywall.save_badge' => '-40%',
			'onboarding.mockups.paywall.price_year' => 'R\$ 39,99 / ano',
			'onboarding.mockups.paywall.price_month' => 'R\$ 4,99 / mês',
			'onboarding.mockups.paywall.cta' => 'Iniciar teste grátis',
			'onboarding.mockups.earnings.notify_title' => 'Novo assinante Pro',
			'onboarding.mockups.earnings.notify_subtitle' => 'Plano anual · +\$49.90',
			'onboarding.mockups.earnings.notify_time' => '1:40 PM',
			'onboarding.mockups.earnings.processing' => 'Processando pagamento…',
			'onboarding.mockups.earnings.summary_label' => 'Ganhos',
			'onboarding.mockups.earnings.summary_body' => 'Você ganhou \$312.40 esta semana de 14 novas assinaturas.',
			'onboarding.mockups.auth.welcome' => 'Bem-vindo de volta',
			'onboarding.mockups.auth.email_hint' => 'voce@email.com',
			'onboarding.mockups.auth.sign_in' => 'Entrar',
			'onboarding.mockups.auth.divider' => 'ou',
			'onboarding.mockups.notification.title' => 'Nova mensagem',
			'onboarding.mockups.notification.time' => 'agora',
			'onboarding.mockups.ai_chat.u1' => 'O que você faz?',
			'onboarding.mockups.ai_chat.a1' => 'Escrevo, resumo e respondo qualquer coisa em segundos.',
			'onboarding.mockups.ai_chat.u2' => 'Resuma minhas anotações',
			'onboarding.mockups.ai_chat.a2' => 'Pronto. Separei os 3 pontos principais de hoje.',
			'onboarding.ageQuestion.title' => 'Qual a sua idade?',
			'onboarding.ageQuestion.description' => 'Isso nos ajuda a personalizar a sua experiência.',
			'onboarding.ageQuestion.options.age18_30' => '18 a 30',
			'onboarding.ageQuestion.options.age31_40' => '31 a 40',
			'onboarding.ageQuestion.options.age41_50' => '41 a 50',
			'onboarding.ageQuestion.options.age51_60' => 'Mais de 50',
			'onboarding.ageQuestion.options.none' => 'Prefiro não dizer',
			'onboarding.ageQuestion.action' => 'Continuar',
			'onboarding.genderQuestion.title' => 'Como você se identifica?',
			'onboarding.genderQuestion.description' => 'Escolha o que combina com você. Pode pular se preferir.',
			'onboarding.genderQuestion.options.male' => 'Masculino',
			'onboarding.genderQuestion.options.female' => 'Feminino',
			'onboarding.genderQuestion.options.none' => 'Prefiro não dizer',
			'onboarding.genderQuestion.action' => 'Continuar',
			'onboarding.notifications.title' => 'Fique por dentro',
			'onboarding.notifications.description' => 'Só falamos com você quando realmente importa. Nada de spam.',
			'onboarding.notifications.continue_button' => 'Ativar notificações',
			'onboarding.notifications.skip_button' => 'Agora não',
			'onboarding.notifications.toasts.push_app_name' => 'Kasy',
			'onboarding.notifications.toasts.push_headline' => 'Seu resumo semanal está pronto',
			'onboarding.notifications.toasts.push_body' => 'Toque para abrir.',
			'onboarding.notifications.toasts.push_sent_at' => 'agora',
			'onboarding.notifications.toasts.subscriber_title' => 'Novo assinante Pro',
			'onboarding.notifications.toasts.subscriber_message' => 'Plano anual · +\$49,90',
			'onboarding.notifications.toasts.streak_title' => 'Sequência de 7 dias!',
			'onboarding.notifications.toasts.streak_message' => 'Você bateu sua meta diária de novo.',
			'onboarding.notifications.toasts.message_title' => 'Nova resposta',
			'onboarding.notifications.toasts.message_message' => 'Alguém respondeu na sua conversa.',
			'onboarding.notifications.toasts.reminder_title' => 'Começa em breve',
			'onboarding.notifications.toasts.reminder_message' => 'Sua sessão começa em 10 minutos.',
			'onboarding.notifications.toasts.payment_title' => 'Pagamento recebido',
			'onboarding.notifications.toasts.payment_message' => '+R\$ 12,50 creditados no seu saldo.',
			'onboarding.notifications.toasts.offer_title' => 'Oferta limitada',
			'onboarding.notifications.toasts.offer_message' => '50% off no anual — acaba hoje.',
			'onboarding.notifications.toasts.social_title' => 'Nova interação',
			'onboarding.notifications.toasts.social_message' => '3 pessoas curtiram sua publicação.',
			'onboarding.att.title' => 'Experiência personalizada',
			'onboarding.att.description' => 'A permissão ajuda a ajustar comunicações ao seu perfil. Não exibe anúncios dentro do app.',
			'onboarding.att.continue_button' => 'Continuar',
			'onboarding.att.skip_button' => 'Agora não',
			'onboarding.att.card.tag' => 'Privacidade',
			'onboarding.loading.welcome' => 'Conta criada.',
			'onboarding.loading.welcome_male' => 'Conta criada. Bem-vindo!',
			'onboarding.loading.welcome_female' => 'Conta criada. Bem-vinda!',
			'onboarding.loading.steps.account' => 'Criando sua conta',
			'onboarding.loading.steps.preferences' => 'Salvando suas preferências',
			'onboarding.loading.steps.ready' => 'Personalizando sua experiência',
			'feature_requests.title' => 'Ideias',
			'feature_requests.description' => 'Vote nas ideias ou envie a sua. Cada voz define o que construímos.',
			'feature_requests.community_ideas' => 'Ideias da comunidade',
			'feature_requests.no_requests' => 'Nenhuma ideia ainda',
			'feature_requests.no_requests_hint' => 'Seja o primeiro a sugerir um recurso ou melhoria.',
			'feature_requests.vote_success.title' => 'Voto registrado',
			'feature_requests.vote_success.description' => 'Obrigado por ajudar a definir as prioridades',
			'feature_requests.vote_error.title' => 'Já votado',
			'feature_requests.vote_error.description' => 'Você já votou nesta ideia',
			'feature_requests.add_feature.chip_label' => 'Add',
			'feature_requests.add_feature.title' => 'Enviar uma ideia',
			'feature_requests.add_feature.description' => 'Conte o que você gostaria de ver no app.',
			'feature_requests.add_feature.save_button' => 'Enviar',
			'feature_requests.add_feature.cancel' => 'Cancelar',
			'feature_requests.add_feature.title_label' => 'Título',
			'feature_requests.add_feature.title_hint' => 'Um título curto e descritivo',
			'feature_requests.add_feature.description_label' => 'Descrição',
			'feature_requests.add_feature.description_hint' => 'Descreva o recurso ou melhoria em detalhes...',
			'feature_requests.add_feature.error_title' => 'Erro',
			'feature_requests.add_feature.error_required' => 'Título e descrição são obrigatórios',
			'feature_requests.add_feature.error_sending' => 'Algo deu errado. Tente novamente.',
			'feature_requests.add_feature.error_too_short' => 'Descrição muito curta. Adicione mais detalhes',
			'feature_requests.add_feature.toast_success.title' => 'Ideia enviada',
			'feature_requests.add_feature.toast_success.description' => 'Vamos analisar e te dar um retorno',
			'update_bottom_sheet.title' => 'O que há de novo?',
			'update_bottom_sheet.description' => 'Fizemos algumas melhorias',
			'update_bottom_sheet.highlights.0' => '- Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
			'update_bottom_sheet.highlights.1' => '- Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
			'update_bottom_sheet.highlights.2' => '- Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
			'update_bottom_sheet.continue_button' => 'Entendi',
			'update_available.title' => 'Atualização disponível',
			'update_available.description' => 'Há uma versão mais nova do app. Atualize para ter as últimas melhorias e correções.',
			'update_available.forced_title' => 'Atualização necessária',
			'update_available.forced_description' => 'Esta versão não é mais suportada. Atualize para continuar usando o app.',
			'update_available.update_button' => 'Atualizar agora',
			'update_available.later_button' => 'Agora não',
			'request_notification_permission.title' => 'Ativar notificações?',
			'request_notification_permission.description' => 'Receba atualizações em tempo real e fique sempre por dentro do que importa.',
			'request_notification_permission.continue_button' => 'Ativar',
			'request_notification_permission.skip_button' => 'Agora não',
			'notification_permission_denied.title' => 'Permissão necessária',
			'notification_permission_denied.description' => 'Para receber notificações, ative as permissões de notificação nas configurações do dispositivo.',
			'notification_permission_denied.allow_button' => 'Permitir notificações',
			'notification_permission_denied.open_settings_button' => 'Abrir configurações',
			'notification_permission_denied.cancel_button' => 'Cancelar',
			'review_popup.question_title' => 'Está gostando do app?',
			'review_popup.question_description' => 'Sua resposta ajuda a gente a melhorar.',
			'review_popup.question_positive' => 'Sim, estou gostando',
			'review_popup.question_negative' => 'Poderia melhorar',
			'review_popup.title' => 'Que bom que curtiu!',
			'review_popup.description' => 'Uma avaliação na loja faz toda a diferença. Leva poucos segundos e ajuda demais a gente a crescer.',
			'review_popup.rate_button' => 'Escrever uma avaliação',
			'navigation.home' => 'Início',
			'navigation.support' => 'Ajuda',
			'navigation.notifications' => 'Notificações',
			'navigation.settings' => 'Config.',
			'navigation.logout' => 'Sair',
			'navigation.skip_to_content' => 'Pular para o conteúdo',
			'reminderPage.title' => 'Lembretes',
			'reminderPage.toggleLabel' => 'Ativar lembrete',
			'reminderPage.typeLabel' => 'Repetir',
			'reminderPage.daily' => 'Todo dia',
			'reminderPage.weekly' => 'Toda semana',
			'reminderPage.specificDate' => 'Uma vez',
			'reminderPage.timeLabel' => 'Horário',
			'reminderPage.dayLabel' => 'Dia da semana',
			'reminderPage.dateLabel' => 'Data',
			'reminderPage.selectDate' => 'Selecionar data',
			'reminderPage.hint' => 'Receba um lembrete para voltar ao app',
			'reminderPage.summaryDaily' => ({required Object time}) => 'Todo dia às ${time}',
			'reminderPage.summaryWeekly' => ({required Object day, required Object time}) => 'Toda semana, ${day} às ${time}',
			'reminderPage.summaryDate' => ({required Object date, required Object time}) => 'Em ${date} às ${time}',
			'time_picker.title' => 'Selecione o horário',
			'time_picker.placeholder' => 'Selecione um horário',
			'time_picker.hour' => 'Hora',
			'time_picker.minute' => 'Minuto',
			'time_picker.am' => 'AM',
			'time_picker.pm' => 'PM',
			'time_picker.confirm' => 'OK',
			'time_picker.cancel' => 'Cancelar',
			'dailyReminder.title' => 'Lembrete',
			'dailyReminder.body' => 'Está na hora de beber água.',
			'settings.title' => 'Configurações',
			'settings.avatar.title' => 'Foto do perfil',
			'settings.avatar.take_photo' => 'Tirar foto',
			'settings.avatar.choose_library' => 'Biblioteca de fotos',
			'settings.avatar.remove_photo' => 'Remover foto',
			'settings.avatar.cancel' => 'Cancelar',
			'settings.language_title' => 'Idiomas',
			'settings.theme_title' => 'Tema',
			'settings.theme_option_system' => 'Sistema',
			'settings.theme_option_light' => 'Claro',
			'settings.theme_option_dark' => 'Escuro',
			'settings.haptic_feedback_title' => 'Feedback háptico',
			'settings.hide_chrome_on_scroll_title' => 'Ocultar barras ao rolar',
			'settings.section_preferences_label' => 'PREFERÊNCIAS',
			'settings.section_security_label' => 'SEGURANÇA',
			'settings.section_support_label' => 'AJUDA',
			'settings.biometric_title' => 'Bloqueio do app',
			'settings.biometric_subtitle_ios' => 'Exige Face ID ou Touch ID ao abrir com sessão ativa.',
			'settings.biometric_subtitle_ios_face' => 'Exige Face ID ao abrir com sessão ativa.',
			'settings.biometric_subtitle_ios_touch' => 'Exige Touch ID ao abrir com sessão ativa.',
			'settings.biometric_subtitle_android' => 'Pedimos uma confirmação no celular sempre que você abrir com sessão ativa.',
			'settings.biometric_subtitle_android_face' => 'Exige desbloqueio facial ao abrir com sessão ativa.',
			'settings.biometric_subtitle_android_fingerprint' => 'Exige impressão digital ao abrir com sessão ativa.',
			'settings.biometric_subtitle_android_face_and_fingerprint' => 'Exige impressão digital ou desbloqueio facial ao abrir com sessão ativa.',
			'settings.biometric_disable_title' => 'Desligar bloqueio?',
			_ => null,
		} ?? switch (path) {
			'settings.biometric_disable_message' => 'Sem bloqueio, quem pegar no celular desbloqueado abre o app até você sair da conta.',
			'settings.biometric_disable_confirm' => 'Desligar',
			'settings.biometric_disable_cancel' => 'Cancelar',
			'settings.biometric_enable_reason_ios' => 'Confirme com Face ID ou Touch ID para ativar o bloqueio',
			'settings.biometric_enable_reason_ios_face' => 'Confirme com Face ID para ativar o bloqueio',
			'settings.biometric_enable_reason_ios_touch' => 'Confirme com Touch ID para ativar o bloqueio',
			'settings.biometric_enable_reason_android' => 'Confirme no celular para ativar o bloqueio',
			'settings.biometric_enable_reason_android_face' => 'Confirme com desbloqueio facial para ativar o bloqueio',
			'settings.biometric_enable_reason_android_fingerprint' => 'Confirme com impressão digital para ativar o bloqueio',
			'settings.biometric_enable_reason_android_face_and_fingerprint' => 'Confirme com digital ou rosto para ativar o bloqueio',
			'settings.biometric_login_reason_ios' => 'Desbloqueie com Face ID ou Touch ID',
			'settings.biometric_login_reason_ios_face' => 'Desbloqueie com Face ID',
			'settings.biometric_login_reason_ios_touch' => 'Desbloqueie com Touch ID',
			'settings.biometric_login_reason_android' => 'Confirme sua identidade',
			'settings.biometric_login_reason_android_face' => 'Desbloqueie com desbloqueio facial',
			'settings.biometric_login_reason_android_fingerprint' => 'Desbloqueie com impressão digital',
			'settings.biometric_login_reason_android_face_and_fingerprint' => 'Desbloqueie com digital ou rosto',
			'settings.biometric_unavailable_message_ios' => 'Ative Face ID, Touch ID ou código em Ajustes.',
			'settings.biometric_unavailable_message_ios_face' => 'Ative Face ID ou código do aparelho em Ajustes.',
			'settings.biometric_unavailable_message_ios_touch' => 'Ative Touch ID ou código do aparelho em Ajustes.',
			'settings.biometric_unavailable_message_android' => 'Ative biometria ou um bloqueio de tela nas definições do telefone.',
			'settings.biometric_unavailable_message_android_face' => 'Cadastre rosto ou bloqueio de tela nos ajustes.',
			'settings.biometric_unavailable_message_android_fingerprint' => 'Cadastre impressão digital ou bloqueio de tela nos ajustes.',
			'settings.biometric_unavailable_message_android_face_and_fingerprint' => 'Cadastre impressão digital ou rosto nas definições do telefone.',
			'settings.biometric_not_enabled_message' => 'Bloqueio do app não foi ativado.',
			'settings.feedback' => 'Enviar feedback',
			'settings.premium' => 'Premium',
			'settings.billing' => 'Cobrança',
			'settings.privacy' => 'Política de privacidade',
			'settings.support' => 'Central de ajuda',
			'settings.disconnect' => 'Sim, sair',
			'settings.disconnect_confirm_title' => 'Sair da conta?',
			'settings.disconnect_confirm_message' => 'Tem certeza que deseja sair?',
			'settings.disconnect_cancel' => 'Cancelar',
			'settings.logout' => 'Sair',
			'settings.my_account' => 'Minha conta',
			'settings.not_signed_in' => 'Não conectado',
			'settings.register' => 'Cadastrar',
			'settings.name_label' => 'Nome',
			'settings.edit' => 'Editar',
			'settings.email_label' => 'Email',
			'settings.connected_with_label' => 'Conectado com',
			'settings.provider_email' => 'E-mail e senha',
			'settings.provider_phone' => 'Telefone',
			'settings.create_password_title' => 'Criar senha',
			'settings.create_password_subtitle' => 'Defina uma senha para também entrar com e-mail e senha, além do login social.',
			'settings.create_password_field' => 'Nova senha',
			'settings.create_password_confirm_label' => 'Confirmar senha',
			'settings.create_password_success' => 'Senha criada',
			'settings.create_password_error' => 'Não foi possível criar a senha. Tente novamente.',
			'settings.create_password_too_short' => 'A senha deve ter pelo menos 6 caracteres',
			'settings.create_password_mismatch' => 'As senhas não coincidem',
			'settings.link_social' => ({required Object provider}) => 'Vincular ${provider}',
			'settings.link_social_success' => ({required Object provider}) => '${provider} vinculado',
			'settings.link_social_error' => 'Não foi possível vincular. Tente novamente.',
			'settings.edit_name_title' => 'Editar nome',
			'settings.edit_name_hint' => 'Seu nome',
			'settings.edit_name_save' => 'Salvar',
			'settings.edit_name_cancel' => 'Cancelar',
			'settings.edit_name_success' => 'Nome atualizado',
			'settings.edit_name_error' => 'Não foi possível atualizar seu nome. Tente novamente.',
			'settings.reminders' => 'Lembretes',
			'settings.admin_panel' => 'Painel Admin',
			'settings.admin_debug_section_label' => 'ADMIN (SÓ EM DEBUG)',
			'settings.admin_panel_debug_notice' => 'Toda esta seção Admin (título, painel e opções) só existe em build de debug. Em release esse bloco não é incluído; quem instala pela loja ou por APK de produção não vê nada disso.',
			'settings.delete_account.button' => 'Quero excluir minha conta',
			'settings.delete_account.title' => 'Quer excluir sua conta?',
			'settings.delete_account.content' => 'Atenção: esta ação é permanente e não pode ser desfeita.',
			'settings.delete_account.content_subscriber' => 'Atenção: esta ação é permanente. Você perde sua assinatura ativa, e criar uma nova conta depois (mesmo com o mesmo e-mail) não recupera ela.',
			'settings.delete_account.cancel' => 'Cancelar',
			'settings.delete_account.confirm' => 'Sim, excluir',
			'settings.delete_account.error' => 'Algo deu errado. Por favor, tente novamente.',
			'settings.admin.update_bottom_sheet' => 'Pré-visualizar novidades',
			'settings.admin.preview_update_available' => 'Pré-visualizar atualização disponível',
			'settings.admin.paywalls' => 'Paywalls',
			'settings.admin.test_onboarding' => 'Testar onboarding',
			'settings.admin.copy_user_id' => 'Copiar ID do usuário',
			'settings.admin.user_id_copied' => 'ID do usuário copiado para a área de transferência',
			'settings.admin.copy_fcm_token' => 'Copiar FCM Token',
			'settings.admin.fcm_token_copied' => 'FCM Token copiado para a área de transferência',
			'settings.admin.fcm_token_unavailable' => 'Token não disponível (notificações desativadas?)',
			'settings.admin.ask_notification' => 'Pedir permissão de notificação',
			'settings.admin.native_only' => 'Disponível apenas no app nativo (iOS / Android)',
			'settings.admin.ask_review' => 'Pedir avaliação',
			'settings.admin.home_widgets_panel' => 'Painel de Home Widgets',
			'settings.admin.home_widgets_title' => 'Painel de Home Widgets',
			'settings.admin.ads_demo_panel' => 'Demo de anúncios',
			'settings.admin.ads_demo_title' => 'Demo de anúncios',
			'settings.admin.ads_demo_subtitle' => 'Os quatro formatos do AdMob com anúncios de teste do Google. Teste cada um e coloque onde quiser no seu app.',
			'settings.admin.ads_banner_label' => 'Banner',
			'settings.admin.ads_interstitial_title' => 'Intersticial',
			'settings.admin.ads_interstitial_desc' => 'Anúncio em tela cheia. Toque para mostrar.',
			'settings.admin.ads_rewarded_title' => 'Recompensado',
			'settings.admin.ads_rewarded_desc' => 'O usuário assiste para ganhar uma recompensa. Toque para mostrar.',
			'settings.admin.ads_rewarded_interstitial_title' => 'Recompensado intersticial',
			'settings.admin.ads_rewarded_interstitial_desc' => 'Anúncio em tela cheia que também dá recompensa. Toque para mostrar.',
			'settings.admin.ads_reward_earned' => ({required Object amount, required Object type}) => 'Recompensa ganha: ${amount} ${type}',
			'settings.admin.ads_load_failed' => 'Não foi possível carregar o anúncio (sem preenchimento). Tente de novo em instantes.',
			'settings.admin.ads_code_copied' => 'Código copiado para a área de transferência',
			'settings.admin.ads_status_safe' => 'Esta demo sempre mostra anúncios de teste do Google, então é seguro tocar, mesmo em produção.',
			'settings.admin.ads_status_test' => 'Seus ad ids reais ainda não estão definidos. Configure para ir ao ar:',
			'settings.admin.ads_status_real' => 'Ad ids reais configurados para esta plataforma.',
			'settings.admin.inspector_fab_title' => 'Inspector de widgets',
			'settings.admin.inspector_fab_subtitle_prefix' => 'Atalho global:',
			'settings.admin.update_mywidget_title' => 'Atualizar Widget MyWidget',
			'settings.admin.update_mywidget_desc' => 'Chamar atualização manual para o widget MyWidget',
			'settings.admin.paywalls_title' => 'Painel Admin de Paywalls',
			'settings.admin.send_push_title' => 'Enviar notificação',
			'settings.admin.send_push_to_all' => 'Enviar para todos',
			'settings.admin.send_push_email_hint' => 'Adicionar e-mail',
			'settings.admin.send_push_title_label' => 'Título',
			'settings.admin.send_push_title_hint' => 'Ex: Nova atualização disponível',
			'settings.admin.send_push_body_label' => 'Mensagem',
			'settings.admin.send_push_body_hint' => 'Até 3 linhas na lista do app (máx. 140 caracteres)',
			'settings.admin.send_push_image_label' => 'URL da imagem (opcional)',
			'settings.admin.send_push_image_hint' => 'https://...',
			'settings.admin.send_push_email_label' => 'E-mails dos destinatários',
			'settings.admin.send_push_success' => 'Notificação enviada!',
			'settings.admin.send_push_user_not_found' => ({required Object email}) => 'Usuário não encontrado: ${email}',
			'settings.admin.send_push_send_button' => 'Enviar',
			'settings.admin.send_push_required' => 'Título e mensagem são obrigatórios',
			'settings.admin.send_push_no_emails' => 'Adicione pelo menos um e-mail',
			'settings.admin.send_push_route_label' => 'Página ao abrir',
			'settings.admin.send_push_route_description' => 'Tela aberta quando o usuário toca na notificação.',
			'settings.admin.send_push_route_notifications' => 'Notificações',
			'settings.admin.send_push_route_home' => 'Início',
			'settings.admin.send_push_route_settings' => 'Configurações',
			'settings.admin.send_push_route_premium' => 'Premium',
			'settings.admin.send_push_route_reminder' => 'Lembretes',
			'settings.admin.send_push_route_feedback' => 'Feedback',
			'settings.admin.send_push_preview_label' => 'Prévia',
			'settings.admin.send_push_preview_now' => 'agora',
			'settings.admin.send_push_preview_title_placeholder' => 'Título da notificação',
			'settings.admin.send_push_preview_body_placeholder' => 'O corpo da mensagem aparece aqui',
			'settings.admin.device_preview_title' => 'Device Preview (somente web)',
			'settings.admin.send_push_section_recipients' => 'Destinatários',
			'settings.admin.send_push_section_content' => 'Conteúdo',
			'settings.admin.send_push_section_advanced' => 'Avançado',
			'settings.admin.send_push_audience_all' => 'Todos',
			'settings.admin.send_push_audience_specific' => 'Específicos',
			'settings.admin.send_push_audience_all_hint' => 'A notificação será enviada para todos os usuários inscritos.',
			'rate_banner.title' => 'Você gostou do nosso app?',
			'rate_banner.text' => 'Você teria um minuto para nos avaliar na loja?',
			'rate_banner.rate_button' => 'Sim, claro!',
			'rate_banner.later_button' => 'Mais tarde...',
			'notifications.title' => 'Notificações',
			'notifications.empty_title' => 'Nenhuma notificação ainda',
			'notifications.empty_subtitle' => 'Fique ligado nas atualizações',
			'notifications.error_fetching' => 'Erro ao buscar notificações',
			'notifications.push_title' => 'Notificações push',
			'notifications.push_subtitle_enabled' => 'Você está recebendo alertas',
			'notifications.push_subtitle_disabled' => 'Toque para ativar nas configurações',
			'notifications.push_subtitle_waiting' => 'Ative para não perder novidades',
			'notifications.mark_all_read' => 'Marcar lidas',
			'notifications.see_all' => 'Ver todas',
			'notifications.group_today' => 'Hoje',
			'notifications.group_yesterday' => 'Ontem',
			'notifications.group_older' => 'Mais antigas',
			'notifications.empty_cta' => 'Ativar notificações',
			'notifications.empty_cta_open_settings' => 'Abrir configurações',
			'notifications.delete_all' => 'Excluir tudo',
			'notifications.options' => 'Opções',
			'notifications.delete_all_confirm_title' => 'Excluir todas as notificações?',
			'notifications.delete_all_confirm_message' => 'Isso vai remover todas as notificações da sua conta. Essa ação não pode ser desfeita.',
			'notifications.delete_action' => 'Sim, excluir',
			'notifications.cancel_action' => 'Cancelar',
			'notifications.deleted_one' => 'Notificação excluída',
			'notifications.deleted_all' => 'Todas as notificações foram excluídas',
			'bottom_router.fake_page_text' => 'Esta é uma página de exemplo',
			'ai_chat.title' => 'Assistente IA',
			'ai_chat.empty_state' => 'Inicie uma conversa com seu assistente.',
			'ai_chat.hint' => 'Pergunte algo...',
			'ai_chat.error_not_configured' => 'O assistente ainda não está disponível. Tente novamente mais tarde.',
			'ai_chat.error_no_reply' => 'Não conseguimos obter uma resposta. Tente de novo.',
			'ai_chat.error_network' => 'Não foi possível conectar ao assistente de IA.',
			'ai_chat.new_conversation' => 'Nova conversa',
			'ai_chat.conversations_empty' => 'Nenhuma conversa ainda',
			'ai_chat.conversations_empty_hint' => 'Toque em Nova conversa para começar.',
			'ai_chat.no_conversation_selected' => 'Escolha uma conversa ou comece uma nova.',
			'ai_chat.delete_title' => 'Excluir conversa?',
			'ai_chat.delete_message' => 'Esta conversa e todas as mensagens serão excluídas permanentemente.',
			'ai_chat.delete_cancel' => 'Cancelar',
			'ai_chat.delete_confirm' => 'Sim, excluir',
			'phone_auth.title_input' => 'Autenticação por Telefone',
			'phone_auth.subtitle_input' => 'Digite seu número de telefone',
			'phone_auth.description_input' => 'Enviaremos um código de verificação para confirmar sua identidade',
			'phone_auth.phone_label' => 'Número de telefone',
			'phone_auth.phone_hint' => '+55 (11) 91234-5678',
			'phone_auth.error_empty' => 'Por favor, digite um número de telefone',
			'phone_auth.error_invalid' => 'Por favor, digite um número válido',
			'phone_auth.continue_btn' => 'Continuar',
			'phone_auth.title_verify' => 'Verificar Código',
			'phone_auth.verification_code' => 'Código de Verificação',
			'phone_auth.code_sent' => ({required Object phone}) => 'Enviamos um código de verificação para ${phone}',
			'phone_auth.signin_success_title' => 'Tudo certo',
			'phone_auth.signin_success_text' => 'Você entrou com seu número de telefone',
			'phone_auth.verify_code' => 'Verificar Código',
			'phone_auth.resend_code' => 'Reenviar Código',
			'phone_auth.enter_all_digits' => 'Por favor, digite todos os 6 números',
			'recover_password_result.title' => 'E-mail enviado',
			'recover_password_result.description' => 'Enviamos um e-mail com um link para redefinir sua senha',
			'recover_password_result.back_to_signin' => 'Voltar para o Login',
			'recover_password_result.note' => 'Nota: Se você não receber um e-mail, verifique sua pasta de spam',
			'page_not_found.title' => '404 - Página não encontrada',
			'devInspector.copied' => 'Contexto copiado. Cole no chat da IA.',
			'devInspector.activate' => 'Ativar inspetor de widgets',
			'devInspector.deactivate' => 'Desativar inspetor de widgets',
			'devInspector.copyForAi' => 'Copiar para IA',
			'devInspector.selectWidgetFirst' => 'Selecione um widget na tela primeiro.',
			'devInspector.inspectorHint' => 'Toque em um widget para selecionar. O contexto copia automaticamente. Tecla C para copiar de novo.',
			'devInspector.statusActive' => 'Inspecionando',
			'webDevicePreview.frame' => 'Frame',
			'webDevicePreview.darkBackground' => 'Fundo escuro',
			'webDevicePreview.darkTheme' => 'Tema escuro',
			'webDevicePreview.landscape' => 'Paisagem',
			'webDevicePreview.textScale' => 'Escala de texto',
			'webDevicePreview.screenshot' => 'Screenshot',
			'webDevicePreview.imageCopied' => 'Imagem copiada — cole no chat',
			'webDevicePreview.imageDownloaded' => 'Imagem baixada',
			'webDevicePreview.hotReload' => 'Hot reload',
			'webDevicePreview.hotRestart' => 'Hot restart',
			'webDevicePreview.hotReloading' => 'Recarregando…',
			'webDevicePreview.hotRestarting' => 'Reiniciando…',
			'webDevicePreview.hotReloadDone' => 'Reload concluído',
			'webDevicePreview.hotRestartDone' => 'Restart concluído',
			'webDevicePreview.hotReloadFailed' => 'Falha no reload',
			'webDevicePreview.hotReloadNeedsRestart' => 'Essa mudança precisa de restart — use o botão R',
			'webDevicePreview.hotReloadCompileError' => 'Erro no código — corrija no editor e recarregue',
			'webDevicePreview.hotRestartFailed' => 'Falha no restart',
			'webDevicePreview.hotRestartCompileError' => 'Erro no código — corrija no editor e reinicie',
			'webDevicePreview.terminalStatusOk' => 'Terminal ok — pode usar o r',
			'webDevicePreview.terminalStatusError' => 'Terminal com erro — corrija ou use o R',
			'webDevicePreview.terminalStatusOffline' => 'Ponte do terminal offline — use kasy run --web',
			'webDevicePreview.devBridgeUnavailable' => 'Servidor dev offline — rode kasy run --web, deixe o terminal aberto e abra a URL que aparecer',
			'biometric_prompt.title_ios_face' => 'Ativar Face ID no bloqueio do app?',
			'biometric_prompt.title_ios_touch' => 'Ativar Touch ID no bloqueio do app?',
			'biometric_prompt.title_ios_mixed' => 'Ativar Face ID ou Touch ID no bloqueio?',
			'biometric_prompt.title_android_face' => 'Ativar bloqueio com desbloqueio facial?',
			'biometric_prompt.title_android_fingerprint' => 'Ativar bloqueio com impressão digital?',
			'biometric_prompt.title_android_mixed' => 'Proteger o app com biometria?',
			'biometric_prompt.message_ios_face' => 'Ao abrir, você confirma com Face ID — continua na conta.',
			'biometric_prompt.message_ios_touch' => 'Ao abrir, você confirma com Touch ID — continua na conta.',
			'biometric_prompt.message_ios_mixed' => 'Ao abrir, usa Face ID ou Touch ID — continua na conta.',
			'biometric_prompt.message_android_face' => 'Ao abrir, confirme com reconhecimento facial — continua na conta.',
			'biometric_prompt.message_android_fingerprint' => 'Ao abrir, confirme com impressão digital — continua na conta.',
			'biometric_prompt.title_android_face_and_fingerprint' => 'Ativar bloqueio com digital ou rosto?',
			'biometric_prompt.message_android_face_and_fingerprint' => 'Qualquer um serve — continua na conta.',
			'biometric_prompt.message_android_mixed' => 'Confirmação rápida ao abrir — continua na conta.',
			'biometric_prompt.not_now' => 'Agora não',
			'biometric_prompt.enable' => 'Ativar',
			'home_widget.greeting_morning' => 'Bom dia',
			'home_widget.greeting_afternoon' => 'Boa tarde',
			'home_widget.greeting_evening' => 'Boa noite',
			'home_widget.title_with_name' => ({required Object name}) => 'Olá, ${name}!',
			'home_widget.title_default' => 'Olá!',
			'home_widget.title_logged_out' => 'Aguardamos seu retorno',
			'home_widget.plan_free' => 'Plano grátis',
			'home_widget.plan_pro' => 'PRO',
			'home_widget.quote' => 'Seu tempo é limitado.\nNão viva a vida de outra pessoa.\nTenha coragem de seguir sua intuição.\nTodo o resto é secundário.',
			'home_widget.quote_author' => 'Steve Jobs',
			'kanban.title' => 'Tarefas',
			'kanban.empty_title' => 'Organize suas tarefas',
			'kanban.empty_description' => 'Crie colunas personalizadas e comece a organizar o que precisa ser feito no seu projeto.',
			'kanban.empty_column' => 'Nenhuma tarefa nesta coluna',
			'kanban.error_title' => 'Erro ao carregar',
			'kanban.add_column' => 'Adicionar coluna',
			'kanban.add_column_subtitle' => 'Escolha um nome curto para organizar suas tarefas nesta coluna.',
			'kanban.add_another_list' => 'Adicionar outra lista',
			'kanban.add_list' => 'Adicionar Lista',
			'kanban.list_name_hint' => 'Digite o nome da lista...',
			'kanban.add_task' => 'Adicionar tarefa',
			'kanban.add_task_subtitle' => 'Defina o titulo e, se quiser, uma descricao e a prioridade.',
			'kanban.edit_column' => 'Editar coluna',
			'kanban.edit_task_subtitle' => 'Atualize os detalhes desta tarefa.',
			'kanban.cancel' => 'Cancelar',
			'kanban.save' => 'Salvar',
			'kanban.delete_column' => 'Excluir coluna',
			'kanban.edit_task' => 'Editar tarefa',
			'kanban.delete_task' => 'Excluir tarefa',
			'kanban.column_name' => 'Nome da coluna',
			'kanban.column_name_hint' => 'Ex: Em andamento, Concluído',
			'kanban.task_title' => 'Título da tarefa',
			'kanban.task_title_hint' => 'Ex: Implementar login',
			'kanban.task_title_required' => 'Informe um título para a tarefa.',
			'kanban.column_name_required' => 'Informe um nome para a coluna.',
			'kanban.task_description' => 'Descrição',
			'kanban.task_description_hint' => 'Detalhes sobre a tarefa',
			'kanban.create' => 'Criar',
			'kanban.mark_complete' => 'Marcar como concluída',
			'kanban.mark_incomplete' => 'Marcar como pendente',
			'kanban.column_created' => 'Coluna criada',
			'kanban.column_updated' => 'Coluna atualizada',
			'kanban.column_deleted' => 'Coluna excluída',
			'kanban.task_created' => 'Tarefa criada',
			'kanban.task_updated' => 'Tarefa atualizada',
			'kanban.task_deleted' => 'Tarefa excluída',
			'kanban.priority' => 'Prioridade',
			'kanban.priority_none' => 'Nenhuma',
			'kanban.priority_low' => 'Baixa',
			'kanban.priority_medium' => 'Media',
			'kanban.priority_high' => 'Alta',
			'kanban.priority_urgent' => 'Urgente',
			'kanban.cards_count' => ({required Object count}) => '${count} cards',
			'kanban.move_to' => 'Mover para coluna',
			'kanban.move_left' => 'Mover para esquerda',
			'kanban.move_right' => 'Mover para direita',
			'kanban.delete_column_confirm' => 'Isso excluira permanentemente todos os cards desta coluna.',
			'kanban.delete_task_confirm' => 'Esta tarefa sera excluida permanentemente.',
			'kanban.created_on' => ({required Object date}) => 'Criado em ${date}',
			'library.title' => 'Biblioteca',
			'library.categories' => 'Categorias',
			'library.manage_categories' => 'Gerenciar Categorias',
			'library.add_category' => 'Adicionar Categoria',
			'library.edit_category' => 'Editar Categoria',
			'library.delete_category' => 'Excluir Categoria',
			'library.category_name' => 'Nome da Categoria',
			'library.category_desc' => 'Descrição da Categoria',
			'library.save' => 'Salvar',
			'library.cancel' => 'Cancelar',
			'library.pdfs' => 'PDFs',
			'library.favorites' => 'Favoritos',
			'library.search_hint' => 'Buscar por título, autor ou tag...',
			'library.add_pdf' => 'Cadastrar PDF',
			'library.edit_pdf' => 'Editar PDF',
			'library.delete_pdf' => 'Excluir PDF',
			'library.pdf_title' => 'Título',
			'library.pdf_desc' => 'Descrição',
			'library.pdf_author' => 'Autor',
			'library.pdf_url' => 'URL do arquivo PDF',
			'library.pdf_thumb' => 'URL da miniatura (capa)',
			'library.pdf_tags' => 'Tags (separadas por vírgula)',
			'library.no_pdfs' => 'Nenhum PDF encontrado',
			'library.comments' => 'Comentários',
			'library.write_comment' => 'Escreva um comentário...',
			'library.submit_comment' => 'Enviar Comentário',
			'library.rating' => 'Avaliação',
			'library.download' => 'Baixar',
			'library.read' => 'Ler',
			'library.unauthorized' => 'Você precisa ser administrador para ver esta página.',
			'library.profile_switcher' => 'Trocar Perfil',
			'library.active_profile' => 'Perfil Ativo',
			'library.admin_dev' => 'Admin / Dev',
			'library.client' => 'Cliente',
			'library.read_sim' => 'Leitor Simulado',
			'library.prev_page' => 'Anterior',
			'library.next_page' => 'Próxima',
			'library.zoom_in' => 'Mais Zoom',
			'library.zoom_out' => 'Menos Zoom',
			'library.page_info' => ({required Object page, required Object total}) => 'Página ${page} de ${total}',
			'library.no_comments' => 'Nenhum comentário ainda. Seja o primeiro a comentar!',
			'library.my_pdfs' => 'Meus PDFs',
			'library.send_pdf' => 'Enviar PDF',
			'library.no_client_pdfs' => 'Nenhum PDF enviado por clientes ainda.',
			'library.upload_box_title' => 'Clique para fazer upload do seu PDF',
			'library.upload_box_subtitle' => 'Formato suportado: PDF (Máx. 10MB)',
			'library.pdf_preview' => 'Pré-visualização do PDF',
			'library.pages' => 'Páginas',
			'library.change_file' => 'Alterar Arquivo',
			'library.explore' => 'Explorar',
			'library.visit_profile' => 'Visitar perfil',
			'library.no_public_pdfs' => 'Nenhum PDF público enviado por outros usuários ainda.',
			'library.uploaded_by' => 'Enviado por',
			'library.sent_by' => 'Enviado por',
			'library.public_profile' => 'Perfil Público',
			'library.view_all_pdfs' => 'Ver todos os PDFs enviados por este usuário',
			_ => null,
		};
	}
}
