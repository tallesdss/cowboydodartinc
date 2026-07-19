import 'dart:async';
import 'dart:math';

import 'package:cowboydodartinc/components/kasy_avatar.dart';
import 'package:cowboydodartinc/components/kasy_button.dart';
import 'package:cowboydodartinc/components/kasy_card.dart';
import 'package:cowboydodartinc/components/kasy_drop_down.dart';
import 'package:cowboydodartinc/components/kasy_empty_state.dart';
import 'package:cowboydodartinc/components/kasy_skeleton.dart';
import 'package:cowboydodartinc/components/kasy_status_tag.dart';
import 'package:cowboydodartinc/components/kasy_text_field.dart';
import 'package:cowboydodartinc/components/kasy_tooltip.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/core/widgets/kasy_hover.dart';
import 'package:cowboydodartinc/features/settings/ui/components/admin/admin_routes.dart';
import 'package:cowboydodartinc/features/settings/ui/components/admin/admin_users_api.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Data: search / filter / sort / pagination run on the server via [fetchPage].
// ─────────────────────────────────────────────────────────────────────────────
final _usersPageProvider = FutureProvider.autoDispose
    .family<AdminUsersPage, AdminUsersQuery>((ref, query) {
  return ref.read(adminUsersApiProvider).fetchPage(query);
});

const double _filterWidth = 208;
const int _pageSize = 10;

/// Which column the table is sorted by. `null` means the smart default order:
/// active first → subscribers first → newest first (what the admin asked for).
enum _SortCol { user, status, plan, joined }

// ─────────────────────────────────────────────────────────────────────────────
// Tab root
// ─────────────────────────────────────────────────────────────────────────────

class AdminUsersTab extends ConsumerStatefulWidget {
  const AdminUsersTab({super.key});

  @override
  ConsumerState<AdminUsersTab> createState() => _AdminUsersTabState();
}

class _AdminUsersTabState extends ConsumerState<AdminUsersTab> {
  final _searchCtrl = TextEditingController();
  String _searchRaw = '';
  String _searchDebounced = '';
  Timer? _searchTimer;
  bool _subscribersOnly = false;
  _SortCol? _sortCol; // null = smart default
  bool _asc = true;
  int _page = 0;

  AdminUsersQuery get _query => AdminUsersQuery(
        page: _page,
        search: _searchDebounced,
        subscribersOnly: _subscribersOnly,
        sort: _wireSort(),
        sortAsc: _asc,
      );

  AdminUsersSort _wireSort() {
    if (_sortCol == null) return AdminUsersSort.defaultOrder;
    return switch (_sortCol!) {
      _SortCol.user => AdminUsersSort.user,
      _SortCol.status => AdminUsersSort.status,
      _SortCol.plan => AdminUsersSort.plan,
      _SortCol.joined => AdminUsersSort.joined,
    };
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearch(String v) {
    setState(() => _searchRaw = v);
    _searchTimer?.cancel();
    _searchTimer = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      setState(() {
        _searchDebounced = _searchRaw;
        _page = 0;
      });
    });
  }

  void _setSubscribersOnly(bool v) => setState(() {
        _subscribersOnly = v;
        _page = 0;
      });

  void _onSort(_SortCol col) => setState(() {
        if (_sortCol == col) {
          _asc = !_asc;
        } else {
          _sortCol = col;
          _asc = col != _SortCol.joined; // joined defaults to newest-first
        }
        _page = 0;
      });

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_usersPageProvider(_query));

    // Gutter applied OUTSIDE the max-width column, same nesting order as
    // every other admin tab (_AdminSectionFrame) — otherwise this tab's
    // content rendered ~32px narrower than Overview/Requests/Kanban on wide
    // desktop viewports (the gutter used to be applied a second time, inside
    // the already-constrained 1080 column).
    return Padding(
      padding: EdgeInsets.fromLTRB(
        KasySpacing.pageHorizontalGutter,
        adminSectionTopInset(context),
        KasySpacing.pageHorizontalGutter,
        0,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: adminSectionMaxWidth),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Mobile: a horizontal table is cramped, so each user becomes a
              // vertical card. Tablet/desktop keep the denser table.
              final bool cards = constraints.maxWidth < 560;
              final bool loading = async.isLoading;
              final int? resultCount =
                  async.hasValue ? async.requireValue.totalUsers : null;

              final Widget content = Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Toolbar(
                    controller: _searchCtrl,
                    resultCount: resultCount,
                    loading: loading,
                    subscribersOnly: _subscribersOnly,
                    onSearch: _onSearch,
                    onSubscribersOnly: _setSubscribersOnly,
                    onRefresh: _refresh,
                    tableCard: !cards,
                  ),
                  if (!loading &&
                      async.hasValue &&
                      async.requireValue.searchCapped)
                    _SearchCappedNote(cards: cards),
                  // Column headers only make sense for the table layout.
                  if (!cards)
                    _TableHeader(sortCol: _sortCol, asc: _asc, onSort: _onSort)
                  else
                    const SizedBox(height: KasySpacing.sm),
                  Expanded(
                    child: async.when(
                      // Skeleton only in the list area; toolbar + header stay put.
                      skipLoadingOnRefresh: false,
                      loading: () => _LoadingTableBody(
                        cards: cards,
                        onPullRefresh: cards ? _refresh : null,
                      ),
                      error: (e, _) => _ErrorState(onRetry: _refresh),
                      data: (page) {
                        if (page.users.isEmpty) {
                          return _EmptyState(
                            searching: _searchDebounced.trim().isNotEmpty,
                            subscribersOnly: _subscribersOnly,
                            onPullRefresh: cards ? _refresh : null,
                          );
                        }
                        return _TableBody(
                          users: page.users,
                          cards: cards,
                          rangeFrom: page.rangeFrom,
                          rangeTo: page.rangeTo,
                          total: page.totalUsers,
                          page: page.page,
                          pageCount: page.pageCount,
                          onPage: (p) => setState(() => _page = p),
                          onPullRefresh: cards ? _refresh : null,
                        );
                      },
                    ),
                  ),
                ],
              );

              // Horizontal/top gutter now lives on the outer Padding above,
              // matching Overview/Requests/Kanban. On mobile the pager owns
              // the bottom inset (fill-height layout); on desktop this keeps
              // air below the card.
              final Widget framed = Padding(
                padding: EdgeInsets.only(
                  bottom: cards
                      ? 0
                      : MediaQuery.paddingOf(context).bottom + KasySpacing.xl,
                ),
                child: cards
                    ? content
                    : DecoratedBox(
                        decoration: BoxDecoration(
                          color: context.colors.surface,
                          borderRadius: KasyRadius.lgBorderRadius,
                          border: Border.all(
                            color: context.colors.outline.withValues(
                              alpha: context.isDark ? 0.45 : 0.6,
                            ),
                          ),
                          boxShadow: [KasyShadows.component(context)],
                        ),
                        child: ClipRRect(
                          borderRadius: KasyRadius.lgBorderRadius,
                          child: content,
                        ),
                      ),
              );

              return framed;
            },
          ),
        ),
      ),
    );
  }

  Future<void> _refresh() async {
    ref.invalidate(_usersPageProvider(_query));
    try {
      await ref.read(_usersPageProvider(_query).future);
    } catch (_) {
      // Error UI handles failed fetch; still dismiss the pull indicator.
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Toolbar: count · search · subscribers filter · refresh
// ─────────────────────────────────────────────────────────────────────────────

class _Toolbar extends StatefulWidget {
  final TextEditingController controller;
  final int? resultCount;
  final bool loading;
  final bool subscribersOnly;
  final ValueChanged<String> onSearch;
  final ValueChanged<bool> onSubscribersOnly;
  final Future<void> Function() onRefresh;
  final bool tableCard;

  const _Toolbar({
    required this.controller,
    required this.resultCount,
    required this.loading,
    required this.subscribersOnly,
    required this.onSearch,
    required this.onSubscribersOnly,
    required this.onRefresh,
    this.tableCard = false,
  });

  @override
  State<_Toolbar> createState() => _ToolbarState();
}

class _ToolbarState extends State<_Toolbar> {
  bool _searchOpen = false;
  late final FocusNode _searchFocus;

  @override
  void initState() {
    super.initState();
    _searchFocus = FocusNode();
    _searchOpen = widget.controller.text.trim().isNotEmpty;
  }

  @override
  void dispose() {
    _searchFocus.dispose();
    super.dispose();
  }

  void _openSearch() {
    setState(() => _searchOpen = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _searchFocus.requestFocus();
    });
  }

  void _closeSearch() {
    _searchFocus.unfocus();
    setState(() => _searchOpen = false);
  }

  @override
  Widget build(BuildContext context) {
    final u = t.admin_console.users;

    return Padding(
      padding: widget.tableCard
          ? const EdgeInsets.fromLTRB(
              KasySpacing.md,
              KasySpacing.md,
              KasySpacing.md,
              KasySpacing.sm,
            )
          : EdgeInsets.zero,
      child: LayoutBuilder(
        builder: (context, c) {
          final compact = c.maxWidth < 560;
          final count = _ResultCount(
            value: widget.resultCount,
            label: u.title,
            loading: widget.loading,
            prominent: compact,
          );
          final filter = _FilterButton(
            subscribersOnly: widget.subscribersOnly,
            onChanged: widget.onSubscribersOnly,
            width: compact ? null : _filterWidth,
          );
          final refresh = _IconAction(
            icon: KasyIcons.refresh,
            tooltip: u.refresh,
            onTap: widget.onRefresh,
          );
          if (compact) {
            final hasQuery = widget.controller.text.trim().isNotEmpty;
            final animDuration = MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : const Duration(milliseconds: 200);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                count,
                const SizedBox(height: KasySpacing.sm),
                Row(
                  children: [
                    Expanded(child: filter),
                    if (!_searchOpen) ...[
                      const SizedBox(width: KasySpacing.sm),
                      _SearchToggleButton(
                        hasQuery: hasQuery,
                        tooltip: u.search_hint,
                        onTap: _openSearch,
                      ),
                    ],
                  ],
                ),
                AnimatedSize(
                  duration: animDuration,
                  curve: Curves.easeOutCubic,
                  alignment: Alignment.topCenter,
                  child: _searchOpen
                      ? Padding(
                          padding: const EdgeInsets.only(top: KasySpacing.sm),
                          child: _SearchField(
                            controller: widget.controller,
                            onChanged: widget.onSearch,
                            focusNode: _searchFocus,
                            onClose: _closeSearch,
                          ),
                        )
                      : const SizedBox(width: double.infinity),
                ),
              ],
            );
          }
          return Row(
            children: [
              count,
              const Spacer(),
              SizedBox(
                width: widget.tableCard ? 280 : 240,
                child: _SearchField(
                  controller: widget.controller,
                  onChanged: widget.onSearch,
                ),
              ),
              const SizedBox(width: KasySpacing.sm),
              filter,
              const SizedBox(width: KasySpacing.xs),
              refresh,
            ],
          );
        },
      ),
    );
  }
}

class _ResultCount extends StatelessWidget {
  final int? value;
  final String label;
  final bool loading;
  final bool prominent;
  const _ResultCount({
    required this.value,
    required this.label,
    required this.loading,
    this.prominent = false,
  });

  @override
  Widget build(BuildContext context) {
    final countLabel = t.admin_console.tabs.users.toLowerCase();
    if (prominent) {
      final TextStyle labelStyle = context.textTheme.bodyLarge!.copyWith(
        color: context.colors.muted,
        fontWeight: FontWeight.w500,
      );
      if (loading) {
        return Row(
          children: [
            const KasySkeleton(width: 52, height: 34),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                countLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: labelStyle,
              ),
            ),
          ],
        );
      }
      return Text.rich(
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        TextSpan(
          children: [
            TextSpan(
              text: '${value ?? 0} ',
              style: context.textTheme.headlineMedium?.copyWith(
                color: context.colors.onSurface,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.8,
                height: 1.1,
              ),
            ),
            TextSpan(
              text: countLabel,
              style: labelStyle,
            ),
          ],
        ),
      );
    }
    if (loading) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const KasySkeleton(width: 28, height: 18),
          const SizedBox(width: 4),
          Text(
            countLabel,
            style: context.textTheme.titleSmall?.copyWith(
              color: context.colors.muted,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '${value ?? 0} ',
            style: context.textTheme.titleMedium?.copyWith(
              color: context.colors.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
          TextSpan(
            text: countLabel,
            style: context.textTheme.titleSmall?.copyWith(
              color: context.colors.muted,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final FocusNode? focusNode;
  final VoidCallback? onClose;
  const _SearchField({
    required this.controller,
    required this.onChanged,
    this.focusNode,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final u = t.admin_console.users;
    return KasyTextField(
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      hint: u.search_hint,
      prefix: Icon(KasyIcons.search, size: KasyIconSize.md, color: context.colors.muted),
      suffix: onClose == null
          ? null
          : GestureDetector(
              onTap: onClose,
              child: Icon(
                KasyIcons.close,
                size: KasyIconSize.sm,
                color: context.colors.muted,
              ),
            ),
      textInputAction: TextInputAction.search,
    );
  }
}

class _SearchToggleButton extends StatelessWidget {
  final bool hasQuery;
  final String tooltip;
  final VoidCallback onTap;
  const _SearchToggleButton({
    required this.hasQuery,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return KasyTooltip(
      message: tooltip,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          KasyButton.iconOnly(
            icon: KasyIcons.search,
            variant: KasyButtonVariant.outline,
            size: KasyButtonSize.small,
            iconOnlyLayoutExtent: 38,
            iconGlyphSize: 18,
            onPressed: onTap,
            semanticLabel: tooltip,
          ),
          if (hasQuery)
            Positioned(
              top: 7,
              right: 7,
              child: Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: c.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: c.surface, width: 1.5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  final bool subscribersOnly;
  final ValueChanged<bool> onChanged;
  final double? width;
  const _FilterButton({
    required this.subscribersOnly,
    required this.onChanged,
    this.width = _filterWidth,
  });

  @override
  Widget build(BuildContext context) {
    final u = t.admin_console.users;
    // Kit dropdown: the floating panel lives under the app Overlay so it always
    // follows the real light/dark theme (the old PopupMenuButton rendered the
    // menu light even in dark mode).
    final dropdown = KasyDropDown<bool>(
      value: subscribersOnly,
      leadingIcon: KasyIcons.filter,
      variant: KasyTextFieldVariant.flat,
      items: [
        KasyDropDownItem(value: false, label: u.filter_all),
        KasyDropDownItem(value: true, label: u.filter_subscribers),
      ],
      onChanged: onChanged,
    );
    if (width == null) return dropdown;
    return SizedBox(width: width, child: dropdown);
  }
}

class _IconAction extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final Future<void> Function() onTap;
  const _IconAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Icon-only control: a tooltip is the right call here (no visible label).
    // KasyButton.iconOnly gives the kit's outlined icon button with proper web
    // hover, focus ring and cursor (no Material ripple).
    return KasyTooltip(
      message: tooltip,
      child: KasyButton.iconOnly(
        icon: icon,
        variant: KasyButtonVariant.outline,
        size: KasyButtonSize.small,
        iconOnlyLayoutExtent: 38,
        iconGlyphSize: 18,
        onPressed: () => onTap(),
        semanticLabel: tooltip,
      ),
    );
  }
}

/// Pull-to-refresh wrapper for the mobile card list (replaces the toolbar icon).
class _CardsPullRefresh extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final Widget child;
  const _CardsPullRefresh({required this.onRefresh, required this.child});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator.adaptive(
      onRefresh: onRefresh,
      child: child,
    );
  }
}

class _SearchCappedNote extends StatelessWidget {
  final bool cards;
  const _SearchCappedNote({this.cards = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        cards ? 0 : KasySpacing.md,
        KasySpacing.sm,
        cards ? 0 : KasySpacing.md,
        0,
      ),
      child: Row(
        children: [
          Icon(KasyIcons.info, size: KasyIconSize.sm, color: context.colors.muted),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              t.admin_console.users.search_capped,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.muted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sortable header
// ─────────────────────────────────────────────────────────────────────────────

class _TableHeader extends StatelessWidget {
  final _SortCol? sortCol;
  final bool asc;
  final ValueChanged<_SortCol> onSort;
  const _TableHeader({
    required this.sortCol,
    required this.asc,
    required this.onSort,
  });

  @override
  Widget build(BuildContext context) {
    final u = t.admin_console.users;
    return Container(
      margin: const EdgeInsets.only(top: KasySpacing.md),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: context.colors.outline.withValues(alpha: 0.3)),
          bottom:
              BorderSide(color: context.colors.outline.withValues(alpha: 0.3)),
        ),
        // Design-system neutral surface (solid) so the header band reads as a
        // distinct table head instead of blending into the white panel.
        color: context.colors.surfaceNeutralSoft,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: KasySpacing.md,
        vertical: 6,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: _HeaderCell(
              label: u.col_user,
              active: sortCol == _SortCol.user,
              asc: asc,
              onTap: () => onSort(_SortCol.user),
            ),
          ),
          Expanded(
            flex: 2,
            child: _HeaderCell(
              label: u.col_status,
              active: sortCol == _SortCol.status,
              asc: asc,
              onTap: () => onSort(_SortCol.status),
            ),
          ),
          Expanded(
            flex: 2,
            child: _HeaderCell(
              label: u.col_plan,
              active: sortCol == _SortCol.plan,
              asc: asc,
              onTap: () => onSort(_SortCol.plan),
            ),
          ),
          SizedBox(
            width: 88,
            child: _HeaderCell(
              label: u.col_joined,
              active: sortCol == _SortCol.joined,
              asc: asc,
              onTap: () => onSort(_SortCol.joined),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String label;
  final bool active;
  final bool asc;
  final VoidCallback onTap;
  const _HeaderCell({
    required this.label,
    required this.active,
    required this.asc,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? context.colors.onSurface : context.colors.muted;
    return KasyHover(
      onTap: onTap,
      focusable: true,
      borderRadius: BorderRadius.circular(KasyRadius.xs),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                label.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.kasyTextTheme.sectionLabel.copyWith(
                  color: color,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            if (active) ...[
              const SizedBox(width: 3),
              Icon(
                asc ? KasyIcons.arrowUp : KasyIcons.arrowDown,
                size: KasyIconSize.xs,
                color: context.colors.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Table body + pagination
// ─────────────────────────────────────────────────────────────────────────────

class _TableBody extends StatelessWidget {
  final List<AdminUser> users;
  final bool cards;
  final int rangeFrom;
  final int rangeTo;
  final int total;
  final int page;
  final int pageCount;
  final ValueChanged<int> onPage;
  final Future<void> Function()? onPullRefresh;

  const _TableBody({
    required this.users,
    required this.cards,
    required this.rangeFrom,
    required this.rangeTo,
    required this.total,
    required this.page,
    required this.pageCount,
    required this.onPage,
    this.onPullRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final u = t.admin_console.users;
    final Widget list = cards
        ? ListView.separated(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            physics: onPullRefresh != null
                ? const AlwaysScrollableScrollPhysics()
                : null,
            padding: const EdgeInsets.only(bottom: KasySpacing.sm),
            itemCount: users.length,
            separatorBuilder: (_, _) =>
                const SizedBox(height: KasySpacing.sm),
            itemBuilder: (_, i) => _UserCard(user: users[i]),
          )
        : ShaderMask(
            // Soft fade at the bottom edge so rows dissolve into the pager
            // instead of being sliced by a hard line — desktop table only.
            shaderCallback: (rect) => const LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Colors.transparent, Colors.black],
              stops: [0.0, 0.045],
            ).createShader(rect),
            blendMode: BlendMode.dstIn,
            child: ListView.separated(
              keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.only(bottom: KasySpacing.md),
              itemCount: users.length,
              separatorBuilder: (_, _) => Divider(
                height: 1,
                thickness: 1,
                indent: KasySpacing.md,
                endIndent: KasySpacing.md,
                color: context.colors.outline.withValues(alpha: 0.18),
              ),
              itemBuilder: (_, i) => _UserRow(user: users[i]),
            ),
          );
    return Column(
      children: [
        Expanded(
          child: onPullRefresh != null
              ? _CardsPullRefresh(
                  onRefresh: onPullRefresh!,
                  child: list,
                )
              : list,
        ),
        Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: context.colors.outline.withValues(alpha: 0.15),
              ),
            ),
          ),
          padding: EdgeInsets.fromLTRB(
            cards ? 0 : KasySpacing.md,
            KasySpacing.md,
            cards ? 0 : KasySpacing.md,
            cards
                ? MediaQuery.paddingOf(context).bottom + KasySpacing.xl
                : KasySpacing.lg,
          ),
          child: LayoutBuilder(
            builder: (context, c) {
              final label = Text(
                u.results(from: rangeFrom, to: rangeTo, total: total),
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.muted,
                ),
              );
              // A single page has no "previous/next" to offer — showing the
              // disabled controls is just dead weight. Keep only the quiet
              // count, centered, so the bar stays clean (pro dashboard style).
              if (pageCount <= 1) {
                return Center(child: label);
              }
              final pager = _Pagination(
                page: page,
                pageCount: pageCount,
                onPage: onPage,
              );
              if (c.maxWidth < 460) {
                return Column(
                  children: [
                    pager,
                    const SizedBox(height: KasySpacing.sm),
                    label,
                  ],
                );
              }
              return Row(
                children: [label, const Spacer(), pager],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _Pagination extends StatelessWidget {
  final int page;
  final int pageCount;
  final ValueChanged<int> onPage;
  const _Pagination({
    required this.page,
    required this.pageCount,
    required this.onPage,
  });

  @override
  Widget build(BuildContext context) {
    final u = t.admin_console.users;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _NavBtn(
          label: u.prev,
          icon: KasyIcons.arrowBackIos,
          leading: true,
          enabled: page > 0,
          onTap: () => onPage(page - 1),
        ),
        const SizedBox(width: 6),
        for (final item in _pageWindow(pageCount, page))
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: item == null
                ? const _Ellipsis()
                : _PageNum(
                    number: item + 1,
                    selected: item == page,
                    onTap: () => onPage(item),
                  ),
          ),
        const SizedBox(width: 6),
        _NavBtn(
          label: u.next,
          icon: KasyIcons.arrowForwardIos,
          leading: false,
          enabled: page < pageCount - 1,
          onTap: () => onPage(page + 1),
        ),
      ],
    );
  }
}

/// Page-number window: first, last, current ±1, with ellipses between gaps.
List<int?> _pageWindow(int count, int current) {
  if (count <= 7) return [for (var i = 0; i < count; i++) i];
  final out = <int?>[];
  out.add(0);
  if (current > 2) out.add(null);
  final start = max(1, current - 1);
  final end = min(count - 2, current + 1);
  for (var i = start; i <= end; i++) {
    out.add(i);
  }
  if (current < count - 3) out.add(null);
  out.add(count - 1);
  return out;
}

class _PageNum extends StatelessWidget {
  final int number;
  final bool selected;
  final VoidCallback onTap;
  const _PageNum({
    required this.number,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Widget content = Container(
      constraints: const BoxConstraints(minWidth: 32),
      height: 32,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        // Unselected pages stay transparent (border only) so KasyHover's overlay
        // shows through on web hover; the current page keeps the solid primary.
        color: selected ? context.colors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(KasyRadius.sm),
        border: Border.all(
          color: selected
              ? context.colors.primary
              : context.colors.outline.withValues(alpha: 0.5),
        ),
      ),
      child: Text(
        '$number',
        style: context.textTheme.labelMedium?.copyWith(
          color: selected ? context.colors.onPrimary : context.colors.onSurface,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
    // Current page: not tappable, no hover. Other pages get the kit hover.
    if (selected) return content;
    return KasyHover(
      onTap: onTap,
      focusable: true,
      borderRadius: BorderRadius.circular(KasyRadius.sm),
      child: content,
    );
  }
}

class _Ellipsis extends StatelessWidget {
  const _Ellipsis();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 32,
      child: Center(
        child: Text(
          '…',
          style: context.textTheme.labelMedium?.copyWith(
            color: context.colors.muted,
          ),
        ),
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool leading;
  final bool enabled;
  final VoidCallback onTap;
  const _NavBtn({
    required this.label,
    required this.icon,
    required this.leading,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        enabled ? context.colors.onSurface : context.colors.muted.withValues(alpha: 0.5);
    final text = Text(
      label,
      style: context.textTheme.labelMedium?.copyWith(
        color: color,
        fontWeight: FontWeight.w600,
      ),
    );
    final ic = Icon(icon, size: 18, color: color);
    final Widget content = Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(KasyRadius.sm),
        border: Border.all(
          color: context.colors.outline.withValues(alpha: enabled ? 0.5 : 0.25),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: leading ? [ic, const SizedBox(width: 2), text] : [text, const SizedBox(width: 2), ic],
      ),
    );
    // Disabled (prev/next at the list edges): no hover, cursor or tap.
    if (!enabled) return content;
    return KasyHover(
      onTap: onTap,
      focusable: true,
      borderRadius: BorderRadius.circular(KasyRadius.sm),
      child: content,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// User row
// ─────────────────────────────────────────────────────────────────────────────

class _UserRow extends StatelessWidget {
  final AdminUser user;
  const _UserRow({required this.user});

  @override
  Widget build(BuildContext context) {
    final u = t.admin_console.users;
    final hasName = user.name?.isNotEmpty == true;
    final hasEmail = user.email?.isNotEmpty == true;

    final String primaryText;
    final String? subText;
    final bool isAnonymous;
    if (hasName) {
      primaryText = user.name!;
      subText = hasEmail ? user.email : null;
      isAnonymous = false;
    } else if (hasEmail) {
      primaryText = user.email!;
      subText = null;
      isAnonymous = false;
    } else {
      primaryText = u.anonymous;
      subText = null;
      isAnonymous = true;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: KasySpacing.md,
        vertical: 10,
      ),
      child: Row(
        children: [
          // ── User cell
          Expanded(
            flex: 5,
            child: Row(
              children: [
                KasyAvatar(
                  diameter: 34,
                  image: _avatarImage(user),
                  initials: hasName ? user.name : (hasEmail ? user.email : null),
                  tone: _avatarTone(
                    hasName ? user.name : (hasEmail ? user.email : null),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        primaryText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: isAnonymous
                            ? context.textTheme.bodyMedium?.copyWith(
                                color: context.colors.muted,
                                fontStyle: FontStyle.italic,
                              )
                            : context.kasyTextTheme.rowTitle.copyWith(
                                color: context.colors.onSurface,
                              ),
                      ),
                      if (subText != null) ...[
                        const SizedBox(height: 1),
                        Text(
                          subText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colors.muted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          // ── Status cell
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: KasyStatusTag(
                label: hasEmail ? u.status_active : u.status_inactive,
                tone: hasEmail
                    ? KasyStatusTagTone.success
                    : KasyStatusTagTone.neutral,
              ),
            ),
          ),
          // ── Plan cell
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: KasyStatusTag(
                label: user.subscriber ? u.plan_subscriber : u.plan_free,
                tone: user.subscriber
                    ? KasyStatusTagTone.primary
                    : KasyStatusTagTone.neutral,
              ),
            ),
          ),
          // ── Joined cell
          SizedBox(
            width: 88,
            child: Text(
              user.createdAt != null ? _formatJoined(user.createdAt!) : '—',
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.muted,
              ),
            ),
          ),
        ],
      ),
    );
  }

}

/// Mobile card for a single user — the same data as a table row, stacked
/// vertically so it reads comfortably on a narrow screen.
class _UserCard extends StatelessWidget {
  final AdminUser user;
  const _UserCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final u = t.admin_console.users;
    final bool hasName = user.name?.isNotEmpty == true;
    final bool hasEmail = user.email?.isNotEmpty == true;
    final String primaryText =
        hasName ? user.name! : (hasEmail ? user.email! : u.anonymous);
    final String? subText = hasName && hasEmail ? user.email : null;
    final bool isAnonymous = !hasName && !hasEmail;

    return KasyCard(
      // Default elevated (white surface + shadow over the F5F5F5 page) so the
      // card reads as a real card, not a transparent outline that blends into
      // the screen. Radius matches the other admin cards (AdminPanelCard,
      // Paywalls, Requests) — not KasyCard's own bare default.
      borderRadius: KasyRadius.lgBorderRadius,
      padding: const EdgeInsets.all(KasySpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              KasyAvatar(
                diameter: 38,
                image: _avatarImage(user),
                initials: hasName ? user.name : (hasEmail ? user.email : null),
                tone: _avatarTone(
                  hasName ? user.name : (hasEmail ? user.email : null),
                ),
              ),
              const SizedBox(width: KasySpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      primaryText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: isAnonymous
                          ? context.textTheme.bodyMedium?.copyWith(
                              color: context.colors.muted,
                              fontStyle: FontStyle.italic,
                            )
                          : context.kasyTextTheme.rowTitle.copyWith(
                              color: context.colors.onSurface,
                            ),
                    ),
                    if (subText != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colors.muted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: KasySpacing.smd),
          Divider(
            height: 1,
            color: context.colors.outline.withValues(alpha: 0.25),
          ),
          const SizedBox(height: KasySpacing.smd),
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: KasySpacing.xs,
                  runSpacing: KasySpacing.xs,
                  children: [
                    KasyStatusTag(
                      label: hasEmail ? u.status_active : u.status_inactive,
                      tone: hasEmail
                          ? KasyStatusTagTone.success
                          : KasyStatusTagTone.neutral,
                    ),
                    KasyStatusTag(
                      label: user.subscriber ? u.plan_subscriber : u.plan_free,
                      tone: user.subscriber
                          ? KasyStatusTagTone.primary
                          : KasyStatusTagTone.neutral,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: KasySpacing.sm),
              Text(
                user.createdAt != null ? _formatJoined(user.createdAt!) : '—',
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.muted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Shared joined-date formatter (dd/MM/yy) for the table row and mobile card.
String _formatJoined(DateTime dt) {
  final d = dt.toLocal();
  return '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/'
      '${d.year.toString().substring(2)}';
}

// ─────────────────────────────────────────────────────────────────────────────
// Avatar tone — a stable design-system tone per user (variety, not random).
// ─────────────────────────────────────────────────────────────────────────────

KasyAvatarTone _avatarTone(String? seed) {
  if (seed == null || seed.trim().isEmpty) return KasyAvatarTone.neutral;
  const tones = [
    KasyAvatarTone.blue,
    KasyAvatarTone.green,
    KasyAvatarTone.orange,
    KasyAvatarTone.red,
    KasyAvatarTone.neutral,
  ];
  return tones[seed.trimLeft().codeUnitAt(0) % tones.length];
}

/// The user's photo when they have one, else null so [KasyAvatar] falls back to
/// initials. The avatarPath is the public URL the backend already stores.
ImageProvider? _avatarImage(AdminUser user) {
  final path = user.avatarPath;
  if (path == null || path.isEmpty) return null;
  return NetworkImage(path);
}

// ─────────────────────────────────────────────────────────────────────────────
// Loading / empty / error states
// ─────────────────────────────────────────────────────────────────────────────

/// Skeleton rows inside the real table shell (header + footer stay visible).
class _LoadingTableBody extends StatelessWidget {
  final bool cards;
  final Future<void> Function()? onPullRefresh;
  const _LoadingTableBody({required this.cards, this.onPullRefresh});

  @override
  Widget build(BuildContext context) {
    final int count = cards ? 5 : _pageSize;
    final Widget list = KasySkeletonGroup(
      child: ListView.separated(
        physics: onPullRefresh != null
            ? const AlwaysScrollableScrollPhysics()
            : const NeverScrollableScrollPhysics(),
        padding: cards
            ? const EdgeInsets.only(bottom: KasySpacing.sm)
            : const EdgeInsets.only(bottom: KasySpacing.md),
        itemCount: count,
        separatorBuilder: cards
            ? (_, _) => const SizedBox(height: KasySpacing.sm)
            : (_, _) => Divider(
                  height: 1,
                  thickness: 1,
                  indent: KasySpacing.md,
                  endIndent: KasySpacing.md,
                  color: context.colors.outline.withValues(alpha: 0.18),
                ),
        itemBuilder: (_, i) => cards
            ? const _UserCardSkeleton()
            : const Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: KasySpacing.md,
                  vertical: 10,
                ),
                child: _UserRowSkeleton(),
              ),
      ),
    );
    return Column(
      children: [
        Expanded(
          child: onPullRefresh != null
              ? _CardsPullRefresh(onRefresh: onPullRefresh!, child: list)
              : list,
        ),
        Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: context.colors.outline.withValues(alpha: 0.15),
              ),
            ),
          ),
          padding: EdgeInsets.fromLTRB(
            cards ? 0 : KasySpacing.md,
            KasySpacing.md,
            cards ? 0 : KasySpacing.md,
            cards
                ? MediaQuery.paddingOf(context).bottom + KasySpacing.xl
                : KasySpacing.lg,
          ),
          child: const Center(
            child: KasySkeleton(width: 168, height: 12),
          ),
        ),
      ],
    );
  }
}

class _UserRowSkeleton extends StatelessWidget {
  const _UserRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        KasySkeleton.circle(size: 34),
        SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              KasySkeleton(width: 140, height: 12),
              SizedBox(height: 6),
              KasySkeleton(width: 90, height: 10),
            ],
          ),
        ),
        SizedBox(width: 12),
        KasySkeleton(width: 56, height: 20),
        SizedBox(width: 12),
        KasySkeleton(width: 40, height: 12),
      ],
    );
  }
}

class _UserCardSkeleton extends StatelessWidget {
  const _UserCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return const KasyCard(
      padding: EdgeInsets.all(KasySpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              KasySkeleton.circle(size: 38),
              SizedBox(width: KasySpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    KasySkeleton(width: 150, height: 13),
                    SizedBox(height: 6),
                    KasySkeleton(width: 100, height: 10),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: KasySpacing.md),
          Row(
            children: [
              KasySkeleton(width: 64, height: 22),
              SizedBox(width: 8),
              KasySkeleton(width: 64, height: 22),
              Spacer(),
              KasySkeleton(width: 44, height: 12),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool searching;
  final bool subscribersOnly;
  final Future<void> Function()? onPullRefresh;
  const _EmptyState({
    required this.searching,
    required this.subscribersOnly,
    this.onPullRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final u = t.admin_console.users;
    final IconData icon;
    final String title;
    final String? subtitle;
    if (searching) {
      icon = KasyIcons.searchEmpty;
      title = u.empty_search;
      subtitle = u.empty_search_hint;
    } else if (subscribersOnly) {
      icon = KasyIcons.star;
      title = u.empty_subscribers;
      subtitle = u.empty_subscribers_hint;
    } else {
      icon = KasyIcons.users;
      title = u.empty;
      subtitle = u.empty_hint;
    }
    final Widget body = KasyEmptyState(
      icon: icon,
      title: title,
      subtitle: subtitle,
    );
    if (onPullRefresh == null) return body;
    return _CardsPullRefresh(
      onRefresh: onPullRefresh!,
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: body,
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final Future<void> Function() onRetry;
  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final u = t.admin_console.users;
    return KasyEmptyState(
      icon: KasyIcons.error,
      title: u.title,
      subtitle: u.error,
      action: KasyButton(
        label: u.retry,
        variant: KasyButtonVariant.outline,
        size: KasyButtonSize.small,
        onPressed: () => onRetry(),
      ),
    );
  }
}

