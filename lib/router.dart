import 'package:cowboydodartinc/core/bottom_menu/bart_inner_navigation.dart';
import 'package:cowboydodartinc/core/bottom_menu/bottom_menu.dart';
import 'package:cowboydodartinc/core/bottom_menu/web_url.dart';
import 'package:cowboydodartinc/core/chrome/chrome_visibility.dart';
import 'package:cowboydodartinc/core/config/features.dart';
import 'package:cowboydodartinc/core/data/api/analytics_api.dart';
import 'package:cowboydodartinc/core/data/models/user.dart';
import 'package:cowboydodartinc/core/navigation/dev_route_memory.dart';
import 'package:cowboydodartinc/core/navigation/kasy_navigation_config.dart';
import 'package:cowboydodartinc/core/navigation/kasy_page_transition.dart';
import 'package:cowboydodartinc/core/security/biometric_guard.dart';
import 'package:cowboydodartinc/core/states/user_state_notifier.dart';
import 'package:cowboydodartinc/core/widgets/page_not_found.dart';
import 'package:cowboydodartinc/features/authentication/ui/phone_auth_page.dart';
import 'package:cowboydodartinc/features/authentication/ui/recover_password_page.dart';
import 'package:cowboydodartinc/features/authentication/ui/signin_page.dart';
import 'package:cowboydodartinc/features/authentication/ui/signup_page.dart';
import 'package:cowboydodartinc/features/home/design_system_page.dart';
import 'package:cowboydodartinc/features/home/home_components_page.dart';
import 'package:cowboydodartinc/features/home/home_components_preview_page.dart';
import 'package:cowboydodartinc/features/home/home_components_preview_registry.dart';
import 'package:cowboydodartinc/features/library/ui/admin/manage_pdfs_page.dart';
import 'package:cowboydodartinc/features/library/ui/global_search_page.dart';
import 'package:cowboydodartinc/features/library/ui/pdf_detail_page.dart';
import 'package:cowboydodartinc/features/library/ui/pdf_reader_page.dart';
import 'package:cowboydodartinc/features/library/ui/uploader_profile_page.dart';
import 'package:cowboydodartinc/features/onboarding/ui/onboarding_page.dart';
import 'package:cowboydodartinc/features/settings/ui/components/admin/admin_home_widgets.dart';
import 'package:cowboydodartinc/features/settings/ui/components/admin/admin_page.dart';
import 'package:cowboydodartinc/features/settings/ui/components/admin/admin_routes.dart';
import 'package:cowboydodartinc/features/settings/ui/components/admin/ads_demo_page.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/component/premium_page_factory.dart';
import 'package:cowboydodartinc/features/subscriptions/ui/premium_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  // Re-run the auth redirect whenever the user state changes (sign-in, logout,
  // onboarding completion, guest continue). This is what makes navigation
  // reactive and reliable — the redirect replaces the old "navigate from inside
  // a widget's build()" pattern that could leave a black screen frozen until
  // the user tapped the screen.
  final refresh = ValueNotifier<int>(0);
  ref.listen(userStateNotifierProvider, (_, _) => refresh.value++);
  ref.onDispose(refresh.dispose);
  final router = generateRouter(ref: ref, refreshListenable: refresh);

  // Debug-only: keep the dev loop on the screen you're working on.
  //
  // The bottom bar (Bart) writes each tab's URL directly via history.pushState,
  // bypassing GoRouter, and a detail screen (e.g. /components, /admin) is PUSHED
  // on the root navigator OVER the tab — so the address bar keeps reading as the
  // underlying tab while GoRouter is really on the detail route. We mirror
  // GoRouter's true location to (a) SharedPreferences, so a hot restart can
  // resume it, and (b) on web the address bar, as you navigate — so the bar
  // stays honest and reload boots from the right URL in the first place.
  if (kDebugMode) {
    void persist() {
      final String loc = router.routerDelegate.currentConfiguration.uri.path;
      DevRouteMemory.save(loc);
      if (kIsWeb) syncBrowserUrl(loc);
    }

    router.routerDelegate.addListener(persist);
    ref.onDispose(() => router.routerDelegate.removeListener(persist));

    // Native honours `initialLocation` (no flash). Web ignores it and boots from
    // the address bar; if it's still stale, reconcile to the saved location once
    // the first frame settles (which also re-syncs the bar via the listener).
    final String? resume = DevRouteMemory.lastLocation;
    if (kIsWeb && resume != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final String current = router.routerDelegate.currentConfiguration.uri
            .toString();
        if (current != resume) router.go(resume);
      });
    }
  }

  return router;
});

extension GoRouterRiverpod on Ref {
  GoRouter get goRouter => read(goRouterProvider);
}

final navigatorKey = GlobalKey<NavigatorState>();



String? _authRedirect(Ref ref, GoRouterState state) {
  final userState = ref.read(userStateNotifierProvider);
  final user = userState.user;

  if (user is LoadingUserData) {
    return null;
  }

  final isAuthPath = state.uri.path == '/signin' ||
      state.uri.path == '/signup' ||
      state.uri.path == '/signinWithPhone' ||
      state.uri.path == '/recover' ||
      state.uri.path == '/recover_password';

  final isAnonymous = user is AnonymousUserData;
  final notifier = ref.read(userStateNotifierProvider.notifier);
  final isAuthRequired = notifier.mode == AuthenticationMode.authRequired;

  if (isAnonymous && isAuthRequired) {
    if (!isAuthPath) {
      return '/signin';
    }
  } else if (user is AuthenticatedUserData) {
    if (isAuthPath) {
      return '/';
    }
    final path = state.uri.path;
    final isAdminRoute = path.startsWith('/admin') || path.startsWith('/library/admin');
    if (isAdminRoute && !user.isAdmin) {
      return '/library';
    }
  }

  return null;
}

GoRouter generateRouter({
  required Ref ref,
  String? initialLocation,
  List<GoRoute>? additionalRoutes,
  List<NavigatorObserver>? observers,
  Listenable? refreshListenable,
}) {
  return GoRouter(
    initialLocation: initialLocation ?? DevRouteMemory.lastLocation ?? '/',
    navigatorKey: navigatorKey,
    refreshListenable: refreshListenable,
    redirect: (context, state) => _authRedirect(ref, state),
    // Catches unknown routes (e.g. an Android warm-start from the home widget
    // landed on a stale URI) and silently sends the user home instead of
    // surfacing a dead-end "404" page. We log the offending URI so a real
    // misconfigured route doesn't get masked.
    // Note: GoRouter doesn't accept both onException and errorBuilder, so the
    // /404 GoRoute below is what reaches PageNotFound when explicitly navigated.
    onException: (context, state, router) {
      Logger().w(
        'GoRouter caught unknown route → "${state.uri}" '
        '(matched: "${state.matchedLocation}", error: ${state.error}). '
        'Redirecting to "/".',
      );
      router.go('/');
    },
    observers: [
      AnalyticsObserver(analyticsApi: MixpanelAnalyticsApi.instance()),
      KasyChromeVisibilityObserver(),

      ...?observers,
    ],
    routes: [
      GoRoute(
        name: 'home',
        path: '/',
        pageBuilder: (context, state) => kasyTransitionPage(
          key: state.pageKey,
          child: const BiometricGuard(child: BottomMenu()),
        ),
      ),
      // Home showcase detail screens. These are TOP-LEVEL routes (siblings of
      // '/', not children of the BottomMenu shell), so go_router renders them on
      // the root navigator: full-screen, above the bottom bar, URL-addressable.
      // Returning pops back to the tab with its menu intact.
      GoRoute(
        name: 'design_system',
        path: '/design-system',
        pageBuilder: (context, state) => kasyTransitionPage(
          key: state.pageKey,
          child: const DesignSystemPage(),
        ),
      ),
      GoRoute(
        name: 'search',
        path: '/search',
        pageBuilder: (context, state) {
          final q = state.uri.queryParameters['q'];
          return kasyTransitionPage(
            key: state.pageKey,
            child: GlobalSearchPage(initialQuery: q),
          );
        },
      ),
      GoRoute(
        name: 'components',
        path: '/components',
        pageBuilder: (context, state) => kasyTransitionPage(
          key: state.pageKey,
          child: const HomeComponentsPage(),
        ),
        routes: [
          // /components/:name — a single component's preview, looked up from the
          // registry so the URL alone restores the screen on web reload.
          GoRoute(
            name: 'component_preview',
            path: ':name',
            pageBuilder: (context, state) {
              final ComponentPreviewDefinition? definition =
                  getComponentPreviewDefinition(
                    state.pathParameters['name'] ?? '',
                  );
              if (definition == null) {
                return kasyTransitionPage(
                  key: state.pageKey,
                  child: const PageNotFound(),
                );
              }
              return kasyTransitionPage(
                key: state.pageKey,
                child: HomeComponentsPreviewPage(
                  title: definition.title,
                  variants: definition.variants,
                ),
              );
            },
          ),
        ],
      ),
      GoRoute(
        name: 'onboarding',
        path: '/onboarding',
        pageBuilder: (context, state) => kasyTransitionPage(
          key: state.pageKey,
          // ?preview=true opens the flow as a side-effect-free walkthrough from
          // the admin Debug screen (no account creation, returns to Debug).
          child: OnboardingPage(
            preview: state.uri.queryParameters['preview'] == 'true',
          ),
        ),
      ),
      GoRoute(
        name: 'signup',
        path: '/signup',
        pageBuilder: (context, state) => kasyTransitionPage(
          key: state.pageKey,
          transition: KasyNavigationConfig.authPeer,
          child: const SignupPage(),
        ),
      ),
      GoRoute(
        name: 'signin',
        path: '/signin',
        pageBuilder: (context, state) => kasyTransitionPage(
          key: state.pageKey,
          transition: KasyNavigationConfig.authPeer,
          child: const SigninPage(),
        ),
      ),
      GoRoute(
        name: 'recover_password',
        path: '/recover_password',
        pageBuilder: (context, state) => kasyTransitionPage(
          key: state.pageKey,
          child: const RecoverPasswordPage(),
        ),
      ),
      GoRoute(
        name: 'signinWithPhone',
        path: '/signinWithPhone',
        pageBuilder: (context, state) => kasyTransitionPage(
          key: state.pageKey,
          child: const PhoneAuthPage(),
        ),
      ),
      if (withRevenuecat)
        GoRoute(
          name: 'premium',
          path: '/premium',
          pageBuilder: (context, state) => kasyPaywallRoutePage(
            context: context,
            key: state.pageKey,
            child: const PremiumPage(paywall: PaywallFactory.unlock),
          ),
        ),
      // Feedback and Reminders are sub-pages of Settings rendered INSIDE the
      // shell (inner routes — see [subRoutes]), so the sidebar stays put on
      // desktop. These top-level routes exist only as deep-link / reload entry
      // points: they open the shell directly on that inner route.
      if (withFeedback)
        GoRoute(
          name: 'feedback',
          path: '/feedback',
          redirect: (_, _) => settingsInnerPath('feedback'),
        ),
      if (withFeedback)
        GoRoute(
          name: 'settings_feedback',
          path: settingsInnerPath('feedback'),
          pageBuilder: (context, state) => kasyTransitionPage(
            key: state.pageKey,
            child: BiometricGuard(
              child: BottomMenu(
                initialRoute: settingsInnerPath('feedback'),
              ),
            ),
          ),
        ),
      if (withLocalReminders)
        GoRoute(
          name: 'reminder',
          path: '/reminder',
          redirect: (_, _) => settingsInnerPath('reminder'),
        ),
      if (withLocalReminders)
        GoRoute(
          name: 'settings_reminder',
          path: settingsInnerPath('reminder'),
          pageBuilder: (context, state) => kasyTransitionPage(
            key: state.pageKey,
            child: BiometricGuard(
              child: BottomMenu(
                initialRoute: settingsInnerPath('reminder'),
              ),
            ),
          ),
        ),
      // Tab deep links: open the BottomMenu shell on the right tab. They also
      // make a web reload resume onto the tab you were on (see DevRouteMemory).
      // Support is gated like its tab (withAiChat) so the route never dangles
      // when AI chat is off.
      if (withAiChat)
        GoRoute(
          name: 'support',
          path: '/support',
          pageBuilder: (context, state) => kasyTransitionPage(
            key: state.pageKey,
            child: const BiometricGuard(
              child: BottomMenu(initialRoute: 'support'),
            ),
          ),
        ),
      GoRoute(
        name: 'notifications',
        path: '/notifications',
        pageBuilder: (context, state) => kasyTransitionPage(
          key: state.pageKey,
          child: const BiometricGuard(
            child: BottomMenu(initialRoute: 'notifications'),
          ),
        ),
      ),
      GoRoute(
        name: 'settings',
        path: '/settings',
        pageBuilder: (context, state) => kasyTransitionPage(
          key: state.pageKey,
          child: const BiometricGuard(
            child: BottomMenu(initialRoute: 'settings'),
          ),
        ),
      ),
      GoRoute(
        name: 'explore',
        path: '/explore',
        pageBuilder: (context, state) => kasyTransitionPage(
          key: state.pageKey,
          child: const BiometricGuard(
            child: BottomMenu(initialRoute: 'explore'),
          ),
        ),
      ),
      GoRoute(
        name: 'profiles',
        path: '/library/profiles',
        pageBuilder: (context, state) => kasyTransitionPage(
          key: state.pageKey,
          child: const BiometricGuard(
            child: BottomMenu(initialRoute: 'profiles'),
          ),
        ),
      ),
      GoRoute(
        name: 'my_profile',
        path: '/library/my-profile',
        pageBuilder: (context, state) => kasyTransitionPage(
          key: state.pageKey,
          child: const BiometricGuard(
            child: BottomMenu(initialRoute: 'my-profile'),
          ),
        ),
      ),
      GoRoute(
        name: 'uploader_profile',
        path: '/library/uploader/:name',
        pageBuilder: (context, state) => kasyTransitionPage(
          key: state.pageKey,
          child: UploaderProfilePage(uploaderName: state.pathParameters['name'] ?? ''),
        ),
      ),
      GoRoute(
        name: 'library',
        path: '/library',
        pageBuilder: (context, state) => kasyTransitionPage(
          key: state.pageKey,
          child: const BiometricGuard(
            child: BottomMenu(initialRoute: 'library'),
          ),
        ),
      ),
      GoRoute(
        name: 'pdf_detail',
        path: '/library/pdf/:id',
        pageBuilder: (context, state) => kasyTransitionPage(
          key: state.pageKey,
          child: PdfDetailPage(pdfId: state.pathParameters['id'] ?? ''),
        ),
      ),
      GoRoute(
        name: 'pdf_reader',
        path: '/library/pdf/:id/read',
        pageBuilder: (context, state) => kasyTransitionPage(
          key: state.pageKey,
          child: PdfReaderPage(pdfId: state.pathParameters['id'] ?? ''),
        ),
      ),
      GoRoute(
        name: 'admin_cadastrar_pdf',
        path: '/library/admin/cadastrar-pdf',
        pageBuilder: (context, state) => kasyTransitionPage(
          key: state.pageKey,
          child: const ManagePdfsPage(),
        ),
      ),

      // Admin console: a StatefulShellRoute so every section is a real,
      // URL-addressable screen that keeps its own state while the navigation
      // rail persists across them. The top-level sections (/admin, /admin/users,
      // /admin/requests) and the four "Ferramentas" sub-screens (/admin/tools/*)
      // are ALL branches — each its own URL, reached from the sidebar. Registered
      // always (admins reach it in release too); the redirect above blocks
      // /admin* for non-admins in production. adminSections() is the single
      // source the sidebar reads too, so branches and nav rows stay aligned.
      StatefulShellRoute.indexedStack(
        // Enter /admin with the app's standard page transition
        // (KasyNavigationConfig.push), same as every other route — pageBuilder
        // (not builder), otherwise go_router falls back to its default platform
        // transition. Switching sections is instant (IndexedStack), like tabs.
        pageBuilder: (context, state, navigationShell) => kasyTransitionPage(
          key: state.pageKey,
          child: AdminShell(navigationShell: navigationShell),
        ),
        branches: [
          for (final section in adminSections())
            StatefulShellBranch(
              routes: [
                if (section.id == AdminSection.components)
                  GoRoute(
                    path: section.path,
                    pageBuilder: (context, state) => kasyTransitionPage(
                      key: state.pageKey,
                      child: section.build(),
                    ),
                    routes: [
                      GoRoute(
                        name: 'admin_design_system',
                        path: 'design-system',
                        pageBuilder: (context, state) => kasyAdminDrillDownPage(
                          key: state.pageKey,
                          child: const DesignSystemPage(),
                        ),
                      ),
                      GoRoute(
                        name: 'admin_component_preview',
                        path: 'preview/:name',
                        pageBuilder: (context, state) {
                          final ComponentPreviewDefinition? definition =
                              getComponentPreviewDefinition(
                                Uri.decodeComponent(
                                  state.pathParameters['name'] ?? '',
                                ),
                              );
                          if (definition == null) {
                            return kasyAdminDrillDownPage(
                              key: state.pageKey,
                              child: const PageNotFound(),
                            );
                          }
                          return kasyAdminDrillDownPage(
                            key: state.pageKey,
                            child: HomeComponentsPreviewPage(
                              title: definition.title,
                              variants: definition.variants,
                            ),
                          );
                        },
                      ),
                    ],
                  )
                else
                  GoRoute(
                    path: section.path,
                    pageBuilder: (context, state) => kasyTransitionPage(
                      key: state.pageKey,
                      child: section.build(),
                    ),
                  ),
              ],
            ),
        ],
      ),
      // Drill-downs pushed full-screen from inside the console (their own back
      // button) — the redirect above keeps /admin* admin-only.
      //
      // Paywall variant preview is pushed from the Paywalls section, which ships
      // in production, so it's registered always.
      GoRoute(
        name: 'admin_premium_preview',
        path: '/admin/premium/:variant',
        pageBuilder: (context, state) {
          final paywall = paywallFactoryFromAdminRoute(
            state.pathParameters['variant'],
          );
          if (paywall == null || !withRevenuecat) {
            return kasyTransitionPage(
              key: state.pageKey,
              child: const PageNotFound(),
            );
          }
          return kasyPaywallRoutePage(
            context: context,
            key: state.pageKey,
            // Admin Debug preview: show the paywall design without letting the
            // admin start a real purchase or manage their own subscription.
            child: PremiumPage(paywall: paywall, preview: true),
          );
        },
      ),
      // Home-widgets panel: debug + native only (no widgets on web).
      if (kDebugMode && !kIsWeb)
        GoRoute(
          name: 'admin_home_widgets',
          path: adminRouteHomeWidgets,
          pageBuilder: (context, state) => kasyTransitionPage(
            key: state.pageKey,
            child: const AdminHomeWidgets(),
          ),
        ),
      // Ads demo: native-only (AdMob does not run on web). Pushed from the Debug
      // section; access is still gated by the /admin role guard.
      if (!kIsWeb)
        GoRoute(
          name: 'admin_ads_demo',
          path: adminRouteAdsDemo,
          pageBuilder: (context, state) => kasyTransitionPage(
            key: state.pageKey,
            child: const AdsDemoPage(),
          ),
        ),
      GoRoute(
        name: '404',
        path: '/404',
        pageBuilder: (context, state) =>
            kasyTransitionPage(key: state.pageKey, child: const PageNotFound()),
      ),
    ],
  );
}
