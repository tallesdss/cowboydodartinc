import 'dart:async';

import 'package:cowboydodartinc/components/components.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/core/toast/toast_service.dart';
import 'package:cowboydodartinc/core/widgets/kasy_hover.dart';
import 'package:cowboydodartinc/core/widgets/responsive_layout.dart';
import 'package:cowboydodartinc/features/kanban/domain/kanban_column.dart';
import 'package:cowboydodartinc/features/kanban/domain/kanban_task.dart';
import 'package:cowboydodartinc/features/kanban/providers/kanban_notifier.dart';
import 'package:cowboydodartinc/features/kanban/providers/models/kanban_state.dart';
import 'package:cowboydodartinc/features/settings/ui/components/admin/admin_routes.dart';
import 'package:cowboydodartinc/i18n/translations.g.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Drag data carriers
// ─────────────────────────────────────────────────────────────────────────────
class _DragData {
  final KanbanTask task;
  final String sourceColumnId;
  const _DragData({required this.task, required this.sourceColumnId});
}

class _ColumnDragData {
  final String columnId;
  final int columnIndex;
  const _ColumnDragData({required this.columnId, required this.columnIndex});
}

// Signals which column ID is being dragged so the whole column can dim.
final _draggingColumnId = ValueNotifier<String?>(null);

// True while a task card is mid-drag — freezes board/column scroll on touch.
final _draggingTaskActive = ValueNotifier<bool>(false);

/// Touch-first kanban input: native iOS/Android, DevicePreview simulating those
/// platforms, and mobile/tablet web (where [Draggable] does not accept touch).
bool _kanbanUsesTouchDrag(BuildContext context) {
  final TargetPlatform platform = Theme.of(context).platform;
  if (platform == TargetPlatform.iOS || platform == TargetPlatform.android) {
    return true;
  }
  if (kIsWeb &&
      MediaQuery.sizeOf(context).shortestSide <= DeviceType.large.breakpoint) {
    return true;
  }
  return false;
}

DeviceType _kanbanDeviceType(BuildContext context) =>
    DeviceType.fromWidth(MediaQuery.sizeOf(context).width);

/// Task card title — token roles only, stepped by breakpoint:
/// - phone (`small`): [KasyTextTheme.listRowTitle] 16/w500 (was `cardTitle` 14)
/// - tablet (`medium`): same 16, SemiBold so it holds next to priority chips
/// - desktop (`large`+): [KasyTextTheme.sectionTitle] 16/w600 (Heading 4)
TextStyle _kanbanTaskTitleStyle(BuildContext context) {
  final DeviceType device = _kanbanDeviceType(context);
  final theme = context.kasyTextTheme;
  final TextStyle base = switch (device) {
    DeviceType.small => theme.listRowTitle,
    DeviceType.medium => theme.listRowTitle.withWeight(FontWeight.w600),
    DeviceType.large || DeviceType.xlarge => theme.sectionTitle,
  };
  return base.copyWith(color: context.colors.onSurface, height: 1.3);
}

// ─────────────────────────────────────────────────────────────────────────────
// Page entry point
// ─────────────────────────────────────────────────────────────────────────────

class KanbanPage extends ConsumerWidget {
  const KanbanPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(kanbanProvider);

    return asyncState.when(
      loading: () => const _KanbanLoadingBoard(),
      error: (error, _) => _ErrorState(error: error.toString()),
      data: (state) => _KanbanBoard(state: state),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Board
// ─────────────────────────────────────────────────────────────────────────────

class _KanbanBoard extends ConsumerStatefulWidget {
  final KanbanState state;
  const _KanbanBoard({required this.state});

  @override
  ConsumerState<_KanbanBoard> createState() => _KanbanBoardState();
}

class _KanbanBoardState extends ConsumerState<_KanbanBoard> {
  static const double _boardAutoScrollEdge = 56;
  static const double _boardAutoScrollMaxStep = 18;

  // Live preview order during a column drag; null = use provider order.
  List<KanbanColumn>? _previewColumns;
  final ScrollController _boardScrollController = ScrollController();
  final GlobalKey _boardViewportKey = GlobalKey();
  Timer? _boardAutoScrollTimer;
  double _boardAutoScrollDelta = 0;
  bool _pointerRouteInstalled = false;

  @override
  void initState() {
    super.initState();
    _draggingColumnId.addListener(_onDragChanged);
    _draggingColumnId.addListener(_onBoardDragActivityChanged);
    _draggingTaskActive.addListener(_onBoardDragActivityChanged);
  }

  @override
  void dispose() {
    _draggingColumnId.removeListener(_onDragChanged);
    _draggingColumnId.removeListener(_onBoardDragActivityChanged);
    _draggingTaskActive.removeListener(_onBoardDragActivityChanged);
    _removeBoardPointerRoute();
    _stopBoardAutoScroll();
    _boardScrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_KanbanBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state) _previewColumns = null;
  }

  void _onDragChanged() {
    if (_draggingColumnId.value != null || !mounted) return;
    // Drag ended. Commit the live preview order so the reorder always persists,
    // even when the pointer is released over the gap between columns instead of
    // squarely on a column. didUpdateWidget clears _previewColumns once the
    // committed state arrives, so the board never flashes back to the old order.
    final preview = _previewColumns;
    if (preview != null) {
      ref.read(kanbanProvider.notifier).commitColumnOrder(preview);
    } else {
      setState(() => _previewColumns = null);
    }
  }

  void _onBoardDragActivityChanged() {
    final bool active =
        _draggingColumnId.value != null || _draggingTaskActive.value;
    if (active) {
      _installBoardPointerRoute();
    } else {
      _removeBoardPointerRoute();
      _stopBoardAutoScroll();
    }
  }

  void _installBoardPointerRoute() {
    if (_pointerRouteInstalled) return;
    _pointerRouteInstalled = true;
    WidgetsBinding.instance.pointerRouter.addGlobalRoute(
      _handleBoardPointerEvent,
    );
  }

  void _removeBoardPointerRoute() {
    if (!_pointerRouteInstalled) return;
    _pointerRouteInstalled = false;
    WidgetsBinding.instance.pointerRouter.removeGlobalRoute(
      _handleBoardPointerEvent,
    );
  }

  void _handleBoardPointerEvent(PointerEvent event) {
    if (_draggingColumnId.value == null && !_draggingTaskActive.value) {
      return;
    }
    if (event is PointerUpEvent || event is PointerCancelEvent) {
      _stopBoardAutoScroll();
      return;
    }
    if (event is! PointerMoveEvent) return;
    final BuildContext? viewportContext = _boardViewportKey.currentContext;
    if (viewportContext == null) return;
    final RenderObject? renderObject = viewportContext.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) return;
    final Offset local = renderObject.globalToLocal(event.position);
    if (!local.dx.isFinite || !local.dy.isFinite) return;
    _updateBoardAutoScroll(local.dx, renderObject.size.width);
  }

  void _updateBoardAutoScroll(double localDx, double viewportWidth) {
    if (localDx < _boardAutoScrollEdge) {
      final double intensity =
          ((_boardAutoScrollEdge - localDx) / _boardAutoScrollEdge)
              .clamp(0.0, 1.0);
      _boardAutoScrollDelta = -_boardAutoScrollMaxStep * intensity;
    } else if (localDx > viewportWidth - _boardAutoScrollEdge) {
      final double intensity =
          ((localDx - (viewportWidth - _boardAutoScrollEdge)) /
                  _boardAutoScrollEdge)
              .clamp(0.0, 1.0);
      _boardAutoScrollDelta = _boardAutoScrollMaxStep * intensity;
    } else {
      _boardAutoScrollDelta = 0;
    }
    if (_boardAutoScrollDelta == 0) {
      _boardAutoScrollTimer?.cancel();
      _boardAutoScrollTimer = null;
      return;
    }
    _boardAutoScrollTimer ??= Timer.periodic(
      const Duration(milliseconds: 16),
      (_) => _tickBoardAutoScroll(),
    );
  }

  void _tickBoardAutoScroll() {
    if (!_boardScrollController.hasClients || _boardAutoScrollDelta == 0) {
      return;
    }
    final ScrollPosition position = _boardScrollController.position;
    final double next = (position.pixels + _boardAutoScrollDelta)
        .clamp(position.minScrollExtent, position.maxScrollExtent);
    if (next == position.pixels) {
      _stopBoardAutoScroll();
      return;
    }
    _boardScrollController.jumpTo(next);
  }

  void _stopBoardAutoScroll() {
    _boardAutoScrollDelta = 0;
    _boardAutoScrollTimer?.cancel();
    _boardAutoScrollTimer = null;
  }

  void _onColumnHover(String draggingId, String targetId, bool isBefore) {
    final current = _previewColumns ?? widget.state.columns;
    final dragIdx = current.indexWhere((c) => c.id == draggingId);
    final targetIdx = current.indexWhere((c) => c.id == targetId);
    if (dragIdx == -1 || targetIdx == -1 || dragIdx == targetIdx) return;

    final newList = List<KanbanColumn>.from(current);
    final col = newList.removeAt(dragIdx);
    final adjustedTarget = dragIdx < targetIdx ? targetIdx - 1 : targetIdx;
    final insertAt =
        (isBefore ? adjustedTarget : adjustedTarget + 1).clamp(0, newList.length);
    newList.insert(insertAt, col);

    final unchanged = List.generate(
      newList.length,
      (i) => newList[i].id == current[i].id,
    ).every((v) => v);
    if (unchanged) return;
    setState(() => _previewColumns = newList);
  }

  @override
  Widget build(BuildContext context) {
    final columns = _previewColumns ?? widget.state.columns;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: adminSectionTopInset(context)),
        // Board: left edge tracks the header centering; no right padding so
        // columns scroll freely to the screen edge.
        Expanded(
          child: LayoutBuilder(
            builder: (ctx, constraints) {
              final inner = constraints.maxWidth -
                  2 * KasySpacing.pageHorizontalGutter;
              final centeringOffset = inner > adminSectionMaxWidth
                  ? (inner - adminSectionMaxWidth) / 2.0
                  : 0.0;
              final leftPad =
                  KasySpacing.pageHorizontalGutter + centeringOffset;
              return ValueListenableBuilder<bool>(
                valueListenable: _draggingTaskActive,
                builder: (context, taskDragging, _) {
                  return ValueListenableBuilder<String?>(
                    valueListenable: _draggingColumnId,
                    builder: (context, columnDragging, _) {
                      final bool scrollLocked =
                          taskDragging || columnDragging != null;
                      return KeyedSubtree(
                        key: _boardViewportKey,
                        child: SingleChildScrollView(
                        controller: _boardScrollController,
                        scrollDirection: Axis.horizontal,
                        physics: scrollLocked
                            ? const NeverScrollableScrollPhysics()
                            : null,
                        padding: EdgeInsets.only(left: leftPad),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (int i = 0; i < columns.length; i++) ...[
                              if (i > 0)
                                const SizedBox(width: KasySpacing.md),
                              SizedBox(
                                key: ValueKey(columns[i].id),
                                width: 300,
                                child: _KanbanColumnWidget(
                                  column: columns[i],
                                  tasks: widget.state
                                      .getTasksForColumn(columns[i].id),
                                  columnIndex: i,
                                  totalColumns: columns.length,
                                  onColumnHover: _onColumnHover,
                                ),
                              ),
                            ],
                            if (columns.isNotEmpty)
                              const SizedBox(width: KasySpacing.md),
                            // "Add another list" — a column-shaped tile that
                            // morphs into an inline name field (Trello pattern).
                            const SizedBox(
                              width: 300,
                              child: Align(
                                alignment: Alignment.topCenter,
                                child: _AddColumnTile(),
                              ),
                            ),
                            const SizedBox(width: KasySpacing.md),
                          ],
                        ),
                      ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
        SizedBox(
          height: MediaQuery.paddingOf(context).bottom + KasySpacing.xl,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Add-column tile — trailing the board. Collapsed it is a column-width button;
// tapped it morphs in place into a name field + confirm/cancel (Trello pattern).
// ─────────────────────────────────────────────────────────────────────────────

class _AddColumnTile extends ConsumerStatefulWidget {
  const _AddColumnTile();

  @override
  ConsumerState<_AddColumnTile> createState() => _AddColumnTileState();
}

class _AddColumnTileState extends ConsumerState<_AddColumnTile> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _editing = false;
  bool _saving = false;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startEditing() => setState(() => _editing = true);

  void _cancel() {
    _controller.clear();
    setState(() {
      _editing = false;
      _saving = false;
    });
  }

  Future<void> _save() async {
    if (_saving) return;
    final String name = _controller.text.trim();
    if (name.isEmpty) {
      _focusNode.requestFocus();
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(kanbanProvider.notifier).createColumn(name);
      if (!mounted) return;
      _controller.clear();
      setState(() {
        _editing = false;
        _saving = false;
      });
      ref.read(toastProvider).alert(
            title: t.common.saved,
            text: t.kanban.column_created,
          );
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = t.kanban;

    if (!_editing) {
      // Collapsed: a subtle, column-width placeholder that invites a new list.
      return KasyHover(
        onTap: _startEditing,
        pressColor: context.colors.onSurface,
        borderRadius: BorderRadius.circular(KasyRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(KasySpacing.md),
          decoration: BoxDecoration(
            color: context.colors.backgroundSecondary.withValues(
              alpha: context.isDark ? 0.5 : 0.6,
            ),
            borderRadius: BorderRadius.circular(KasyRadius.lg),
            border: Border.all(
              color: context.colors.outline.withValues(
                alpha: context.isDark ? 0.35 : 0.5,
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(
                KasyIcons.add,
                size: KasyIconSize.md,
                color: context.colors.onSurface,
              ),
              const SizedBox(width: KasySpacing.xs),
              Text(
                tr.add_another_list,
                style: context.kasyTextTheme.sectionTitle.copyWith(
                  color: context.colors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Editing: the same tray shape, now holding the name field + actions.
    return Container(
      padding: const EdgeInsets.all(KasySpacing.sm),
      decoration: BoxDecoration(
        color: context.colors.backgroundSecondary,
        borderRadius: BorderRadius.circular(KasyRadius.lg),
        border: Border.all(
          color: context.colors.outline.withValues(
            alpha: context.isDark ? 0.45 : 0.6,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          KasyTextField(
            controller: _controller,
            focusNode: _focusNode,
            hint: tr.list_name_hint,
            autofocus: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _save(),
          ),
          const SizedBox(height: KasySpacing.sm),
          Row(
            children: [
              KasyButton(
                label: tr.add_list,
                size: KasyButtonSize.small,
                isLoading: _saving,
                onPressed: _saving ? null : _save,
              ),
              const SizedBox(width: KasySpacing.xs),
              KasyButton.iconOnly(
                icon: KasyIcons.close,
                variant: KasyButtonVariant.ghost,
                size: KasyButtonSize.small,
                iconGlyphSize: KasyIconSize.lg,
                onPressed: _saving ? null : _cancel,
                semanticLabel: tr.cancel,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Column widget
// ─────────────────────────────────────────────────────────────────────────────

class _KanbanColumnWidget extends ConsumerWidget {
  final KanbanColumn column;
  final List<KanbanTask> tasks;
  final int columnIndex;
  final int totalColumns;
  final void Function(String draggingId, String targetId, bool isBefore)?
      onColumnHover;

  const _KanbanColumnWidget({
    required this.column,
    required this.tasks,
    required this.columnIndex,
    required this.totalColumns,
    this.onColumnHover,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = t.kanban;

    return DragTarget<_ColumnDragData>(
      onWillAcceptWithDetails: (details) => details.data.columnId != column.id,
      onMove: (details) {
        final draggingId = _draggingColumnId.value;
        if (draggingId == null) return;
        final box = context.findRenderObject() as RenderBox?;
        if (box == null) return;
        final local = box.globalToLocal(details.offset);
        onColumnHover?.call(draggingId, column.id, local.dx < box.size.width / 2);
      },
      // Reorder is committed when the drag ends (see _onDragChanged), not here,
      // so a drop in the gap between columns still persists the new order.
      onAcceptWithDetails: (_) {},
      builder: (ctx, columnCandidates, columnRejected) {
        return ValueListenableBuilder<String?>(
          valueListenable: _draggingColumnId,
          builder: (_, draggingId, child) => AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: draggingId == column.id ? 0.0 : 1.0,
            child: child,
          ),
          child: Container(
            // Column = a recessed tray, one step off the page canvas
            // (backgroundSecondary), so the surface cards inside read as lifted
            // panels — the same fill the sidebar and app bar use.
            decoration: BoxDecoration(
              color: context.colors.backgroundSecondary,
              borderRadius: BorderRadius.circular(KasyRadius.lg),
              border: Border.all(
                color: context.colors.outline.withValues(
                  alpha: context.isDark ? 0.45 : 0.6,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Column header — drag handle spans the full title bar (not only
                // the text) so short names still have a comfortable touch target.
                Row(
                  children: [
                    Expanded(
                      child: _ColumnDraggableHeader(
                        column: column,
                        columnIndex: columnIndex,
                        tasks: tasks,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                            KasySpacing.md,
                            KasySpacing.md,
                            KasySpacing.xs,
                            KasySpacing.sm,
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    column.name,
                                    overflow: TextOverflow.ellipsis,
                                    style: context.kasyTextTheme.sectionTitle
                                        .copyWith(
                                      color: context.colors.onSurface,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: KasySpacing.xs),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: context.colors.muted
                                        .withValues(alpha: 0.1),
                                    borderRadius: KasyRadius.fullBorderRadius,
                                  ),
                                  child: Text(
                                    '${tasks.length}',
                                    style:
                                        context.kasyTextTheme.caption.copyWith(
                                      color: context.colors.muted,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    KasyHover(
                      onTap: () => _showTaskForm(
                        context,
                        ref,
                        columnId: column.id,
                      ),
                      borderRadius: BorderRadius.circular(KasyRadius.sm),
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Icon(
                          KasyIcons.add,
                          size: KasyIconSize.inline,
                          color: context.colors.muted,
                        ),
                      ),
                    ),
                    _ColumnMenu(
                      column: column,
                      columnIndex: columnIndex,
                      totalColumns: totalColumns,
                    ),
                  ],
                ),
                Divider(
                  height: 1,
                  color: context.colors.outline.withValues(alpha: 0.35),
                ),
                // Task list
                Expanded(
                  child: tasks.isEmpty
                      ? DragTarget<_DragData>(
                          onAcceptWithDetails: (details) {
                            ref.read(kanbanProvider.notifier).moveTask(
                              taskId: details.data.task.id,
                              targetColumnId: column.id,
                              targetIndex: 0,
                            );
                          },
                          builder: (ctx2, candidates2, _) => Padding(
                            padding: const EdgeInsets.all(KasySpacing.sm),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              decoration: candidates2.isNotEmpty
                                  ? BoxDecoration(
                                      color: ctx2.colors.primary
                                          .withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(
                                          KasyRadius.md),
                                      border: Border.all(
                                        color: ctx2.colors.primary
                                            .withValues(alpha: 0.4),
                                      ),
                                    )
                                  : null,
                              child: Center(
                                child: Text(
                                  tr.empty_column,
                                  textAlign: TextAlign.center,
                                  style: ctx2.textTheme.bodySmall?.copyWith(
                                    color: candidates2.isNotEmpty
                                        ? ctx2.colors.primary
                                            .withValues(alpha: 0.6)
                                        : ctx2.colors.muted,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      : ValueListenableBuilder<bool>(
                          valueListenable: _draggingTaskActive,
                          builder: (context, taskDragging, _) {
                            return ListView(
                              physics: taskDragging
                                  ? const NeverScrollableScrollPhysics()
                                  : null,
                              padding: const EdgeInsets.fromLTRB(
                                KasySpacing.sm,
                                KasySpacing.sm,
                                KasySpacing.sm,
                                0,
                              ),
                              children: [
                                _DropZone(columnId: column.id, index: 0),
                                for (int i = 0; i < tasks.length; i++) ...[
                                  _DraggableCard(
                                    task: tasks[i],
                                    columnId: column.id,
                                  ),
                                  _DropZone(
                                    columnId: column.id,
                                    index: i + 1,
                                  ),
                                ],
                              ],
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Column 3-dot menu — KasyMenuAnchor on desktop, choice sheet on mobile/tablet
// ─────────────────────────────────────────────────────────────────────────────

class _ColumnMenu extends ConsumerWidget {
  final KanbanColumn column;
  final int columnIndex;
  final int totalColumns;

  const _ColumnMenu({
    required this.column,
    required this.columnIndex,
    required this.totalColumns,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = t.kanban;
    final isDesktop =
        MediaQuery.sizeOf(context).width >= DeviceType.large.breakpoint;

    if (isDesktop) {
      return KasyMenuAnchor(
        width: 180,
        align: KasyPopoverAlign.end,
        sections: [
          KasyMenuSection(
            items: [
              KasyMenuItem(
                title: tr.edit_column,
                icon: KasyIcons.edit,
                onTap: () =>
                    _showColumnForm(context, ref, column: column),
              ),
              KasyMenuItem(
                title: tr.delete_column,
                icon: KasyIcons.trash,
                tone: KasyMenuItemTone.danger,
                onTap: () => _confirmDeleteColumn(context, ref),
              ),
            ],
          ),
        ],
        builder: (ctx, open) => KasyHover(
          onTap: open,
          borderRadius: BorderRadius.circular(KasyRadius.sm),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child:
                Icon(KasyIcons.moreVert, size: KasyIconSize.inline, color: ctx.colors.muted),
          ),
        ),
      );
    }

    return KasyHover(
      onTap: () => showKasyChoiceSheet(
        context: context,
        title: column.name,
        options: [
          KasyBottomSheetOption(
            icon: KasyIcons.edit,
            label: tr.edit_column,
            onTap: () => _showColumnForm(context, ref, column: column),
          ),
          KasyBottomSheetOption(
            icon: KasyIcons.trash,
            label: tr.delete_column,
            danger: true,
            onTap: () => _confirmDeleteColumn(context, ref),
          ),
        ],
      ),
      borderRadius: BorderRadius.circular(KasyRadius.sm),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(KasyIcons.moreVert, size: KasyIconSize.inline, color: context.colors.muted),
      ),
    );
  }

  void _confirmDeleteColumn(BuildContext context, WidgetRef ref) {
    final tr = t.kanban;
    showKasyConfirmDialog(
      context,
      title: tr.delete_column,
      message: tr.delete_column_confirm,
      cancelLabel: t.common.close,
      confirmLabel: tr.delete_column,
      destructive: true,
      onConfirmAsync: () async {
        await ref.read(kanbanProvider.notifier).deleteColumn(column.id);
        if (context.mounted) {
          ref.read(toastProvider).alert(
            title: t.common.saved,
            text: tr.column_deleted,
          );
        }
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Task card
// ─────────────────────────────────────────────────────────────────────────────

class _TaskCard extends ConsumerWidget {
  final KanbanTask task;

  const _TaskCard({required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return KasyHover(
      onTap: () => _showTaskDetail(context, ref, task),
      borderRadius: BorderRadius.circular(KasyRadius.md),
      child: Container(
        padding: const EdgeInsets.all(KasySpacing.smd),
        // Card = the surface fill used by the sidebar / app bar (and the
        // elevated KasyCard): lifts off the darker column tray. Hairline border
        // in light mode; a soft shadow gives the panel elevation in both modes.
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(KasyRadius.md),
          border: context.isDark
              ? null
              : Border.all(
                  color: context.colors.outline.withValues(alpha: 0.18),
                ),
          boxShadow: [
            KasyShadows.component(
              context,
              blurRadius: 6,
              spreadRadius: -2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Priority chip + options menu row
            Row(
              children: [
                if (task.priority != null)
                  _PriorityChip(priority: task.priority!),
                const Spacer(),
                _TaskMenu(task: task),
              ],
            ),
            if (task.priority != null) const SizedBox(height: KasySpacing.xs),
            // Title — see [_kanbanTaskTitleStyle] (responsive token ladder).
            Text(
              task.title,
              style: _kanbanTaskTitleStyle(context),
            ),
            // Description preview
            if (task.description != null && task.description!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                task.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.kasyTextTheme.cardSubtitle.copyWith(
                  color: context.colors.muted,
                  height: 1.35,
                ),
              ),
            ],
            // Footer: creation date
            const SizedBox(height: KasySpacing.sm),
            Row(
              children: [
                Icon(
                  KasyIcons.calendar,
                  size: KasyIconSize.xxs,
                  color: context.colors.muted.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  DateFormat.MMMd().format(task.createdAt),
                  style: context.kasyTextTheme.caption.copyWith(
                    color: context.colors.muted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Task 3-dot menu — KasyMenuAnchor on desktop, choice sheet on mobile/tablet
// ─────────────────────────────────────────────────────────────────────────────

class _TaskMenu extends ConsumerWidget {
  final KanbanTask task;

  const _TaskMenu({required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = t.kanban;
    final isDesktop =
        MediaQuery.sizeOf(context).width >= DeviceType.large.breakpoint;

    if (isDesktop) {
      return KasyMenuAnchor(
        width: 160,
        align: KasyPopoverAlign.end,
        sections: [
          KasyMenuSection(
            items: [
              KasyMenuItem(
                title: tr.edit_task,
                icon: KasyIcons.edit,
                onTap: () => _showTaskForm(context, ref, editingTask: task),
              ),
              KasyMenuItem(
                title: tr.delete_task,
                icon: KasyIcons.trash,
                tone: KasyMenuItemTone.danger,
                onTap: () => _confirmDeleteTask(context, ref),
              ),
            ],
          ),
        ],
        builder: (ctx, open) => KasyHover(
          onTap: open,
          borderRadius: BorderRadius.circular(KasyRadius.sm),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Icon(
              KasyIcons.moreVert,
              size: KasyIconSize.sm,
              color: ctx.colors.muted,
            ),
          ),
        ),
      );
    }

    return KasyHover(
      onTap: () => showKasyChoiceSheet(
        context: context,
        title: task.title,
        options: [
          KasyBottomSheetOption(
            icon: KasyIcons.edit,
            label: tr.edit_task,
            onTap: () => _showTaskForm(context, ref, editingTask: task),
          ),
          KasyBottomSheetOption(
            icon: KasyIcons.trash,
            label: tr.delete_task,
            danger: true,
            onTap: () => _confirmDeleteTask(context, ref),
          ),
        ],
      ),
      borderRadius: BorderRadius.circular(KasyRadius.sm),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(KasyIcons.moreVert, size: KasyIconSize.sm, color: context.colors.muted),
      ),
    );
  }

  void _confirmDeleteTask(BuildContext context, WidgetRef ref) {
    final tr = t.kanban;
    showKasyConfirmDialog(
      context,
      title: tr.delete_task,
      message: tr.delete_task_confirm,
      cancelLabel: t.common.close,
      confirmLabel: tr.delete_task,
      destructive: true,
      onConfirmAsync: () async {
        await ref.read(kanbanProvider.notifier).deleteTask(task.id);
        if (context.mounted) {
          ref.read(toastProvider).alert(
            title: t.common.saved,
            text: tr.task_deleted,
          );
        }
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Priority chip
// ─────────────────────────────────────────────────────────────────────────────

/// Resolves a task priority to its readable-by-theme accent token (shared by the
/// display chip and the form selector). See [KasyColors.priorityLow] etc.
Color _priorityColor(BuildContext context, TaskPriority priority) =>
    switch (priority) {
      TaskPriority.low => context.colors.priorityLow,
      TaskPriority.medium => context.colors.priorityMedium,
      TaskPriority.high => context.colors.priorityHigh,
      TaskPriority.urgent => context.colors.priorityUrgent,
    };

class _PriorityChip extends StatelessWidget {
  final TaskPriority priority;

  const _PriorityChip({required this.priority});

  @override
  Widget build(BuildContext context) {
    final tr = t.kanban;
    final label = switch (priority) {
      TaskPriority.low => tr.priority_low,
      TaskPriority.medium => tr.priority_medium,
      TaskPriority.high => tr.priority_high,
      TaskPriority.urgent => tr.priority_urgent,
    };
    // Same status pill as the admin tables — a soft-tinted dot + label, colored
    // by the priority token so kanban and tables read identically.
    return KasyStatusTag(
      label: label,
      color: _priorityColor(context, priority),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Priority selector (chip row inside forms)
// ─────────────────────────────────────────────────────────────────────────────

class _PrioritySelector extends StatelessWidget {
  final TaskPriority? selected;
  final ValueChanged<TaskPriority?> onChanged;

  const _PrioritySelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final tr = t.kanban;
    final options = <(TaskPriority?, String)>[
      (null, tr.priority_none),
      (TaskPriority.low, tr.priority_low),
      (TaskPriority.medium, tr.priority_medium),
      (TaskPriority.high, tr.priority_high),
      (TaskPriority.urgent, tr.priority_urgent),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr.priority,
          style: context.kasyTextTheme.caption.copyWith(
            color: context.colors.muted,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: KasySpacing.xs),
        Wrap(
          spacing: KasySpacing.xs,
          runSpacing: KasySpacing.xs,
          children: options.map((opt) {
            final (priority, label) = opt;
            final bool isNone = priority == null;
            // The kit's flicker-free chip carries the whole no-blink recipe; the
            // selected colour matches the card's priority tag. "None" has no dot.
            return KasySelectableChip(
              key: ValueKey<TaskPriority?>(priority),
              label: label,
              selected: selected == priority,
              showDot: !isNone,
              color: isNone ? context.colors.muted : _priorityColor(context, priority),
              onTap: () => onChanged(priority),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Loading shell (header stays visible; only columns skeleton)
// ─────────────────────────────────────────────────────────────────────────────

class _KanbanLoadingBoard extends StatelessWidget {
  const _KanbanLoadingBoard();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: adminSectionTopInset(context)),
        Expanded(
          child: KasySkeletonGroup(
            child: LayoutBuilder(
              builder: (ctx, constraints) {
                final double inner =
                    constraints.maxWidth - 2 * KasySpacing.pageHorizontalGutter;
                final double centeringOffset = inner > adminSectionMaxWidth
                    ? (inner - adminSectionMaxWidth) / 2.0
                    : 0.0;
                final double leftPad =
                    KasySpacing.pageHorizontalGutter + centeringOffset;
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.only(left: leftPad),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _KanbanColumnSkeleton(),
                      SizedBox(width: KasySpacing.md),
                      _KanbanColumnSkeleton(),
                      SizedBox(width: KasySpacing.md),
                      _KanbanColumnSkeleton(),
                      SizedBox(width: KasySpacing.md),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        SizedBox(
          height: MediaQuery.paddingOf(context).bottom + KasySpacing.xl,
        ),
      ],
    );
  }
}

class _KanbanColumnSkeleton extends StatelessWidget {
  const _KanbanColumnSkeleton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: Container(
        decoration: BoxDecoration(
          color: context.colors.backgroundSecondary,
          borderRadius: BorderRadius.circular(KasyRadius.lg),
          border: Border.all(
            color: context.colors.outline.withValues(
              alpha: context.isDark ? 0.45 : 0.6,
            ),
          ),
        ),
        padding: const EdgeInsets.all(KasySpacing.md),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(child: KasySkeleton(width: 100, height: 14)),
                SizedBox(width: KasySpacing.xs),
                KasySkeleton(width: 22, height: 18),
              ],
            ),
            SizedBox(height: KasySpacing.md),
            KasySkeleton(
              width: double.infinity,
              height: 72,
              borderRadius: BorderRadius.all(Radius.circular(KasyRadius.md)),
            ),
            SizedBox(height: KasySpacing.sm),
            KasySkeleton(
              width: double.infinity,
              height: 72,
              borderRadius: BorderRadius.all(Radius.circular(KasyRadius.md)),
            ),
            SizedBox(height: KasySpacing.sm),
            KasySkeleton(
              width: double.infinity,
              height: 72,
              borderRadius: BorderRadius.all(Radius.circular(KasyRadius.md)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Error state
// ─────────────────────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  final String error;

  const _ErrorState({required this.error});

  @override
  Widget build(BuildContext context) {
    final tr = t.kanban;

    return SingleChildScrollView(
      padding: adminSectionBodyPadding(context),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: adminSectionMaxWidth),
          child: KasyCard(
            // Was relying on KasyCard's bare default (24px) by omission —
            // every other empty/error-state card in admin uses 16px.
            borderRadius: KasyRadius.lgBorderRadius,
            child: Padding(
              padding: const EdgeInsets.all(KasySpacing.xxl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(KasyIcons.error, size: KasyIconSize.hero, color: context.colors.error),
                  const SizedBox(height: KasySpacing.md),
                  Text(
                    tr.error_title,
                    textAlign: TextAlign.center,
                    style: context.kasyTextTheme.pageTitle.copyWith(
                      color: context.colors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: KasySpacing.xs),
                  Text(
                    error,
                    textAlign: TextAlign.center,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colors.muted,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Draggable card wrapper
// ─────────────────────────────────────────────────────────────────────────────

class _DraggableCard extends StatelessWidget {
  final KanbanTask task;
  final String columnId;

  const _DraggableCard({required this.task, required this.columnId});

  @override
  Widget build(BuildContext context) {
    final data = _DragData(task: task, sourceColumnId: columnId);
    final feedback = IgnorePointer(
      child: Transform.rotate(
        angle: 0.022,
        child: SizedBox(
          width: 268,
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(KasyRadius.md),
            elevation: 14,
            shadowColor: Colors.black.withValues(alpha: 0.45),
            child: _TaskCard(task: task),
          ),
        ),
      ),
    );
    final ghost = Opacity(opacity: 0.3, child: _TaskCard(task: task));
    final card = _TaskCard(task: task);

    void onDragStart() => _draggingTaskActive.value = true;
    void onDragEnd(dynamic _) => _draggingTaskActive.value = false;

    if (_kanbanUsesTouchDrag(context)) {
      return LongPressDraggable<_DragData>(
        data: data,
        delay: const Duration(milliseconds: 120),
        rootOverlay: true,
        feedback: feedback,
        childWhenDragging: ghost,
        onDragStarted: onDragStart,
        onDragEnd: onDragEnd,
        onDraggableCanceled: (_, _) => onDragEnd(null),
        child: card,
      );
    }

    return Draggable<_DragData>(
      data: data,
      feedback: feedback,
      childWhenDragging: ghost,
      onDragStarted: onDragStart,
      onDragEnd: onDragEnd,
      child: card,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Drop zone (between cards; expands when a card hovers over it)
// ─────────────────────────────────────────────────────────────────────────────

class _DropZone extends ConsumerWidget {
  final String columnId;
  final int index;

  const _DropZone({required this.columnId, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DragTarget<_DragData>(
      onWillAcceptWithDetails: (details) {
        final data = details.data;
        if (data.sourceColumnId != columnId) return true;
        final tasks =
            ref.read(kanbanProvider).value?.getTasksForColumn(columnId) ?? [];
        final sourceIndex = tasks.indexWhere((t) => t.id == data.task.id);
        if (sourceIndex == -1) return true;
        return !(index == sourceIndex || index == sourceIndex + 1);
      },
      onAcceptWithDetails: (details) {
        final data = details.data;
        final notifier = ref.read(kanbanProvider.notifier);
        if (data.sourceColumnId == columnId) {
          final tasks =
              ref.read(kanbanProvider).value?.getTasksForColumn(columnId) ?? [];
          final sourceIndex = tasks.indexWhere((t) => t.id == data.task.id);
          if (sourceIndex == -1) return;
          notifier.reorderTasksInColumn(
            columnId: columnId,
            oldIndex: sourceIndex,
            newIndex: index,
          );
        } else {
          notifier.moveTask(
            taskId: data.task.id,
            targetColumnId: columnId,
            targetIndex: index,
          );
        }
      },
      builder: (ctx, candidateData, _) {
        final isActive = candidateData.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          // Tighter card gap when inactive (token, not a magic number);
          // 100px active = visible drop slot.
          height: isActive ? 100 : KasySpacing.xs,
          margin: isActive
              ? const EdgeInsets.symmetric(vertical: 3)
              : EdgeInsets.zero,
          decoration: isActive
              ? BoxDecoration(
                  color: ctx.colors.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(KasyRadius.md),
                  border: Border.all(
                    color: ctx.colors.primary.withValues(alpha: 0.38),
                    width: 1.5,
                  ),
                )
              : null,
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Column drag feedback (full column preview, like task card drag)
// ─────────────────────────────────────────────────────────────────────────────

class _ColumnDragFeedback extends StatelessWidget {
  static const double width = 300;
  static const double maxHeight = 480;

  final KanbanColumn column;
  final List<KanbanTask> tasks;

  const _ColumnDragFeedback({
    required this.column,
    required this.tasks,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(KasyRadius.lg),
        elevation: 14,
        shadowColor: Colors.black.withValues(alpha: 0.45),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: maxHeight),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(KasyRadius.lg),
            child: Container(
              decoration: BoxDecoration(
                color: context.colors.backgroundSecondary,
                borderRadius: BorderRadius.circular(KasyRadius.lg),
                border: Border.all(
                  color: context.colors.outline.withValues(
                    alpha: context.isDark ? 0.45 : 0.6,
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      KasySpacing.md,
                      KasySpacing.md,
                      KasySpacing.md,
                      KasySpacing.sm,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            column.name,
                            overflow: TextOverflow.ellipsis,
                            style: context.kasyTextTheme.sectionTitle.copyWith(
                              color: context.colors.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: KasySpacing.xs),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: context.colors.muted.withValues(alpha: 0.1),
                            borderRadius: KasyRadius.fullBorderRadius,
                          ),
                          child: Text(
                            '${tasks.length}',
                            style: context.kasyTextTheme.caption.copyWith(
                              color: context.colors.muted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: context.colors.outline.withValues(alpha: 0.35),
                  ),
                  if (tasks.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(KasySpacing.md),
                      child: Text(
                        t.kanban.empty_column,
                        textAlign: TextAlign.center,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colors.muted,
                        ),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        KasySpacing.sm,
                        KasySpacing.sm,
                        KasySpacing.sm,
                        KasySpacing.sm,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (int i = 0; i < tasks.length; i++) ...[
                            if (i > 0) const SizedBox(height: 6),
                            _TaskCard(task: tasks[i]),
                          ],
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Column draggable header
// ─────────────────────────────────────────────────────────────────────────────

class _ColumnDraggableHeader extends StatelessWidget {
  final KanbanColumn column;
  final int columnIndex;
  final List<KanbanTask> tasks;
  final Widget child;

  const _ColumnDraggableHeader({
    required this.column,
    required this.columnIndex,
    required this.tasks,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final data =
        _ColumnDragData(columnId: column.id, columnIndex: columnIndex);

    final feedback = IgnorePointer(
      child: Transform.rotate(
        angle: 0.022,
        child: _ColumnDragFeedback(column: column, tasks: tasks),
      ),
    );
    final ghost = Opacity(opacity: 0.3, child: child);

    void onStart() => _draggingColumnId.value = column.id;
    void onEnd(dynamic _) => _draggingColumnId.value = null;

    if (_kanbanUsesTouchDrag(context)) {
      return LongPressDraggable<_ColumnDragData>(
        data: data,
        delay: const Duration(milliseconds: 150),
        rootOverlay: true,
        feedback: feedback,
        childWhenDragging: ghost,
        onDragStarted: onStart,
        onDragEnd: onEnd,
        onDraggableCanceled: (_, _) => onEnd(null),
        child: child,
      );
    }

    return Draggable<_ColumnDragData>(
      data: data,
      feedback: feedback,
      childWhenDragging: ghost,
      onDragStarted: onStart,
      onDragEnd: onEnd,
      child: MouseRegion(cursor: SystemMouseCursors.grab, child: child),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Column form (create / edit) — dialog on desktop, sheet on mobile/tablet
// ─────────────────────────────────────────────────────────────────────────────

class _ColumnForm extends ConsumerStatefulWidget {
  final bool asDialog;
  final KanbanColumn? editingColumn;

  const _ColumnForm({required this.asDialog, this.editingColumn});

  @override
  ConsumerState<_ColumnForm> createState() => _ColumnFormState();
}

class _ColumnFormState extends ConsumerState<_ColumnForm> {
  late final TextEditingController _nameController;
  bool _saving = false;
  String? _nameError;

  bool get _isEdit => widget.editingColumn != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.editingColumn?.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    final String name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = t.kanban.column_name_required);
      return;
    }
    setState(() {
      _nameError = null;
      _saving = true;
    });
    try {
      if (_isEdit) {
        await ref.read(kanbanProvider.notifier).updateColumn(
              widget.editingColumn!.id,
              name,
            );
      } else {
        await ref.read(kanbanProvider.notifier).createColumn(name);
      }
      if (!mounted) return;
      Navigator.of(context).pop();
      ref.read(toastProvider).alert(
            title: t.common.saved,
            text: _isEdit ? t.kanban.column_updated : t.kanban.column_created,
          );
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = t.kanban;
    final title = _isEdit ? tr.edit_column : tr.add_column;

    final body = KasyTextField(
      controller: _nameController,
      label: tr.column_name,
      hint: tr.column_name_hint,
      showRequiredIndicator: true,
      errorText: _nameError,
      autofocus: true,
      onChanged: (_) {
        if (_nameError != null) {
          setState(() => _nameError = null);
        }
      },
      onSubmitted: (_) => _save(),
    );

    final actions = [
      KasyButton(
        label: tr.cancel,
        variant: KasyButtonVariant.outline,
        expand: true,
        onPressed: _saving ? null : () => Navigator.of(context).pop(),
      ),
      KasyButton(
        label: _isEdit ? tr.save : tr.create,
        expand: true,
        isLoading: _saving,
        onPressed: _saving ? null : _save,
      ),
    ];

    if (widget.asDialog) {
      return KasyDialog(
        title: title,
        message: _isEdit ? null : tr.add_column_subtitle,
        showCloseButton: false,
        body: body,
        actionsAxis: Axis.horizontal,
        actions: actions,
      );
    }

    return KasyBottomSheet.form(
      title: title,
      body: body,
      actions: actions,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Task form (create / edit) — dialog on desktop, sheet on mobile/tablet
// ─────────────────────────────────────────────────────────────────────────────

class _TaskForm extends ConsumerStatefulWidget {
  final bool asDialog;
  final String? columnId;         // create mode
  final KanbanTask? editingTask;  // edit mode

  const _TaskForm({
    required this.asDialog,
    this.columnId,
    this.editingTask,
  });

  @override
  ConsumerState<_TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends ConsumerState<_TaskForm> {
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  late TaskPriority? _priority;
  bool _saving = false;
  String? _titleError;

  bool get _isEdit => widget.editingTask != null;

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.editingTask?.title);
    _descController =
        TextEditingController(text: widget.editingTask?.description ?? '');
    _priority = widget.editingTask?.priority;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    final String title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _titleError = t.kanban.task_title_required);
      return;
    }
    setState(() {
      _titleError = null;
      _saving = true;
    });
    try {
      final desc = _descController.text.trim().isEmpty
          ? null
          : _descController.text.trim();
      if (_isEdit) {
        await ref.read(kanbanProvider.notifier).updateTask(
              id: widget.editingTask!.id,
              title: title,
              description: desc,
              priority: _priority,
              updatePriority: true,
            );
      } else {
        await ref.read(kanbanProvider.notifier).createTask(
              title: title,
              description: desc,
              columnId: widget.columnId!,
              priority: _priority,
            );
      }
      if (!mounted) return;
      Navigator.of(context).pop();
      ref.read(toastProvider).alert(
            title: t.common.saved,
            text: _isEdit ? t.kanban.task_updated : t.kanban.task_created,
          );
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = t.kanban;
    final title = _isEdit ? tr.edit_task : tr.add_task;

    final formBody = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KasyTextField(
          controller: _titleController,
          label: tr.task_title,
          hint: tr.task_title_hint,
          showRequiredIndicator: true,
          errorText: _titleError,
          autofocus: true,
          textInputAction: TextInputAction.next,
          onChanged: (_) {
            if (_titleError != null) {
              setState(() => _titleError = null);
            }
          },
        ),
        const SizedBox(height: KasySpacing.sm),
        KasyTextField(
          controller: _descController,
          label: tr.task_description,
          hint: tr.task_description_hint,
          minLines: 3,
          maxLines: 5,
        ),
        const SizedBox(height: KasySpacing.md),
        _PrioritySelector(
          selected: _priority,
          onChanged: (p) => setState(() => _priority = p),
        ),
      ],
    );

    final actions = [
      KasyButton(
        label: tr.cancel,
        variant: KasyButtonVariant.outline,
        expand: true,
        onPressed: _saving ? null : () => Navigator.of(context).pop(),
      ),
      KasyButton(
        label: _isEdit ? tr.save : tr.create,
        expand: true,
        isLoading: _saving,
        onPressed: _saving ? null : _save,
      ),
    ];

    if (widget.asDialog) {
      return KasyDialog(
        title: title,
        message: _isEdit ? tr.edit_task_subtitle : tr.add_task_subtitle,
        showCloseButton: false,
        body: formBody,
        actionsAxis: Axis.horizontal,
        actions: actions,
      );
    }

    return KasyBottomSheet.form(
      title: title,
      body: formBody,
      actions: actions,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Task detail view — dialog on desktop, sheet on mobile/tablet
// ─────────────────────────────────────────────────────────────────────────────

class _TaskDetailView extends StatelessWidget {
  final bool asDialog;
  final KanbanTask task;
  final VoidCallback? onEdit;

  const _TaskDetailView({
    required this.asDialog,
    required this.task,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final tr = t.kanban;
    final dateStr = DateFormat.yMMMd().format(task.createdAt);
    final descriptionStyle = context.kasyTextTheme.bodyLarge.copyWith(
      height: 1.5,
    );
    final dateStyle = context.kasyTextTheme.caption.copyWith(
      color: context.colors.muted,
    );
    final bool hasDescription =
        task.description != null && task.description!.trim().isNotEmpty;

    final Widget details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (task.priority != null) ...[
          _PriorityChip(priority: task.priority!),
          const SizedBox(height: KasySpacing.md),
        ],
        if (hasDescription) ...[
          SelectableText(task.description!, style: descriptionStyle),
          const SizedBox(height: KasySpacing.md),
        ] else ...[
          Text(
            tr.task_description_hint,
            style: descriptionStyle.copyWith(
              color: context.colors.muted,
            ),
          ),
          const SizedBox(height: KasySpacing.md),
        ],
        Row(
          children: [
            Icon(
              KasyIcons.calendar,
              size: KasyIconSize.sm,
              color: context.colors.muted,
            ),
            const SizedBox(width: KasySpacing.xs),
            SelectableText(
              tr.created_on(date: dateStr),
              style: dateStyle,
            ),
          ],
        ),
      ],
    );

    if (asDialog) {
      return KasyDialog(
        title: task.title,
        showCloseButton: false,
        body: details,
        actionsAxis: Axis.horizontal,
        actions: [
          KasyButton(
            label: tr.cancel,
            variant: KasyButtonVariant.outline,
            expand: true,
            onPressed: () => Navigator.of(context).pop(),
          ),
          KasyButton(
            label: tr.edit_task,
            icon: KasyIcons.edit,
            expand: true,
            onPressed: onEdit,
          ),
        ],
      );
    }

    return KasyBottomSheet(
      title: task.title,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          details,
          const SizedBox(height: KasySpacing.lg),
          KasyButton(
            label: tr.edit_task,
            icon: KasyIcons.edit,
            variant: KasyButtonVariant.outline,
            expand: true,
            onPressed: onEdit,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Surface launchers
// ─────────────────────────────────────────────────────────────────────────────

Future<void> _showColumnForm(
  BuildContext context,
  WidgetRef ref, {
  KanbanColumn? column,
}) async {
  final isDesktop =
      MediaQuery.sizeOf(context).width >= DeviceType.large.breakpoint;
  if (isDesktop) {
    await showKasyBlurDialog<void>(
      context: context,
      builder: (_) => _ColumnForm(asDialog: true, editingColumn: column),
    );
  } else {
    await showKasyBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ColumnForm(asDialog: false, editingColumn: column),
    );
  }
}

Future<void> _showTaskForm(
  BuildContext context,
  WidgetRef ref, {
  String? columnId,
  KanbanTask? editingTask,
}) async {
  final isDesktop =
      MediaQuery.sizeOf(context).width >= DeviceType.large.breakpoint;
  if (isDesktop) {
    await showKasyBlurDialog<void>(
      context: context,
      builder: (_) => _TaskForm(
        asDialog: true,
        columnId: columnId,
        editingTask: editingTask,
      ),
    );
  } else {
    await showKasyBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _TaskForm(
        asDialog: false,
        columnId: columnId,
        editingTask: editingTask,
      ),
    );
  }
}

Future<void> _showTaskDetail(
  BuildContext context,
  WidgetRef ref,
  KanbanTask task,
) async {
  final isDesktop =
      MediaQuery.sizeOf(context).width >= DeviceType.large.breakpoint;
  if (isDesktop) {
    final wantsEdit = await showKasyBlurDialog<bool>(
      context: context,
      builder: (dialogCtx) => _TaskDetailView(
        asDialog: true,
        task: task,
        onEdit: () => Navigator.of(dialogCtx).pop(true),
      ),
    );
    if (wantsEdit == true && context.mounted) {
      await _showTaskForm(context, ref, editingTask: task);
    }
  } else {
    final wantsEdit = await showKasyBottomSheet<bool>(
      context: context,
      builder: (sheetCtx) => _TaskDetailView(
        asDialog: false,
        task: task,
        onEdit: () => Navigator.of(sheetCtx).pop(true),
      ),
    );
    if (wantsEdit == true && context.mounted) {
      await _showTaskForm(context, ref, editingTask: task);
    }
  }
}
