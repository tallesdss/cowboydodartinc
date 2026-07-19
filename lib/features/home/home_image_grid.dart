import 'dart:ui' as ui;

import 'package:cowboydodartinc/components/kasy_card.dart';
import 'package:cowboydodartinc/components/kasy_image_viewer.dart';
import 'package:cowboydodartinc/components/kasy_skeleton.dart';
import 'package:cowboydodartinc/core/haptics/kasy_haptics.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/core/widgets/kasy_focus_ring.dart';
import 'package:flutter/material.dart';

/// A single image shown in the masonry feed.
class HomePhoto {
  final String id;
  final String author;
  final String ago;

  const HomePhoto({required this.id, required this.author, required this.ago});

  /// Retina-safe source: masonry tiles are ~300 logical px wide; at 3× DPR
  /// that needs ~900 device px. `w=600&q=75` looked soft/pixelated on phone.
  String get url =>
      'https://images.unsplash.com/photo-$id?w=1200&q=85&fit=crop&auto=format&dpr=2';
}

/// Network image with a synced shimmer skeleton while loading and a graceful
/// fallback on error. Adapts to light/dark via [KasySkeleton]'s own palette.
class KasyNetworkImage extends StatelessWidget {
  const KasyNetworkImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
  });

  final String url;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: fit,
      gaplessPlayback: true,
      filterQuality: FilterQuality.high,
      isAntiAlias: true,
      loadingBuilder:
          (BuildContext context, Widget child, ImageChunkEvent? progress) {
            if (progress == null) return child;
            return const _ImageSkeleton();
          },
      errorBuilder:
          (BuildContext context, Object error, StackTrace? stackTrace) {
            return ColoredBox(
              color: context.colors.surfaceNeutralSoft,
              child: Icon(KasyIcons.gallery, color: context.colors.muted),
            );
          },
    );
  }
}

class _ImageSkeleton extends StatelessWidget {
  const _ImageSkeleton();

  @override
  Widget build(BuildContext context) {
    return const KasySkeletonGroup(
      child: KasySkeleton(
        width: double.infinity,
        height: double.infinity,
        borderRadius: BorderRadius.zero,
      ),
    );
  }
}

/// Pinterest-style masonry feed. Tile heights vary by a repeating ratio set and
/// tiles are balanced across columns by running height. Column count is
/// responsive: 2 on phones, 3 on tablets, 4 on desktop and up to 8 on very
/// wide displays.
class HomeImageGrid extends StatelessWidget {
  const HomeImageGrid({super.key, required this.photos});

  final List<HomePhoto> photos;

  static const double _gap = KasySpacing.smd;
  static const List<double> _ratios = <double>[
    0.72,
    1.0,
    0.8,
    1.32,
    0.75,
    1.0,
    0.7,
    1.25,
    0.85,
    1.4,
  ];

  /// Target tile width. Columns are derived from the available width so the
  /// grid stays dense on big desktops without ever letting tiles get too
  /// narrow — naturally stepping 5 → 4 → 3 → 2 as the screen shrinks.
  static const double _targetTileWidth = 300;

  /// Hard floor/ceiling on column count: never fewer than 2 (the mobile feel)
  /// and never more than 8 (lets big desktops fit 6–8 columns while still
  /// capping density so tiles don't get tiny on huge monitors).
  static const int _minColumns = 2;
  static const int _maxColumns = 8;

  int _columnsFor(double width) {
    final int columns = (width / _targetTileWidth).ceil();
    if (columns < _minColumns) return _minColumns;
    if (columns > _maxColumns) return _maxColumns;
    return columns;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = constraints.maxWidth;
        final int columns = _columnsFor(width);
        final double columnWidth = (width - _gap * (columns - 1)) / columns;

        final List<List<Widget>> buckets = List<List<Widget>>.generate(
          columns,
          (_) => <Widget>[],
        );
        final List<double> heights = List<double>.filled(columns, 0);

        for (int i = 0; i < photos.length; i++) {
          final double ratio = _ratios[i % _ratios.length];
          int shortest = 0;
          for (int c = 1; c < columns; c++) {
            if (heights[c] < heights[shortest]) shortest = c;
          }
          if (buckets[shortest].isNotEmpty) {
            buckets[shortest].add(const SizedBox(height: _gap));
          }
          buckets[shortest].add(
            _PhotoTile(photo: photos[i], aspectRatio: ratio),
          );
          heights[shortest] += columnWidth / ratio + _gap;
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            for (int col = 0; col < columns; col++) ...<Widget>[
              if (col > 0) const SizedBox(width: _gap),
              Expanded(child: Column(children: buckets[col])),
            ],
          ],
        );
      },
    );
  }
}

/// Diameter of the circular "like" button — shared so the caption text can
/// reserve exactly enough room to sit beside it without overlapping.
const double _likeButtonSize = 36;

class _PhotoTile extends StatefulWidget {
  final HomePhoto photo;
  final double aspectRatio;

  const _PhotoTile({required this.photo, required this.aspectRatio});

  @override
  State<_PhotoTile> createState() => _PhotoTileState();
}

class _PhotoTileState extends State<_PhotoTile> {
  bool _liked = false;

  void _toggleLike() {
    KasyHaptics.light(context);
    setState(() => _liked = !_liked);
  }

  void _openViewer() {
    KasyHaptics.light(context);
    showKasyImageViewer(
      context,
      imageUrl: widget.photo.url,
      heroTag: widget.photo.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    final HomePhoto photo = widget.photo;

    return KasyCard(
      padding: EdgeInsets.zero,
      child: AspectRatio(
        aspectRatio: widget.aspectRatio,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            // Photo. The Hero gives the smooth zoom into and out of the viewer.
            Positioned.fill(
              child: Hero(
                tag: photo.id,
                child: KasyNetworkImage(url: photo.url),
              ),
            ),

            // Smooth caption scrim — keeps text legible over any photo, in
            // both light and dark themes. Decorative only: never eats taps.
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: IgnorePointer(child: _CaptionScrim()),
            ),

            // Caption text — decorative only. The right padding reserves room
            // for the like button so the text never runs underneath it.
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: IgnorePointer(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    KasySpacing.md,
                    KasySpacing.md,
                    KasySpacing.md + _likeButtonSize + KasySpacing.sm,
                    KasySpacing.md,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        photo.author,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.kasyTextTheme.cardTitle.copyWith(
                          color: context.colors.onSurface,
                        ),
                      ),
                      Text(
                        photo.ago,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.kasyTextTheme.caption.copyWith(
                          color: context.colors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Full-tile tap target sits ABOVE the scrim and caption so tapping
            // anywhere on the tile (gradient included) opens the viewer.
            Positioned.fill(
              child: KasyFocusRing(
                onActivate: _openViewer,
                borderRadius: BorderRadius.circular(KasyRadius.xl),
                child: GestureDetector(
                  onTap: _openViewer,
                  behavior: HitTestBehavior.opaque,
                ),
              ),
            ),

            // Like button — kept on top of the tap target so it still wins
            // taps within its own area.
            Positioned(
              right: KasySpacing.md,
              bottom: KasySpacing.md,
              child: _LikeButton(liked: _liked, onTap: _toggleLike),
            ),
          ],
        ),
      ),
    );
  }
}

/// A smooth caption scrim: one continuous [surface]-tinted gradient that fades
/// from solid at the bottom to fully transparent at the top — no banding, no
/// hard edges. Adapts to light/dark via the theme's [surface] colour.
class _CaptionScrim extends StatelessWidget {
  const _CaptionScrim();

  static const double _height = 88;

  @override
  Widget build(BuildContext context) {
    final Color base = context.colors.surface;

    return Container(
      height: _height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: <Color>[
            base.withValues(alpha: 0.94),
            base.withValues(alpha: 0.62),
            base.withValues(alpha: 0.0),
          ],
          stops: const <double>[0.0, 0.45, 1.0],
        ),
      ),
    );
  }
}

/// Circular glass "like" button. The heart pops (scales with an overshoot) and
/// turns the theme's danger red when liked; idle state stays neutral.
class _LikeButton extends StatefulWidget {
  final bool liked;
  final VoidCallback onTap;

  const _LikeButton({required this.liked, required this.onTap});

  @override
  State<_LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<_LikeButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _scale = TweenSequence<double>(<TweenSequenceItem<double>>[
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: 1.0,
          end: 1.35,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: 1.35,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 60,
      ),
    ]).animate(_controller);
  }

  @override
  void didUpdateWidget(_LikeButton old) {
    super.didUpdateWidget(old);
    // Pop only when transitioning into the liked state.
    if (widget.liked && !old.liked) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool dark = context.isDark;
    final Color heart = widget.liked
        ? context.colors.danger
        : context.colors.primary;

    return KasyFocusRing(
      onActivate: widget.onTap,
      borderRadius: BorderRadius.circular(KasyRadius.full),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: ClipOval(
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              width: _likeButtonSize,
              height: _likeButtonSize,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: context.colors.surface.withValues(
                  alpha: dark ? 0.5 : 0.7,
                ),
                shape: BoxShape.circle,
              ),
              child: ScaleTransition(
                scale: _scale,
                child: Icon(
                  widget.liked ? KasyIcons.favoriteFilled : KasyIcons.favorite,
                  size: KasyIconSize.md,
                  color: heart,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
